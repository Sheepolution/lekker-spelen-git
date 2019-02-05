Level = Scene:extend()

Level.music = {
	level1 = Asset.audio("music/level1", "stream"),
	level2 = Asset.audio("music/level2", "stream"),
	level3 = Asset.audio("music/level3", "stream"),
	level4_intro = Asset.audio("music/level4_intro", "stream"),
	level4 = Asset.audio("music/level4", "stream"),
	level5 = Asset.audio("music/level5", "stream"),
	level6 = Asset.audio("music/level6", "stream"),
	shop = Asset.audio("music/shop", "stream"),
	richard = Asset.audio("music/richard", "stream"),
	lekkerchat = Asset.audio("music/lekkerchat", "stream"),
	koter_intro = Asset.audio("music/koter_intro", "stream"),
	emotilord = Asset.audio("music/emotilord", "stream")
}

function Level:new(name, restart)
	Level.super.new(self)
	Game = self
	-----------
	self.camera = Camera(0, 0, 1920/2, 1080/2)
	self.camera.draw_deadzone = true

	self.centerPoint = Rect(0, 0, 1, 1)

	self.name = name
	if _.is(GM.currentLevelName, "level4", "lekkerchat_intro") then
		self.tileset = "tiles_grave"
	else
		self.tileset = "tiles"
	end
	self.isRestart = restart

	if DATA.options.game.speedrun then
		self.isRestart = true
	end

	self.map = Tilemap(self, name)

	self.SFX = {}
	self.SFX.earthquake = SFX("sfx/earthquake", 1)

	self.map:setFollow(self.centerPoint)
	local portal = self.map.entities:find(function (e) return e:is(LevelPortal) and e.spawn end)[1]
	self:addEntity(portal)

	self.background = Sprite(0, 0)
	self.background:setImage("background")

	self.textbox = Textbox()
	self.textbox.scene = self

	self.donateMessage = DonateMessage(WIDTH/2, 400)
	self.donateMessage.scene = self

	self.health = GM:getStartHealth()
	self.euros = DATA.euros
	self.doorKeys = 0

	self.gui = GUI()

	self.titles = {
		"Richard",
		"LekkerChat",
		"Koter"
	}

	self.subtitles = {
		"The Choking One",
		"Ranzige verwijderde emoticon",
		"Irritant kutkind"
	}

	self.introText = self:createFancyText(0, 330, "Richard", 48)
	self.introSubtext = self:createFancyText(0, 390, "", 30)
	self.deathCounterText = self:createFancyText(0, 190, "Death Counter", 48)
	self.deathCounterNumberText = self:createFancyText(0, 250, "0", 40)
	self.inkomerText = self:createFancyText(0, 300, "(Inkompotje, telt niet)", 24)

	self.deathCounterTexts = buddies.new(self.deathCounterText, self.deathCounterNumberText, self.inkomerText)

	self.fadeRect = Rect(-10, -10, 2000, 2000)
	self.fadeRect.color = {0, 0, 0}
	self.fadeRect.alpha = 1
	love.graphics.setBackgroundColor(132/255, 108/255, 134/255)

	self.audioList = {}

	-- Audio stuff
	self.dontGiveUpSong = Asset.audio("music/geefnooitop")
	self.themeVolume = .3

	self.shaking = false
	self.shakeTimer = step.new(0.05)
	self.shakeLengthTimer = step.new(5, false)
	self.shakeIntensity = 5
	self.shakeOffset = Point(0, 0)

	self.drawingBackground = true
	self.backgroundIsMoving = false
	self.movingBackgroundPosition = 0
	self.movingBackgroundSpeed = 300

	self.earthquaking = false
	self.eartquakeTimer = step.new({10, 30})

	self.lastCheckpoint = nil

	self.pauseScreen = Pause(self)
	self.pausing = false

	self.tick:delay(.1, function ()
		self:fade(false)
	end)

	self:onInit()
end


function Level:update(dt)
	if self.pausing then
		if Key:isPressed("escape", "start", "h") then
			self:unpause()
			return
		end
	else
		if Key:isPressed("escape", "start") then
			self:pause()
			return
		end
	end

	if self.pausing then
		self.pauseScreen:update(dt)
		return
	end

	for i,v in _.ripairs(self.audioList) do
		if not v:isPlaying() then
			table.remove(self.audioList, i)
		end
	end

	self.map:update(dt)
	Level.super.update(self, dt)
	if self.dead then return end
	-- if not (self.peter.teleporting and self.timon.teleporting) then
		local px = self.peter:centerX()
		local tx = self.timon:centerX()
		if px > tx then
			self.centerPoint.x = tx + (px - tx)/2
		else
			self.centerPoint.x = px + (tx - px)/2
		end

		local py = self.peter:centerY()
		local ty = self.timon:centerY()
		if py > ty then
			self.centerPoint.y = ty + (py - ty)/2
		else
			self.centerPoint.y = py + (ty - py)/2
		end
	-- end

	if self.peter.sittingOnTimon then
		self.centerPoint:set(self.timon:center())
	end

	self.camera:follow(self.centerPoint:get())

	self.textbox:update(dt)
	self.gui:update(dt)
	self.donateMessage:update(dt)

	if self.earthquaking then
		if self.eartquakeTimer(dt) then
			self:playSFX(self.SFX.earthquake)
			self:shake(math.random(1, 4), 5, true)
		end
	end

	if self.peter and not self.peter.dead then
		if self.peter.inControl or self.timon.inControl then
			DATA.time = DATA.time + dt
		end
	end

	if self.backgroundIsMoving then
		self.movingBackgroundPosition = self.movingBackgroundPosition - self.movingBackgroundSpeed * dt
		if self.movingBackgroundPosition < -self.background.width then
			self.movingBackgroundPosition = self.movingBackgroundPosition + self.background.width
		end
	end

	if self.shaking then
		if self.shakeTimer(dt) then
			local a = self.shakeIntensity
			self.shakeOffset:set(_.random(-a, a), _.random(-a, a))
		end
		if self.shakeLengthTimer(dt) then
			self.shaking = false
			self.shakeLengthTimer()
		end
	end

end


function Level:draw()
	-- self.background:draw()
	-- self:drawBackground()

	Level.super.draw(self)
	self.gui:draw()
	self.textbox:draw()
	self.introText:draw()
	self.donateMessage:draw()
	self.fadeRect:draw()
	self.deathCounterTexts:draw()

	if self.pausing then
		self.pauseScreen:draw()
	end

	-- self.introSubtext:draw()
end


function Level:drawInCamera()
	love.graphics.push()
	if self.shaking then
		love.graphics.translate(self.shakeOffset:get())
	end
	self:drawBackground()
	Level.super.drawInCamera(self)
	love.graphics.pop()
end

function Level:drawBackground()
	if not self.drawingBackground then return end
	for i=0,50 do
		love.graphics.push()
		love.graphics.translate(i * self.background.width + self.movingBackgroundPosition - 400, - 100)
		self.background:draw()
		love.graphics.pop()
	end
end


function Level:takeControlFromPlayers()
	self.players:set("inControl", false)
end


function Level:giveControlToPlayers()
	self.gui:enter()
	self.players:set("inControl", true)
end


function Level:onInit()
	local delay = 4
	if self.name == "level1" then
		if self.isRestart then
			self:onRestart()
		else
			self:takeControlFromPlayers()
			self.tick:delay(delay, function ()
				self.textbox:open([[
O man, m'n hoofd. Peter, waar zijn we in hemelsnaam?|
<talk=peter>Timon... je bent een hond!|
<talk=timon>Even geen grappen, Peter. Wat is dit voor plek?|
<talk=peter>Nee, ik meen het, kijk dan!|
<talk=timon>Peter, wat lul je nou slap?<exe=Game:event("level1_dog_twist")><.3>.<.3>.<.3>.<.3><empty>Wow, Peter, je bent een volledige rat!|
<talk=peter>Ja, en jij een hond, Timon!|
<talk=timon>Dit is helemaal geflipt, Peter. En wat is deze plek?|
<talk=peter>Ons Twitch-kanaal werd gehackt, weet je nog? En toen werden we ons scherm in gezogen.|
<talk=timon><exe=Game:event("level1_dog_twist")>Is dit dan de binnenkant van ons Twitch-kanaal?|
<talk=peter>Ik denk het? Ik had het ranziger verwacht, moet ik eerlijk zeggen.|
<talk=timon>Peter, laten we dan dat virus vinden, en dan breken we dat nekkie!|
<talk=peter>Timon, er is zojuist het onmogelijke gebeurd.<.5> We zitten werkelijk als virtuele dieren in ons Twitch-kanaal.<.5> Hoe kun je zo chill blijven?|
<talk=timon>Dat is waarom ik main event ben, Peter.|
<talk=peter>Timon, jij wereldgozer.|
<small>Maar ik ben main event.<2><close>|
				]], "timon", function () self:startLevel() end)
			end)
		end
	elseif self.name == "shop" then
		self:initShop()
		if self.isRestart then
			self:onRestart()
		else
			if CURRENT_LEVEL == 2 then
				self:takeControlFromPlayers()
				self.tick:delay(delay, function ()
					self.textbox:open([[
Wat is dit nou weer?|
<talk=peter>Kijk, Timon, ik zie onze shirtjes hangen.|
<talk=timon>O, dus dit is onze webshop dan misschien?<.2><exe=Game:event("buy_shirts")><7><empty>
<talk=peter>Wat is dit nou? Moeten we nou onze eigen shirtjes gaan kopen?|
<talk=timon>En hoezo maar een hartje? Hoezo niet onsterfelijk?|
<talk=peter>Ja, dat vind ik ook raar. Erg onrealistisch.]], "timon", function () self:startLevel() end)
				end)
			else
				self:startLevel()
			end
		end
	elseif self.name == "level2" then
		self:takeControlFromPlayers()
		if self.isRestart then
			self:onRestart()
		else
			self.tick:delay(delay, function ()
			self.textbox:open([[Timon, heb je gezien hoe onze emoticons leven in deze wereld?|
<talk=timon>Ja beetje ranzig is het wel.|
<talk=peter>Maar waarom hebben we nou geen sexy vrouw als emoticon?|
<talk=timon>Noouu, een sexy vrouw zou wel heel nice zijn hoor!|
<talk=peter>Als we hier uit zijn moeten we die toevoegen en dan hopen dat we weer worden gehackt.|
<talk=timon>Jaaaa, nooouuuu Peter! Jij bent ook echt slim weet je dat.|
<talk=peter>Een IQ van 124 om precies te zijn.]], "peter", function () self:startLevel() end)
		end)
	end

	elseif self.name == "richard" then
		self:takeControlFromPlayers()
		if self.isRestart then
			self:onRestart("richard_start")
		else
			self.tick:delay(delay, function ()
				self.textbox:open([[
Yooo malse makkers!|
<talk=timon>Hey Richard! Wat doe jij hier?|
<talk=richard>Wat..<.3> wat schitterend dat...<.3> dat...<.3> dat ik hier mag zijn!|
<talk=peter>Richard! Weet jij wie ons kanaal heeft gehackt?|
<talk=timon>'Gehanckt' is het volgens mij, Peter.|
<talk=richard><exe=Game:event("richard_glitch_small")>Yo<shake>o</shake>o m<shake>al<shake>se mak<shake>k</shake>e<shake>rs</shake>!|
<talk=peter>Gaat alles wel goed, Richard?|
<talk=richard_glitched><exe=Game:event("richard_glitch_big")><big><shake>YOOO MALSE MAKKERS</shake><3><reset><empty>
<talk=timon>Kijk uit, Peter! Hij is wild!<3><close>]], "richard", function () self:event("richard_start") end)
			end)
		end
	elseif self.name == "level3" then
			self:takeControlFromPlayers()
			if self.isRestart then
				self:onRestart()
			else
				self.tick:delay(delay, function ()
				self.textbox:open([[
Zeg, Peter, wie zou ons kanaal hebben gehackt denk je?|
<talk=peter>Waarschijnlijk zo'n YouTuber die jaloers is dat wij de meeste subscribers ter wereld hebben.|
<talk=timon>Ja, heel naar is dat. Geef dan ook gewoon je verlies toe.|
<talk=peter>Dat is nou eenmaal wat er gebeurt als je de grootste bent, Timon. Dan wil iedereen je neerhalen, koste wat het kost.]],
"timon", function () self:startLevel() end)
		end)
	end
	elseif self.name == "level4_intro" then
			self:takeControlFromPlayers()
			if self.isRestart then
				self:onRestart()
			else
				self.tick:delay(delay, function ()
				self.textbox:open([[Timon, ik begin digitale honger te krijgen.|
<talk=timon>We hadden die papflap-emoticon nooit moeten verwijderen, die zou nu recht door dat keelgaatje gaan.|
<talk=peter>O ja, zo'n papflappie zou echt heerlijk zijn.<2> Waar denk je dat emoticons heen gaan wanneer ze worden verwijderd?|
<talk=timon>Maak je daar nou geen zorgen over. Met dit tempo kan het niet lang meer duren voordat we hieruit zijn.|
<talk=peter>We zijn niet voor niets gesponsord door speedrunners.nl]], "peter", function () self:startLevel() end)
		end)
	end
	elseif self.name == "level4" then
			self:createPlayers()
			self.peter.x = 80
			self.peter.y = -100
			self.timon.x = 125
			self.timon.y = -100
			self.peter.anim:set("fall")
			self.timon.anim:set("fall")
			self.background:setImage("background_grave")
			self:takeControlFromPlayers()
			if self.isRestart then
				self:onRestart()
			else
				self.tick:delay(delay - 2, function ()
				self.textbox:open([[
Waar zijn we nou weer?|
<talk=timon>Geen idee, Peter, maar het ruikt naar oude troep.]], "peter", function () self:startLevel() end)
		end)
	end
	elseif self.name == "lekkerchat_intro" then
		self.background:setImage("background_grave")
		self:takeControlFromPlayers()
		if self.isRestart then
			CURRENT_LEVEL = 12
			self:new("lekkerchat")
			return
		end

		self.tick:delay(delay, function ()
			self.textbox:open([[
Kijk, Timon, het is die ranzige lekkerChat-emoticon.|
<talk=timon>Ik was alweer vergeten hoe ranzig die was.|
<talk=lekkerchat><shake>ZijN jUlLiE miJn mAkErS?</shake>|
<talk=peter>O god, stop alsjeblieft met praten. Je gekrijs doet pijn aan mijn oorschelpen.|
<talk=timon>Peter, wat bezielde je toen je dit ding maakte?|
<talk=peter>Ik?! Alleen jij hebt het in je om zoiets lelijks als dit te tekenen.|
<talk=lekkerchat><shake>WaArOm hEbBeN julLiE mIj WeGgEgoOi..</shake><1><empty>
<talk=timon>Aaaa stop nou!!<2> Peter, laten we weggaan.|
<talk=lekkerchat><shake>GeNoEg! JuLlIe zUlLeN sPiJt kRiJgEn mIj oOiT tE hEbBeN vErWiJdErD!! </shake>|
<talk=peter>We hebben al spijt dat we je ooit hebben gemaakt!|
<talk=lekkerchat><exe=Game:event("lekkerchat_remove")><shake>KraAaAaAaaAaaaaAAAaaaaaA!!</shake><2><close>
			]], "peter", function () end)
		end)
	elseif self.name == "level5" then
			self:takeControlFromPlayers()
			if self.isRestart then
				self:onRestart()
				self.peter:sitOnTimon()
				local blocks = self:findEntitiesOfType(BreakableBlock)
				for i,v in ipairs(blocks) do
					block:destroy()
				end
				local bigxd = self:findEntityOfType(BigXD)
				bigxd.x = 300
				bigxd:startMoving()
			else
				self.tick:delay(delay, function ()
				self.textbox:open([[
Timon, dit is zeer waarschijnlijk de laatste keer dat we dierenlichamen hebben.|
<talk=timon>Wat ben je van plan, Peter?|
<talk=peter>Laat me op je rijden, Timon!|
<talk=timon>Nee, Peter, dit gaan we niet doen.|
<talk=peter>Kom op, Timon, een keertje maar! Deze kans krijgen we nooit meer!|
<talk=timon>Stik in je digitale speeksel, Peter.<.2><exe=Game:event("sit_on_timon")><6><empty>
<talk=timon>Wat?!<1> Opkutten, Peter, ik meen het echt!|
<talk=peter>Kom maar hier met die hondenrug van je, Timon!|
<talk=timon><exe=Game:event("start_rolling")>Peter, jij ben toch veel te zwa<.2>.<.2>.<.9> WAT IS DAT?!<1><empty>
<talk=peter><exe=Game:event("jump_on_timon")>RENNEN TIMON!<1><close>
]], "peter", function () self:startLevel() end)
		end)
	end
	elseif self.name == "level6" then
			self.earthquaking = true
			self:takeControlFromPlayers()
			if self.isRestart then
				self:onRestart()
			else
				self:playSFX(self.SFX.earthquake)
				self:shake(6, 5)
				self.tick:delay(delay, function ()
				self.textbox:open([[
Wat gebeurt er?!|
<talk=peter>Het virus vernietigt ons Twitch-kanaal! <exe=Game:shake(3, 5)><1>We moeten opschieten!|
<talk=timon>Ja, anders moeten we een heel nieuw <exe=Game:shake(3, 5)>account aanmaken, en daar heb ik echt even geen zin.
]], "timon", function () self:startLevel() end)
		end)
	end
	elseif self.name == "emotilord" then
		self:takeControlFromPlayers()
		if self.isRestart then
			self:onRestart("koter_transform_quick")
		else
			self.tick:delay(delay, function ()
			self.textbox:open([[
Daar zijn jullie dan eindelijk. Jullie zijn beter dan ik dacht.|
<talk=timon>Heb jij ons gehanckt?|
<talk=peter>Geef ons Twitch-kanaal terug, jij smerig joch!|
<talk=koter><big>ZWIJG!<1><empty><reset>Jullie kunnen mij niet stoppen! Met het script dat ik op internet heb gevonden zal ik jullie kanaal vernietigen.|
<talk=peter>Maar waarom doe je dit?|
<talk=koter>Omdat jullie haten op kinderen zoals ik! Ik wil ook naar jullie streams kijken, maar ik word altijd gelijk weggestuurd. Het is niet eerlijk.|
<talk=timon>Is dat alles?|
<talk=koter>Ja...|
<talk=peter>Hey joh, als jij zo graag onze streams wilt kijken, dan moet je dat gewoon doen toch?|
<talk=timon>Ja, ga gewoon kijken. Wat boeit ons dat nou?|
<talk=koter>Menen jullie...<1> menen jullie dat echt?<1> *snif*<1> Oke, dan zal ik stoppen met hack..<1><empty>
<talk=peter>NEE NATUURLIJK NIET JIJ DWAAS!|
<talk=timon><reset>Dacht je nou echt dat we ranzige kutkoters gaan toelaten? <1>Ben je wel helemaal lekker in dat koppie van je?!|
<talk=peter>Moet je eens even goed luisteren. Je gaat naar intertoys.nl en dan tik je in: 'hoepel'.|Om die heupies heen en HOEPELEN MAAR!|
<talk=koter><big><shake>GENOEG!</shake><exe=Game:event("koter_transform")><1><empty><reset>Jullie beseffen niet hoeveel macht ik hier heb. Eerst reken ik af met jullie en daarna met jullie kanaal!<4><close>
]]
				, "koter"
			)
		end)
	end
	elseif self.name == "lekkerchat" then
		self.backgroundIsMoving = true
		self:createPlayers(true)
		self:takeControlFromPlayers()
		local chat = self:findEntityOfType(LekkerChat)
		chat:startMove()
		local players = self:findEntitiesOfType(PlayerPlane)
		self:playTheme(self.name)
		self.tick:delay(3, function () self:startLevel(self.name) end)
		self:showTitle(2)
	end
end


function Level:event(name)
	if name == "level1_dog_twist" then
		self.timon.velocity.y = -130
		self.timon.flip.x = not self.timon.flip.x
	elseif name == "richard_glitch_small" then
		local richard = self:findEntityOfType(Richard)
		richard:startGlitching(.5)
	end

	if name == "richard_glitch_big" then
		local richard = self:findEntityOfType(Richard)
		richard:startGlitching(.7)
		self:shake(6, 5)
	end

	if name == "richard_start" then
		local richard = self:findEntityOfType(Richard)
		richard:startMoving()
		self:showTitle(1)
		self:playTheme("richard")
		self.tick:delay(2, function () self:giveControlToPlayers() self.gui:enter() end)
	end

	if name == "koter_transform" then
		self.music.koter_intro:play()

		self:shake(10, 5)

		self.tick:delay(1, function ()
			local koter = self:findEntityOfType(Koter)
			koter:startTransform()
			-- Key:rumble(1., .6, 9)
			-- Key:rumble(2, .6, 9)
			self.tick:delay(12, function () self:startLevel("emotilord") end)
		end)
	end

	if name == "koter_title" then
		self:showTitle(3)
	end

	if name == "koter_transform_quick" then
		local koter = self:findEntityOfType(Koter)
		koter:destroy()
		local emotilord = self:addEntity(Emotilord())
		emotilord:center(koter:center())
		emotilord:startMove()
		self:showTitle(3)
	end

	if name == "buy_shirts" then
		self.donateMessage:donate(2)
	end

	if name == "sit_on_timon" then
		self.donateMessage:donate(6)
	end

	if name == "start_rolling" then
		local xd = self:findEntityOfType(BigXD)
		xd:startMoving()
		self.tick:delay(.3, function ()
			self:shake(2, 5)
		end)
	end

	if name == "jump_on_timon" then
		local peter = self:findEntityOfType(Peter)
		peter:moveRight()
		peter.velocity.y = -350
		self.tick:delay(.4, function () peter:sitOnTimon() end)
	end


	if name == "lekkerchat_remove" then
		for i,v in ipairs(self.map.currentRoom.map.tiles) do
			v.dead = true
		end

		self:shake(3, 5)

		self.map.currentRoom.map.visuals[1].visible = false
		self.tick:delay(2, function ()
			GM:goToNextLevel()
		end)
	end


	if name == "emotilord_ending" then
		self:stopTheme()
		self.tick:delay(2, function ()
			self.textbox:open("<big><shake>NEEE</shake>EE<shake>E</shake>E<shake>EEEE</shake>E<shake>E!!!!!</shake><3><close>", "koter_sad")
		end)


		local tiles = {}
		local spiral = self:addScenery(Sprite(0, 0, "intro/spiral"))
		spiral:center(WIDTH/2, HEIGHT/2)
		spiral.rotate = -4
		spiral.scale:set(2, 2)
		spiral.z = 1010

		local portal = LevelPortal()
		portal:center(WIDTH/2, HEIGHT/2)
		portal.hidden = truea
		portal.distance = 200
		portal.z = 2020
		portal.special = true

		self:addEntity(portal)

		self.tick:delay(13, self.wrap:fade(true, function () self.tick:delay(2, function () State:toState(Credits())  end) end))
		self.tick:delay(8, self.wrap:takeControlFromPlayers())
		self.tick:delay(8, function () portal:teleportPlayersToNextLevel() end)
		self.drawingBackground = false
		for i=1,22 do
			for j=1,15 do
				local a = self:addScenery(Sprite((i-1) * 46 + 15, (j-1) * 46 - 7,  "background_tile"))
				a.z = 1000
				a.flux:to(a.scale, 1, {x = 0, y = 0}):delay(5 + _.random(1, 2))
			end
		end

		self:shake(7, 5)
	end
end


function Level:onRestart(event)
	self:spawnPlayers()
	self:startLevel()
	self:event(event)
	self.euros = DATA.lastEuros
	DATA.euros = DATA.lastEuros
	self.gui:updateEuros()
end


function Level:startLevel()
	self:giveControlToPlayers()
	self:playTheme(self.name)
	-- if map == "level1" then
		-- sel
	-- elseif map = "level2" then

	-- end
end


function Level:showTitle(i)
	self.introText:write(self.titles[i])

	self.introSubtext:write(self.subtitles[i])
	self.flux:to(self.introText, 1, {alpha = 1})
	:after(1, {alpha = 0})
	:delay(2)

	self.flux:to(self.introSubtext, 1, {alpha = 1})
	:after(1, {alpha = 0})
	:delay(2)
end


function Level:loseHealth(amount)
	self.health = self.health - (amount or 1)
	self.gui:updateHealth()
	if self.health <= 0 then
		self:onDead()
	end
end


function Level:gainHealth(amount)
	self.health = self.health + (amount or 1)
	self.gui:updateHealth()
end


function Level:gainEuros(amount)
	self.euros = self.euros + (amount or 1)
	DATA.euros = DATA.euros + (amount or 1)
	self.gui:updateEuros()
end

function Level:loseEuros(amount)
	self.euros = self.euros - (amount or 1)
	DATA.euros = DATA.euros - (amount or 1)
	self.gui:updateEuros()
end


function Level:onDead()
	if self.gameOver then return end
	self.gameOver = true

	for i,v in ipairs(self.audioList) do
		v:stop()
	end

	if self.currentTheme then
		self.flux:to(self, 1.3, {themeVolume = 0} ):onupdate(function () self.currentTheme:setVolume(self.themeVolume) end)
	end

	self.peter.SFX.hurt:play()
	self.peter:kill()
	self.timon:kill()
	
	self.deathCounterNumberText:write(DATA.deaths)

	if self.isRestart then
 		DATA.deaths = DATA.deaths + 1
	end 

	SAVE_DATA()

	self.tick:delay(1.3, function () self:playAudio(self.dontGiveUpSong) end)
	self.flux:to(self.fadeRect, 1, {alpha = 1})
	:oncomplete(function ()
		self:showDeathCounter()
	end)
	:delay(2)
end


function Level:showDeathCounter()
	local first = false

	for i,v in ipairs(self.deathCounterTexts) do
		if i < 3 or first then
			self.flux:to(v, 0.3, {alpha = 1})
			:oncomplete(
			function ()
				if self.isRestart then
					self.tick:delay(1, function ()
						local oldy = self.deathCounterNumberText.y
						self.deathCounterNumberText.y = oldy - 5
						self.flux:to(self.deathCounterNumberText, 0.2, {y = oldy})
						self.deathCounterNumberText:write(DATA.deaths)
						end)
					self.tick:delay(3, function () GM:reloadLevel() end)
				else
					self.flux:to(self.inkomerText, 1, {alpha = 1})
					:delay(1.5)
					:oncomplete(function () self.tick:delay(2, function () GM:reloadLevel() end) end)
				end
			end)
		end
	end
end


function Level:createFancyText(x, y, txt, size)
	local text = Text(x, y, txt, "OptimusPrincepsSemiBold", size)

	text.align.x = "center"
	text.font:setFilter("linear", "linear")
	text.limit = WIDTH
	text.x = 0
	text.alpha = 0
	text.color = {255, 255, 255}
	text.border:set(4)

	return text
end


function Level:playTheme(map)
	if self.currentTheme == Level.music[map] then return end
	self.currentTheme = Level.music[map]
	self.themeVolume = 0
	self.flux:to(self, .5, {themeVolume = GET_MUSIC_VOLUME()} ):onupdate(function () self.currentTheme:setVolume(self.themeVolume) end)
	self.currentTheme:stop()
	self.currentTheme:setLooping(true)
	self.currentTheme:setVolume(self.themeVolume)
	self:playAudio(self.currentTheme)
end


function Level:stopTheme()
	if self.currentTheme then
		self.flux:to(self, .1, {themeVolume = .0} ):onupdate(function () self.currentTheme:setVolume(self.themeVolume) end)
	end
end


function Level:playAudio(audio)
	table.insert(self.audioList, audio)
	audio:play()
end


function Level:createPlayers(plane)
	if plane then
		self.peter = self:findEntity(function (e) return e.id == "peter" end)
		self.timon = self:findEntity(function (e) return e.id == "timon" end)
	else
		self.peter = self:addEntity(Peter())
		self.timon = self:addEntity(Timon())
	end

	self.timon:setPartner(self.peter)
	self.peter:setPartner(self.timon)

	self.players = buddies.new(self.timon, self.peter)
end


function Level:spawnPlayers()
	local portal = self:findEntityOfType(LevelPortal, function (e) return e.spawn end)
	if portal then
		portal:spawnPlayersInstantly()
	end
	if DATA.lastCheckpoint then
		local x, y = DATA.lastCheckpoint.x, DATA.lastCheckpoint.y
		self.players:center(x, y - 30)
		for i,v in ipairs(self.map.entities) do
			if v:is(Euro) or v:is(Enemy) then
				if v.x < DATA.lastCheckpoint.x then
					v.destroyed = true
				end
			end
		end
	end
end


function Level:getRandomPlayer()
	return _.coin() and self.peter or self.timon
end


function Level:goToNextLevel()
	self:fade(true, function ()
		GM.nextLevel = true
	end)
end


function Level:growPortal()
	local portal = self:findEntityOfType(LevelPortal, function (e) return e.hidden end)
	if portal then
		portal:grow()
	end
end


function Level:fade(fadein, oncomplete)
	local tween
	if fadein then
		tween = self.flux:to(self.fadeRect, 1, {alpha = 1})
	else
		tween = self.flux:to(self.fadeRect, 1, {alpha = 0})
	end
	if oncomplete then
		tween:oncomplete(oncomplete)
	end
	return tween
end


function Level:shake(length, intensity, norumble)
	self.shakeLengthTimer:set(length)
	self.shakeIntensity = intensity or 5
	self.shaking = true
	if not norumble then
		Key:rumble(1, .2, length)
		Key:rumble(2, .2, length)
	end
end


function Level:initShop()
	for i=1,5 do
		self:addScenery(Sprite((i-1)*192 + 288, 224, "shirts/bar"))
		if not DATA.shirts[i] then
			self:addEntity(Shirt((i-1)*192 + 303, 220, i))
		end
	end
end


function Level:buyShirt(shirt, shirtID, player)
	local gier = self:findEntityOfType(Gier)
	self:takeControlFromPlayers()
	self.players:stopMoving()
	gier:stealMoneyFromPlayer(player, shirt)
	DATA.baseHealth = DATA.baseHealth + shirt.hearts
end


function Level:onBuyingShirt(player, shirt)
	Game:loseEuros(shirt.price)
	self.flux:to(shirt, .2, {y = shirt.y - 20 }):ease("linear"):oncomplete(function ()
		self.flux:to(shirt.scale, 1, {x = 0, y = 0})
		self.flux:to(shirt, 1, {x = player:centerX() - shirt.width/2, y = player:centerY() - shirt.height/2})
		:oncomplete(function ()
			self:giveControlToPlayers()
			shirt:destroy()
			self:gainHealth(shirt.hearts)
			DATA.shirts[shirt.shirtID] = true
		end)
	end)
end


function Level:getLastCheckpoint()
	return self.lastCheckpoint
end


function Level:kill()
	self.dead = true
	for i,v in ipairs(self.audioList) do
		v:stop()
	end
end


function Level:playSFX(sfx)
	if not self.gameOver then
		-- local aud = sfx:getAudio()
		local audio = sfx:play()
		if audio then
			table.insert(self.audioList, audio)
		end
		return audio
	end
end


function Level:pause()
	for i,v in ipairs(self.audioList) do
		v:pause()
	end
	self.pausing = true
	self.pauseScreen:show()
end


function Level:unpause()
	for i,v in ipairs(self.audioList) do
		v:play()
	end
	self.pausing = false
	self.pauseScreen:hide()
end

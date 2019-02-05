Story = Scene:extend("Story")

function Story:new(...)
	Story.super.new(self, ...)
	Game = self

	self.background = Sprite(0, 0, "intro/background")

	---- PAGE SPRITES 
	-- page 1
	self.waitSprite = Sprite(0, 0, "intro/wachten")

	-- page 2
	self.introSprite = Sprite(0, 0, "intro/intro")

	-- page 3
	self.playingSprite = Sprite(0, 0, "intro/mariokart")

	-- page 4
	self.peterSprite = Sprite(0, 0, "intro/angry_peter")

	-- page 5
	self.timonSprite = Sprite(0, 0, "intro/angry_timon")

	-- page 6
	self.glitchingPageBackground = Sprite(0, 0, "intro/channel_page")
	
	self.glitchingName = Sprite(57, 3, "intro/glitching_name", 4)
	self.glitchingName.anim:add("_")

	self.glitchingMK = Sprite(59, 58, "intro/glitching_mariokart", 519, 293)
	self.glitchingMK.anim:add("_")

	self.backgroundRect = Rect(0, 0, 1000, 1000)
	self.backgroundRect.color = {255, 255, 255}

	-- page 8
	self.spiral = Sprite(160, -40, "intro/spiral")
	self.spiral.rotate = -3

	---- END PAGE SPRITES

	self.textbox = Textbox()
	self.textbox.narrator = true
	self.textbox.width = 740
	self.textbox.y = 410

	self.camera = Camera(1920/4, 1080/4, 1920/2, 1080/2)
	self.camera.draw_deadzone = true
	-- self.camera.scale = 1.5

	self.chats = Sprite(170, -150, "intro/chats", 5)
	self.chats:setFilter("linear")
	self.chats.anim:add("_")
	self.chats.scale:set(.5)

	self.song1 = Asset.audio("music/story_1")
	self.song2 = Asset.audio("music/story_2")
	self.song1:setVolume(GET_MUSIC_VOLUME())
	self.song2:setVolume(GET_MUSIC_VOLUME())
	self.song1:setLooping(true)
	self.song2:setLooping(true)

	self.songVolume = 0

	self.flux:to(self, .5, {songVolume=GET_MUSIC_VOLUME()}):onupdate(function () self.song1:setVolume(self.songVolume) end)
	self.song1:play()

	self.page = 1

	self.fadeRect = Rect(-100, -100, 10000, 1000)
	self.fadeRect.color = {0, 0, 0}

	self.flux:to(self.fadeRect, 1, {alpha = 0})
	:oncomplete(function () 
self.textbox:open([[Het begon allemaal op een doodgewone maandagavond. Die malse makkers van Lekker Spelen gingen live! De chat zat klaar om te genieten van weer een prachtige stream.|
<exe=Game:nextPage()>Zoals elke maandagavond begon Lekker Spelen stipt op tijd om 20:30. Tijd voor een potje Mario Kart!|
<exe=Game:nextPage()>Iedereen was welkom! Behalve die ranzige kutkoters natuurlijk. Alleen volwassen zakenmannen die terug komen van een lange werkdag.|
<exe=Game:nextPage()>Peter en Timon hadden dolle pret. Ze houden heel veel van elkaar, en vinden het heel leuk om samen computerspelletjes te spelen.|
<exe=Game:nextPage()>"Je bent een vuile hond, Timon!", schreeuwde Peter in zijn microfoon.|
<exe=Game:nextPage()>"En jij bent een smerige rat, Peter!", reageerde Timon.|
<exe=Game:nextPage()>Terwijl Peter en Timon elkaar complimenteerden om hun skills gebeurde er ineens iets geks.|
"Wat gebeurt er nou allemaal? Ons Twitch-kanaal is aan het glitchen", zei Timon.|
"Volgens mij worden we gehackt", zei Peter, die het probeerde te fixen door alle knoppen in zijn streamingprogramma in te drukken.|
<exe=Game:nextPage()>Maar helaas, niks kon het virus stoppen. Hun hele Twitch-kanaal werd aangevallen, en niks deed het meer. Zelfs de facecam kon niet meer worden aangezet.|
<exe=Game:nextPage()>En net op het punt dat Peter de stekker van zijn computer eruit wilde trekken...<100>]])
	end)
end


function Story:update(dt)
	Story.super.update(self, dt)
	self.textbox:update(dt)
	if self.page == 3 then
		self.chats:update(dt)
	elseif self.page >= 7 then
		self.glitchingName:update(dt)
		self.glitchingMK:update(dt)
		self.spiral:update(dt)
	end
end


function Story:draw()
	Story.super.draw(self)
	self.textbox:draw()
	self.fadeRect:draw()
	-- elseif self.page == 6 thenj
end


function Story:drawInCamera()
	self.backgroundRect:draw()
	if self.page == 9 then
		self.spiral:draw()
	end

	self.background:draw()
	love.graphics.push()
	if self.page < 5 or self.page > 6 then
		love.graphics.translate(160, 81)
	end
	if self.page == 1 then
		self.waitSprite:draw()
	elseif self.page == 2 then
		self.introSprite:draw()
	elseif self.page == 3 then
		self.chats:draw()
	elseif self.page == 4 then
		self.playingSprite:draw()
	elseif self.page == 5 then
		self.peterSprite:draw()
	elseif self.page == 6 then
		self.timonSprite:draw()
	elseif self.page >= 7 then
		self.glitchingPageBackground:draw()
		self.glitchingName:draw()
		self.glitchingMK:draw()
	end
	love.graphics.pop()
end


function Story:nextPage()
	self.page = self.page + 1

	if self.page == 7 then
		self.flux:to(self, .5, {songVolume=0})
		:onupdate(function () self.song1:setVolume(self.songVolume) end)
		:oncomplete(function () self.song1:stop() self.song2:play() self.song2:setVolume(0) end)
		:after(self, .5, {songVolume=GET_MUSIC_VOLUME()}):onupdate(function () self.song2:setVolume(self.songVolume) end)
	end
	
	if self.page == 9 then
		self.flux:to(self.glitchingMK, 1, {alpha = 0}):delay(1)
		self.flux:to(self, 2, {songVolume=0})
		:onupdate(function () self.song2:setVolume(self.songVolume) end)
		:delay(4)
		self.flux:to(self.camera, 4, {scale=5}):delay(3):ease("quadin")
		:after(self.fadeRect, 1, {alpha = 1})
		:oncomplete(function ()
			self.song1:stop()
			self.song2:stop()
			State:toState(GameManager())
		end)
	end
end
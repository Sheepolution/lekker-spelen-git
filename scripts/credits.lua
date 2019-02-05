Credits = Scene:extend("Credits")

function Credits:new(...)
	Credits.super.new(self, ...)

	self.centerSprites = buddies.new()
	self.centerSprites:add(self:addScenery(Sprite(0, 30, "logos/game_logo_x4")))
	self.centerSprites:add(self:addScenery(Sprite(0, 680, "logos/sheepolution_hd")))
	self:addScenery(self:createText(590, "Gemaakt door", 64))
	self.centerSprites:add(self:addScenery(Sprite(0, 1000, "credits/progress/peter_timon")))
	self:addScenery(self:createText(1400, "- Graphics, code, verhaal, leveldesign -\nSheepolution", 64))
	self.centerSprites:add(self:addScenery(Sprite(0, 1550, "credits/progress/concept_enemies")))
	self:addScenery(self:createText(2050, "- Muziek voor levels, menu en intro -\nKutjoch_", 64))
	self:addScenery(self:createText(2250, "- Muziek voor eindbazen en credits -\nHenkKoelka", 64))
	self.centerSprites:add(self:addScenery(Sprite(0, 2400, "credits/progress/emotes")))
	self:addScenery(self:createText(2900, "- Pixelart-shirtjes -\nMakkeraadKora", 64))
	self:addScenery(self:createText(3060, "- Endcard -\nGloeiwurmpie", 64))
	self:addScenery(self:createText(3230, "- Advies en ideetjes -\nKutjoch_, Lisaaavdw, MakkeraadKora, Mojosaman, Vampierusboy", 64))
	self.centerSprites:add(self:addScenery(Sprite(0, 3490, "credits/progress/richard")))
	self:addScenery(self:createText(3900, "- Testers -\no_Esther, Pannenkoekjeff, Barrie de Beer, Suzanzanzan, Shineepinee, Raijinfang, MaraMarilynde, Danvandee, KeesApenvlees, Catlover160, Meneerhoed, Slakkeneter, Kutjoch_, Loezis, Bramigo, Addictedgamer747, Lisaaavdw, Yirii078, Vampierusboy", 64))
	self.centerSprites:add(self:addScenery(Sprite(0, 4400, "credits/progress/emotilord")))
	self:addScenery(self:createText(4900, "- Special Thanks -\nPeter en Timon\nDe Lekker Spelen-community", 64))
	local heart = self:addScenery(Sprite(0, 5200, "pickupables/lekkerlief", 26))
	self:addScenery(self:createText(5340, "Einde", 64))
	self.deaths = self:addScenery(self:createText(5440, "Deathcounter: " .. DATA.deaths, 64))
	self.time = self:addScenery(self:createText(5540, "Tijd: " .. Utils.secondsToClock(DATA.time), 64))
	self.uploading = self:addScenery(self:createText(5595, "Uploaden", 64))
	self.uploadingCounter = 0
	self.uploading.visible = false

	self.deaths.visible = false
	self.time.visible = false

	if DATA.fastestTime < 0 then
		DATA.fastestTime = DATA.time
	else
		DATA.fastestTime = math.min(DATA.fastestTime, DATA.time)
	end

	heart.anim:add("beat", "1>12")
	heart.origin:set(0)
	heart.scale:set(4)
	heart.border:set(1)
	heart.border.color = {255, 255, 255}
	heart.width = heart.width * 4
	self.centerSprites:add(heart)

	self.centerSprites:centerX(WIDTH/2)

	self.background = Sprite(0, 0, "background")

	self.fadeRect = Rect(-1000, -1000, 5000, 5000)
	self.fadeRect.color = {0, 0, 0}

	self.flux:to(self.fadeRect, 1, {alpha=0})

	self.endcard = self:addScenery(Sprite(0, 5150, "credits/endcard"))
	self.endcard:setFilter("linear")
	-- self.endcard.origin:set(0)
	-- self.endcard.scale:set(.5)
	self.endcard.visible = false

	self.endcardTune = Asset.audio("music/endcard")
	self.endcardTune:setVolume(GET_MUSIC_VOLUME())

	self.atEndCard = false

	self.goingBack = false

	self.offsetY = 0

	self.flux:to(self, 51, {offsetY = -5150}):ease("linear"):delay(2)
	:oncomplete(function ()
		self.tick:delay(2, function ()
			self.deaths.visible = true
			self.tick:delay(2, function ()
				self.time.visible = true
				self.tick:delay(1, function ()
					self.uploading.visible = true
					self.tick:delay(.3, function ()
						self.uploading:write("Uploaden.")
						self.tick:delay(.3, function ()
							self.uploading:write("Uploaden..")
							self.tick:delay(.3, function ()
								self.uploading:write("Uploaden...")
								self.tick:delay(.9, function ()
									if DATA.fastestTime == DATA.time then
										self.uploading:write("Nieuw wereldrecord!")
									else
										self.uploading:write("Geen nieuw wereldrecord :(")
									end
									self.atBottom = true
								end)
							end)
						end)
					end)
				end)
			end)
		end)
	end)

	self.music = Asset.audio("music/credits")
	self.music:setVolume(GET_MUSIC_VOLUME())
	-- self.music:setLooping(true)
	self.tick:delay(.3, function ()
		self.music:play()
	end)
end


function Credits:update(dt)

	if self.atBottom then
		if not self.goingToEndcard then
			if Key:isPressed("return", "g") then
				self.goingToEndcard = true
				self.flux:to(self.fadeRect, 2, {alpha = 1})
				:oncomplete(function () self.music:stop() self.endcard.visible = true end)
				:after(self.fadeRect, 2, {alpha = 0}):delay(.3)
				:oncomplete(function () self.endcardTune:play()
					self.tick:delay(10, function ()
						self.atEndCard = true
						DATA.level = 0
						SAVE_DATA()
					end)
				end)
			end
		end
	end

	if self.atEndCard then
		if not self.goingBack then
			if Key:isPressed("return", "g") then
				self.goingBack = true
				self.flux:to(self.fadeRect, .5, {alpha = 1}):oncomplete(function () State:toState(Menu()) end)
			end
		end
	end
	Credits.super.update(self, dt)
end


function Credits:draw()
	love.graphics.push()
	love.graphics.translate(0, self.offsetY)
	for i=0,50 do
		self.background.offset.y = self.background.height * i
		self.background:draw()
	end
	Credits.super.draw(self)
	love.graphics.pop()

	self.fadeRect:draw()
end



function Credits:createText(y, txt, size)
	local text = Text(0, y, txt, "sheepixel", size)

	text.align.x = "center"
	text.font:setFilter("linear", "linear")
	text.limit = WIDTH
	text.x = 0
	text.color = {255, 255, 255}

	return text
end
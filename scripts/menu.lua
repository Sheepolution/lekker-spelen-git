Menu = Scene:extend("Menu")

function Menu:new(...)
	Menu.super.new(self, ...)
	local controllers = love.joystick.getJoysticks()
	if #controllers > 0 then
		controllers[1]:setVibration(.001, .0001, .4)
	end

	self.selectSFX = SFX("sfx/textbox/char")

	self.versionText = self:addScenery(Text(WIDTH - 50, -30, "v" .. VERSION, "sheepixel", 24))
	self.versionText.color = {64, 64, 64}
	self.versionText.visible = false

	-- INTRO ------------------
	self.logo = self:addScenery(Sprite(0, 0, "logos/game_logo_x4_menu", 2))
	self.logo.anim:add("color", 2)
	self.logo.anim:add("gray", 1)
	self.logo:center(WIDTH/2, HEIGHT/2 - HEIGHT)
	self.logo.y = self.logo.y - 30
	-- self.logo:addShader("border")

	self.glitchText = self:addScenery(Sprite(100, -100, "logos/glitch_text", 7))
	self.glitchText.anim:add("glitch", "2>7", nil, "once"):after("idle"):onComplete(function () self.glitchText:setShader() end):onUpdate(function () self.glitchText:send("dirs", _.rgbdirs()) end)
	self.glitchText.anim:add("idle", 1)
	self.glitchText.visible = false
	self.glitchText:addShader("rgb")
	self.glitchText:setShader()

	self.glitchTimer = step.new({1, 3})

	self.introPart = Asset.audio("music/menu1", "stream", true)
	self.introPart:setVolume(GET_MUSIC_VOLUME())
	self.song = Asset.audio("music/menu2", "stream", true)
	self.song:setVolume(GET_MUSIC_VOLUME())
	self.song:setLooping(true)
	self.drawingBackground = false

	self.background = Sprite(0, 0, "background")
	self.background.x = -5
	self.background.y = -HEIGHT

	self.fadeRect = Rect(0, -HEIGHT, 5000, 5000)
	self.fadeRect.color = {0, 0, 0}
	self.fadeRect.alpha = 1
	self.flux:to(self.fadeRect, 1, {alpha = 0}):delay(.5)
	:oncomplete(function ()
		self.introPart:play()
		self.fadeRect.color = {255, 255, 255}
		self.tick:delay(1.3, function ()
			self.fadeRect.alpha = 1 
			self.drawingBackground = true
			self.glitchText.visible = true
			self.versionText.visible = true
			self.logo.anim:set("color")
			self.flux:to(self.fadeRect, 1, {alpha = 0})
			self.tick:delay(0, function () self.pressStart.visible = true self.ready = true end)
		end)
	end)

	self.pressStart = self:addScenery(self:createText(480 - HEIGHT, "Druk Start", 48))
	self.pressStart.border:set(2)
	self.pressStart.border.color = {100, 65, 165}
	self.pressStart.visible = false
	self.pressStart.color = {244, 154, 192}

	self.timer = 0

	self.ready = false
	self.onLogo = true
	-- END INTRO ------------------

	self.offsetY = HEIGHT
	self.offsetX = 0

	self.buttons = buddies.new()
	self.menuButtons = self.buttons

	self.buttons:add(self:addScenery(MenuButton(190, "Lekker spelen")))
	self.buttons:add(self:addScenery(MenuButton(305, "Opties")))
	self.buttons:add(self:addScenery(MenuButton(420, "Afsluiten")))

	self.buttons[1].func = function () self:startGame(true) end
	self.buttons[2].func = function () self:goToOptions() end
	self.buttons[3].func = function () love.event.quit() end

	if DATA.level > 0 then
		self.verderspelen = self:addScenery(MenuButton(75, "Verder spelen"))
		self.verderspelen.special = true
		self.buttons:add(self.verderspelen)
		self.buttons[4].func = function () CURRENT_LEVEL = DATA.level self:startGame() end

		self.buttons[4].selected = true
		self.selected = 4
	else
		self.buttons[1].selected = true
		self.selected = 1
	end


	--OPTIONS------------------------
	self.optionButtons = buddies.new()

	self.optionButtons:add(self:addScenery(MenuButton(75, "Scherm")))
	self.optionButtons:add(self:addScenery(MenuButton(190, "Geluid")))
	self.optionButtons:add(self:addScenery(MenuButton(305, "Game/Controls")))
	self.optionButtons:add(self:addScenery(MenuButton(420, "Terug")))
	self.optionButtons:centerX(WIDTH/2 + WIDTH)

	self.optionButtons[1].selected = true
	self.optionButtons[1].func = function () self:goToSpecificOptionsMenu(self.screenButtons, 1) end
	self.optionButtons[2].func = function () self:goToSpecificOptionsMenu(self.audioButtons, 1) end
	self.optionButtons[3].func = function () self:goToSpecificOptionsMenu(self.controllerButtons, 1) end
	self.optionButtons[4].func = function () self:goBackToMenu() end


	--SCREEN--
	self.screenButtons = buddies.new()

	self.screenButtons:add(self:addScenery(MenuButton(75, DATA.options.screen.fullscreen and "Fullscreen" or "Windowed")))
	self.screenButtons:add(self:addScenery(MenuButton(190, DATA.options.screen.pixelperfect and "Pixelperfect: aan" or "Pixelperfect: uit")))
	self.screenButtons:add(self:addScenery(MenuButton(305, DATA.options.screen.vsync and "Vsync: aan" or "Vsync: uit")))
	self.screenButtons:add(self:addScenery(MenuButton(420, "Terug")))
	self.screenButtons:centerX(WIDTH/2 + WIDTH)
	self.screenButtons[1].selected = true
	
	self.screenButtons[1].func = function ()
		local fullscreen = not DATA.options.screen.fullscreen
		DATA.options.screen.fullscreen = fullscreen
		self.screenButtons[1].text:write(fullscreen and "Fullscreen" or "Windowed")
		RESET_SCREEN()
	end

	self.screenButtons[2].func = function ()
		local pixelperfect = not DATA.options.screen.pixelperfect
		DATA.options.screen.pixelperfect = pixelperfect
		self.screenButtons[2].text:write(pixelperfect and "Pixelperfect: aan" or "Pixelperfect: uit")
		RESET_SCREEN()
	end

	self.screenButtons[3].func = function ()
		local vsync = not DATA.options.screen.vsync
		DATA.options.screen.vsync = vsync
		self.screenButtons[3].text:write(vsync and "Vsync: aan" or "Vsync: uit")
		RESET_SCREEN()
	end


	self.screenButtons[4].func = function () self:goToSpecificOptionsMenu(self.optionButtons, 1) end
	self.screenButtons:set("visible", false)

	--AUDIO--
	self.audioButtons = buddies.new()

	self.audioButtons:add(self:addScenery(MenuButton(75,  "Master:----------|")))
	self.audioButtons:add(self:addScenery(MenuButton(190, "Music: ----------|")))
	self.audioButtons:add(self:addScenery(MenuButton(305, "SFX:  ----------|")))
	self.audioButtons:add(self:addScenery(MenuButton(420, "Terug")))
	self.audioButtons:centerX(WIDTH/2 + WIDTH)
	self.audioButtons[1].selected = true
	self.audioButtons[1].analog = true
	self.audioButtons[2].analog = true
	self.audioButtons[3].analog = true

	do
		local volume = DATA.options.audio.master_volume
		local str = ""
		for i=0,10 do
			if i == volume then
				str = str .. "|"
			else
				str = str .. "-"
			end
		end
		self.audioButtons[1].text:write("Master:" .. str)
	end

	do
		local volume = DATA.options.audio.music_volume
		local str = ""
		for i=0,10 do
			if i == volume then
				str = str .. "|"
			else
				str = str .. "-"
			end
		end
		self.audioButtons[2].text:write("Music: " .. str)
	end

	do
		local volume = DATA.options.audio.sfx_volume
		local str = ""
		for i=0,10 do
			if i == volume then
				str = str .. "|"
			else
				str = str .. "-"
			end
		end
		self.audioButtons[3].text:write("SFX:  " .. str)
	end
	
	self.audioButtons[1].func = function ()
		local volume = DATA.options.audio.master_volume
		if volume < 10 then
			volume = volume + 1
			DATA.options.audio.master_volume = volume
			love.audio.setVolume(volume/5)
			local str = ""
			for i=0,10 do
				if i == volume then
					str = str .. "|"
				else
					str = str .. "-"
				end
			end
			self.audioButtons[1].text:write("Master:" .. str)
		end
	end

	self.audioButtons[1].bfunc = function ()
		local volume = DATA.options.audio.master_volume
		if volume > 0 then
			volume = volume - 1
			DATA.options.audio.master_volume = volume
			love.audio.setVolume(volume/5)
			local str = ""
			for i=0,10 do
				if i == volume then
					str = str .. "|"
				else
					str = str .. "-"
				end
			end
			self.audioButtons[1].text:write("Master:" .. str)
		end
	end

	self.audioButtons[2].func = function ()
		local volume = DATA.options.audio.music_volume
		if volume < 10 then
			volume = volume + 1
			DATA.options.audio.music_volume = volume
			self.introPart:setVolume(.3 * volume/5)
			self.song:setVolume(.3 * volume/5)
			local str = ""
			for i=0,10 do
				if i == volume then
					str = str .. "|"
				else
					str = str .. "-"
				end
			end
			self.audioButtons[2].text:write("Music: " .. str)
		end
	end

	self.audioButtons[2].bfunc = function ()
		local volume = DATA.options.audio.music_volume
		if volume > 0 then
			volume = volume - 1
			DATA.options.audio.music_volume = volume
			self.introPart:setVolume(.3 * (volume/5))
			self.song:setVolume(.3 * (volume/5))
			local str = ""
			for i=0,10 do
				if i == volume then
					str = str .. "|"
				else
					str = str .. "-"
				end
			end
			self.audioButtons[2].text:write("Music: " .. str)
		end
	end

	self.audioButtons[3].func = function ()
		local volume = DATA.options.audio.sfx_volume
		if volume < 10 then
			volume = volume + 1
			DATA.options.audio.sfx_volume = volume
			local str = ""
			for i=0,10 do
				if i == volume then
					str = str .. "|"
				else
					str = str .. "-"
				end
			end
			self.audioButtons[3].text:write("SFX:  " .. str)
		end
	end

	self.audioButtons[3].bfunc = function ()
		local volume = DATA.options.audio.sfx_volume
		if volume > 0 then
			volume = volume - 1
			DATA.options.audio.sfx_volume = volume
			local str = ""
			for i=0,10 do
				if i == volume then
					str = str .. "|"
				else
					str = str .. "-"
				end
			end
			self.audioButtons[3].text:write("SFX:  " .. str)
		end
	end

	-- self.audioButtons[1].func = function ()

	-- end

	self.audioButtons[4].func = function () self:goToSpecificOptionsMenu(self.optionButtons, 2) end
	self.audioButtons:set("visible", false)

	--CONTROLLER--
	self.controllerButtons = buddies.new()

	self.controllerButtons:add(self:addScenery(MenuButton(75, DATA.options.game.speedrun and "Speedrun mode: Aan" or "Speedrun mode: Uit")))
	self.controllerButtons:add(self:addScenery(MenuButton(190, DATA.options.controller.rumble and "Rumble: Aan" or "Rumble: Uit")))
	self.controllerButtons:add(self:addScenery(MenuButton(305, DATA.options.controller.singleplayer and "Singleplayer controls" or "Multiplayer controls")))
	self.controllerButtons:add(self:addScenery(MenuButton(420, "Terug")))
	self.controllerButtons:centerX(WIDTH/2 + WIDTH)
	self.controllerButtons[1].selected = true

	self.controllerButtons[1].func = function ()
		local speedrun = not DATA.options.game.speedrun
		DATA.options.game.speedrun = speedrun
		self.controllerButtons[1].text:write(speedrun and "Speedrun mode: Aan" or "Speedrun mode: Uit")
	end
	
	self.controllerButtons[2].func = function ()
		local rumble = not DATA.options.controller.rumble
		DATA.options.controller.rumble = rumble
		self.controllerButtons[2].text:write(rumble and "Rumble: Aan" or "Rumble: Uit")
		if rumble then
			for i,v in ipairs(love.joystick.getJoysticks()) do
				v:setVibration(.5, .5, .25)
			end
		end
	end

	-- self.controllerButtons[2].func = function ()
	-- 	local upjump = not DATA.options.controller.upjump
	-- 	DATA.options.controller.upjump = upjump
	-- 	self.controllerButtons[2].text:write(upjump and "Up = Jump: Aan" or "Up = Jump: Uit")
	-- end

	self.controllerButtons[3].func = function ()
		local singleplayer = not DATA.options.controller.singleplayer
		print(singleplayer)
		DATA.options.controller.singleplayer = singleplayer
		self.controllerButtons[3].text:write(singleplayer and "Singleplayer controls" or "Multiplayer controls")
	end

	self.controllerButtons:set("visible", false)

	self.controllerButtons[4].func = function () self:goToSpecificOptionsMenu(self.optionButtons, 3) end

	--MAP--------------------------
	self.map = Tilemap(self, "menu")

	self.peter = self:findEntity(function (e) return e.id == "peter" end)
	self.timon = self:findEntity(function (e) return e.id == "timon" end)
	self.peter.menu = true
	self.timon.menu = true

	self.peter:setPartner(self.timon)
	self.timon:setPartner(self.peter)
	------------

	if DATA.fastestTime > 0 then
		self.time = self:addScenery(self:createText(10, "Wereldrecord: " .. Utils.secondsToClock(DATA.fastestTime), 32))
		self.time.x = 10
		self.time.align.x = "left"
	end

end


function Menu:update(dt)
	self.timer = self.timer + dt

	self.glitchText.x = 166
	self.glitchText.y = -160

	self.pressStart.offset.y = math.sin(self.timer * PI * 2) * 3

	if self.introPart:tell("seconds") > 15.463 - (dt * 2) or (self.drawingBackground and not self.introPart:isPlaying()) then
		self.song:play()
	end

	if self.ready then
		if self.onLogo then
			if self.glitchTimer(dt) then
				self.glitchText.anim:set("glitch")
				self.glitchText:setShader("rgb")
			end
			if Key:isPressed("return", "g") then
				self.onLogo = false
				self.ready = false
				self.flux:to(self, 1, {offsetY = 0}):oncomplete(function () self.ready = true end)
			end
		else
			if Key:isPressed("escape", "h") then
				if self.buttons ~= self.menuButtons then
					self.buttons[#self.buttons]:activate()
				else
					self.song:stop()
					self.introPart:stop()
					local Intro = require "base/intro"
					State:toState(Intro())
					return
				end
			elseif Key:isPressed("return", "g") then
				if not self.buttons[self.selected].analog then
					self.buttons[self.selected]:activate()
				end
			elseif Key:isPressed("down") then
				self.selectSFX:play()
				self.buttons[self.selected]:deselect()
				self.selected = self.selected + 1
				if self.selected > #self.buttons then
					self.selected = 1
				end
				self.buttons[self.selected]:select()
			elseif Key:isPressed("up") then
				self.selectSFX:play()
				self.buttons[self.selected]:deselect()
				self.selected = self.selected - 1
				if self.selected < 1 then
					self.selected = #self.buttons
				end
				self.buttons[self.selected]:select()
			elseif Key:isPressed("left") then
				if self.buttons[self.selected].analog then
					self.buttons[self.selected]:unactivate()
					self.selectSFX:play()
				end
			elseif Key:isPressed("right") then
				if self.buttons[self.selected].analog then
					self.buttons[self.selected]:activate()
					self.selectSFX:play()
				end
			end
		end
	end
	Menu.super.update(self, dt)
end


function Menu:draw()
	love.graphics.push()
	love.graphics.translate(self.offsetX, self.offsetY)
		if self.drawingBackground then
			for i=0,3 do
				for j=0,4 do
					self.background.offset:set(i * self.background.width, j * self.background.height)
					self.background:draw()
				end
			end
		end
		Menu.super.draw(self)
	love.graphics.pop()	
	self.fadeRect:draw()
end


function Menu:createText(y, txt, size)
	local text = Text(0, y, txt, "sheepixel", size)

	text.align.x = "center"
	text.font:setFilter("linear", "linear")
	text.limit = WIDTH
	text.x = 0
	text.color = {255, 255, 255}

	return text
end


function Menu:goToOptions()
	self.ready = false
	self.optionButtons:deselect()
	self.optionButtons[1].selected = true
	
	self.showOptions = true -- TODO: Is deze nodig?
	self.selected = 1
	self.flux:to(self, .5, {offsetX = -WIDTH}):oncomplete(function ()
		self.ready = true
		self.buttons = self.optionButtons
		-- self.timon:moveRight()
	end)
	:onupdate(function ()
		if self.offsetX < -WIDTH/2 then
			if self.peter.x < WIDTH then
				self.peter:teleport(WIDTH * 2 + 30)
				self.peter:moveLeft()
				self.timon:moveRight()
			end
		end
	end)
end


function Menu:goBackToMenu()
	self.ready = false
	self.showOptions = false
	self.selected = 2
	self.flux:to(self, .5, {offsetX = 0}):oncomplete(function ()
		self.ready = true
		self.buttons = self.menuButtons
	end)
	:onupdate(function ()
		if self.offsetX > -WIDTH/2 then
			if self.peter.x > WIDTH then
				self.peter:teleport(0)
				self.tick:delay(.2, function ()
					self.peter:moveRight()
				end)
				self.timon:moveLeft()
			end
		end
	end)
end


function Menu:goToSpecificOptionsMenu(buttons, selected)
	self.buttons:set("visible", false)
	self.buttons:deselect()
	self.buttons = buttons
	self.buttons:set("visible", true)
	self.buttons[selected].selected = true
	self.selected = selected
	SAVE_DATA()
end


function Menu:startGame(story)
	print(story, CURRENT_LEVEL)
	if story then
		local options = DATA.options
		DATA = GET_NEW_DATA()
		DATA.options = options
		CURRENT_LEVEL = 1
	else
		CURRENT_LEVEL = DATA.level
	end

	self.ready = false

	self.themeVolume = GET_MUSIC_VOLUME()

	self.flux:to(self, .5, {themeVolume = 0}):onupdate(function ()
		self.song:setVolume(self.themeVolume)
		self.introPart:setVolume(self.themeVolume)
	end)

	self.fadeRect.color = {0, 0, 0}

	if DATA.options.game.speedrun then
		story = false
	end

	self.flux:to(self.fadeRect, .5, {alpha = 1})
	:oncomplete(function () State:toState(story and Story() or GameManager()) end)
end
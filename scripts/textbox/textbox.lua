Textbox = Rect:extend()

Textbox.height = 39

Textbox.effectList = {
	["i"] = "italic",
	["b"] = "bold",
	["gr"] = "group",
	["circle"] = "circle",
	["shake"] = "shake",
	["wave"] = "wave",
	["fade"] = "fade",
	["wacky"] = "wacky",
	["wobble"] = "wobble",
	["glow"] = "glow"
}


function Textbox:new()
	Textbox.super.new(self, 175, 20, 615, 61)


	self.portraits = {
		peter = "textbox/portraits/peter",
		timon = "textbox/portraits/timon",
		richard = "textbox/portraits/richard",
		richard_glitched = "textbox/portraits/richard",
		koter = "textbox/portraits/koter",
		koter_sad = "textbox/portraits/koter_sad",
		lekkerchat = "textbox/portraits/lekkerchat"
	}

	self.audioEffects = {
		peter = "sfx/textbox/squeak",
		timon = "sfx/textbox/bark",
		richard = "sfx/textbox/malsemakkers",
		richard_glitched = "sfx/textbox/malsemakkers_glitched",
		koter = "sfx/textbox/koter",
		koter_sad = "sfx/textbox/koter_sad",
		lekkerchat = "sfx/textbox/lekkerchat2"
	}

	self.charSFX = SFX("sfx/textbox/char", 1)

	self.drawPortrait = true

	--Content
	self.textFeed = {}
	self.commands = {}

	--State
	self.state = "_"
	self.closed = true
	self.currentLine = 1

	--Sprites

	self.background = Sprite(0, 0, "textbox/background")
	self.background2 = Sprite(0, 0, "textbox/background2")

	--Used when there is text left
	self.arrow = Sprite(self.width - 25, 80, "textbox/arrow", 7, 10)
	self.arrow.anim:add("idle",{1,1,2,3,4,5,5},{11,11,13,16,13,11,11},"pingpong")
	self.arrow.scale:set(2, 2)

	--Used when at the end of the conversation
	self.block = Sprite(self.width - 25, 80, "textbox/block")
	self.block.rotate = 3
	self.block.scale:set(2, 2)

	--Properties
	self.pauseTimer = 0

	self.charInterval = 0.01
	self.charTimer = 0

	self.textStartX = 130
	self.textStartY = 6

	self.fontSize = 32
	self.fontScale = 1

	self.effects = {}

	self.conversation = nil

	--Text objects
	self.text = self:createText()
	self.effectText = buddies.new()

	--Flow
	self.flux = flux.group()
	self.tick = tick.group()
end


function Textbox:update(dt)
	if self.closed then return end

	self.flux:update(dt)
	self.tick:update(dt)

	self.arrow:update(dt)
	self.block:update(dt)

	if self.drawPortrait then
		-- self.portrait:update(dt)
	end

	self:updateEffectText(dt)

	if self.state == "write" then

		if self.pauseTimer > 0 then self.pauseTimer = self.pauseTimer - dt return end

		--self.textFeed - The text
		--self.textFeed[1] - The current part (till next command)
		--self.textFeed[1][1] - The current word
		--self.textFeed[1][1][1] - The current character  

		if #self.textFeed > 0 then --If there's still parts
			if #self.textFeed[1] > 0 then -- If this part still has words
				if self.textFeed[1][1].word then
					self:handleLimitHitting(self.textFeed[1][1].word)
					self.textFeed[1][1].word = nil
					if self.state == "next" then return end
				end
				if #self.textFeed[1][1] > 0 then -- If this word still has characters
					self.charTimer = self.charTimer + dt
					while self.charTimer > self.charInterval do
						local char = self.textFeed[1][1][1]
						if self:hasEffect() then
							local t = self:createEffectChar(char)
							self.effectText:add(t)
							self.text:append(char, {0, 0, 0, 0})
						else
							self.text:append(char)
						end
						if self.narrator then
							self.charSFX:play()
						end
						table.remove(self.textFeed[1][1], 1)
						self.charTimer = self.charTimer - self.charInterval
						if #self.textFeed[1][1] == 0 then break end
					end
				else
					table.remove(self.textFeed[1], 1)
				end
			end

			--Text is split up between commands
			--No words left means the next command should be executed
			if #self.textFeed[1] == 0 then
				self:applyCommand(self.commands[1])

				table.remove(self.textFeed, 1)
				table.remove(self.commands, 1)
			end
		end
	elseif self.state == "paused" then
		if Key:isPressed("g", "return", "space") or (DATA.options.controller.singleplayer and Key:isPressed("i")) then
			self:emptyBox()
			self.state = "write"
		end
	elseif self.state == "next" then
		if Key:isPressed("g", "return", "space") or (DATA.options.controller.singleplayer and Key:isPressed("i")) then
			self:scrollUp()
		end
	elseif self.state == "stop" then
		if Key:isPressed("g", "return", "space") or (DATA.options.controller.singleplayer and Key:isPressed("i")) then
			self.conversation = self.conversation.after
			if self.conversation then
				self.state = "write"
				if self.conversation.emotion then
					self.portrait:set(self.conversation.emotion)
				end
				if self.conversation.func then
					self.conversation.func()
				end
				if self.conversation.text then
					self:feed(self.conversation.text)
				else
					self:close()
				end
			else
				self:close()
			end
		end
	elseif self.state == "response" then
		self.optionBox:update(dt)
		local r = self.optionBox:getOption()
		if r then
			if self.conversation.response[r].after then
				self.conversation = self.conversation.response[r].after
				self:emptyBox()
				self.state = "write"
				if self.conversation.emotion then
					self.portrait:set(self.conversation.emotion)
				end
				if self.conversation.func then
					print("Wordt dit uitgevoerd?")
					self.conversation.func()
				end
				if self.conversation.text then
					self:feed(self.conversation.text)
				else
					self:close()
				end
			else
				self:close()
			end
		end
	end
end
	

function Textbox:draw()
	if self.closed then return end
	
	if self.narrator then
		Rect.drawAsChild(self.background2, self)
	else
		Rect.drawAsChild(self.background, self)
	end

	if self.state == "next" or self.state == "empty" or self.state == "paused" then
		Rect.drawAsChild(self.arrow, self)
	elseif self.state == "stop" then
		Rect.drawAsChild(self.block, self)
		-- self.optionBox:draw()
	end
	-- love.graphics.setScissor((self.x+4)*4, (self.y+3)*4, 300*4, 50 * 4)
	if self.drawPortrait then
		Rect.drawAsChild(self.portrait, self)
	end
	Rect.drawAsChild(self.text, self)
	Rect.drawAsChild(self.effectText, self)
	-- love.graphics.setScissor()
	-- self:drawForeground()
end



function Textbox:updateEffectText(dt)
	for i,v in ipairs(self.effectText) do

		if self.currentLine >= v.line + self:getMaxLines() then
			 v.dead = true
		end

		v.y = self.text.y
		v.timer = v.timer + dt

		local factor = self.fontScale * 1

		if v.effects.wave then
			v.offset.y = math.sin(v.timer * 13) * factor
		end

		if v.effects.wacky then
			v.offset.x = math.cos(v.timer * 10) * (math.sin(v.timer) * 3)
			v.offset.y = math.sin(v.timer * 10) * (math.cos(v.timer) * 2)
		end

		if v.effects.shake then
			-- local old = math.getrandomseed()
			-- math.randomseed(v.timer)
			local shake_amount = 1
			v.offset:set(lume.random(-shake_amount, shake_amount) * factor, lume.random(-shake_amount, shake_amount) * factor)
			-- math.randomseed(old)
		end

		if v.effects.glow then
			v.shadow:set((_.absincos(v.timer * 7)/2) / factor)
			v.shadow.color = {1, 1, 1}
		end

		if v.effects.wobble then
			local w, lines = v:getWrap()
			local height = self.text:getTrueHeight() * #lines
			v.origin:set(v:getLength(lines[#lines]) - 2, height - v:getLineHeight())
			v.angle = math.cos(v.timer * 7) / 6
		end

		if v.effects.fade then
			v.alpha = 0.1 + _.absincos(v.timer * 7) * 0.9
		end

		if v.effects.bold then
			v.border:set(1)
			v.border.color = {1, 1, 1, 0}
			v.color = {0, 0, 0}
		end

		if v.effects.circle then
			v.offset.x = math.cos(v.timer * 10) * 2
			v.offset.y = math.sin(v.timer * 10) * 2 
		end

		if v.effects.italic then
			v.shear:set(-0.2, 0)
		end
	end
	self.effectText:removeIf(function (t) return t.dead end)
end


function Textbox:applyCommand(c)
	if c == "pause" then
		self.state = "paused"
	-- elseif c == "clear" then
		-- self:scrollUp()
	elseif c == "nl" then
		self:newLine()
	elseif c == "empty" then
		self:emptyBox()
	elseif c== "close" then
		self:close()
	elseif c == "stop" then
		local resp = self.conversation.response
		if resp and #resp > 0 then
			self.state = "response"
			self.optionBox:open(resp)
		else
			self.state = "stop"
		end
	elseif c:find("speed=") then
		self.charInterval = tonumber(c:match("speed=(%S+)"))
	elseif c:find("anim=") then
		self.currentTalker.anim:set(c:match("anim=(%S+)"))
	elseif c:find("emo=") then
		self.portrait:set(c:match("emo=(%S+)"))
	elseif c:find("talk=") then
		local talker = c:match("talk=(%S+)")
		if talker == "none" then
			self:setPortrait()
		else
			self:setPortrait(talker)
		end
	elseif c:find("exe=") then
		local f = c:match("exe=(.+)")
		info("Textbox - Executing command: " .. f)
		local t = _.dostring(f)
		if t then
			self:addFeed(t)
		end
	elseif tonumber(c) ~= nil then
		self.pauseTimer = tonumber(c)
	elseif Textbox.effectList[c] then
		self.effects[Textbox.effectList[c]] = true 
	elseif c:sub(1, 1) == "/" then
		for k,v in pairs(Textbox.effectList) do
			if "/" .. k == c then
				self.effects[Textbox.effectList[k]] = false
			end
		end
	elseif c == "big" then
		self.fontScale = 2
		self:resetFont()
	elseif c == "small" then
		self.fontScale = 0.5
		self:resetFont()
	elseif c == "reset" then
		self.fontScale = 1
		self:resetFont()
		self.charInterval = 0.01
	end
end


function Textbox:feed(text)
	self.textFeed = {}
	self.commands = {}
	self.currentLine = 1
	self.text.y = self.textStartY
	self.text:write("")
	local text = type(text) == "string" and text or text()
	self:splitText(self:formatFeed(text))
end


function Textbox:splitText(feed, insert)
	for line, command in feed:gmatch("([^<]-)<([^>]-)>") do
		local words = {}
		for word in line:gmatch("(%s?%S+%s?)") do
			local t = {word = word}
			--Put each character of the word in the table
			word:gsub(".",function(c) table.insert(t,c) end)
			table.insert(words, t)
		end

		table.insert(self.textFeed, insert or #self.textFeed + 1, words)
		table.insert(self.commands, insert or #self.commands + 1, command)
	end
end


function Textbox:addFeed(text)
	local feed = text .. "<>"
	self:splitText(feed, 2)
end


function Textbox:formatFeed(feed)
	feed = feed:gsub("|\n","|")
	feed = feed:gsub("\n"," ")
	feed = feed:gsub("|","<pause>")
	feed = feed .. " <stop>"
	return feed
end


function Textbox:setPortrait(a)
	if a then
		self.textStartX = 130
		self.drawPortrait = true

		local name = a
		self.portrait = Sprite(6, -4, self.portraits[name:lower()])
		self.portrait.scale:set(0.9)
		self.portrait.origin:set(0, self.portrait.height)

		local aud = Asset.audio(self.audioEffects[name:lower()])

		if self.scene then
			self.scene:playAudio(aud)
		else
			aud:play()
		end

		self.flux:to(self.portrait, 0.2, {y = -8})
		self.flux:to(self.portrait.scale, 0.2, {x = 1, y = 1})
		self:resetText()
	else
		self.textStartX = 15
		self.drawPortrait = false
		self:resetText()
	end
end


function Textbox:handleLimitHitting(word)
	lastline = self.text:match("\n.+$") or self.text:read()
	if self.text:getLength(lastline .. word) >= self:getLimit() then
		self:newLine()
	end
end


function Textbox:newLine()
	self.text:append("\n")
	if self.currentLine >= self:getMaxLines() then
		self.state = "next"
	else
		self.currentLine = self.currentLine + 1
	end
end


function Textbox:getMaxLines()
	return math.floor(3 / self.fontScale) 
end


function Textbox:scrollUp()
	if self.state ~= "scroll" then
		self.state = "scroll"
		self.flux:to(self.text, 0.4, {y = self.text.y - self.text:getTrueHeight()})
			:oncomplete(function ()  self.state = "write" self.currentLine = self.currentLine + 1 end)
	end
end


function Textbox:emptyBox()
	self.effectText = buddies.new()
	self.text:write("")
	self.text.y = self.textStartY
	self.currentLine = 1
end


function Textbox:getLimit()
	local x = 140
	return self.width - x - 16
end


function Textbox:hasEffect()
	for k,v in pairs(self.effects) do
		if v then return true end
	end
	return false
end


function Textbox:createText(x, y, t, s)
	local t = Text(x or self.textStartX, y or self.textStartY, t or "", "sheepixel", self.fontSize * self.fontScale, true)
	t.font:setLineHeight(1)
	return t
end


function Textbox:resetText()
	self.text.x = self.textStartX
	self.text.y = self.textStartY
end


function Textbox:resetFont()
	self.text:setFont("sheepixel", self.fontSize * self.fontScale, true)
end


function Textbox:createEffectChar(char)
	local t = self:createText()
	t.y = self.text.y
	t:write(self.text:read(), {0, 0, 0, 0})

	t:append(char)

	local last = self.effectText[#self.effectText]
	t.timer = self.effects.group and (last and last.timer or 0) or -string.len(t:read())
	t.line = self.currentLine
	
	t.effects = {}

	for k,v in pairs(self.effects) do
		t.effects[k] = v
	end

	return t
end


function Textbox:open(t, p, f)
	if t then
		if type(t) ~= "table" then
			t = {{text = t}}
		end
		self:setPortrait(p)
		local a = 0
		for i,v in ipairs(t) do
			if (not v.condition or v.condition()) and (not v.counter or v.counter == p.talkedToCounter) then
				-- a = a + 1
				-- if not p or p.talkedToCounter == a or i == #t then
					self.conversation = v
					self:feed(v.text)
					if v.emotion then
						self.portrait:set(v.emotion)
					end
					if v.func then
						v.func()
					end
					break
				-- end
			else
				self:feed("What?")
			end
		end
	end
	self.effectText = buddies.new()
	self.currentTalker = p
	self.onClose = f
	self.closed = false
	self.tick:delay(0.1, function () self.state = "write" end)
	-- self.flux:to(self, 0.5, {y = self.y - 39}):ease("quintout")
end


function Textbox:close()
	self.state = "_"
	if self.onClose then self.onClose() end
	self.flux:to(self, 0.8, {y = self.y - 150}):ease("quintout"):oncomplete(function () self.closed = true self.y = self.y + 150 end)
end


function Textbox:__tostring()
	return lume.tostring(self, "Textbox")
end
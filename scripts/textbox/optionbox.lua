local Box = require "textbox/box"
Optionbox = Box:extend()

function Optionbox:new()
	Optionbox.super.new(self, 0, 0, WIDTH/2, HEIGHT/2 - 10)
	self.text = Text(15, 4, "", "sheepixelsmall", 12, true)
	self.text.font:setLineHeight(0.9)
	self.closed = true
	self.choice = 1

	self.arrow = Sprite(7, 3, "textbox/arrow", 7, 10)
	self.arrow.anim:add("idle",{1,1,2,3,4,5,5},{11,11,13,16,13,11,11},"pingpong")
	self.arrow.angle = -PI/2
	self.arrow.moving = false

	self.canSelect = false

	self.flux = flux.group()
end


function Optionbox:update(dt)
	if self.closed then return end

	self.flux:update(dt)

	if not self.arrow.moving then
		if Key:isPressed("down") then
			if self.choice < #self.options then
				self.arrow.moving = true
				self.arrow.anim:set("idle", true)
				self.flux:to(self.arrow, 0.1, {y = self.arrow.y + self.text:getTrueHeight()}):oncomplete(function () self.arrow.moving = false end)
				self.choice = self.choice + 1
			end
		elseif Key:isPressed("up") then
			if self.choice > 1 then
				self.arrow.moving = true
				self.arrow.anim:set("idle", true)
				self.flux:to(self.arrow, 0.1, {y = self.arrow.y - self.text:getTrueHeight()}):oncomplete(function () self.arrow.moving = false end)
				self.choice = self.choice - 1
			end
		end
	end
	self.arrow:update(dt)
end
	

function Optionbox:draw()
	if self.closed then return end

	Optionbox.super.draw(self)
	if self.drawText then
		self.text:drawAsChild(self)
		self.arrow:drawAsChild(self)
	end
end


function Optionbox:getOption()
	if Key:isPressed("z") then
		self.closed = true
		return self.choice
	end
end


function Optionbox:open(opt)
	local longest = 0
	self.text:write("")
	options = {}
	for i,v in ipairs(opt) do
		v.text = type(v.text) == "string" and v.text or tostring(v.text())
		if not v.condition or v.condition() then
			longest = math.max(longest, self.text:getLength(v.text))
			self.text:append(v.text .. "\n")
			table.insert(options, v)
		end
	end
	self.choice = 1
	self.arrow:set(7, 6)
	self.options = options
	self.closed = false
	self.drawText = false
	self.width = longest + 22 
	self.height = self.text:getTrueHeight() * #options + 10
	self:centerX(WIDTH/2)
	self:centerY((HEIGHT - Textbox.height)/2)
	self.y = math.max(0, self.y)
	local x, y, w, h = math.floor(self.x), math.floor(self.y), self.width, self.height
	self.x = self.x + self.width/2
	self.y = self.y + self.height/2
	self.width = 10
	self.height = 10
	
	self.flux:to(self, 0.2, {x = x})
	self.flux:to(self, 0.2, {y = y})
	self.flux:to(self, 0.2, {width = w})
	self.flux:to(self, 0.2, {height = h}):oncomplete(function () self.drawText = true end)
end


function Optionbox:__tostring()
	return lume.tostring(self, "Optionbox")
end
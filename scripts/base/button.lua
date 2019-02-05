local Button = Sprite:extend()

Button.defaultShape = "rectangle"

function Button:new(x, y, shape)
	Button.super.new(self, x, y)
	self.radius = 0

	self.shape = shape or Button.defaultShape

	self.onRelease = false
	self.buttons = {1}
	self.keys = {}

	self.active = true

	self.hovering = false
	self.hold = false
	self.activated = false
end


function Button:update(dt)
	if not self.active then return end

	Button.super.update(self, dt)

	self.activated = false
	local a = self.hovering

	if self:hovers(Mouse) then
		if self.hoverFunc then self.hoverFunc(self) end
		if self:isTriggerPressed() then
			self.hold = true
			if not self.onRelease then
				self.activated = true
				self.hold = false
			end
		end
	else
		if a then
			if self.offFunc then self.offFunc(self) end
		end
	end


	if self._image then
		if not self.anim:is("active") or self.anim.ended then
			if self.hovering and not self.hold then
				self.anim:set("hover")
			elseif self.hold then
				self.anim:set("hold")
			elseif not self.hovering and not self.hold then
				self.anim:set("idle")
			end
		end
	end

	if self.onRelease then
		if self:isTriggerReleased() then
			if self.hovering and self.hold then
				self.activated = true
				self.hold = false
			end
			self.hold = false
		end
	end

	if self.activated then
		if self._image then
			self.anim:set("active", true)
		end
		if self.func then self.func(self) end
	end
end


function Button:onPress(func)
	self.func = func
	return self
end


function Button:onHover(func)
	self.hoverFunc = func
	return self
end


function Button:offHover(func)
	self.offFunc = func
	return self
end


function Button:hovers(p)
	if self.shape == "rectangle" then
		self.hovering = self:overlaps(p)
	else
		self.hovering = Circle.overlaps(self, p)
	end

	if self.hovering then
		Mouse:setCursor(Cursors.hand)
	end

	return self.hovering
end


function Button:setImage(url, width, height)
	Button.super.setImage(self, url, width, height)
	
	if self.shape == "circle" then
		self:centerOffset()
		self.radius = self.width
		self.width = nil
		self.height = nil
	end

	local a1, a2, a3
	a1 = #self._frames > 1 and 2 or 1
	a2 = #self._frames > 2 and 3 or a1
	a3 = #self._frames > 3 and 4 or a2
	
	self.anim:add("idle",{1})
	-- if auto then
		self.anim:add("hover", {a1})
		self.anim:add("hold", {a2})
		self.anim:add("active", {a3})
	-- end
	self.anim:set("idle", true)
	return self
end


function Button:isTriggerPressed()
	return Mouse:isPressed(unpack(self.buttons)) or Key:isPressed(unpack(self.keys))
end


function Button:isTriggerReleased()
	return Mouse:isReleased(unpack(self.buttons)) or Key:isReleased(unpack(self.buttons))
end


function Button:_str()
	return "hover: " .. self.hovering .. ", hold:" .. self.hold .. ", activated: " .. self.activated 
end


function Button:__tostring()
	return lume.tostring(self, "Button")
end

return Button
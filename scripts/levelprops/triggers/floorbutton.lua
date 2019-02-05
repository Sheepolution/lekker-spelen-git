FloorButton = Thing:extend("FloorButton")

FloorButton.SFX = SFX("sfx/button")

function FloorButton:new(...)
	FloorButton.super.new(self, ...)
	self:setImage("levelprops/triggers/button", 8)
	self.anim:add("down", 2)
	self.anim:add("up", 1)
	self.offset.y = 7
	self.hitbox = self:addHitbox("solid", 0, 0, self.width * .6, self.height)
	self.isPressed = 0
	self.solid = 0
	self:addIgnoreCollision(Box)
	self.z = 3
	self.gravity = 0
	self.moves = false
end


function FloorButton:update(dt)
	FloorButton.super.update(self, dt)
	if self.isPressed == 2 then
		self.isPressed = 1
	elseif self.isPressed == 1 then
		self.isPressed = 0
		self.anim:set("up")
		self:onOff()
	end
end


function FloorButton:onOverlap(e, mine, his)
	if e.teleporting then return false end
	if his.solid and e.canTrigger then
		self.anim:set("down")
		if self.isPressed == 0 then
			self:onPressed()
		end
		self.isPressed = 2
		return false
	end

	return FloorButton.super.onOverlap(self, e, mine, his)
end


function FloorButton:draw()
	FloorButton.super.draw(self)
end


function FloorButton:onPressed()
	if not GM.currentLevelName == "level4_intro" then
		self.scene:playSFX(FloorButton.SFX)
	end
	if self.link ~= nil then
		local matches = self.scene:findEntities(function (e) return e.link == self.link end)

		for i,match in ipairs(matches) do
			if not match:is(FloorButton) then
				match:onTrigger()
			end
		end
	end
end


function FloorButton:onOff()
	local matches = self.scene:findEntities(function (e) return e.link == self.link end)

	for i,match in ipairs(matches) do
		if not match:is(FloorButton) then
			match:onOff()
		end
	end
end
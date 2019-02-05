Box = Thing:extend("Box")

function Box:new(...)
	Box.super.new(self, ...)
	self:setImage("levelprops/box")
	self.y = self.y - 16
	self.offset.y = 16
	self.solid = 2
	self.hitbox = self:addHitbox("solid", 0, 12, self.width, 32)
	self.separatePriority:set(1)
	
	self.SFX.pushed = SFX("sfx/push_box", 1)
	self.SFX.drop = SFX("sfx/box_drop", 1)

	self.gravity = 200

	self:delay(.2, {gravity = Thing.gravity * 2})

	self.canDie = false
	self.canTrigger = true
end


function Box:update(dt)
	if self.last.x ~= self.x then
		self.scene:playSFX(self.SFX.pushed)
	end
	Box.super.update(self, dt)
end


function Box:draw()
	Box.super.draw(self)
end


function Box:onGrounding()
	if GM.currentLevelName ~= "level4_intro" then
		self.scene:playSFX(self.SFX.drop)
	end
	Box.super.onGrounding(self)
end
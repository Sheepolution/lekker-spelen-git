Euro = Pickupable:extend("Euro")

Euro.SFX = SFX("sfx/euro")


function Euro:new(x, y, drop)
	Euro.super.new(self, x, y)
	self:setImage("pickupables/lekkereuro", 24)
	self.anim:add("idle")


	if not drop then
		self.pickupable = true
		self.gravity = 0
	else
		self.pickupable = false
		self:delay(0.3, {pickupable = true})
		self.velocity.y = -math.random(380, 420)
		self.velocity.x = math.random(-30, 30)
	end

	self.z = ZMAP.Pickupable
	
	self.autoFlip.x = false
end


function Euro:update(dt)
	if self.grounded then
		self:stopMoving()
	end
	Euro.super.update(self, dt)
end


function Euro:onPickedUp()
	Game:gainEuros()
	self.scene:playSFX(Euro.SFX)
	Euro.super.onPickedUp(self)
end
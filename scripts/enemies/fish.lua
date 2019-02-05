Fish = Enemy:extend("Fish")
-- lekkerOh

Fish:implement(Locator)

function Fish:new(...)
	Fish.super.new(self, ...)
	self:setImage("lekkeroh", 36)
	self.anim:add("shy", "1>24")
	self.anim:add("attack", "25>36")

	self:addIgnoreOverlap(SolidTile)

	self.floating = true
	self.solid = 0
	self.gravity = 0
	self.speed = 100

	self.jumpToKill = true
	self.damaging = true
	self.canBeKilled = false
end


function Fish:update(dt)
	if not self.dead then
		self:findTarget(Player, 700)
	end

	Fish.super.update(self, dt)
end


function Fish:draw()
	Fish.super.draw(self)
end


function Fish:onFindingTarget(target)
	self:lookAt(target)
	if target:isLookingAt(self) then
		if self.anim:is("attack") then
			-- self.scene:playSFX(self.SFX.oh)
		end
		self.anim:set("shy")
		self:stopMoving()
	else
		if self.anim:is("shy") then
			-- self.scene:playSFX(self.SFX.scary)
		end
		self.anim:set("attack")
		self:moveToEntity(target)
	end
end
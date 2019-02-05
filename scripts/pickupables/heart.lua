Heart = Pickupable:extend("Heart")


function Heart:new(...)
	Heart.super.new(self, ...)
	self:setImage("pickupables/lekkerlief", 26)
	self.anim:add("stand", 13)
	self.anim:add("run", "14>19")
	self.anim:add("jump", 16)
	self.anim:add("idle", "1>12")

	self.SFX.pickedup = SFX("sfx/heart")
	self.SFX.jump = SFX("sfx/heart_jump")

	self.speed = 160

	self.hitbox = self:addHitbox("solid", 0, self.height/2, 32, self.height/4)
	self.hitbox.pickup = true
	self.jumpBox = self:addHitbox("jump", 20, 6, self.width + 18, self.height/4)
	self.jumpBox.solid = false

	self.bounce.x = 1

	self.state = "sit"
end


function Heart:update(dt)
	local nearest, distance = self.scene:findNearestEntityOfType(self, Player)
	if nearest then
		if self:getDistanceY(nearest) < self.height * 6 then
			if self.state == "sit" then
				if distance < 280 then
					self:startLooking(nearest)
				end
			elseif self.state == "looking" or (self.state == "running" and self.grounded) then
				if distance < 200 then
					self:startRunning(nearest)
				end
			end
		end
	end
	Heart.super.update(self, dt)
end


function Heart:draw()
	Heart.super.draw(self)
end


function Heart:onOverlap(e, mine, his)
	if mine.name == "jump" then
		if e:is(SolidTile) then
			self.anim:set("jump")
			self:jump()
		end
	end

	return Heart.super.onOverlap(self, e, mine, his)
end


function Heart:onGrounding()
	Heart.super.onGrounding(self)
	if self.velocity.x ~= 0 then
		self.anim:set("run")
	end
end


function Heart:jump()
	if self.grounded then
		self.y = self.last.y
		self.velocity.y = -550
		self.grounded = false
		self.scene:playSFX(self.SFX.jump)
	end
end


function Heart:startLooking(target)
	self.state = "looking"
	self:lookAt(target)
	self.velocity.y = -180
	self.scene:playSFX(self.SFX.jump)
	self.anim:set("stand")
end


function Heart:startRunning(target)
	self.state = "running"
	self:lookAway(target)
	if self.grounded then
		self.anim:set("run")
	else
		self.anim:set("jump")
	end
	self:moveToDirection()
end


function Heart:onPickedUp()
	print("Picked up!")
	Game:gainHealth()
	self.scene:playSFX(self.SFX.pickedup)
	Heart.super.onPickedUp(self)
end
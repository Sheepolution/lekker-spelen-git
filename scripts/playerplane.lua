PlayerPlane = Player:extend("PlayerPlane")

PlayerPlane.bulletPositions = {-20, -10, 0, 10, 20}


function PlayerPlane:new(...)
	PlayerPlane.super.new(self, ...)

	self.shootTimer = step.new(0.1)
	self.platformer = false

	self.inControl = false

end


-- function PlayerPlane:update(dt)

-- 	PlayerPlane.super.update(self, dt)
-- end


function PlayerPlane:inputs(dt)
	if self.dead then return end
	self:stopMoving()
	if self.inControl then
		if Key:isDown(unpack(self.keys.right)) then
			self:moveRight(self.speed * AXIS[self.player_id].x)
		elseif Key:isDown(unpack(self.keys.left)) then
			self:moveLeft(self.speed * AXIS[self.player_id].x)
		end

		if Key:isDown(unpack(self.keys.up)) then
			self:moveUp(self.speed * AXIS[self.player_id].y)
		elseif Key:isDown(unpack(self.keys.down)) then
			self:moveDown(self.speed * AXIS[self.player_id].y)
		end

		if self.shootTimer(dt) then
			if DATA.options.controller.singleplayer or Key:isDown(unpack(self.keys.shoot)) then
				self:shoot()
			end
		end
	end
end


function PlayerPlane:draw()
	PlayerPlane.super.draw(self)
end


function PlayerPlane:shoot()
	self.scene:playSFX(self.SFX.shoot)
	local b = PlaneBullet(self:right() - 20, self:centerY() + _.randomchoice(PlayerPlane.bulletPositions), self.id)
	self.scene:addEntity(b)
end

function PlayerPlane:getSkullPos()
	return self:getRelPos(2, -10)
end


function PlayerPlane:kill()
	PlayerPlane.super.kill(self)
	self.skullSprite.solid = 0
end
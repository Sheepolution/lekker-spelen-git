Enemy = Thing:extend("Enemy")

function Enemy:new(...)
	Enemy.super.new(self, ...)

	self.SFX.hurt = SFX("sfx/enemy_hurt")
	self.SFX.kill = SFX("sfx/destroy")

	self.z = ZMAP.Enemy

	self.floating = false
	self.bounceOffWalls = true
	self.walkOffPlatform = false

	self.nearingEndOfPlatform = false

	self.canGetSquashed = true
	self.euroSpawnAmount = 1
end


function Enemy:update(dt)
	if not self.floating and not self.walkOffPlatform then
		if self.nearingEndOfPlatform then
			self.velocity.x = -self.velocity.x
		end
	end
	Enemy.super.update(self, dt)
	self.nearingEndOfPlatform = true
end


function Enemy:draw()
	Enemy.super.draw(self)
end


function Enemy:onOverlap(e, mine, his)
	if e:is(Player) and his.solid then
		if self.jumpToKill then
			if self:fromAbove(his, mine) then
				self.scene:playSFX(self.SFX.hurt)
				self:kill()
				return false
			else
				self:onTouchPlayer()
			end
		else
			self:onTouchPlayer()
		end
	end

	if e.solid == 2 then
		if self.velocity.x < 0 and mine:left() > his:left() then
			self.nearingEndOfPlatform = false
		elseif self.velocity.x > 0 and mine:right() < his:right() then
			self.nearingEndOfPlatform = false
		end
	end

	return Enemy.super.onOverlap(self, e, mine, his)
end


function Enemy:kill()
	if not self.dead then

		self:stopMoving()
		self:setShader("rgb")
		self.anim:stop()

		Enemy.super.kill(self)
		self:event(function ()
			self:send("dirs", _.rgbdirs())
		end, 0.05, 6)
	end
end


function Enemy:destroy()
	for i=1,self.euroSpawnAmount do
		local euro = Euro(self.x, self.y, true)
		euro:center(self:center())
		self.scene:addEntity(euro)
	end
	Enemy.super.destroy(self)
end


function Enemy:onTouchPlayer()

end
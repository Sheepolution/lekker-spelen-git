Projectile = Thing:extend("Projectile")

function Projectile:new(...)
	Projectile.super.new(self, ...)
	
	self:addIgnoreOverlap(Projectile)

	self.gravity = 0

	self.floating = true

	self.destroyOutsideScreen = true
end


function Projectile:update(dt)
	if self.destroyOutsideScreen then
		--TODO: Make this outside of map instead of outside of screen
		if self:right() < -100 or self.y < -100 or self.y > HEIGHT + 100 or self.x > WIDTH + 100 then
			self:destroy()
		end
	end
	Projectile.super.update(self, dt)
end


function Projectile:draw()
	Projectile.super.draw(self)
end
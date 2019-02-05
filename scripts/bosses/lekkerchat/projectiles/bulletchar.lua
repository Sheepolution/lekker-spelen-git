local BulletChar = Projectile:extend("BulletChar")

BulletChar.xSpeed = 400

function BulletChar:new(...)
	BulletChar.super.new(self, ...)

	self:addIgnoreOverlap(BulletChar, LekkerChat)
	
	self.autoFlip.x = false
	self.solid = 0
	self.velocity.x = -600
	self.gravity = 0
	self.z = 10

	self.damaging = true
end


function BulletChar:update(dt)

	BulletChar.super.update(self, dt)
end


function BulletChar:draw()
	BulletChar.super.draw(self)
end

return BulletChar
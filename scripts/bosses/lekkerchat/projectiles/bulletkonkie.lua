local BulletKonkie = Projectile:extend("BulletKonkie")

function BulletKonkie:new(x, y, angle)
	BulletKonkie.super.new(self, x, y)
	self:setImage("bosses/lekkerchat/konkie")

	self.solid = 0
	self:addIgnoreOverlap(LekkerChat, SolidTile)

	self.autoFlip.x = false
	self.speed = 700
	self.velocity.x = -self.speed
	
	self.damaging = true

	self.scale:set(0)
	self.flux:to(self.scale, 0.3, {x = 1, y = 1})
end


function BulletKonkie:update(dt)
	BulletKonkie.super.update(self, dt)
end


function BulletKonkie:draw()
	BulletKonkie.super.draw(self)
end

return BulletKonkie
local BulletTear = Projectile:extend("BulletTear")

function BulletTear:new(x, y, dir)
	BulletTear.super.new(self, x, y)
	self:setImage("bosses/emotilord/tear")

	self.dir = dir
	self.velocity.x = _.random(230, 600) * dir
	self.rotate = 1 * dir
	self.angleOffset = PI * -dir
	self.velocity.y = _.random(-300, -500)

	self.gravity = Thing.gravity

	self.floating = false

	self.damaging = true

	self.pixelChance = .5
end


function BulletTear:update(dt)
	BulletTear.super.update(self, dt)
end


function BulletTear:draw()
	BulletTear.super.draw(self)
end


function BulletTear:onOverlap(e, mine, his)
	if e:is(SolidTile) then
			self:kill()
	end
	return BulletTear.super.onOverlap(self, e, mine, his)
end

return BulletTear
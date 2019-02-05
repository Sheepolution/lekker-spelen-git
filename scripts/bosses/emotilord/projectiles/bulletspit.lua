BulletSpit = Projectile:extend("BulletSpit")

function BulletSpit:new(x, y, dir, count)
	BulletSpit.super.new(self, x, y)
	self:setImage("bosses/emotilord/spit")
	
	self.velocity.x = _.random(0, 400) * dir
	self.velocity.y = -700

	self.gravity = Thing.gravity

	self.floating = false

	self.scale:set(0.5)
	self.flux:to(self.scale, 1.5, {x = 1, y = 1})

	self.autoFlip.x = false
	self.autoAngle = true

	self.damaging = true
	-- self.rotate = dir
end


function BulletSpit:update(dt)
	BulletSpit.super.update(self, dt)
end


function BulletSpit:draw()
	BulletSpit.super.draw(self)
end


function BulletSpit:onOverlap(e, mine, his)
	if e:is(SolidTile) then
			self:kill()
	end
	return BulletSpit.super.onOverlap(self, e, mine, his)
end


function BulletSpit:kill()
	self.autoAngle = false
	BulletSpit.super.kill(self)
end
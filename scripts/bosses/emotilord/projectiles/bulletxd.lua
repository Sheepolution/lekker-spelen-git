local BulletXD = Thing:extend("BulletXD")

function BulletXD:new(x, y, dir)
	BulletXD.super.new(self, x, y)
	self:setImage("bosses/emotilord/lekkerxd", 4)
	self.anim:add("idle")

	self.bouncing = _.coin()
	self.dir = dir
	self.velocity.x = 200 * dir
	self.rotate = 5 * dir

	self.SFX.bounce = SFX("sfx/xd_bounce")

	self.firstBounce = false

	if self.bouncing then
		self.bounce.y = 1
	else
		self.bounce.y = 0.6
	end

	self.scale:set(0)
	self.flux:to(self.scale, 0.5, {x=1, y=1})

	self.damaging = true
end


function BulletXD:update(dt)
	BulletXD.super.update(self, dt)
end


function BulletXD:draw()
	BulletXD.super.draw(self)
end


function BulletXD:onOverlap(e, mine, his)
	if e:is(SolidTile) then
		if self:fromRight(mine, his) or self:fromLeft(mine, his) then
			self:kill()
		end
	end
	return BulletXD.super.onOverlap(self, e, mine, his)
end


function BulletXD:onGrounding()
	BulletXD.super.onGrounding(self)
	if not self.firstBounce then
		self.firstBounce = true
		self.scene:playSFX(self.SFX.bounce)
	end
end

return BulletXD
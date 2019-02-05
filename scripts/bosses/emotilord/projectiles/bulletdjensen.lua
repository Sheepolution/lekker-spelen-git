local BulletDjensen = Thing:extend("BulletDjensen")

function BulletDjensen:new(x, y, dir)
	BulletDjensen.super.new(self, x, y)
	self:setImage("bosses/emotilord/djensen")

	self.SFX.bounce = SFX("sfx/frog_bounce")

	self.velocity.x = _.signbool(dir) and -700 or 400
	self.velocity.y = -_.random(400, 550)

	self.damaging = true

	self.angleTimer = step.new(0.5)

	self.bounce:set(1)
end


function BulletDjensen:done()
	BulletDjensen.super.done(self)
end


function BulletDjensen:update(dt)
	if self.angleTimer(dt) then
		self.angle = _.random(-.3, .3)
	end
	BulletDjensen.super.update(self, dt)
end


function BulletDjensen:draw()
	BulletDjensen.super.draw(self)
end


function BulletDjensen:onGrounding()
	BulletDjensen.super.onGrounding(self)
	self.scene:playSFX(self.SFX.bounce)
end


return BulletDjensen
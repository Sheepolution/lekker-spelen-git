Frog = Enemy:extend("Frog")

function Frog:new(...)
	Frog.super.new(self, ...)
	self:setImage("enemies/lekker_djensen")

	self.SFX.bounce = SFX("sfx/frog_bounce")

	self.startX = self.x

	self.velocity.y = -600 * _.scoin()
	self.velocity.x = 100 * _.scoin()
	self.bounce.y = 1

	self.flip.x = true
	self.floating = true
	self.damaging = true
	self.jumpToKill = true
end


function Frog:update(dt)
	if self.x < self.startX - 100 then
		self.x = self.startX - 100
		self.velocity.x = -self.velocity.x
	end

	if self.x > self.startX + 100 then
		self.x = self.startX + 100
		self.velocity.x = -self.velocity.x
	end
	if not self.dead then
		self.velocity.y = _.sign(self.velocity.y) * 500
	end
	Frog.super.update(self, dt)
end


function Frog:draw()
	Frog.super.draw(self)
end


function Frog:onSeparate(...)
	Frog.super.onSeparate(self, ...)
	self.angle = _.random(-.3, .3)


	-- self.scene:playSFX(self.SFX.bounce)
end
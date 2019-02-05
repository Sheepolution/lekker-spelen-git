Spit = Projectile:extend("Spit")

function Spit:new(x, y, dir)
	Spit.super.new(self, x, y)
	self:setImage("projectiles/lekker_rochel", 3)
	self.anim:add("idle", {1,2}, 8, "once")

	self.hitbox = self:addHitbox("solid", self.width * .75, self.height * .75)

	self:center(x, y)

	self.velocity.x = dir * 400
	self.gravity = 100

	self.destroyOutsideScreen = false

	self.pixelChance = 15

	self.damaging = true

	self.timer = 0
end


function Spit:update(dt)
	self.timer = self.timer + dt
	if self.timer > 1 then
		self:kill()
	end
	Spit.super.update(self, dt)
end


function Spit:draw()
	Spit.super.draw(self)
end


function Spit:onOverlap(e, mine, his)
	if his.solid  then
		if e.solid == 2 or e:is(Player) then
			self:kill()
		end
	end
end
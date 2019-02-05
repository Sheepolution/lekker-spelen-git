PlaneBullet = Projectile:extend("PlaneBullet")

function PlaneBullet:new(x, y, id)
	PlaneBullet.super.new(self, x, y)
	self:setImage("projectiles/plane_bullet", 2)
	self.anim:add("a", id == "peter" and 1 or 2)
	self.velocity.x = 1000
	self.hitbox = self:addHitbox("solid")
	self.hitbox.auto = false
end


function PlaneBullet:update(dt)
	if self.x > WIDTH + 100 then
		self:destroy()
	end

	local boss = self.scene:findEntityOfType(LekkerChat)

	if boss then
		if self:overlaps(boss, "solid") then
			self:destroy()
			boss:hit()
		end
	end

	PlaneBullet.super.update(self, dt)
end


function PlaneBullet:draw()
	PlaneBullet.super.draw(self)
end

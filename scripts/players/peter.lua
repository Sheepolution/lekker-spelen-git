Peter = Player:extend("Peter")

function Peter:new(...)
	Peter.super.new(self, ...)
	self:setImage("peter", 23)
	self.anim:add("run", "16>23")
	self.anim:add("idle", "1>15")
	self.anim:add("jump", {23,16}, nil, "once")
	self.anim:add("fall", 16)

	self.keys = {
		left = "left",
		right = "right",
		jump = "up",
		teleport = "down",
	}

	self.teleportOffset = -10

	self.hitbox = self:addHitbox("solid", 20, self.height * .9)
	self.teleportHitbox = self:addHitbox("teleport", 0, self.teleportOffset, self.width * .75, self.height)
	self.teleportHitbox.solid = false
end


function Peter:update(dt)

	Peter.super.update(self, dt)
end


function Peter:draw()
	Peter.super.draw(self)
end
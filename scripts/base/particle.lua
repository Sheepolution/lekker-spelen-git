local Particle = Entity:extend()

function Particle:new(x, y, flags)
	Particle.super.new(self, x, y)
	self.timer = 0
	if flags then
		for k,v in pairs(flags) do
			self[k] = v
		end
	end
	if self.maxSpeed then
		local speed = lume.random(self.minSpeed or 0, self.maxSpeed)
		if self.circleSpread then
			self.angle = math.random(TAU)
			self:moveToAngle(speed)
		end
	end
end


function Particle:update(dt)
	self:onUpdate(dt)
end


function Particle:onUpdate(dt)
	Particle.super.update(self, dt)
	self.timer = self.timer + dt

	if self.lifespan then
		self.lifespan = self.lifespan - dt
		if self.lifespan <= 0 then
			self:destroy()
		end
	end

	if self.alphaSpeed then
		self.alpha = self.alpha - self.alphaSpeed * dt
		if self.alpha <= 0 then
			self.alpha = 0
			self:destroy()
		end
	end

	if self.scaleSpeed then
		self.scale.x = self.scale.x + self.scaleSpeed * dt
		self.scale.y = self.scale.y + self.scaleSpeed * dt
		if self.scale.x <= 0 then
			self.scale.x = 0
			self:destroy()
		end
	end
end


function Particle:__tostring()
	return lume.tostring(self, "Particle")
end

-----------------------
Particles = {}

Particles.death = function (x, y, tox, toy)
	local self = Particle(x, y)
	self:setImage("particles/twitch_pixel", 3)
	self.anim:add("size", math.random(1,2))

	self.scale:set(0)
	self.flux:to(self.scale, 0.3, {x = 1, y = 1})
	self.flux:to(self, Player.teleportTime, {x=tox, y=toy})
	:delay(_.random(0.05, .2))
	:after(self.scale, 0.3, {x = 0, y = 0})
	:oncomplete(function () self:destroy() end)
	return self
end

Particles.finger = function (x, y)
	local self = Particle(x, y)
	self:setImage("particles/twitch_pixel", 3)
	self.anim:add("size", math.random(1,2))
	self.xoff = math.random(1, 20)
	self.yoff = math.random(1, 20)
	self.speed = math.random(8, 12)/10
	self.timer = math.random(1, 10)
	self.solid = 1

	function self:update(dt)
		self.offset.x = math.sin(self.timer * 6 * self.speed) * (17 + self.xoff)
		self.offset.y = math.cos(self.timer * 3 * self.speed) * (5 + self.yoff)
		self:onUpdate(dt)
	end


	return self
end



local confetti_colors = {
	{255, 0, 0},
	{255, 255, 0},
	{255, 0, 255},
	{255, 255, 255},
	{0, 255, 255},
	{0, 255, 0},
	{0, 0, 255}
}


Particles.confetti = function (x, y)
	local self = Particle(x, y)
	self.width = 1
	self.height = 3

	self.color = _.randomchoice(confetti_colors)

	self.startY = y

	self.solid = 0

	self.lifespan = _.random(1.3, 1.8)

	self.velocity.y = -_.random(200, 300)
	self.velocity.x = _.random(140) * _.scoin()

	self.maxheight = _.random(50, 70)

	function self:update(dt)
		self.visible = _.chance(50)
		if self.y < self.startY - self.maxheight then
			self.velocity.y = _.random(30, 50)
			self.velocity.x = 0
		end
		self:onUpdate(dt)
	end

	return self
end


return Particle
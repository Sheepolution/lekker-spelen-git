RichardFingerLaser = Thing:extend("RichardFingerLaser")

function RichardFingerLaser:new(x, y)
	RichardFingerLaser.super.new(self, x, y)
	self.width = 30
	self.height = 30
	self:addHitbox("solid")

	self.gravity = 0
	self.speed = 800

	self.particles = buddies.new()
	for i=1,50 do
		local p = Particles.finger()
		self.particles:add(p)
		p.visible = false
		self.tick:delay(i/30, function () p.visible = true end)
	end

	self.damaging = true
end


function RichardFingerLaser:update(dt)
	self.particles:update(dt)
	RichardFingerLaser.super.update(self, dt)
end


function RichardFingerLaser:draw()
	self.particles:drawAsChild(self, {"visible", "offset"}, false)
end


function RichardFingerLaser:moveTo(target)
	self:moveToEntity(target)
end


function RichardFingerLaser:onOverlap(e, mine, his)

	if e:is(SolidTile) then
		local bips = Bips(self.x, self.y)
		self.scene:addEntity(bips)
		bips:spawn()
		bips.flip.x = self.velocity.x < 0
		self:destroy()
	end

	return RichardFingerLaser.super.onOverlap(self, e, mine, his)
end

	-- function self:onOverlap(e, mine, his)
	-- 	if e:is(SolidTile) then
	-- 		local bips = self.scene:addEntity(Bips(self.x, self.y))
	-- 		-- bips:spawn()
	-- 		self:destroy()
	-- 	end
	-- 	return self.super.onOverlap(self, e, mine, his)
	-- end
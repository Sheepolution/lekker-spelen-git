NoiseBlock = Thing:extend("NoiseBlock")

function NoiseBlock:new(...)
	NoiseBlock.super.new(self, ...)
	self:setImage("levelprops/noiseblock")
	self.gravity = 0
	self:addShader("noise", "rgb", "tvnoise")
	self.origin:set(0)

	self.moves = false
	self.solid = 0
	self.z = ZMAP.NoiseBlock

	self.killOnTouch = true
end


function NoiseBlock:done()
	self.width, self.height = self.mapObject.width, self.mapObject.height
	self.columns = self.width/32
	self.rows = self.height/32
	self.scale.x = self.columns
	self.scale.y = self.rows

	self:clearHitboxes()
	self.hitbox = self:addHitbox("solid", self.width, self.height)
end

function NoiseBlock:update(dt)
	NoiseBlock.super.update(self, dt)
	self.color = {math.random(255), math.random(255), math.random(255)}
end


function NoiseBlock:draw()
	self:setShader("noise")
	self:send("tvnoise_rnd", math.random())
	self.alpha = 1
	NoiseBlock.super.draw(self)
	self:setShader()
	self.alpha = .5
	self.color = {math.random(255), math.random(255), math.random(255)}
	NoiseBlock.super.draw(self)
end

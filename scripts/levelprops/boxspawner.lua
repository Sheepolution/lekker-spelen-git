BoxSpawner = Thing:extend("BoxSpawner")

function BoxSpawner:new(...)
	BoxSpawner.super.new(self, ...)
	self:setImage("levelprops/boxspawner")

	self.solid = 0
	self.gravity = 0
	self.canDie = false
	self.box = nil
end


function BoxSpawner:update(dt)
	BoxSpawner.super.update(self, dt)
end


function BoxSpawner:draw()
	BoxSpawner.super.draw(self)
end

	
function BoxSpawner:onTrigger()
	self:spawnBox()
end


function BoxSpawner:onOff()
end


function BoxSpawner:spawnBox()
	if self.box then
		self.box.canDie = true
		self.box:kill()
	end

	self.box = Box(self.x, self.y)
	self.scene:addEntity(self.box)
end
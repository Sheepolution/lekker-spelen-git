Block = Thing:extend("Block")

function Block:new(...)
	Block.super.new(self, ...)
	self:setImage("tiles",  2)
	self.anim:add("_", 1)
	self.moves = false
	self.gravity = 0
	self.solid = 0
end


function Block:update(dt)
	Block.super.update(self, dt)
end


function Block:draw()
	Block.super.draw(self)
end
require "pickupables/euro"
Papflap = Euro:extend("Papflap")

function Papflap:new(x, y, drop)
	Papflap.super.new(self, x, y)
	self:setImage("pickupables/papflap")
	self.timer = 0
end


function Papflap:update(dt)
	self.timer = self.timer + dt
	self.offset.y = math.sin( self.timer * PI * 1) * 10

	Papflap.super.update(self, dt)
end
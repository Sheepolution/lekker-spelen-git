Boss = Enemy:extend("Boss")

function Boss:new(...)
	Boss.super.new(self, ...)
	
end


function Boss:update(dt)
	Boss.super.update(self, dt)
end


function Boss:draw()
	Boss.super.draw(self)
end

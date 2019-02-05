Cube = Sprite:extend("Cube")

function Cube:new(x, y)
	print("wat")
	Cube.super.new(self, x, y)
	
end


function Cube:update(dt)
	Cube.super.update(self, dt)
end


function Cube:draw()
	Cube.super.draw(self)
end
local Circle = Point:extend()

function Circle:new(x, y, radius)
	Circle.super.new(self, x, y)
	self.radius = radius or 0
	self.thickness = 2
	self.color = {255, 255, 255}
	self.alpha = 1
end


function Circle:draw(mode, segments)
	love.graphics.setLineWidth(self.thickness)
	love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.alpha*255)
	love.graphics.circle(mode or self.mode or "fill", self.x, self.y, self.radius, self.segments or segments or 25)
	love.graphics.setColor(255, 255, 255)
	love.graphics.setLineWidth(2)
end


function Circle:set(x, y, radius)
	Circle.super.new(self, x, y)
	self.radius = radius
end


function Circle:get()
	return x, y, radius
end


function Circle:clone(c)
	Circle.super.clone(self, c)
	if c:is(Circle) then
		self.radius = c.radius
	elseif c:is(Rect) then
		self.radius = math.max(c.width, c.height)
	end
end


function Circle:overlaps(c)
	return math.sqrt((self.x - c.x)^2 + (self.y - c.y)^2) < self.radius/2 + (c.radius or 0)/2
end


function Circle:overlapsX(c)
	if r:is(Circle) then
		return self.x - self.radius/2 < c.x + c.radius/2 
		and self.x + self.radius/2 > c.x - c.radius/2
	else
		return self.x - self.radius/2 < c.x + (c.width or 0)
		and self.x + self.radius/2 > c.x
	end
end


function Circle:overlapsY(r)
	if r:is(Circle) then
		return self.y - self.radius/2 < c.y + c.radius/2 
		and self.y + self.radius/2 > c.y - c.radius/2
	else
		return self.y - self.radius/2 < c.y + (c.width or 0)
		and self.y + self.radius/2 > c.y
	end
end


function Circle:left(val)
	if val then self.x = val + self.radius/2 end
	return self.x - self.radius/2
end


function Circle:right(val)
	if val then self.x = val - self.radius/2 end
	return self.x + self.radius/2
end


function Circle:top(val)
	if val then self.y = val + self.radius/2 end
	return self.y - self.radius/2
end


function Circle:bottom(val)
	if val then self.y = val - self.radius/2 end
	return self.y + self.radius/2
end


function Circle:centerX(val)
	if val then self.x = val end
	return self.x
end


function Circle:centerY(val)
	if val then self.y = val end
	return self.y
end


function Circle:_str()
	return "x: " .. self.x .. ", y: " .. self.y .. ", radius: " .. self.radius
end


function Circle:__tostring()
	return lume.tostring(self, "Circle")
end

return Circle
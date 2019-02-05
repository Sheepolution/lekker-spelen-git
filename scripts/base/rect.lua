local Rect = Point:extend()

function Rect:new(x, y, width, height)
	Rect.super.new(self, x, y)
	self.width = width or 0
	self.height = height == nil and self.width or height
	self.color = {255, 255, 255}
	self.alpha = 1
end


function Rect:draw(mode, x, y, width, height)
	love.graphics.setColor(self.color[1]/255, self.color[2]/255, self.color[3]/255, self.alpha)
	love.graphics.rectangle(mode or self.mode or "fill", self.x, self.y, self.width, self.height, self.radius or 0)
	love.graphics.setColor(1, 1, 1, 1)
end


function Rect:drawAsChild(p)
	local parent = p or self.parent
	assert(parent, "Please assign a parent", 2)
	if parent then
		love.graphics.translate(parent.x, parent.y)
		self:draw()
		love.graphics.translate(-parent.x, -parent.y)
	end
end


function Rect:setColor(r, g, b)
	self.color = {r, g, b}
end


function Rect:getColor()
	return unpack(self.color)
end


function Rect:set(x, y, width, height)
	Rect.super.set(self, x, y)
	self.width = width or self.width
	self.height = height and height or width and width or self.height
end


function Rect:get()
	return self.x, self.y, self.width, self.height
end


function Rect:clone(r)
	Rect.super.clone(self, r)
	if r:is(Rect) then
		self.width = r.width
		self.height = r.height
	end
end


--If rect overlaps with rect or point
function Rect:overlaps(r)
	return  self.x + self.width > r.x and
			self.x < r.x + (r.width or 0) and
			self.y + self.height > r.y and
			self.y < r.y + (r.height or 0)
end


function Rect:overlapsX(r)
	return  self.x + self.width > r.x and
			self.x < r.x + (r.width or 0)
end


function Rect:overlapsY(r)
	return  self.y + self.height > r.y and
			self.y < r.y + (r.height or 0)
end


function Rect:insideOf(r)
	return  self.x > r.x and
			self.x + self.width < r.x + (r.width or 0) and
			self.y > r.y and
			self.y + self.height < r.y + (r.height or 0)
end


function Rect:left(val)
	if val then self.x = val end
	return self.x
end


function Rect:right(val)
	if val then self.x = val - self.width end
	return self.x + self.width
end


function Rect:top(val)
	if val then self.y = val end
	return self.y
end


function Rect:bottom(val)
	if val then self.y = val - self.height end
	return self.y + self.height
end


function Rect:centerX(val)
	if val then self.x = val - self.width / 2 end
	return self.x + self.width / 2
end


function Rect:centerY(val)
	if val then self.y = val - self.height / 2 end
	return self.y + self.height / 2
end


function Rect:center(_x, _y)
	if _x then self.x = _x - self.width / 2 end
	if _y then self.y = _y - self.height / 2 end
	return self.x + self.width / 2, self.y + self.height / 2
end


function Rect:getDistance(r)
	local x1, y1 = self:centerX(), self:centerY()
	local x2 = r:is(Rect) and r:centerX() or r.x
	local y2 = r:is(Rect) and r:centerY() or r.y

	return lume.distance(self.x + self.width / 2, self.y + self.height / 2, r.x + (r.width and r.width / 2 or 0), r.y + (r.height and r.height / 2 or 0))
end


function Rect:getDistanceX(r)
	local x1, y1 = self:centerX()
	local x2 = r:is(Rect) and r:centerX() or r.x

	return math.abs((self.x + self.width / 2) - (r.x + (r.width and r.width / 2 or 0)))
end


function Rect:getDistanceY(r)
	local x1, y1 = self:centerY()
	local x2 = r:is(Rect) and r:centerY() or r.y

	return math.abs((self.y + self.width / 2) - (r.y + (r.width and r.width / 2 or 0)))
end


function Rect:getAngle(r)
	local x1, y1 = self:centerX(), self:centerY()
	local x2 = r:is(Rect) and r:centerX() or r.x
	local y2 = r:is(Rect) and r:centerY() or r.y

	return _.angle(self.x + self.width / 2, self.y + self.height / 2, r.x + (r.width and r.width / 2 or 0), r.y + (r.height and r.height / 2 or 0))
end


function Rect:toCircle()
	self.radius = math.max(self.width, self.height)
	self.thickness = 2
	self.draw = Circle.draw 
	self.set = Circle.set 
	self.get = Circle.get 
	self.clone = Circle.clone 
	self.overlaps = Circle.overlaps 
	self.left = Circle.left 
	self.right = Circle.right 
	self.top = Circle.top 
	self.bottom = Circle.bottom 
	self.centerX = Circle.centerX 
	self.centerY = Circle.centerY

	self.width = nil
	self.height = nil
end


function Rect:__tostring()
	return lume.tostring(self, "Rect")
end

return Rect
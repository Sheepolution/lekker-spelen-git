local Mouse = require("base.input"):extend()

Mouse:implement(Point)

function Mouse:new()
	Mouse.super.new(self)
	self.x = love.mouse.getX()
	self.y = love.mouse.getY()
	self.cursor = nil
end


function Mouse:update()
	local x, y = love.mouse.getPosition()
	x, y = toGameCoords(x, y)
	self.x = x
	self.y = y
	self.cursor = nil
end


function Mouse:isDown(...)
	return lume.any({...}, function (a) return self._custom[a] and lume.any(self._custom[a], function (b) return love.mouse.isDown(b) end) end)
end


function Mouse:draw()
	love.graphics.circle("fill",self.x, self.y, 5, 25)
end


function Mouse:setCursor(cursor)
	self.cursor = cursor
end


function Mouse:reset()
	Mouse.super.reset(self)
	local current = love.mouse.getCursor()
	if current == self.cursor then
		return
	else
		love.mouse.setCursor(self.cursor)
	end
end


function Mouse:grab()
	love.mouse.setGrabbed(true)
end


function Mouse:release()
	love.mouse.setGrabbed(false)
end


function Mouse:_str()
	return "x: " .. self.x .. ", y: " .. self.y
end


function Mouse:__tostring()
	return lume.tostring(self, "Mouse")
end


function Mouse:is(a)
	return a == Mouse or a == Point
end

return Mouse
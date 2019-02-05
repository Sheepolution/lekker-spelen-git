local HCbox = Object:extend()

local Hitbox = require "base.hitbox"

function HCbox:new(p, n, x, y, w, h, proptype)
	self.parent = p
	self.name = n
	self.x = x
	self.y = y
	self.width = w
	self.height = h
	self.box = HC.rectangle(x, y, w, h)
	if proptype then
		for k,v in pairs(Hitbox.propTypes[proptype]) do
			self[k] = v
		end
	else
		self.solid = true
		self.weakness = false
		self.damaging = false
	end
end


function HCbox:update(dt)
	self.box:setRotation(self.parent.angle + self.parent.angleOffset)
	local x, y
	if self.parent.planet then
		x, y = self.parent:getPositionCoords(self.x, self.y)
	else
		x, y = self.parent:centerX(), self.parent:centerY()
	end 
	self.box:moveTo(x, y)
end


function HCbox:draw()
	love.graphics.setColor(0, 100, 200, 100)
	love.graphics.setLineWidth(0.5)
	self.box:draw("line")
	love.graphics.setColor(255, 255, 255)
end


function HCbox:kill()
	HC.remove(self.box)
end


function HCbox:overlaps(e)
	if DEBUG then Debug.add("collision") end
	return self.box:collidesWith(e.box)
end


function HCbox:set(x, y , width, height)
	HC.remove(self.box)
	self.box = HC.rectangle(x, y, width, height)
end


function HCbox:__tostring()
	return lume.tostring(self, "HCbox")
end

return HCbox
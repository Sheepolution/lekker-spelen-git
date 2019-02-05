local gamera = require "libs/gamera"

local Camera = Point:extend()

function Camera:new(x, y, w, h)
	Camera.super.new(self)
	self.cam = gamera.new(x, y, w, h)
	
	self.follow = Mouse
	self.followLock = true
	self.followSpeed = 5
	self.basedOnDistance = true

	self.velocity = Point()

	self.rotate = false
	self.rotateLock = false
	self.baseAngle = 0

	self.angle = self.cam:getAngle()

	self.zoom = 1
	self:zoomTo(1)
	self:set(0)
end


function Camera:update(dt)
	self.angle = self.cam:getAngle()
	if self.follow then
		local x, y
		if self.follow.centerX then
			x, y = self.follow:centerX(), self.follow:centerY()
		else
			x, y = self.follow:getX(), self.follow:getY()
		end

		if self.followLock then
			self.x = x
			self.y = y
		else
			self.x = x
			self.y = y
			--TODO: LERP!
		end

		if self.rotate and self.follow.angle then
			local follow_angle = self.follow.angle + (self.follow.angleOffset or 0)
			if self.rotateLock then
				self.angle = follow_angle
			else
				self.angle = lume.rotate(self.angle, follow_angle, dt * 2)
				self.rotateLock = self.angle == follow_angle
			end
		end
	end

	if not self.rotate then
		if self.rotateLock then
			self.angle = self.baseAngle
		else
			self.angle = lume.rotate(self.angle, self.baseAngle, dt * 2)
		end
	end
	
	self.width, self.height = love.graphics.getDimensions()

	self.cam:setPosition(self.x, self.y)
	self.cam:setAngle(self.angle)
	self.cam:setScale(self.zoom)
end


function Camera:draw(f)
	self.cam:draw(f)
end


function Camera:setRotate(r, lock)
	self.rotate = r
	self.rotateLock = lock
end


function Camera:setAngle(a)
	self.angle = a
	self.cam:setAngle(a)
end


function Camera:setPosition(x, y)
	self.x, self.y = x, y
	self.cam:setPosition(x, y)
end


function Camera:getTruePosition()
	return self.cam:getPosition(x, y)
end


function Camera:setFollow(f)
	self.follow = f
end


function Camera:zoomTo(zoom)
	self.zoom = zoom
end


function Camera:zoomIn(amount)
	self.zoom = self.zoom + (amount or 0.1)
end


function Camera:zoomOut(amount)
	self.zoom = self.zoom - (amount or 0.1)
end


function Camera:getZoom()
	return self.cam:getScale()
end


function Camera:__tostring()
	return lume.tostring(self, "Camera")
end

return Camera
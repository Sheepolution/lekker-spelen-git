local Box = Rect:extend()

function Box:new(x, y, w, h)
	Box.super.new(self, x, y, w, h)
	self.corners = Sprite(0, 0, "textbox/corners", 9, 9)
	self.corners.anim:add("topleft", 1)
	self.corners.anim:add("bottomleft", 2)
	self.corners.anim:add("topright", 3)
	self.corners.anim:add("bottomright", 4)
end
	

function Box:draw()
	self:drawBackground()
	self:drawForeground()
end


function Box:drawBackground()
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end


function Box:drawForeground()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle("line", self.x + 3, self.y + 3, self.width - 6, self.height - 6)
	self.corners.x = self.x
	self.corners.y = self.y
	self.corners.anim:set("topleft")
	self.corners:draw()
	self.corners.anim:set("topright")
	self.corners.x = self.x + self.width - self.corners.width
	self.corners:draw()
	self.corners.anim:set("bottomright")
	self.corners.y = self.y + self.height - self.corners.height
	self.corners:draw()
	self.corners.anim:set("bottomleft")
	self.corners.x = self.x
	self.corners:draw()
end


function Box:__tostring()
	return lume.tostring(self, "Box")
end

return Box
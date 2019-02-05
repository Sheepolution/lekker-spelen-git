HangLogo = Thing:extend("HangLogo")

function HangLogo:new(x, y, t)
	HangLogo.super.new(self, x, y)
	self:setImage("lekkerlogo2")
	self.spelen = true
	self.timer = 0
	self.startX = self.x
	self.z = 1000
	self.gravity = 0
end


function HangLogo:done()
	if self.lekker then
		self.spelen = false
		self:setImage("lekkerlogo1")
		self.timer = 6
	end
end


function HangLogo:update(dt)
	self.timer = self.timer + dt
	if self.spelen then
		self.x = self.startX + math.sin(self.timer * PI * .5) * 10
	end
	HangLogo.super.update(self, dt)
end


function HangLogo:draw()
	love.graphics.setColor(.3, .3, .3)
	love.graphics.line(self.startX + self.width/2, 100, self:centerX(), self:centerY())
	love.graphics.setColor(1, 1, 1)
	HangLogo.super.draw(self)
end
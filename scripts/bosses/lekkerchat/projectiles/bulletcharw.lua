local BulletChar = require "bosses/lekkerchat/projectiles/bulletchar"
local BulletCharW = BulletChar:extend("BulletCharW")

function BulletCharW:new(...)
	BulletCharW.super.new(self, ...)
	self:setImage("bosses/lekkerchat/char_w")

	self.velocity.x = -BulletChar.xSpeed
	self.startY = self.y
	self.timer = 0
	self.dir = _.coin()
end


function BulletCharW:update(dt)
	self.timer = self.timer + dt
	self.y = self.startY + math.sin(self.timer * PI) * (self.dir and 200 or -200)
	BulletCharW.super.update(self, dt)
end


function BulletCharW:draw()
	BulletCharW.super.draw(self)
end

return BulletCharW
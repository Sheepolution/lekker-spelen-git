local BulletChar = require "bosses/lekkerchat/projectiles/bulletchar"
local BulletCharDollar = BulletChar:extend("BulletCharDollar")

function BulletCharDollar:new(...)
	BulletCharDollar.super.new(self, ...)
	self:setImage("bosses/lekkerchat/char_dollar")
	
	self.accel.x = 300
	self.velocity.x = -BulletChar.xSpeed * 1.5
	local dir = _.boolsign(_.coin())
	self.rotate = dir
	local velocity = _.random(30, 60)
	self.velocity.y = velocity * dir
	self.timer = 0
end


function BulletCharDollar:update(dt)
	BulletCharDollar.super.update(self, dt)
end


function BulletCharDollar:draw()
	BulletCharDollar.super.draw(self)
end

return BulletCharDollar
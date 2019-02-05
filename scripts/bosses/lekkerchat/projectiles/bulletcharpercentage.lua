local BulletChar = require "bosses/lekkerchat/projectiles/bulletchar"
local BulletCharPercentage = BulletChar:extend("BulletCharPercentage")

BulletCharPercentage.ySpeed = 400

function BulletCharPercentage:new(x, y, part)
	BulletCharPercentage.super.new(self, x, y)

	if part then
		self.isPart = true
		self:setImage("bosses/lekkerchat/char_percentage_part")
		self.velocity.x = 0
		if part == "up" then
			self.velocity.y = -BulletCharPercentage.ySpeed
		else
			self.velocity.y = BulletCharPercentage.ySpeed
		end
	else
		self:setImage("bosses/lekkerchat/char_percentage")
	end
end


function BulletCharPercentage:update(dt)
	if not self.isPart then
		if self.x < 35 then
			self.scene:addEntity(BulletCharPercentage(self.x, self.y, "up"))
			self.scene:addEntity(BulletCharPercentage(self.x, self.y, "down"))
			self:destroy()
		end
	end
	BulletCharPercentage.super.update(self, dt)
end


function BulletCharPercentage:draw()
	BulletCharPercentage.super.draw(self)
end

return BulletCharPercentage
local BulletChar = require "bosses/lekkerchat/projectiles/bulletchar"
local BulletCharGT = BulletChar:extend("BulletCharGT")

function BulletCharGT:new(x, y, part)
	BulletCharGT.super.new(self, x, y)

	if part then
		self.isPart = true
		self:setImage("bosses/lekkerchat/char_gt_part")
		if part == "up" then
			self.velocity.y = -100
		else
			self.flip.y = true
			self.velocity.y = 100
		end
	else
		self:setImage("bosses/lekkerchat/char_gt")
	end


	self.velocity.x = -BulletChar.xSpeed
	self.timer = 0
end


function BulletCharGT:update(dt)
	if not self.isPart then
		self.timer = self.timer + dt

		if self.timer > 0.6 then
			self.scene:addEntity(BulletCharGT(self.x, self.y, "up"))
			self.scene:addEntity(BulletCharGT(self.x, self.y, "down"))
			self:destroy()
		end
	end
	BulletCharGT.super.update(self, dt)
end


function BulletCharGT:draw()
	BulletCharGT.super.draw(self)
end

return BulletCharGT
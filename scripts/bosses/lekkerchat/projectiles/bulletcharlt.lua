local BulletChar = require "bosses/lekkerchat/projectiles/bulletchar"
local BulletCharLT = BulletChar:extend("BulletCharLT")

function BulletCharLT:new(...)
	BulletCharLT.super.new(self, ...)
	self:setImage("bosses/lekkerchat/char_gt")
	
	self.startY = self.y
	self.timer = 0
end


function BulletCharLT:done()
	BulletCharLT.super.done(self)
	local players = self.scene:findEntitiesOfType(Player)
	local target = _.randomchoice(players)
	self:moveToEntity(target, BulletChar.xSpeed, true)
end


function BulletCharLT:update(dt)
	self.timer = self.timer + dt
	BulletCharLT.super.update(self, dt)
end


function BulletCharLT:draw()
	BulletCharLT.super.draw(self)
end

return BulletCharLT
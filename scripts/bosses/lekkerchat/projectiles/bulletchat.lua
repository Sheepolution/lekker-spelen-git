BulletChat = Thing:extend("BulletChat")

function BulletChat:new(...)
	BulletChat.super.new(self, ...)
	self:setImage("bosses/lekkerchat/chats", 341, 22)
	self.anim:add("idle", math.random(1, self.anim:getNumberOfFrames()))

	self:addIgnoreOverlap(SolidTile)

	self.autoFlip.x = false
	self.solid = 0
	self.velocity.y = 150
	self.gravity = 0
	self.z = 10
	self.damaging = true
end


function BulletChat:update(dt)
	BulletChat.super.update(self, dt)
	if self.y > HEIGHT + 10 then
		self:destroy()
	end
end


function BulletChat:draw()
	BulletChat.super.draw(self)
end
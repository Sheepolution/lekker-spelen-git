Tongue = Enemy:extend("Tongue")
-- lekkerLikken

function Tongue:new(...)
	Tongue.super.new(self, ...)
	self:setImage("enemies/lekker_likken", 19)
	self.anim:add("idle", {1, 2}, 4)
	self.anim:add("attack", "9>19", nil, "once"):onComplete(function () self:walk() end)
	self.anim:add("walk", "3>8")

	self.SFX.lick = SFX("sfx/lick")

	self.speed = 130
	self:moveRight()
	self.bounce.x = 1

	self.hitbox = self:addHitbox("solid", 40, self.height)
	
	self.damaging = true
	self.jumpToKill = true
	self.timer = step.new({2, 6})
end


function Tongue:update(dt)
	if self.timer(dt) then
		self:attack()
	end
	Tongue.super.update(self, dt)
end


function Tongue:draw()
	Tongue.super.draw(self)
end


function Tongue:onTouchPlayer()
	self:attack()
	self.timer()
end

function Tongue:attack()
	self:stopMoving()
	if self.anim:is("walk") then
		self.scene:playSFX(self.SFX.lick)
	end
	self.anim:set("attack")
end

function Tongue:walk()
	self:moveToDirection()
	self.anim:set("walk")
end
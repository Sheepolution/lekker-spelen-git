Gier = Enemy:extend("Gier")

Gier:implement(Locator)

function Gier:new(...)
	Gier.super.new(self, ...)
	self:setImage("enemies/lekker_gier", 22)
	self.anim:add("finger", "2>22", nil, "once"):after("idle"):onComplete(function () self.hook.anim:set("hook") self.stealing = false end)
	self.anim:add("idle", 1)

	self.hitbox = self:addHitbox("solid", self.width * 3, 10)

	self.SFX.buy = SFX("sfx/buy")

	self.hook = Sprite(0, 0, "enemies/lekker_gier_hook", 5)
	self.hook.anim:add("money", "2>5")
	self.hook.anim:add("hook", 1)
	self.idleHookY = 30
	self.hook.y = self.idleHookY
	self.hook.x = self.width/2+2

	self.gravity = 0
	self.timer = 0
	self.baseY = self.y 

	self.speed = 100
	self.autoFlip.x = false
	self.canDie = false

	self.floating = true

	self.stealing = false
end


function Gier:update(dt)
	self:findTarget(Player, 600)

	self.hook:update(dt)

	self.timer = self.timer + dt
	self.y = self.baseY + math.sin(self.timer * PI) * 5
	Gier.super.update(self, dt)
end


function Gier:draw()
	Gier.super.draw(self)
	if self.anim:is("idle") then
		local startx, starty = self:getRelPos(23, -25)
		love.graphics.line(startx, starty, startx, starty + self.hook.y + self.height/2 - self.hook.height/2)
		self.hook:drawAsChild(self, {"flip"}, true)
	end
end


function Gier:onFindingTarget(target)
	if self.stealing then return end
	local distance = self:getDistanceX(target)
	if distance < 20 then self:stopMoving()  return end
	self:lookAt(target)
	self:moveToDirection()
end


function Gier:stealMoneyFromPlayer(player, shirt)
	self.scene:playSFX(self.SFX.buy)
	self.stealing = true
	self:stopMoving()
	self.flux:to(self, .5, {x = player:centerX()})
	:oncomplete(function () self.flip.x = true end)
	:after(self.hook, 1, {y = player:centerY() - self:centerY()})
	:oncomplete(function () self.hook.anim:set("money") Game:onBuyingShirt(player, shirt) end)
	:after(self.hook, 1, {y = self.idleHookY })
	:oncomplete(function () self.anim:set("finger") end)
end


function Gier:kill() end
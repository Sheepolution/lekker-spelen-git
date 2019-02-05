Spitter = Enemy:extend("Spitter")
-- lekkerSpugen

Spitter:implement(Locator)

function Spitter:new(...)
	Spitter.super.new(self, ...)
	self:setImage("enemies/lekker_spugen", 14)
	self.anim:add("idle", {1, 2}, 4)
	self.anim:add("attack", "9>14|14|14|14|14|14|14|14|14", 8, "once"):onFrame(4, function () self:spit() end):onComplete(function () self:walk() end)
	self.anim:add("walk", "3>8")

	self.SFX.spitStart = SFX("sfx/spit_start")
	self.SFX.spit = SFX("sfx/spit")

	self.speed = 130
	self:moveRight()
	self.bounce.x = 1

	self.damaging = true
	self.jumpToKill = true
	self.timer = step.new({2, 6})
end


function Spitter:update(dt)
	-- if self.timer(dt) then
	-- 	self:attack()
	-- end


	-- if not self.dead then
	-- 	local target, distance = self:findTarget()
	-- 	if target then
	-- 		if distance < 700 then
	-- 			self:lookAt(target)
	-- 			if target:isLookingAt(self) then
	-- 				self.anim:set("shy")
	-- 				self:stopMoving()
	-- 			else
	-- 				self.anim:set("attack")
	-- 				self:moveToEntity(target)
	-- 			end
	-- 		end
	-- 	end
	-- end

	Spitter.super.update(self, dt)
	self:findTarget(Player, 200)
end


function Spitter:draw()
	Spitter.super.draw(self)
end


function Spitter:onTouchPlayer()
	self:attack()
	self.timer()
end

function Spitter:attack()
	self:stopMoving()
	if self.anim:is("walk") then
		self.scene:playSFX(self.SFX.spitStart)
	end
	self.anim:set("attack")
end

function Spitter:walk()
	self:moveToDirection()
	self.anim:set("walk")
end

function Spitter:spit()
	local dir = _.boolsign(not self.flip.x)
	local x, y = self:getRelPos(5, -5)
	local spit = Spit(x, y, dir)
	self.scene:playSFX(self.SFX.spit)
	self.scene:addEntity(spit)
end

function Spitter:onFindingTarget(target)
	self:lookAt(target)
	self:clone(self.last)
	self:attack()
end
-- LekkerRichard
Richard = Boss:extend("Richard")

Richard.chargeTime = 2
Richard.floatHeight = 60
Richard.chokingDelay = 1
Richard.numberOfChokes = 5
Richard.peekHeight = 265
Richard.centerOfRoom = 90
Richard.introFloatHeight = 120
Richard.dabSpeed = 1000
Richard.dabHeight = -1100

function Richard:new(...)
	Richard.super.new(self, ...)

	self:setImage("bosses/richard/lekkerrichard", 5)
	self.anim:add("dab", 5)
	self.anim:add("charge", 2)
	self.anim:add("choke", 4)
	self.anim:add("idle", 1)
	self.anim:add("shoot", 3)

	self.SFX.choke = SFX("sfx/richard_choke_start")
	self.SFX.finger = SFX("sfx/finger_spawn")

	self.hitbox = self:addHitbox("solid", 0, 0)
	self.hitbox.auto = false
	self.peekBox = self:addHitbox("peek", 50, 0, 150, 100)
	self.peekBox.auto = false
	self.dabBox = self:addHitbox("dab", -40, 150, 100, 450)
	self.dabBox.damaging = true
	self.dabBox.auto = false

	self.gravity = 0
	self.timer = 0
	self.solid = 0
	self.z = 100
	self.solid = 0

	self.time = step.new(2, true)

	self.flip.x = true

	self.timer = 0
	self.floating = true

	self.dabCounter = 0
	self.choking = false

	self.floatingRight = false

	self.peeking = false
	self.peekCount = 0

	self.x = Richard.centerOfRoom
	self.y = Richard.introFloatHeight

	self.latestTween = nil

	self.glitching = 0

	self.jumpToKill = true

	self.beingDamaged = false

	self.dabIndicator = Sprite(0, 80, "bosses/richard/indicator")

	self.health = 3
	self.euroSpawnAmount = 10
	self.defeated = false

	self:addShader("superglitch", "teeth", "rgb")
	self:send("teeth_amount", .1)
	self:send("teeth_curves", 300)
	self:setShader()

	self.z = ZMAP.Richard
end


function Richard:update(dt)

	self.timer = self.timer + dt

	if self.floating then
		self.offset.y = math.sin(self.timer * PI * 1) * 10
	else
		self.timer = 0
	end

	if self.dabbing then
		self:handleDabbing()
		self.dabIndicator:centerX(self.target:centerX())
		if self:bottom() < -400 then
			self:centerX(self.target:centerX() + math.random(-50, 50))
		end
	end

	if self.glitching > 0 then
		if _.chance(2) then
			self:glitch()
		end
	end

	Richard.super.update(self, dt)
end


function Richard:draw()
	Richard.super.draw(self)
	if self.dabbing and self:bottom() < 0 then
		-- self.dabIndicator:draw()
	end
end


function Richard:startShooting()
	local tween

	self.floatLeft = not self.floatLeft

	if self.floatLeft then
		self.flip.x = false
		tween = self:tween(1, -242, self.y)
	else
		self.flip.x = true
		tween = self:tween(1, 408, self.y)
	end

	tween:oncomplete(function ()
		self.anim:set("charge")
		self.charging = true
		self.bullet = RichardFingerLaser(self:getFingerPosition())
		self.bullet:center(self:getFingerPosition())
		self.scene:addEntity(self.bullet)
		self.scene:playSFX(self.SFX.finger)
		self:delay(self.chargeTime, "shoot")
	end)
end


function Richard:shoot()
	self.charging = false
	self.anim:set("shoot")
	self.target = self.scene:getRandomPlayer()
	self.bullet:moveTo(self.target)
	self:delay(2, "startPeeking")
end


function Richard:getFingerPosition()
	return self:getRelPos(80, 10)
end


function Richard:startDabbing()
	-- TODO: Function that gives the center of the room
	self.dabCounter = 3
	self.anim:set("dab")
	self:tween(2, Richard.centerOfRoom, -self.height*2):delay(1)
	:oncomplete(_.wrap(self, "dab"))
	self.flip.x = false
	self.target = self.scene:getRandomPlayer()
end


function Richard:dab()
	self.y = Richard.dabHeight
	self.dabBox.auto = true
	self.floating = false
	self.angle = PI/2
	self.velocity.y = Richard.dabSpeed
	self.dabbing = true
	self.x = self:getRandomDabPosition()
	self.target = self.scene:getRandomPlayer()
end


function Richard:handleDabbing()
	if self.y > 1050 then
		self.y = Richard.dabHeight
		self.dabCounter = self.dabCounter - 1
		self.x = self:getRandomDabPosition()
		if self.dabCounter <= 0 then
			self:stopDabbing()
		end
	end
end


function Richard:stopDabbing()
	self.velocity.y = 0
	self.floating = true
	self.dabbing = false
	self.angle = 0
	self.dabBox.auto = false

	self.anim:set("idle")
	self:tween(2, Richard.centerOfRoom, Richard.floatHeight)
	:oncomplete(_.wrap(self, "startShooting"))
end


function Richard:getRandomDabPosition()
	return -292 + math.random(0, 700)
end


function Richard:startChoking()
	self.scene:playSFX(self.SFX.choke)
	self.choking = true
	self:tween(2, 90, Richard.floatHeight)
	:oncomplete(function ()
		self.anim:set("choke")
		for i=1,Richard.numberOfChokes do
			self:delay(i * Richard.chokingDelay, "choke")
		end
		self:delay((Richard.numberOfChokes + 1) * Richard.chokingDelay, "stopChoking")
	end)
end


function Richard:choke()
	self.scene:addEntity(VeedAwards(self:getChokingPosition()))
end


function Richard:stopChoking()
	self.choking = false
	self.anim:set("idle")
	self:delay(2, "startDabbing")
end


function Richard:getChokingPosition()
	return self:getRelPos(0, 90)
end


function Richard:startPeeking()
	self.anim:set("idle")
	self.floating = false
	self.peeking = true
	self.peekCount = 3
	self.floatingRight = not self.floatingRight
	self.peekBox.auto = true
	self.latestTween = self:tween(2, Richard.centerOfRoom, -self.height)
	:oncomplete(function ()
		self:peek()
	end)
end


function Richard:peek()
	if not self.peeking then return end
	self.y = Richard.peekHeight
	self.floatingRight = not self.floatingRight
	self.peekCount = self.peekCount - 1

	if self.peekCount < 0 then
		self:stopPeeking()
		return
	end

	if self.floatingRight then
		self.angle = PI/2
		self.flip.x = false
		self.x = -492
		self.latestTween = self:tween(1, -342, Richard.peekHeight)
		:after(self, 1, {x = -492, y = Richard.peekHeight})
		:delay(1.4)
		:oncomplete(_.wrap(self, "peek"))
	else
		self.angle = -PI/2
		self.flip.x = true
		self.x = 668
		self.latestTween = self:tween(1, 518, Richard.peekHeight)
		:after(self, 1, {x = 668, y = Richard.peekHeight})
		:delay(1.4)
		:oncomplete(_.wrap(self, "peek"))
	end
end


function Richard:stopPeeking(choke)
	self.peeking = false
	self.peekBox.auto = false
	self.flux = flux.group()
	self.angle = 0
	self.floating = true

	local bipsen = self.scene:findEntitiesOfType(Bips)

	for i,v in ipairs(bipsen) do
		v:kill()
	end

	if choke then
		self.floatingRight = not self.floatingRight
		self.anim:set("choke")
		self:startChoking()
	else 
		self.y = 0
		self:tween(2, Richard.centerOfRoom, Richard.floatHeight)
		:oncomplete(function ()
			self:startDabbing()
		end)
	end
end


function Richard:onOverlap(e, mine, his)
	if e:is(Player) then
		if mine.name == "peek" then
			if self:fromAbove(his, mine) then
				if self.peeking then
					self:hit()
					if self.health > 0 then
						self:stopPeeking(true)
					end
					return
				end
			end
		end
	end
	return Richard.super.onOverlap(self, e, mine, his)
end


function Richard:startGlitching(amount, super)
	self.glitching = amount
	self:setShader(super and "superglitch" or "rgb")
	self:send("rgb_dirs", _.rgbdirs())
	self:send("rgb_amount", amount)
end

function Richard:glitch()
	self:send("dirs", _.rgbdirs())
end


function Richard:stopGlitching()
	self:setShader()
	self.glitching = 0
end


function Richard:startMoving()
	self:tween(1, self.x, Richard.floatHeight)
	:oncomplete(function () self:delay(1, "startDabbing") end)
	self:stopGlitching()
end


function Richard:hit()
	self.scene:playSFX(self.SFX.hurt)
	self.health = self.health - 1
	if self.health <= 0 then
		self:onDefeat()
	else
		Richard.super.hit(self)
	end
end


function Richard:kill()
end


function Richard:onDefeat()
	if self.defeated then return end
	self.defeated = true
	self:startGlitching(1, true)
	self.peeking = false
	self.peekBox.auto = false
	self.flux = flux.group()
	self.angle = 0
	self.floating = true

	local bipsen = self.scene:findEntitiesOfType(Bips)

	for i,v in ipairs(bipsen) do
		v:kill()
	end

	self.scene:shake(4, 5)

	self.floatingRight = not self.floatingRight
	self.anim:set("choke")
	self.scene.tick:delay(7, function () self.scene:growPortal() end)
	self:tween(2, Richard.centerOfRoom, Richard.floatHeight)
	:oncomplete(function () self.tick:delay(2, function () self.scene:stopTheme() Thing.kill(self) end) end)
end


-- function Richard:destroy()
-- 	Richard.super.destroy(self)
-- end

-- function Richard:dab()
-- 	self.angle = self:getAngle(Game.peter)
-- 	self:moveToAngle(600)
-- 	self.tick:delay(5, function ()
-- 		self.x = math.random(-600, -1000)
-- 		self.y = math.random(-600, -1000)
-- 		self:dab()
-- 	end)
-- end
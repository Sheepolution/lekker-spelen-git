Emotilord = Boss:extend("Emotilord")
local BulletXD = require "bosses.emotilord.projectiles.bulletxd"
local BulletTear = require "bosses.emotilord.projectiles.bullettear"
local BulletDjensen = require "bosses.emotilord.projectiles.bulletdjensen"
local BeerFall = require "bosses.emotilord.projectiles.beerfall"
local BeerWaves = require "bosses.emotilord.projectiles.beerwaves"

Emotilord.xCenterFloat = 380
Emotilord.yCenterFloat = 170
Emotilord.xPosXD = 700
Emotilord.yPosXD = 250
Emotilord.xPosSpit = 700
Emotilord.yPosSpit = 150
Emotilord.xPosBeer = 700
Emotilord.yPosBeer = 100

function Emotilord:new(...)
	Emotilord.super.new(self, ...)
	self:setImage("bosses/emotilord/emotilord", 12)
	self.anim:add("idle", 1)

	for i=1,11 do
		self.anim:add("blink_" .. i, {i+1, i+1}, nil, "once"):after("idle")
	end

	local blink
	blink = function ()
		self.anim:set("blink_" .. math.random(1, 11))
		self.tick:delay(_.random(.2, .8), blink)
	end

	blink()

	self.SFX.cry = SFX("sfx/cry")
	self.SFX.spit = SFX("sfx/spit")
	self.SFX.beer = SFX("sfx/beer")

	self.hitbox = self:addHitbox("solid")
	self.hitbox.ignorePlayer = true
	self.koterBox = self:addHitbox("koter", 140, 30)
	self.koterBox.auto = false

	self.floating = true

	self.gravity = 0
	self.floatY = Emotilord.yCenterFloat
	self.x = Emotilord.xCenterFloat

	self.solid = 0

	self.phase = 0
	self.ready = false

	self.rotating = true

	self.timer = 0

	self.lastState = nil
	self.secondLastState = nil
	self.currentStateNumber = 0

	self.xdTimer = step.new(.9)
	self.cryTimer = step.new(0.06)
	self.spitTimer = step.new(0.3)
	self.beerTimer = step.new(0.05)
	self.counter = 0

	self.jumpToKill = true
	
	self.states = {"spitting", "XD", "crying", "djensen"}

	self:addShader("superglitch", "teeth", "rgb")
	self:send("teeth_amount", .1)
	self:send("teeth_curves", 300)
	self:setShader()

	self.health = 3
	self.euroSpawnAmount = 0
end


function Emotilord:update(dt)
	self.timer = self.timer + dt

	self.y = self.floatY + math.sin(self.timer * PI * 0.5) * 20

	if self.rotating then
		self.angle = math.sin(self.timer * PI * 0.4) / 10
	end

	if self.ready then
		if self.state == "XD" then
			if self.xdTimer(dt) then
				self:shootXD()
			end
		end

		if self.state == "crying" then
			if self.cryTimer(dt) then
				self:shootCrying()
			end
		end

		if self.state == "spitting" then
			if self.spitTimer(dt) then
				self:shootSpitting()
			end
		end

		if self.state == "beer" then
			if self.beerTimer(dt) then
				self:shootBeer()
			end
		end
	end

	-- if DEBUG then
	-- 	if Key:isPressed("b") then
	-- 		self:hit()
	-- 	end
	-- end

	Emotilord.super.update(self, dt)
end


function Emotilord:draw()
	Emotilord.super.draw(self)
end

function Emotilord:onOverlap(e, mine, his)
	if self.state == "crying" then
		if e:is(SolidTile) then
			self.x = self.last.x
			self:doFlip("x")
		end
	end

	if mine.name == "koter" then
		if self.state == "beer" then
			if e:is(Player) then
				if self:fromAbove(his, mine) then
					self:hit()
					self:stopBeer()
				end
			end
		end
	end
end


function Emotilord:nextState()
	if self.defeated then return end

	self.ready = false
	self.phase = self.phase + 1
	self.counter = 0
	if self.state ~= "beer" then
		self.secondLastState = self.lastState
		self.lastState = self.state
	end

	if self.phase == 4 then
		self.state = "beer"
		self.phase = 0
	else
		if DATA.options.game.speedrun then
			self.currentStateNumber = self.currentStateNumber + 1
			if self.currentStateNumber == 5 then
				self.currentStateNumber = 1
			end
			self.state = self.states[self.currentStateNumber]
		else
			local nxt
			repeat
				nxt = _.randomchoice(self.states)
			until nxt ~= self.lastState and nxt ~= self.secondLastState
			self.state = nxt
		end
	end

	self.tick:delay(1.5, function ()
		if self.state == "beer"  then
			self:startBeer()
		elseif self.state == "XD" then
			self:startXD()
		elseif self.state == "crying" then
			self:startCrying()
		elseif self.state == "djensen" then
			self:startDjensen()
		elseif self.state == "spitting" then
			self:startSpitting()
		end
	end)
end



function Emotilord:startXD()
	self.state = "XD"
	self.ready = false
	self.rotating = false
	self.flux:to(self, 1, {floatY = Emotilord.yPosXD - 50, x = Emotilord.xPosXD, angle = PI/2})
	:oncomplete(function () self.ready = true end)
end


function Emotilord:shootXD()
	self.counter = self.counter + 1
	local b = BulletXD(self:centerX(), self:centerY() + 60, -1)
	self.scene:addEntity(b)

	if self.counter >= 15 then
		self:stopXD()
	end
end


function Emotilord:stopXD()
	self.ready = false
	self.flux:to(self, 1, {floatY = Emotilord.yCenterFloat, x = Emotilord.xCenterFloat, angle = 0})
	:delay(1)
	:oncomplete(function () self:nextState() end)
end


function Emotilord:startCrying()
	self.state = "crying"
	self.ready = false
	self.rotating = false
	self.flux:to(self, 1, {floatY = Emotilord.yCenterFloat + 50, x = Emotilord.xCenterFloat, angle = -.8})
	:oncomplete(function ()
		self:shootCrying(2)
		self.tick:delay(1, function ()
			self.ready = true
			self.cryEvent = self:event(function () self:doFlip("x") end, {3, 6})
			self.velocity.x = _.scoin() * 170
		end)
	end)

	self.autoFlip.x = false


	self.tick:delay(11, function () self.cryEvent:stop() self:stopCrying() end)
end


function Emotilord:shootCrying(tears)
	local cry = self.scene:playSFX(self.SFX.cry)
	if cry then cry:setPitch(_.random(.9, 1.1)) end
	for i=1,tears or 1 do
		local a = BulletTear(self:centerX(), self:centerY() - 75, -1)
		local b = BulletTear(self:centerX(), self:centerY() - 75, 1)
		self.scene:addEntity(a, b)
	end
end


function Emotilord:stopCrying()
	self.velocity.x = 0
	self.ready = false
	self.flux:to(self, 1, {angle = 0, x = Emotilord.xCenterFloat, floatY = Emotilord.yCenterFloat})
	:oncomplete(function ()
		self.rotating = true
		self:nextState()
	end)
end


function Emotilord:startDjensen()
	self.state = "djensen"
	self.ready = false
	self.flux:to(self, 1, {floatY = yCenterFloat, x = xCenterFloat})
	:oncomplete(function ()
		self.ready = true
		self:shootDjensen()
	end)
end


function Emotilord:shootDjensen()
	local a = BulletDjensen(self:centerX() - 36, self:centerY() - 84, 1)
	local b = BulletDjensen(self:centerX() - 36, self:centerY() - 84, -1)
	self.scene:addEntity(a, b)
	a.scene:playSFX(a.SFX.bounce)

	self:delay(10, "stopDjensen")
end


function Emotilord:stopDjensen()
	local djensens = self.scene:findEntitiesOfType(BulletDjensen)
	for i,v in ipairs(djensens) do
		v:kill()
	end
	self:nextState()
end


function Emotilord:startSpitting()
	self.state = "spitting"
	self.ready = false
	self.rotating = false
	self.flux:to(self, 1, {floatY = Emotilord.yCenterFloat + 40, x = Emotilord.xCenterFloat, angle = PI/2})
	:oncomplete(function () self.ready = true end)
	:after(1, {x = 100})
	:delay(1)
	:after(2, {x = 600})
	:after(1, {x = Emotilord.xCenterFloat})
	:after(1, {x = 100})
	:delay(1)
	:after(2, {x = 600})
	:after(1, {x = Emotilord.xCenterFloat})
	:oncomplete(function () self:stopSpitting() end)
end


function Emotilord:shootSpitting()
	local spit = self.scene:playSFX(self.SFX.spit)
	if spit then spit:setPitch(_.random(.9, 1.1)) end
	local a = BulletSpit(self:centerX()-20, self:centerY() - 80, _.scoin())
	-- local b = BulletSpit(self:centerX()-20, self:centerY() - 80, 1)
	self.scene:addEntity(a)
end


function Emotilord:stopSpitting()
	self.ready = false
	self.flux:to(self, 1, {angle = 0, floatY = Emotilord.yCenterFloat} )
	:oncomplete(function ()
		self.rotating = true
		self:nextState()
	end)
end


function Emotilord:startBeer()
	-- self.scene:playSFX(self.SFX.beer)
	self.state = "beer"
	self.rotating = false

	self.koterBox.auto = true

	self.flux:to(self, 1, {x = Emotilord.xPosBeer, floatY = Emotilord.yPosBeer})
	:oncomplete(function () self:createPlatforms()
		self.tick:delay(1.9, function ()
			self.scene:playSFX(self.SFX.beer)
		end)
	 end)
	:after(0.5, { angle=-.3 })
	:oncomplete(function ()
		self.ready = true
		self.scene:addEntity(BeerWaves())
	end)
end


function Emotilord:shootBeer()
	local a = BeerFall(self:centerX() - 80, self:centerY() + 35)
	self.scene:addEntity(a)
end


function Emotilord:stopBeer()
	self.koterBox.auto = false
	self.ready = false
	local waves = self.scene:findEntityOfType(BeerWaves)
	waves:back()
	self:destroyPlatforms()
	self.flux:to(self, 2, {x = Emotilord.xCenterFloat, floatY = Emotilord.yCenterFloat, angle = 0})
	:oncomplete(function ()
		self.rotating = true
		self:nextState()
	end)
end


function Emotilord:createPlatforms()
	for i=6,14 do
		self.scene.map.currentRoom.map.tiles[i].dead = false
	end

	self.scene.map.currentRoom.map.visuals[1].visible = true
	-- self:addEntity()
end


function Emotilord:destroyPlatforms()
	for i=6,14 do
		self.scene.map.currentRoom.map.tiles[i].dead = true
	end
	self.scene.map.currentRoom.map.visuals[1].visible = false
	-- self:addEntity()
end


function Emotilord:startMove()
	self.flux:to(self, 1, {x = Emotilord.xCenterFloat, floatY = Emotilord.yCenterFloat - 50 })
	:oncomplete(function ()
		self:delay(1, "nextState")
	end)
end


function Emotilord:startGlitching(amount, super)
	self.glitching = amount
	self:setShader(super and "superglitch" or "rgb")
	self:send("rgb_dirs", _.rgbdirs())
	self:send("rgb_amount", amount)
end


function Emotilord:onDefeat()
	if self.defeated then return end
	self.defeated = true
	self.scene:shake(2, 5)
	self:startGlitching(1, true)
	self.flux = flux.group()
	self.angle = 0

	Game:event("emotilord_ending")
	self.tick:delay(5, function () Thing.kill(self) end)
end


function Emotilord:hit()
	self.scene:playSFX(self.SFX.hurt)
	self.health = self.health - 1
	if self.health <= 0 then
		self:onDefeat()
	else
		Emotilord.super.hit(self)
	end
end
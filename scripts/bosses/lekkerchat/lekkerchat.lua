local BulletCharW = require "bosses.lekkerchat.projectiles.bulletcharw"
local BulletCharPercentage = require "bosses.lekkerchat.projectiles.bulletcharpercentage"
local BulletCharDollar = require "bosses.lekkerchat.projectiles.bulletchardollar"
local BulletCharGT = require "bosses.lekkerchat.projectiles.bulletchargt"
local BulletCharLT = require "bosses.lekkerchat.projectiles.bulletcharlt"
local BulletKonkie = require "bosses.lekkerchat.projectiles.bulletkonkie"

LekkerChat = Boss:extend("LekkerChat")

LekkerChat.rightX = 700
LekkerChat.verticalCenter = 120
LekkerChat.verticalPositions = {0, 120, 240}
LekkerChat.bulletChatPositions = {10, 160, 310}
LekkerChat.chatDelay = 1.1
LekkerChat.voiceDelay = 0.7
LekkerChat.konkieDelay = 0.05
LekkerChat.konkieShootLength = .8
LekkerChat.konkiePauseDelay = 2
LekkerChat.konkieTargetPositions = {50, 250, 400}
LekkerChat.healthPerPhase = {300, 200, 300}
LekkerChat.introFloatHeight = 160
LekkerChat.introFloatX = 360


function LekkerChat:new(...)
	LekkerChat.super.new(self, ...)
	self:setImage("bosses/lekkerchat/lekkerchat", 10)
	self.anim:add("idle")

	-- self.headSprite = Sprite(1, 24, "bosses/lekkerchat/head", 5)
	-- self.headSprite.anim:add("blink", {4,5,4}, nil, "once"):after("idle_closed")
	-- self.headSprite.anim:add("idle_closed", 3)
	-- self.headSprite.anim:add("idle_open", 1)
	-- self.headSprite.origin:set(60, 45)

	-- self.wingSprite = Sprite(0, 0, "bosses/lekkerchat/wing", 10)
	-- self.wingSprite.anim:add("idle")

	self.hitbox = self:addHitbox("solid", 0, -10, self.width * .4, self.height * .6)
	
	self.x = LekkerChat.introFloatX
	self.y = LekkerChat.verticalCenter

	self.solid = 0
	self.gravity = 0

	self.floatY = LekkerChat.introFloatHeight
	
	self.timer = 0

	self.SFX.speech = {
		w = SFX("sfx/lekkerchat/speech_w"),
		gt = SFX("sfx/lekkerchat/speech_greaterthan"),
		lt = SFX("sfx/lekkerchat/speech_lowerthan"),
		dollar = SFX("sfx/lekkerchat/speech_dollar"),
		percentage = SFX("sfx/lekkerchat/speech_procent")
	}

	self.SFX.typing = SFX("sfx/lekkerchat/typing", 1)
	self.SFX.hit = SFX("sfx/lekkerchat/hit")
	self.SFX.konkie = SFX("sfx/konkie")
	self.SFX.scream = SFX("sfx/lekkerchat_scream")

	-- self.SFX.typing:setLooping(true)

	-- self.sounds.typing:play()

	self.chatTimer = step.new(LekkerChat.chatDelay)
	self.voiceTimer = step.new(LekkerChat.voiceDelay)
	self.konkieTimer = step.new(LekkerChat.konkieDelay)
	self.konkiePauseTimer = step.new(LekkerChat.konkiePauseDelay, true)
	self.konkieMoveTimer = step.new(LekkerChat.konkieShootLength, false)
	self.konkiePhaseStarted = false
	self.konkieShootingCenter = false
	self.currentKonkiePosition = 2

	self.konkieTarget = Rect(0, HEIGHT/2, 10, 10)

	-- There are 2 super phases en 3 small phases.
	-- After beating the 3rd phase of the 2nd superphase you beat the boss
	self.phase = 1
	self.superPhase = 1

	self.readyToShoot = false

	self.health = LekkerChat.healthPerPhase[1] + 50

	self.lastChatPosition = 1

	self.euroSpawnAmount = 10
end

function LekkerChat:update(dt)
	self.timer = self.timer + dt

	self.y = self.floatY + math.sin(self.timer * PI * 1) * 30

	if self.readyToShoot then
		if self.phase == 1 then
			if self.chatTimer(dt) then
				self:shootChat()
			end
		elseif self.phase == 2 then
			if self.konkiePauseTimer(dt) then
				self.rotate = 0
				self.angle = 0
				if self.konkieMoveTimer(dt) then
					self:moveKonkie(_.random(0, 300))
				end
				if not self.movingKonkie then
					if self.konkieTimer(dt) then
						self:shootKonkie()
					end
				end
			end
		elseif self.phase == 3 then
			if self.voiceTimer(dt) then
				self:shootVoice()
			end
		end
	end

	LekkerChat.super.update(self, dt)
end


function LekkerChat:draw()
	LekkerChat.super.draw(self)
end


function LekkerChat:startVoice()
	self.flux:to(self, 1, {floatY = LekkerChat.verticalCenter})
	self.tick:delay(2, function ()
		self.rotate = 0
		self.angle = 0
		self.readyToShoot = true
	end)
end


function LekkerChat:shootVoice()
	-- local bullet = _.weightedchoice({["w"]=20, ["%"] = 20, ["<"]=20, [">"]=20, ["$"]=20})
	local bullet = _.randomchoice({"w", "%", "<", ">", "$"})
	local b, s

	if bullet == "w" then
		b = self.scene:addEntity(BulletCharW(self.x + 35, self.y + 70))
		s = self.scene:playSFX(self.SFX.speech.w)
	elseif bullet == "%" then
		b = self.scene:addEntity(BulletCharPercentage(self.x + 35, self.y + 70))
		s = self.scene:playSFX(self.SFX.speech.percentage)
	elseif bullet == "<" then
		b = self.scene:addEntity(BulletCharLT(self.x + 35, self.y + 70))
		s = self.scene:playSFX(self.SFX.speech.lt)
	elseif bullet == ">" then
		b = self.scene:addEntity(BulletCharGT(self.x + 35, self.y + 70))
		s = self.scene:playSFX(self.SFX.speech.gt)
	elseif bullet == "$" then
		b = self.scene:addEntity(BulletCharDollar(self.x + 35, self.y + 70))
		s = self.scene:playSFX(self.SFX.speech.dollar)
	end

	-- b:left()
	if s then
		s:setVolume(1)
		s:setPitch(_.random(.9, 1.1))
	end
end


function LekkerChat:startChat()
	self.flux:to(self, 1, {floatY = LekkerChat.verticalCenter})
	self.tick:delay(2, function ()
		self.scene:playSFX(self.SFX.typing)
		self.rotate = 0
		self.angle = 0
		self.readyToShoot = true
	end)
end


function LekkerChat:shootChat()
	local p
	repeat
		p = _.randomchoice(LekkerChat.bulletChatPositions)
	until p ~= self.lastChatPosition

	self.lastChatPosition = p
	self.scene:addEntity(BulletChat(p, -100))
end


function LekkerChat:shootKonkie()
	local konkie = BulletKonkie(self.x + 35, self.y + 65)
	if self.konkieShootingCenter then
		konkie:moveToEntity(self.konkieTarget)
	end
	self.scene:playSFX(self.SFX.konkie)
	self.scene:addEntity(konkie)
end


function LekkerChat:hit()
	self.health = self.health - 1
	
	if self.health <= 0 then
		self:onZeroHealth()
	end

	if self.beingDamaged then return end

	self.beingDamaged = true
	-- self:setShader("rgb")
	-- self:send("amount", 0.5)
	-- self:send("dirs", _.rgbdirs())
	self.color = {150, 150, 150}
	self.tick:delay(0.1, function ()
		-- self:setShader()
		self.color = {255, 255, 255}
		self.tick:delay(0.01, function ()
			self.beingDamaged = false
		end)
	end)
end


function LekkerChat:onZeroHealth()
	if self.defeated then return end
	self.scene:playSFX(self.SFX.scream)
	self.readyToShoot = false
	self.rotate = 10

	self.SFX.typing:stop()

	if self.phase == 3 then
		if self.superPhase == 1 then
			self:onDefeat()
			return
		else
			self.superPhase = 2
		end
		self.phase = 1
	else
		self.phase = self.phase + 1
	end

	if self.phase == 1 then
		self:startChat()
	elseif self.phase == 2 then
		self.readyToShoot = true
		self.konkiePauseTimer()
	elseif self.phase == 3 then
		self:startVoice()
	end

	self.health = LekkerChat.healthPerPhase[self.phase]
end


function LekkerChat:onDefeat()
	if self.defeated then return end
	self.scene:shake(3, 5)
	self.readyToShoot = false
	self.defeated = true
	self.rotate = 14
	self.tick:delay(3, self.wrap:kill())
end


function LekkerChat:kill()
	self.scene:stopTheme()
	LekkerChat.super.kill(self)
end


function LekkerChat:moveKonkie()
	local i
	repeat
		i = math.random(1, 3)
	until i ~= self.currentKonkiePosition

	self.currentKonkiePosition = i

	self.movingKonkie = true

	self.flux:to(self, 1.5, {floatY = self.verticalPositions[i]})
	:oncomplete(function () 
		self.movingKonkie = false
		self.konkieShootingCenter = true
		self.konkieTarget = _.randomchoice(self.scene:findEntitiesOfType(Player))
		-- self.konkieTarget:set(0, _.randomchoice(LekkerChat.konkieTargetPositions))
		self.konkieMoveTimer()
	end)
end


function LekkerChat:startMove()
	self.floatY = LekkerChat.verticalCenter - 60
	self.flux:to(self, 1, {x = LekkerChat.rightX, floatY = LekkerChat.verticalCenter}):delay(2)
	:oncomplete(function ()
		self.phase = 1
		self:startChat()
	end)
end


function LekkerChat:destroy()
	LekkerChat.super.destroy(self)

	local euros = self.scene:findEntitiesOfType(Euro)
	for i,v in ipairs(euros) do
		v:stopMoving()
		v.floating = true
		v.solid = 0
		v:moveToEntity(self.scene:getRandomPlayer(), math.random(300, 500))
	end

	self.scene.tick:delay(2, function () self.scene:growPortal() end)
end
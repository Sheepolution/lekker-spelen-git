LevelPortal = Entity:extend("LevelPortal")

LevelPortal.startDistance = 30

function LevelPortal:new(...)
	LevelPortal.super.new(self, ...)
	self:setImage("levelprops/portal")

	self.SFX = {}
	self.SFX.spawn = SFX("sfx/portal")

	self.floating = true

	self:addShader("waves")
	self:send("amount", 1)
	self:send("curves", 20)

	self:addHitbox("solid", self.width * .5, self.width * .5)

	self.rotate = 1

	self.rotateTimer = 4.6

	self.teleportingPlayers = false
	self.distance = LevelPortal.startDistance
	self.players = {}

	self.ready = true
end


function LevelPortal:done()
	LevelPortal.super.done(self)
	if self.spawn then
		self.scene:createPlayers()
		if not self.scene.isRestart then
			self:spawnPlayers()
		end
	end

	if self.hidden then
		self.ready = false
		self.scale:set(0)
	end
end


function LevelPortal:update(dt)
	LevelPortal.super.update(self, dt)
	if self.teleportingPlayers then
		self.rotateTimer = self.rotateTimer + dt * 4
		for i,v in ipairs(self.players) do
			v:center(self:centerX() + math.cos(self.rotateTimer + i*3) * self.distance, self:centerY() + math.sin(self.rotateTimer + i*3) * self.distance)
		end
	end
end


function LevelPortal:draw()
	LevelPortal.super.draw(self)
end


function LevelPortal:onOverlap(e)
	if self.spawn then return end
	if not self.ready then return end
	if e:is(Player) then
		if self.scene.timon.carryingPeter then
			self.scene.timon:throwPeterOff()
		end
		self:teleportPlayersToNextLevel()
	end
end


function LevelPortal:grow()
	self.flux:to(self.scale, 1, {x = 1, y = 1})
	:ease("quadout")
	:oncomplete(self.wrap({ready=true}))
end

function LevelPortal:shrink(gonext)
	if gonext then
		if not self.special then
			self.scene:goToNextLevel()
		end
	end
	self.flux:to(self.scale, 1, {x = 0, y = 0})
	:ease("quadin")
	:oncomplete(self.wrap:destroy())
end



function LevelPortal:teleportPlayersToNextLevel()
	self.players = {self.scene.peter, self.scene.timon}
	-- if not self.special then
		self.scene:playSFX(self.SFX.spawn)
	-- end

	for i,v in ipairs(self.players) do
		v.dead = true
		v.canDie = false
		v.inControl = false
		v.readyToTeleport = false
		v.solid = 0
		v.rotate = 7.5 * _.scoin()
		v.gravity = 0
		v:stopMoving()
		self.flux:to(v.scale, self.special and 9 or 2, {x = 0, y = 0})
		self.flux:to(v, .3, {x = self:centerX() + math.cos(self.rotateTimer + i*3) * self.distance - v.width/2, y = self:centerY() + math.sin(self.rotateTimer + i*3) * self.distance - v.height/2})
		:oncomplete(function () self.teleportingPlayers = true end)
	end


	self.flux:to(self, self.special and 9 or 2, {distance=0})
	:oncomplete(self.wrap:shrink(true))
end

function LevelPortal:spawnPlayers()
	self.players = {self.scene.peter, self.scene.timon}


	local delay = .5
	local length = 2

	for i,v in ipairs(self.players) do
		v.inControl = false
		v.rotate = 7.5 * _.scoin()
		v.floating = true
		v:stopMoving()
		v.anim:set("fall")
		v.scale:set(0)
		v:center(self:center())
		self.flux:to(v.scale, length, {x = 1, y = 1})
		:delay(delay)
		:oncomplete(function ()
			v.rotate = 0
			v.angle = 0
			v.floating = false
			-- v.inControl = true
			self.teleportingPlayers = false
			self:shrink()
		end)
	end

	self.distance = 0
	self.flux:to(self, length, {distance = LevelPortal.startDistance })
	:delay(delay)
	:onstart(function ()
		self.teleportingPlayers = true
		self.scene:playSFX(self.SFX.spawn)
	end)
	:oncomplete(function ()

	end)
end


function LevelPortal:spawnPlayersInstantly()
	self.rotateTimer = self.rotateTimer + 2

	self.players = {self.scene.peter, self.scene.timon}
	for i,v in ipairs(self.players) do
		v.x = self:centerX() + math.cos(self.rotateTimer + i*3) * self.distance - v.width/2
		v.y = self:centerY() + math.sin(self.rotateTimer + i*3) * self.distance - v.height/2
	end
	self:destroy()
end
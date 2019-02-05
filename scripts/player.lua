Player = Thing:extend("Player")

Player.speed = 170
Player.jumpPower = 600
Player.maxDistance = 900
Player.teleportTime = 0.4
Player.teleportCooldownTime = 1.5

function Player:new(...)
	Player.super.new(self, ...)

	self.teleporting = false

	self.z = 0

	self.beingDamaged = false
	self.partnerCanTeleport = {left = false, right = false}
	self.partnerTeleportablePosition = {}

	self.platformer = true
	self.inControl = true

	self.canTrigger = true
	self.readyToTeleport = false
	self.readyToTeleportToCheckpoint = false

	self.readyToTeleportTimer = step.new(0, true)
	self.partnerTeleportTimer = step.new(.25)
	self.teleportCooldownTimer = step.new(Player.teleportCooldownTime, true)

	self.slowDownTimer = step.new(0, true)

	self.player_id = 0

	self.canGetSquashed = true

	-- self.maxVelocity.y = Player.maxVelocity
end


function Player:update(dt)
	if not self.slowDownTimer(dt) then
		dt = dt/6
	end
	local can_partner_teleport = self:canPartnerTeleport() 
	if can_partner_teleport then
		-- print(self.partnerCanTeleport.x, self.partenr
		if self.teleportReadySprite then
			self.teleportReadySprite.anim:set("!")
		end
		if self.grounded then
			if self.partnerTeleportTimer(dt) then
				local point = Point(self:center())
				point.dir = can_partner_teleport
				table.insert(self.partnerTeleportablePosition, point)
			end
		end
	else
		if self.teleportReadySprite then
			self.teleportReadySprite.anim:set("x")
		end
	end

	self.teleportCooldownTimer(dt)

	self:inputs(dt)

	if self.platformer then
		local suffix = self.draggingSomething and "_drag" or "" 

		if self:isMoving("y") or self.floating then
			if self.velocity.y >= 0 then
				self.anim:set("fall" .. suffix)
			elseif self.velocity.y < 0 then
				self.anim:set("jump" .. suffix)
			end
		elseif self:isMoving("x") then
			if self.menu then
				self.anim:set("run_menu")
			else
				self.anim:set("run" .. suffix)
			end
		else
			self.anim:set("idle" .. suffix)
		end
	end

	if self.teleporting then
		self:stopMoving()
	end

	Player.super.update(self, dt)

	-- if self.velocity.y > 600 then
	-- 	self.velocity.y = 600
	-- end

	-- Prevent players from walking too far apart from each other.
	local distanceX = self:getDistanceX(self.partner)

	if not self.menu then
		if distanceX > Player.maxDistance then
			self.x = self.last.x
			self.partner.x = self.partner.last.x
		end
	end

	self.partnerCanTeleport.left = true
	self.partnerCanTeleport.right = true

	if GM then
		if self.y > 2000 then
			if _.is(GM.currentLevelName, "lekkerchat_intro", "level4_intro") then return end
			Game:onDead()
		end
	end
end


function Player:draw()
	if not self.dead then
		if self.readyToTeleport and not self.teleporting then
			if not self.teleportCooldownTimer(0) then
				self.teleportReadySprite.anim:set("o")
			end
			self.teleportReadySprite:drawAsChild(self)
		end

		if not self.teleporting and self.readyToTeleportToCheckpoint and self.scene:getLastCheckpoint() then
			self.teleportReadySprite.anim:set("<")
			self.teleportReadySprite:drawAsChild(self)
		end
	end

	Player.super.draw(self)
end


function Player:inputs(dt)
	if self.teleporting then return end
	if self.dead then return end
	if self.platformer then

		if self.inControl then
			self:stopMoving("x")

			if CURRENT_LEVEL >= 14 then
				if Key:isPressed(unpack(self.keys.sit)) then
					if self:getDistance(self.partner) < 50 then
						self:toggleSit()
					end
				end
			end

			if Key:isDown(unpack(self.keys.right)) then
				self:moveRight(self.speed * AXIS[self.player_id].x)
			elseif Key:isDown(unpack(self.keys.left)) then
				self:moveLeft(self.speed * AXIS[self.player_id].x)
			end

			if not self.carryingPeter and not self.sittingOnTimon then
				if Key:isDown(unpack(self.keys.teleport)) then

					if self.readyToTeleportTimer(dt) then
						self.readyToTeleport = true
					end

					if self.teleportCooldownTimer(0) then
						if self.partner.readyToTeleport then
							if not self.teleporting and self:canPartnerTeleport()
								and not self.partner.teleporting and self.partner:canPartnerTeleport() then
								self.readyToTeleport = false
								self.partner.readyToTeleport = false
								self:moveToPartner()
								self.partner:moveToPartner()
								return
							end
						end
					end
				elseif Key:isDown(unpack(self.keys.teleportcheckpoint)) then
					if self.teleportCooldownTimer(dt) then
						self.readyToTeleportToCheckpoint = true
						if self.partner.readyToTeleportToCheckpoint then
							self:moveToCheckpoint()
							self.partner:moveToCheckpoint()
							self.readyToTeleportToCheckpoint = false
							self.partner.readyToTeleportToCheckpoint = false
						end
					end
				else
					self.readyToTeleportToCheckpoint = false
				end

				if Key:isReleased(unpack(self.keys.teleport)) then
					if self.teleportCooldownTimer(0) then
						self.readyToTeleportTimer()
						if not self.teleporting and self:canPartnerTeleport() then
							self.partner:moveToPartner()
						end
					end
					self.readyToTeleport = false
				end
			end
			
			if self.velocity.y < 0 then
				if Key:isReleased(unpack(self.carryingPeter and self.keys.jump_peter or self.keys.jump)) then
					self.velocity.y = self.velocity.y/2
				end
			end

			if Key:isPressed(unpack(self.carryingPeter and self.keys.jump_peter or self.keys.jump)) then
				if self.grounded then
					self.grounded = false
					self.velocity.y = -self.jumpPower
					-- self.scene:playSFX(self.SFX.jump)
				end
			end
		end
	end
end


function Player:onOverlap(e, mine, his)
	if e.solid == 2 then
		if mine == self.teleportHitboxLeft then
			self.partnerCanTeleport.left = false
			return false
		elseif mine == self.teleportHitboxRight then
			self.partnerCanTeleport.right = false
			return false
		end
	end

	if self.teleporting then return false end

	if mine.solid then
		if e.killOnTouch then
			self:fakeKill()
		end

		if e.jumpToKill then
			if not his.ignorePlayer then
				if self:fromDown(his, mine) then
					Key:rumble(self.player_id, .4, .25)

					if Key:isDown(unpack(self.keys.jump)) then
						self.velocity.y = -Player.jumpPower
					else
						self.velocity.y = -Player.jumpPower*.75
					end
					return false
				end
			end
		end


		if e.damaging or his.damaging then
			self:hit()
		end

		if e:is(Bips) then
			if self:fromAbove(mine, his) then
				if (not self.carryingPeter and Key:isDown(unpack(self.keys.jump))) or (self.carryingPeter and Key:isDown(unpack(self.partner.keys.jump))) then
					self.velocity.y = -Player.jumpPower*1.3
				else
					self.velocity.y = -Player.jumpPower
				end
			end
		end
	end
	return Player.super.onOverlap(self, e, mine, his)
end


function Player:canPartnerTeleport()
	if self.partnerCanTeleport.left then
		if self.partnerCanTeleport.right then
			return "center"
		else
			return "left"
		end
	elseif self.partnerCanTeleport.right then
		return "right"
	else
		return false
	end
end


function Player:moveToPartner(tox, toy, dir)
	if not self.teleporting and not self.dead and not self.partner.dead then
		self.partner.teleportCooldownTimer()
		if not tox then
			local dir = self.partner:canPartnerTeleport()
			if not dir then dir = "center" end
			tox, toy = self.partner:center()
			toy = toy - 10
			if dir == "left" then
				tox = tox - 20
			elseif dir == "right" then
				tox = tox + 20
			end
		end

		if dir then
			if dir == "left" then
				tox = tox - 20
			elseif dir == "right" then
				tox = tox + 20
			end
		end

		self:moveToLocation(tox, toy)
	end
end


function Player:moveToCheckpoint()
	local checkpoint = self.scene:getLastCheckpoint()
	if not checkpoint then return end
	local x,y = checkpoint:center()
	self:moveToLocation(x, y - 35)
end



function Player:moveToLocation(tox, toy)
	self.scene:playSFX(self.SFX.teleport)
	if self.teleporting then return end
	local alpha_speed = 0.2
	local pixel_amount = 40
	local pixel_offset = 30

	self.solid = 0

	local x, y, w, h = self._frames[self.anim:getQuad()]:getViewport()
	local frame = love.image.newImageData(w, h)
	frame:paste(self.imageData, 0, 0, x, y, w, h)

	self:stopMoving()
	self.teleporting = true
	self.flux:to(self, alpha_speed, {alpha = 0})
	:after(self, Player.teleportTime, {x=tox - self.width/2, y=toy - self.height/2})
	:after(self, alpha_speed, {alpha = 1})
	:oncomplete(function () self.last:clone(self) self.teleporting = false self.solid = 1 end)

	pixels = {}
	-- for i=1,pixel_amount do
	frame:mapPixel(function (x, y, r, g, b, a)
		if a > 0 then
			if _.chance(5) then
				local nx = x
				if self.flip.x then nx = self.width - x end
				local offx, offy = math.random(-pixel_offset, pixel_offset), math.random(-pixel_offset, pixel_offset) 
				self.scene:addParticle("death", self.x + nx, self.y + y, tox - self.width/2 + nx, toy - self.height/2 + y)
			end
		end
		return x, y, r, g, b, a
	end)
end


function Player:setPartner(partner)
	self.partner = partner
end


function Player:hit()
	if self.teleporting or self.dead then return end
	if self.beingDamaged or self.partner.beingDamaged then return end
	self.scene:playSFX(self.SFX.hurt)
	Key:rumble(self.player_id, .4, .25)
	self.beingDamaged = true
	self:blink()
	self.partner:blink()
	self.readyToTeleport = false
	self.readyToTeleportToCheckpoint = false
	Game:loseHealth()
end


function Player:blink()
	if self.sittingOnTimon then return end
	if self.blinkEvent then self.blinkEvent:stop() end
	self.tick:delay(1.5, function () self.beingDamaged = false  end)
	self.blinkEvent = self:event(function () self.visible = not self.visible if self.sittingOnTimon or (not self.beingDamaged and not self.partner.beingDamaged) then return true end  end, 0.1, nil, function () self.visible = not self.sittingOnTimon end)
end


function Player:getSquashed()
	self:fakeKill()
end


function Player:fakeKill()
	if not self.squashDamage then
		self:hit()
	end
	self.squashDamage = true
	self:delay(2, {squashDamage = false})
	if self.dead then return end
	if self.carryingPeter then
		local pos = self.partnerTeleportablePosition[#self.partnerTeleportablePosition]
		if pos then
			self:moveToLocation(pos.x, pos.y-10)
			table.remove(self.partnerTeleportablePosition, #self.partnerTeleportablePosition)
		end
	else
		local pos = self.partner.partnerTeleportablePosition[#self.partner.partnerTeleportablePosition]
		if pos then
			self:moveToPartner(pos.x, pos.y-10, pos.dir)
			table.remove(self.partner.partnerTeleportablePosition, #self.partner.partnerTeleportablePosition)
		else
			self:moveToPartner()
		end
	end
end


function Player:kill()
	self.flux = flux.group()
	Player.super.kill(self)
	self.skullSprite = Thing(0, 0, "players/" .. self.id .. "_skull")
	self.skullSprite.x = self.flip.x
	self.skullSprite:center(self:getSkullPos())
	self.skullSprite.gravity = 0
	self.skullSprite.bounce:set(.4)
	self.skullSprite:addIgnoreOverlap(Box)
	self.scene:addEntity(self.skullSprite)
end


function Player:destroy()
	self.skullSprite.gravity = 2000
end


function Player:slowDown(time)
	self.slowDownTimer:set(time)
	self.slowDownTimer()
end

function Player:stopSlowDown()
	self.slowDownTimer:set(0)
end

function Player:toggleSit()

end
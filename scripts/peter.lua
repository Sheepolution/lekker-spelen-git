Peter = Player:extend("Peter")

function Peter:new(...)
	Peter.super.new(self, ...)
	self:setImage("peter", 31)
	self.anim:add("run", "16>23", function () return 12 * AXIS[1].x end, nil, {{0, -3},{0, -1},{0, -1},{0, -3},{0, -3},{0, -1},{0, -1},{0, -3}})
	self.anim:add("run_menu", "16>23")
	self.anim:add("idle", "1>15", nil, nil, {{0, 0},{0, 0},{0, 0},{0, 0},{0, 0},{0, 0},{0, 0},{0, 0},{0, -1},{0, -1},{0, -1},{0, -1},{0, -1},{0, -1},{0, -1}})
	self.anim:add("jump", {23,16}, nil, "once", {{0, -3}, {0, -3}})
	self.anim:add("fall", 16, nil, nil, {{0, -3}})
	self.anim:clone("idle", "idle_drag")
	self.anim:add("run_drag", "24>31", function () return 12 * AXIS[1].x end, nil, {{0, -4},{0, -2},{0, -2},{0, -4},{0, -4},{0, -2},{0, -2},{0, -4}})
	self.anim:add("jump_drag", {31,24}, nil, "once", {{0, -3}, {0, -3}})
	self.anim:add("fall_drag", 24, nil, nil, {{0, -3}})

	self.separatePriority:set(0)

	if DATA.options.controller.singleplayer then
		self.keys = {
			left = {"j"},
			right = {"l"},
			jump = {"i"},
			teleport = {"k"},
			buy = {"u"},
			sit = {"o"},
			teleportcheckpoint = {"u"}
		}
	else
		self.keys = {
			left = {"left"},
			right = {"right"},
			jump = {"g"},
			teleport = {"h"},
			buy = {"t"},
			sit = {"y"},
			teleportcheckpoint = {"t"}
		}
	end


	self.SFX.jump = SFX("sfx/heart_jump")
	self.SFX.hurt = SFX("sfx/hurt_peter")
	self.SFX.teleport = SFX("sfx/teleport_peter")

	self.id = "peter"
	self.player_id = 1
	self.z = ZMAP.Peter

	self.teleportOffset = -10

	self.teleportReadySprite = Sprite(0, -40, "teleport_icons", 8)
	-- self.teleportReadySprite.offset.x = -4
	self.teleportReadySprite.anim:add("!", 1)
	self.teleportReadySprite.anim:add("x", 2)
	self.teleportReadySprite.anim:add("o", 3)
	self.teleportReadySprite.anim:add("<", 4)

	self.hitbox = self:addHitbox("solid", 20, self.height * .9)
	self.teleportHitboxLeft = self:addHitbox("teleport_left", -self.width/2, self.teleportOffset, self.width, self.height)
	self.teleportHitboxLeft.solid = false
	self.teleportHitboxLeft.own = true
	self.teleportHitboxLeft.flipRelative.x = false

	self.teleportHitboxRight = self:addHitbox("teleport_right", self.width/2, self.teleportOffset, self.width, self.height)
	self.teleportHitboxRight.solid = false
	self.teleportHitboxRight.own = true
	self.teleportHitboxRight.flipRelative.x = false

	self.doorKey = Sprite(9, -6, "levelprops/hand_key", 2)
	self.doorKey.anim:add("hold", 2)

	self.canPickUpKeys = true
	self.holdingKey = false
	self.draggingSomething = false

	self.sittingOnTimon = false

	self.skullSprite = Sprite(2, -10, "players/peter_skull")
end


function Peter:update(dt)

	Peter.super.update(self, dt)
	if self.sittingOnTimon then
		self:stopMoving()
	end

	if GM then
		if GM.currentLevelName == "level4_intro" then
			if self.y > 1000 then
				GM:goToNextLevel()
			end
		end
	end
end


function Peter:draw()
	if self.sittingOnTimon then
		self.flip.x = self.partner.flip.x
	end

	Peter.super.draw(self)

	if not self.visible then return end

	if self.holdingKey then
		if self.sittingOnTimon then
			self.doorKey.flip.x = self.flip.x
			local offset = self.partner.anim:getOffset()
			self.doorKey.offset.x = -_.boolsign(self.flip.x) * 2
			local off = 17
			if offset then
				self.doorKey.offset.y = offset.y
				self.doorKey.offset.y = self.doorKey.offset.y - off
			else
				self.doorKey.offset.y = -off
			end
			self.doorKey.alpha = self.alpha
			self.doorKey:drawAsChild(self)
		else
			self.doorKey.flip.x = self.flip.x
			local offset = self.anim:getOffset()
			if offset then
				self.doorKey.offset.y = offset.y
			end
			self.doorKey.alpha = self.alpha
			self.doorKey:drawAsChild(self)

		end
	end
end


function Peter:onOverlap(e, mine, his)
	if mine.solid then
		if e:is(Box) then
			if mine:bottom(true) > his:top(true) then
				if e.x ~= e.last.x then
					if self.x == self.last.x then
						self:getSquashed()
						return false
					end
					if e.last.x < e.x then
						if self.velocity.x < 0 then
							self:getSquashed()
							return false
						end
					end
					if e.last.x > e.x then
						if self.velocity.x > 0 then
							self:getSquashed()
							return false
						end
					end
				end

				if self:fromAbove(his, mine) then
					self:getSquashed()
					return false
				end
			end
		end
	end
	Peter.super.onOverlap(self, e, mine, his)
end


function Peter:pickUpKey()
	self.draggingSomething = true
	self.holdingKey = true
end


function Peter:releaseKey()
	self.draggingSomething = false
	self.holdingKey = false
end


function Peter:getSkullPos()
	return self:getRelPos(2, -10)
end


function Peter:toggleSit()
	if not self.sittingOnTimon then
		self:sitOnTimon()
	end
end


function Peter:sitOnTimon()
	self.sittingOnTimon = true
	self.solid = 0
	self.visible = false
	self.hitbox.auto = false
	self.inControl = false
	self.partner:havePeterSitOnMe()
end


function Peter:getOffTimon()
	self.solid = 1
	self.sittingOnTimon = false
	self.velocity.y = -200
	self.y = self.y - 20
	self.visible = true
	self.inControl = true
	self.hitbox.auto = true
end
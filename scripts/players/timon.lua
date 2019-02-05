Timon = Player:extend("Timon")

Timon.speed = Player.speed + 20
Timon.fasterSpeed = Timon.speed + 30

function Timon:new(...)
	Timon.super.new(self, ...)
	-- image and animation
	self:setImage("timon", 22)
	self.anim:add("run", {19, 20, 21, 22, 17, 18}, function () return 12 * AXIS[2].x end, nil, {{0, -2}, {0, 0}, {0, 0}, {0, 0}, {0, -1}, {0, -2}})
	self.anim:add("run_menu", {19, 20, 21, 22, 17, 18})
	self.anim:add("idle", "1>16", nil, nil, {{0, -1},{0, -1},{0, -1},{0, -1},{0, -1},{0, -1},{0, -1},{0, -1},{0, 0},{0, 0},{0, 0},{0, 0},{0, 0},{0, 0},{0, 0},{0, 0}})
	self.anim:add("jump", {17,18}, nil, "once", {{0, 0}, {0, -1}})
	self.anim:add("fall", 18)

	self.peterSprite = Sprite(-1, -16, "peter_sitting", 8)
	self.peterSprite.anim:add("idle")

	self.SFX.jump = SFX("sfx/jump_timon")
	self.SFX.hurt = SFX("sfx/hurt_timon")
	self.SFX.teleport = SFX("sfx/teleport_timon")

	-- keys

	if DATA.options.controller.singleplayer then
		self.keys = {
			left = {"a"},
			right = {"d"},
			jump = {"w"},
			teleport = {"s"},
			sit = {"e"},
			buy = {"q"},
			jump_peter = {"i"},
			teleportcheckpoint = {"q"}
		}
	else
		self.keys = {
			left = {"a"},
			right = {"d"},
			jump = {"k"},
			teleport = {"l"},
			sit = {"o"},
			buy = {"i"},
			jump_peter = {"g"},
			teleportcheckpoint = {"i"}
		}
	end
	
	self.id = "timon"
	self.player_id = 2
	self.z = ZMAP.Timon

	self.separatePriority:set(2)

	-- self.maxVelocity.y = 650
	self.jumpPower = Player.jumpPower + 60
	self.speed = Player.speed + 20

	self.hitbox = self:addHitbox("solid", self.width * .75, self.height * .83)

	self.partnerCanTeleport = {left = true, right = true}

	self.teleportReadySprite = Sprite(20, -45, "teleport_icons", 8)
	self.teleportReadySprite.offset.x = 5
	self.teleportReadySprite.anim:add("!", 5)
	self.teleportReadySprite.anim:add("x", 6)
	self.teleportReadySprite.anim:add("o", 7)
	self.teleportReadySprite.anim:add("<", 8)

	self.teleportOffset = -10

	self.carryingPeter = false

	-- self.teleportHitbox = self:addHitbox("teleport",  0, self.teleportOffset, self.width * .6,  self.height * .75)
	-- self.teleportHitbox.solid = false
	-- self.teleportHitbox.own = true
end


function Timon:update(dt)
	-- if Key:isPressed() then
	-- 	local tiles = self.scene.map:getSolidTiles()
	-- 	if not _.any(tiles, function (t) return self.teleportHitbox:overlaps(t) end) then
	-- 		-- self.partner:centerX(self:centerX())
	-- 		local x, y = self:center()
	-- 		self.partner:moveToPartner(x, y)
	-- 	end
	-- end
	Timon.super.update(self, dt)
	if self.carryingPeter then
		self.partner:center(self:center())
	end
	self.peterSprite:update(dt)
	self.speed = self.carryingPeter and Timon.fasterSpeed or Timon.speed
end


function Timon:draw()
	Timon.super.draw(self)
	if not self.carryingPeter or self.dead then return end

	local offset = self.anim:getOffset()
	if offset then
		self.peterSprite.offset.y = offset.y
	end

	self.peterSprite:drawAsChild(self, {"flip", "visible", "alpha"}, true)
end


function Timon:onOverlap(e, mine, his)
	if mine.solid then
		if e:is(Box) then
			if self:fromAbove(his, mine) then
				self:getSquashed()
			end
			if self:centerY() > e:top() then
				-- self.scene:playSFX(self.SFX.pushBox)
				self.oldSpeed = self.speed
				self.speed = self.speed/2
			end
		end
	end

	return Timon.super.onOverlap(self, e, mine, his)
end


function Timon:getSkullPos()
	return self:getRelPos(20, -10)
end


function Timon:toggleSit()
	if self.carryingPeter then
		self:throwPeterOff()
	end
end

function Timon:throwPeterOff()
	self.carryingPeter = false
	self.speed = Timon.speed
	self.oldSpeed = self.speed
	self.partner:getOffTimon()
end


function Timon:havePeterSitOnMe()
	self.carryingPeter = true
	self.speed = Timon.fasterSpeed
	self.oldSpeed = self.speed
end
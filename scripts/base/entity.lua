local Entity = Sprite:extend()
local Hitbox = require "base.hitbox"
local HCbox = require "base.hcbox"

function Entity:new(x, y, img, w, h)
	Entity.super.new(self, x, y, img, w, h)

	self.z = 0
	
	self.velocity = Point(0, 0)
	self.maxVelocity = Point(9999999, 9999999)
	self.accel = Point(0, 0)
	self.drag = Point(0, 0)

	self.angularVelocity = 0
	
	self.last = Rect(x, y, w, h)
	self.dead = false
	self.destroyed = false
	self.solid = 1
	self.bounce = Point(0, 0)
	self.moves = true

	self.autoFlip = {x = true, y = false}
	self.autoAngle = false

	self.ignoreOverlap = {}
	self.ignoreCollision = {}
	self.immovableObjects = {}

	self.events = {}

	self.separatePriority = Point(0,0)
	self.immovable = false

	self._collCopy = {}
	self._collCopy.changed = false
	self._collCopy.sp = Point()
	self._collCopy.immovable = {x = self.immovable, y = self.immovable}

	self.inControl = true

	self.HC = false
	self.hitboxes = {}
end


function Entity:postNew()
	self.last:clone(self)

	self._collCopy.sp:clone(self.separatePriority)
	self._collCopy.immovable = {x = self.immovable, y = self.immovable}

	if self.width > 0 and not self.hitbox then
		self.hitbox = self:addHitbox("solid", self.width, self.height, self.hitboxType or "solid")
	end
end


function Entity:update(dt)
	Entity.super.update(self, dt)

	self._collCopy.changed = false
	self._collCopy.sp:clone(self.separatePriority)
	self._collCopy.immovable = {x = self.immovable, y = self.immovable}

	if self.moves then
		self:move(dt)
	end

	for k,v in pairs(self.hitboxes) do
		v:update(dt)
	end
end


function Entity:draw()
	self:handleFlip()

	if self.autoAngle then
		self.angle = self:getVelocityAngle()
		if self.velocity.x < 0 then
			self.flip.y = true
		end
	end

	Entity.super.draw(self)
end


function Entity:drawDebug()
	Entity.super.drawDebug(self)
	for k,v in pairs(self.hitboxes) do
		Debug.add("drawcalls", -1)
		v:draw()
	end
end


function Entity:handleFlip()
	if self.autoFlip.x then
		self.flip.x = self.velocity.x == 0 and self.flip.x or self.velocity.x < 0 and true or false
	end
	if self.autoFlip.y then
		self.flip.y = self.velocity.y == 0 and self.flip.y or self.velocity.y < 0 and true or false
	end
end


function Entity:doFlip(axis)
	if axis then
		self.velocity[axis] = -self.velocity[axis]
	else
		self.velocity.x = -self.velocity.x
		self.velocity.y = -self.velocity.y
	end
end


function Entity:move(dt)
	self.last:clone(self)

	if self.angularVelocity ~= 0 then
		local angle = self.moveAngle or self.angle
		local cos, sin = math.cos(angle), math.sin(angle)
		self.x = self.x + cos * self.angularVelocity * dt
		self.y = self.y + sin * self.angularVelocity * dt
	else
		for i,v in ipairs({"x", "y"}) do
			self.velocity[v] = self.velocity[v] + self.accel[v] * dt;
			if math.abs(self.velocity[v]) > self.maxVelocity[v] then
				self.velocity[v] = self.maxVelocity[v] * (self.velocity[v] > 0 and 1 or -1);
			end

			self[v] = self[v] + self.velocity[v] * dt;
		end
		self:applyDrag(dt)
	end
end

local xy = {"x", "y"}

function Entity:applyDrag(dt)
	for i,v in ipairs(xy) do
		if self.accel[v] == 0 and self.velocity[v] ~= 0 and self.drag[v] ~= 0 then
			if (self.drag[v] * dt > math.abs(self.velocity[v])) then
				self.velocity[v] = 0;
			else
				self.velocity[v] = self.velocity[v] + self.drag[v] * dt * (self.velocity[v] > 0 and -1 or 1);
			end
		end
	end
end


function Entity:moveToDirection(flip, speed, axis, auto)
	axis = axis or "x"
	speed = speed or self.speed
	flip = flip or self.flip[axis]
	auto = auto == nil and true or false
	self.velocity[axis] = flip and -speed or speed
	if auto then
		self.flip[axis] = flip
	end
end


function Entity:moveToAngle(angle, speed)
	self.velocity.x = math.cos(angle or self.angle) * (speed or self.speed)
	self.velocity.y = math.sin(angle or self.angle) * (speed or self.speed)
end


function Entity:getVelocityAngle()
	local angle = math.atan2(self.velocity.y, self.velocity.x)
	return angle
end


function Entity:moveToEntity(e, speed, auto)
	local angle = self:getAngle(e)
	if auto then self.angle = angle end
	self:moveToAngle(angle, speed)
end


function Entity:stopMoving(axis)
	if axis then
		self.velocity[axis] = 0
	else
		self.velocity:set(0)
	end
	self.angularVelocity = 0
end


function Entity:isMoving(axis)
	if axis then
		return self.moves and self.velocity[axis] ~= 0
	else
		return self.moves and (self.velocity.x ~= 0 or self.velocity.y ~= 0)
	end
end


function Entity:teleport(x, y)
	self.x = x or self.x
	self.y = y or self.y
	self.last:clone(self)
end


function Entity:kill()
	self.dead = true
end


function Entity:destroy()
	self.destroyed = true
end


--Set relative velocity
function Entity:setRelVel(x, y)
	if x then
		self.velocity.x = self.flip.x and -x or x
	end
	if y then
		self.velocity.y = self.flip.y and -y or y
	end
end


function Entity:getRelPos(x, y)
	local xx, yy = self:centerX(), self:centerY()
	return xx + (self.flip.x and -x or x), yy + (self.flip.y and -y or y)
end


function Entity:moveLeft(vel)
	self.velocity.x = -(vel or self.speed or 100)
end


function Entity:moveRight(vel)
	self.velocity.x = vel or self.speed or 100
end


function Entity:moveUp(vel)
	self.velocity.y = -(vel or self.speed or 100)
end


function Entity:moveDown(vel)
	self.velocity.y = vel or self.speed or 100
end


function Entity:shake(intensity, time, force)
	if force then
		if self.events.shake then
			self.events.shake:stop()
			self.events.shake = nil
		end
	end
	if not self.events.shake then
		self.events.shake = self.coil:add(function ()
			for i=1,time/0.05 do
				self.offset:set(_.random(-intensity, intensity), _.random(-intensity, intensity))
				coil.wait(0.05)
			end
			self.events.shake = nil
		end)
	end
end


function Entity:addHitbox(name, x, y, width, height, proptype)
	if type(name) == "number" then
		proptype = height
		height = width
		width = y
		y = x
		x = name
		name = "solid"
	end

	self.hitboxes[name] = (self.HC and HCBox or Hitbox)(self, name, x, y, width, height, proptype or self.hitboxType)

	if not self.hitbox then self.hitbox = self.hitboxes[name] end

	return self.hitboxes[name]
end


function Entity:removeHitbox(name)
	if self.hitboxes[name] then
		self.hitboxes[name]:kill()
		self.hitboxes[name] = nil
	end
end


function Entity:clearHitboxes()
	for k,v in pairs(self.hitboxes) do
		v:kill()
	end
	self.hitboxes = {}
end


function Entity:countHitboxes()
	return _.count(self.hitboxes)
end


local isClass = function (t, e)
	if #t == 0 then return false end
	return _.any(t, function (a) return e:is(a) end)
end


function Entity:setCollisionTiles(dt)
	if self:countHitboxes() == 0 then return end

	local left, right, top, bottom
	local marginx = math.abs(self.velocity.x * dt)
	local marginy = math.abs(self.velocity.y * dt)

	local first = true
	for k,v in pairs(self.hitboxes) do
		if not first then
			local n_left = v:left()
		    local n_right = v:right()
			local n_top = v:top()
			local n_bottom = v:bottom()
			left = n_left < left and n_left or left
			right = n_right > right and n_right or right
			top = n_top < top and n_top or top
			bottom = n_bottom > bottom and n_bottom or bottom
		else
			first = false
			left, right, top, bottom = v:left(), v:right(), v:top(), v:bottom()
		end
	end

	self.scene:coordsToCollisionTiles(self, left - marginx, right + marginx, top - marginy, bottom + marginy)
end


function Entity:overlappable(e)
	return self ~= e
	and not self.dead and not e.dead
	and not self.destroyed and not e.destroyed
	and not isClass(self.ignoreOverlap, e)
	and not isClass(e.ignoreOverlap, self)
end


function Entity:overlaps(e, mine, his)
	if e == self then return false end
	
	if his then
		if not self.hitboxes[mine] or not e.hitboxes[his] then return false end
		return self.hitboxes[mine]:overlaps(e.hitboxes[his])
	end

	local t = {}
	local succes = false
	local list

	if mine then
		for hisname,hisbox in pairs(e.hitboxes) do
			if hisbox.auto then
				if self.hitboxes[mine]:overlaps(hisbox) then
					table.insert(t, v)
					succes = true
				end
			end
		end
		return succes and t or false
	end

	for myname,mybox in pairs(self.hitboxes) do
		if mybox.auto then
			for hisname,hisbox in pairs(e.hitboxes) do
				if hisbox.auto then
					if mybox:overlaps(hisbox) then
						table.insert(t, {mybox, hisbox})
						succes = true
					end
				end
			end
		end
	end

	return succes and t or false
end


function Entity:onOverlap(e, mine, his)
	-- 0 = Can't collide with this
	-- 1 = Only collides with 2
	-- 2 = Collides with 1 and 2.
	if self.solid == 0 or e.solid == 0 then return end
	if self.solid == 2 or e.solid == 2 then
		return not (isClass(self.ignoreCollision, e) or isClass(e.ignoreCollision, self))
	end
end


function Entity:resolveCollision(e, mine, his)
	if self:overlappable(e) then
		local t = self:overlaps(e, mine, his)
		if t then
			for i,v in ipairs(t) do
				local mine, his = v[1], v[2]
				local a, b = 0, 0
				if not his.own then
					a = self:onOverlap(e, mine, his)
				end
				if not mine.own then
					b = e:onOverlap(self, his, mine)
				end
				if a == nil then
					a = Entity.onOverlap(self, e, mine, his)
				end
				if b == nil then
					b = Entity.onOverlap(e, self, his, mine)
				end
				if a and b then
					if mine.solid and his.solid then
						self:separate(e, mine, his)
					end
				end
			end
		end
	end
end


function Entity:fromAbove(mine, his)
	return mine:bottom(true) < his:top(true)
end


function Entity:fromDown(mine, his)
	return mine:top(true) > his:bottom(true)
end


function Entity:fromLeft(mine, his)
	return mine:right(true) < his:left(true)
end


function Entity:fromRight(mine, his)
	return mine:left(true) > his:right(true)
end


function Entity:separate(e, mine, his)
	local x, y = mine:overlapsY(his, true), mine:overlapsX(his, true)
	if not x and not y then	return end
	self:separateAxis(e, x and "x" or "y", mine, his);
end


function Entity:separateAxis(e, a, mine, his)
	local s = a == "x" and "width" or "height"

	local scm = self._collCopy
	local ecm = e._collCopy

	if scm.immovable[a] and ecm.immovable[a] then return end

	local sim = isClass(self.immovableObjects, e) 
	local eim = isClass(e.immovableObjects, self)

	if (sim or scm.immovable[a]) or (not (eim or ecm.immovable[a])) and scm.sp[a] >= ecm.sp[a] then
		local f = "_getlocal" .. a
		local ms = mine[f](mine)
		local hs = his[f](his)

		local ms_l = mine[f](mine, true)
		local hs_l = his[f](his, true)

		if e.last[a] + e.last[s]/2 + hs_l < self.last[a] + self.last[s]/2 + ms_l then
			e[a] = self[a] + self[s]/2 + ms - mine[s]/2 - (e[s]/2 + hs + his[s]/2)
		else
			e[a] = self[a] + self[s]/2 + ms + mine[s]/2 - (e[s]/2 + hs - his[s]/2)
		end
		e:onSeparate(self, a, his, mine)
	else
		e:separateAxis(self, a, his, mine)
	end
end


function Entity:onSeparate(e, a, mine, his)
	self.velocity[a] = self.velocity[a] * -self.bounce[a]
	if math.abs(self.velocity[a]) < 1 then self.velocity[a] = 0 end
	self._collCopy.sp[a] = e._collCopy.sp[a]
	self._collCopy.changed = true
	self._collCopy.immovable[a] = isClass(e.immovableObjects, self) or e._collCopy.immovable[a]
	-- self._collChain:add(e)
end


function Entity:lookAt(e)
	if self:centerX() < e:centerX() then
		self.flip.x = false
		self.velocity.x = math.abs(self.velocity.x)
	else
		self.flip.x = true
		self.velocity.x = -math.abs(self.velocity.x)
	end
end


function Entity:isLookingAt(e)
	if self:centerX() < e:centerX() then
		return not self.flip.x
	else
		return self.flip.x
	end
end


function Entity:lookAway(e)
	if self:centerX() < e:centerX() then
		self.flip.x = true
		self.velocity.x = -math.abs(self.velocity.x)
	else
		self.flip.x = false
		self.velocity.x = math.abs(self.velocity.x)
	end
end


function Entity:isLookingAway(e)
	if self:centerX() < e:centerX() then
		return self.flip.x
	else
		return not self.flip.x
	end
end



local function addToList(t, ...)
	if not t then t = {} end
	for i,v in ipairs({...}) do
		table.insert(t, v)		
	end
	return _.set(t)
end


function Entity:addIgnoreOverlap(...)
	self.ignoreOverlap = addToList(self.ignoreOverlap, ...)
end


function Entity:addIgnoreCollision(...)
	self.ignoreCollision = addToList(self.ignoreCollision, ...)
end


function Entity:addImmovableObjects(...)
	self.immovableObjects = addToList(self.immovableObjects, ...)
end


  -- ☐ beter delay function for entity. Start with delay for consistency. And maybe delay(1, "test", true) for properties?
function Entity:delay(t, f, args)
	if type(f) == "table" then
		self.tick:delay(t or 1, function () for k,v in pairs(f) do self[k] = v end end)
	else
		self.tick:delay(t or 1, function () if type(f) == "string" then self[f](self, unpack(args or {})) else f(unpack(args or {})) end end)
	end
end


function Entity:tween(t, x, y)
	x = type(x) == "table" and x or {x = x or self.y, y = y or self.y}
	return self.flux:to(self, t, x)
end


function Entity:event(f, t, l, e)
	t = t or 0.1
	local random = false
	if type(t) == "table" then
		random = true
	end
	return self.coil:add(function ()
		local i = 0
		while (not l) or (i <= l) do
			if f() then
				break
			end
			coil.wait(random and _.random(t[1], t[2]) or t)
			i = i + 1
		end
		if e then e() end
	end)
end


function Entity:emit(name, x, y, ...)
	x = x or 0
	y = y or 0
	if self.world then
		self.world:addParticle(name, self:centerX() + x, self:centerY() + y, ...)
	end
end


function Entity:__tostring()
	return _.tostring(self, "Entity")
end

return Entity
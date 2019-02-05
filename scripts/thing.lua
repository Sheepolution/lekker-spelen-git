Thing = Entity:extend("Thing")

Thing.gravity = 1600
-- Thing.gravity = 900


function Thing:new(...)
	Thing.super.new(self, ...)
	self:addShader("rgb")
	self:send("amount", 1)
	self:setShader()
	self.canDie = true

	self.SFX = {}

	self.pixelChance = 2
	self.canGetSquashed = false

end


function Thing:update(dt)
	if self.velocity.y > 0 then
		self.grounded = false
	end
	
	-- if self.velocity.y < 0 then
	if not self.floating then
		self.accel.y = self.gravity
	end
	-- else
		-- self.accel.y = self.gravity * 1
	-- end

	Thing.super.update(self, dt)
end


function Thing:onOverlap(e, mine, his)
	if e:is(SolidTile) then
		if e:is(HalfTile) then
			if e.through then
				if mine:bottom(true) > his:top(true) then
					return false
				end
			end
		end
	end
	return Thing.super.onOverlap(self, e, mine, his)
end


function Thing:onSeparate(e, a, mine, his)
	local diff = math.abs(self.last[a] - self[a])
	-- printif(self:is(Peter), e, a, mine, his, diff, mine:bottom(true), his:top(true), mine:bottom(true) < his:top(true))
	if diff > 10 and diff > math.abs(self.velocity[a]) then
		if e:is(TriggerWall) or e:is(Box) then
			self.x = self.last.x
			self.y = self.last.y
			self:getSquashed()
		end
	end
	Thing.super.onSeparate(self, e, a, mine, his)
		-- printif(self:is(Peter), mine.parent.solid, his.parent.solid)
	if mine:bottom(true) < his:top(true) then
		self:onGrounding()
	end
end


function Thing:onGrounding()
	if not self.floating then
		self.grounded = true
	end
end


function Thing:onFalling()

end


function Thing:getSquashed()
	if self.canGetSquashed then
		self:kill()
	end
end


function Thing:getImagePixelPositions(chance)
	pixels = {}

	local x, y, w, h = self._frames[self.anim:getQuad()]:getViewport()
	local frame = love.image.newImageData(w, h)
	frame:paste(self.imageData, 0, 0, x, y, w, h)

	frame:mapPixel(function (x, y, r, g, b, a)
		if a > 0 then
			if _.chance(chance or self.pixelChance) then
				local nx = x
				if self.flip.x then nx = self.width - x end
				table.insert(pixels, {x = self.x + nx, y = self.y + y})
			end
		end
		return x, y, r, g, b, a
	end)

	return pixels
end


function Thing:kill()
	if not self.canDie then return end
	if not self.dead then
		self:stopMoving()
		self.anim:stop()
		Thing.super.kill(self)

		local alpha_speed = 0.2

		self.gravity = 0

		self.flux:to(self, alpha_speed, {alpha = 0})
		:oncomplete(function ()
			if self.SFX.kill then
				self.scene:playSFX(self.SFX.kill)
			end
			self:destroy()
		end)

		local x, y, w, h = self._frames[self.anim:getQuad()]:getViewport()
		local frame = love.image.newImageData(w, h)
		frame:paste(self.imageData, 0, 0, x, y, w, h)

		self:stopMoving()

		local pixels = self:getImagePixelPositions()

		for i,v in ipairs(pixels) do
			local pixel = TwitchPixel(v.x, v.y,  v.x, v.y - 10)
			self.scene:addParticle(pixel)
		end
	end
end


function Thing:hit()
	if self.beingDamaged then return end
	self.beingDamaged = true
	self:event(function () self.visible = not self.visible end, 0.1, 8, function () self.visible = true self.beingDamaged = false end)
end
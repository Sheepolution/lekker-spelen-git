Chill = Enemy:extend("Chill")

Chill:implement(Locator)

Chill.green = {51/255, 219/255, 53/255, .5}
Chill.red = {228/255, 59/255, 68/255, .5}

function Chill:new(...)
	Chill.super.new(self, ...)
	self:setImage("enemies/lekker_chill", 2)
	self.anim:add("mad", 2)
	self.anim:add("chill", 1)

	self.solid = 0
	self.speed = 100
	self.floating = true
	self.jumpToKill = true


	self.timer = 0
	self.chill = true
	self.radiation = 0
	self.radiationAlpha = 1
	self.radiationChill = true
	self:radiate()

	self.autoFlip.x = false
end


function Chill:update(dt)

	-- print(self.madTimer.timer)
	-- if self.madTimer(dt) then
	-- 	self.chill = true
	-- 	self.anim:set("chill")
	-- end

	self:stopMoving()

	if not self.dead then
		self:findTarget(Player, 400)
		self:findTargets(Player)
	end

	self.timer = self.timer + dt
	-- self.offset.y = math.sin(self.timer * PI * .4) * 10
	Chill.super.update(self, dt)

end


function Chill:draw()
	local r, g, b = unpack(self.radiationChill and Chill.green or Chill.red)
	love.graphics.setColor(r, g, b, self.radiationAlpha)
	love.graphics.circle("fill", self:centerX(), self:centerY(), self.radiation, 50)
	love.graphics.setColor(r, g, b, self.radiationAlpha * 10)
	love.graphics.circle("line", self:centerX(), self:centerY(), self.radiation, 50)
	Chill.super.draw(self)
end


function Chill:radiate()
	self.radiation = 0
	self.radiationAlpha = 1
	if self.chill then
		self.radiationChill = true
	else
		if not self.radiationChill then
			self.radiationChill = true
			self:goChill()
		else
			self.radiationChill = false
		end
	end
	self.flux:to(self, self.chill and 1 or .5, {radiation = 100, radiationAlpha = 0})
	:oncomplete(self.wrap:radiate())
	:delay(self.chill and 1 or .2)
end


function Chill:onFindingTarget(target, distance)
	if self.radiation == 0 then
		self:moveToEntity(target)
	end
end


function Chill:onFindingTargets(targets, distance)
	for i,v in ipairs(targets) do
		if self.radiation > 0 and self.radiationAlpha > 0.1 then
			if v.distance < self.radiation then
				if self.radiationChill then
					self:goMad()
					v.target:slowDown(1)
				else
					v.target:hit()
					v.target:stopSlowDown()
				end
			end
		end
	end
end


function Chill:goChill()
	self.chill = true
	self.anim:set("chill")
end


function Chill:goMad()
	self.chill = false
	self.anim:set("mad")
end
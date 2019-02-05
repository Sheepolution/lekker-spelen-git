GUI = Object:extend("GUI")
local GUIHeart = require "guiprops.guiheart"

function GUI:new()
	self.x = 0
	self.y = -300

	self.hideY = -300 
	self.showY = 0 
	self.hearts = buddies.new()
	self.deadHearts = buddies.new()

	self.peterEnTimon = Sprite(15, 15, "gui/peterentimon") 
	self.peterEnTimon.border:set(1)
	self.peterEnTimon.border.color = {255, 255, 255}

	self.health =  Game.health


	for i=1,self.health do
		local heart = GUIHeart(self:getHeartPosition(i))
		self.hearts:add(heart)
	end

	self.euro = Sprite(23, 70, "pickupables/lekkereuro", 24)
	self.euro.anim:add("idle")
	self.euro.border:set(1)
	self.euro.border.color = {255, 255, 255}

	self.euroText = Text(68, 72, Game.euros, "sheepixel", 32)
	self.euroText.border:set(2)

	if DATA.options.game.speedrun then
		self.timeText = Text(23, 116, "Tijd:", "sheepixel", 32)
		self.timeText.border:set(2)
		self.timeText:write("Tijd: " .. Utils.secondsToClock(DATA.time))
	end

	self.visible = true

	self.flux = flux.group()
end


function GUI:update(dt)
	self.hearts:update(dt)
	self.deadHearts:update(dt)

	self.deadHearts:removeIf(function (e) return e.destroyed end)

	self.euro:update(dt)

	if DATA.options.game.speedrun then
		self.timeText:write("Tijd: " .. Utils.secondsToClock(DATA.time))
	end

	self.flux:update(dt)
end


function GUI:draw()
	if not self.visible then return end
	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	self.peterEnTimon:draw()

	self.deadHearts:draw()
	self.hearts:draw()

	self.euro:draw()
	self.euroText:draw()

	if DATA.options.game.speedrun then
		self.timeText:draw()
	end

	love.graphics.pop()
end


function GUI:updateEuros()
	self.euros = Game.euros
	self.euroText:write(self.euros)
end


function GUI:updateHealth()
	local oldhealth = self.health
	self.health = Game.health

	if oldhealth == 0 then
		return
	end

	if oldhealth < self.health then
		self:gainHearts(self.health - oldhealth)
	else
		self:loseHearts(oldhealth - self.health)
	end
end


function GUI:gainHearts(amount)
	for i=1,amount do
		self.hearts:add(GUIHeart(self:getHeartPosition(#self.hearts + 1)))
	end
end


function GUI:loseHearts(amount)
	if #self.hearts > 0 then
		self.hearts[self.health+1]:kill()
		self.deadHearts:add(self.hearts[self.health + 1])
		self.hearts:remove(self.health + 1)
	end
end


function GUI:getHeartPosition(i)
	return 25 + i * 35, 20
end


function GUI:enter()
	self.flux:to(self, 0.5, {y = self.showY})
end


function GUI:leave()
	self.flux:to(self, 0.5, {y = self.hideY})
end
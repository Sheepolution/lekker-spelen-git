TwitchPixel = Entity:extend("TwitchPixel")

function TwitchPixel:new(x, y, tx, ty)
	TwitchPixel.super.new(self, x, y)
	self:setImage("particles/twitch_pixel", 3)
	self.anim:add("size", math.random(1,2))

	self.scale:set(0)
	self.flux:to(self.scale, 0.3, {x = 1, y = 1})
	self.flux:to(self, Player.teleportTime, {x=tx, y=ty})
	:delay(_.random(0.05, .2))
	:after(self.scale, 0.3, {x = 0, y = 0})
	:oncomplete(function () self:destroy() end)
end


function TwitchPixel:draw()
	-- self.alpha = 0.5
	-- local x, y = self.x, self.y
	-- self.x = self.last.x, self.last.y
	-- TwitchPixel.super.draw(self)

	-- self.x, self.y = x, y
	self.alpha = 1
	TwitchPixel.super.draw(self)
end
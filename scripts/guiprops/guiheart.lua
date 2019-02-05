local GUIHeart = Sprite:extend("GUIHeart")

function GUIHeart:new(...)
	GUIHeart.super.new(self, ...)
	self:setImage("pickupables/lekkerlief", 26)
	self.anim:add("beat", "1>12", nil, "once"):after("idle")
	self.anim:add("die", "20>26|26|26|26", nil, "once")
	self.anim:add("idle", 1)
	self.border:set(1)
	self.border.color = {255, 255, 255}
	self.scale:set(0)
	self.flux:to(self.scale, 0.4, {x = 1, y = 1})
end


function GUIHeart:update(dt)
	GUIHeart.super.update(self, dt)

	if not self.dead then
		if _.chance(0.04) then
			self.anim:set("beat")
		end
	end
end


function GUIHeart:draw()
	GUIHeart.super.draw(self)
end


function GUIHeart:kill()
	self.dead = true
	self.anim:set("die")
	self.flux:to(self, 0.5, {alpha = 0})
	:delay(0.6)
	:oncomplete(function () self.destroyed = true end)
	:onstart(function () self.border:set(0) end)
end


return GUIHeart
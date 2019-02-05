Pickupable = Thing:extend("Pickupable")

function Pickupable:new(...)
	Pickupable.super.new(self, ...)
	self.pickupable = true

	self.z = ZMAP.Pickupable
	
	self.border:set(1)
	self.border.color = {255, 255, 255}
end


function Pickupable:update(dt)
	Pickupable.super.update(self, dt)
end


function Pickupable:draw()
	Pickupable.super.draw(self)
end


function Pickupable:onOverlap(e, mine, his)
	if self.pickupable then
		if mine.name == "solid" and his.name == "solid" and e:is(Player) then
			self:onPickedUp()
		end
	end

	return Pickupable.super.onOverlap(self, e, mine, his)
end


function Pickupable:onPickedUp()
	self:tween(0.3, self.x, self.y - 10)
	self.flux:to(self.scale, 0.3, {x=0, y=0})
	self:kill()
end
require "levelprops/triggers/floorbutton"

FloorButtonPeter = FloorButton:extend("FloorButtonPeter")

function FloorButtonPeter:new(...)
	FloorButtonPeter.super.new(self, ...)
	self:setImage("levelprops/triggers/button", 8)
	self.anim:add("down", 8)
	self.anim:add("up", 7)
end

function FloorButtonPeter:onOverlap(e, mine, his)
	if not e:is(Peter) and not e:is(Tile) and not e.carryingPeter then
		return
	end
	return FloorButtonPeter.super.onOverlap(self, e, mine, his)
end
require "levelprops/triggers/floorbutton"

FloorButtonBox = FloorButton:extend("FloorButtonBox")

function FloorButtonBox:new(...)
	FloorButtonBox.super.new(self, ...)
	self:setImage("levelprops/triggers/button", 8)
	self.anim:add("down", 4)
	self.anim:add("up", 3)
end


function FloorButtonBox:onOverlap(e, mine, his)
	if not e:is(Box) and not e:is(SolidTile) then
		return
	end
	return FloorButtonBox.super.onOverlap(self, e, mine, his)
end
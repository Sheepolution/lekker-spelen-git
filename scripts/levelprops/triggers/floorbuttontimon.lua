require "levelprops/triggers/floorbutton"

FloorButtonTimon = FloorButton:extend("FloorButtonTimon")

function FloorButtonTimon:new(...)
	FloorButtonTimon.super.new(self, ...)
	self:setImage("levelprops/triggers/button", 8)
	self.anim:add("down", 6)
	self.anim:add("up", 5)
end

function FloorButtonTimon:onOverlap(e, mine, his)
	if not e:is(Timon) and not e:is(Tile) then
		return
	end
	return FloorButtonTimon.super.onOverlap(self, e, mine, his)
end
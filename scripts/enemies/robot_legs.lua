RobotLegs = Sprite:extend("RobotLegs")

RobotLegs.offsets = {
	idle = {{0,0}, {0,0}, {0,0}, {0,-1}, {0,-1}, {0,-1}},
	walk = {{0,0}, {0,0}, {0,-1}, {0,0}, {0,0}, {0,-1}}
}

function RobotLegs:new(...)
	RobotLegs.super.new(self, ...)
	self:setImage("enemies/robot_legs", 8)
	self.anim:add("idle", {1, 1, 1, 2, 2, 2}, nil, nil, RobotLegs.offsets.idle)
	self.anim:add("walk", {3, 4, 5, 6, 7, 8}, nil, nil, RobotLegs.offsets.walk)
end
local map = {
	Tiles = -100,
	LockedDoor = -100,
	Peter = -2,
	Timon = -1,
	Enemy = 20,
	Pickupable = 35,
	NoiseBlock = 40,
	Background = 100,
	Richard = 110,
	TriggerWall = 90
}

--IMRPOVE: Try to find a better method than this.
map.__index = function (self, k)
	return map[k] + math.random()
end

ZMAP = setmetatable({}, map)
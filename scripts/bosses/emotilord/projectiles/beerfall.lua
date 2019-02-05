local BeerFall = Projectile:extend("BeerFall")
local BeerWaves = require "bosses.emotilord.projectiles.beerwaves"

function BeerFall:new(x, y, dir)
	BeerFall.super.new(self, x, y)
	self:setImage("bosses/emotilord/beerfall", 4)
	self.anim:add("idle", "1>4", nil, nil, nil, 2)

	self.gravity = Thing.gravity

	self.floating = false
	self.damaging = false
end


function BeerFall:update(dt)
	BeerFall.super.update(self, dt)
end


function BeerFall:draw()
	BeerFall.super.draw(self)
end



function BeerFall:onOverlap(e, mine, his)
	if e:is(SolidTile) or e:is(BeerWaves) then
			self:destroy()
	end
	return BeerFall.super.onOverlap(self, e, mine, his)
end

return BeerFall
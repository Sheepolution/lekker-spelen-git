require "levelprops/block"

BreakableBlock = Block:extend("BreakableBlock")

BreakableBlock:implement(Locator)

function BreakableBlock:new(...)
	BreakableBlock.super.new(self, ...)

	self.SFX.brokko = SFX("sfx/block_break")

	self.solid = 0
	self.moves = {x = true, y = true}
end


function BreakableBlock:update(dt)

	if not self.dead then
		self:findTarget(BigXD, 250)
	end

	BreakableBlock.super.update(self, dt)
end


function BreakableBlock:draw()
	BreakableBlock.super.draw(self)
end


function BreakableBlock:jump()
	self.dead = true
	
	local sfx = self.scene:playSFX(self.SFX.brokko)
	if sfx then sfx:setPitch(_.random(.9, 1.1)) end

	self.gravity = Thing.gravity
	self.velocity.x = 100
	self.velocity.x = math.random(100, 500)
	self.tick:delay(5, self.wrap:destroy())
end


function BreakableBlock:onFindingTarget(target, distance)
	self:jump()
end
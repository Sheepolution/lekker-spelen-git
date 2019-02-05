require "levelprops/block"

DyingBlock = Block:extend("DyingBlock")

DyingBlock:implement(Locator)

function DyingBlock:new(...)
	DyingBlock.super.new(self, ...)
	self.distance = math.random(100, 400)
	self.SFX.dead = SFX("sfx/block_dead", 1)
end


function DyingBlock:update(dt)

	if not self.dead then
		self:findTarget(Player)
	end

	DyingBlock.super.update(self, dt)
end


function DyingBlock:draw()
	DyingBlock.super.draw(self)
end


function DyingBlock:onFindingTarget(target)
	if self:getDistanceX(target) < self.distance then
		local sfx = self.scene:playSFX(self.SFX.dead)
		if sfx then
			sfx:setPitch(_.random(.9,1.1))
		end
		self:kill()
	end
end
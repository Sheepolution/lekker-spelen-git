OverlapTrigger = Entity:extend("OverlapTrigger")

function OverlapTrigger:new(...)
	OverlapTrigger.super.new(self, ...)
	self.state = xool.new()
	self.solid = 0
	self.target = Player
	self.visible = false
end


function OverlapTrigger:done()
	TriggerWall.super.done(self)
	self.rows, self.height = self.mapObject.width, self.mapObject.height

	self:clearHitboxes()
	self.hitbox = self:addHitbox("solid", self.width, self.height)
end


function OverlapTrigger:update(dt)
	OverlapTrigger.super.update(self, dt)
	if self.state() then
		self:offTrigger()
	end
end


function OverlapTrigger:draw()
	OverlapTrigger.super.draw(self)
end


function OverlapTrigger:onOverlap(e, mine, his)
	if e:is(self.target) then
		if not self.state(true) then
			self:onTrigger()
		end
	end
end


function OverlapTrigger:onTrigger()
	print("BINNEN!!")
end


function OverlapTrigger:offTrigger()
	print("BUIITTENEN!!")
end
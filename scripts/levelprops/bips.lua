Bips = Thing:extend("Bips")


function Bips:new(...)
	Bips.super.new(self, ...)
	self:setImage("levelprops/bips", 6)
	self.anim:add("bounce", "2>6", nil, "once"):after("idle")
	self.anim:add("idle", 1)
	self.offset.x = 4

	self.SFX = SFX("sfx/bips", 2)
	
	self.solid = 0

	self.moves = false
	self.hitbox = self:addHitbox("solid", 0, 10, self.width, self.height * .3)

	self.canGetSquashed = false


end


function Bips:done()
	Bips.super.done(self)
	if self.flip.x then
		self.x = self.x - 6
	else
		self.x = self.x - 1
	end
end


function Bips:update(dt)
	Bips.super.update(self, dt)
end


function Bips:onOverlap(e, mine, his)
	if e:is(Player) then
		if self:fromAbove(his, mine) and e.velocity.y >= 0 then
			self.scene:playSFX(self.SFX)
			self.anim:set("bounce")
		end
	end
end


function Bips:spawn()
	self.alpha = 0
	self.flux:to(self, 0.4, {alpha = 1})

	local pixels = self:getImagePixelPositions(4)
	for i,v in ipairs(pixels) do
		local pixel = TwitchPixel(v.x, v.y,  v.x, v.y - 10)
		self.scene:addParticle(pixel)
	end
end


function Bips:draw()
	Bips.super.draw(self)
end
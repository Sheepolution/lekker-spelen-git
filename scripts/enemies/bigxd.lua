BigXD = Enemy:extend("BigXD") 
function BigXD:new(...)
	BigXD.super.new(self, ...)
	self:setImage("enemies/big_xd")
	self.SFX.laugh = SFX("sfx/laughing", 1)
	self:addIgnoreOverlap(SolidTile)
	self.rotate = .8
	self.floating = true
	self.velocity.x = 0
	self.floorHeight = 32
	self.x = self.x - 500
	self.solid = 0
	self.z = -1000
	self.size = 250
end


function BigXD:update(dt)
	BigXD.super.update(self, dt)

	if self.velocity.x > 0 then
		local sfx = self.scene:playSFX(self.SFX.laugh)
		if sfx then self.lastLaugh = sfx end
	end
	if self.lastLaugh then
		self.lastLaugh:setVolume(math.max(0, 1 - (self:getDistance(self.scene.timon)/800)))
	end

	if self.y > self.floorHeight then
		self.y = self.floorHeight
	end

	if self:getDistance(self.scene.timon) < self.size then
		if self.scene.timon.inControl and not self.scene.timon.dead then
			Game:onDead()
		end
	end

end


function BigXD:draw()
	BigXD.super.draw(self)
end


function BigXD:startMoving()
	self.velocity.x = Player.speed - 5
end
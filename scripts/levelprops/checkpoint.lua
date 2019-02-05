Checkpoint = Thing:extend("Checkpoint")

function Checkpoint:new(...)
	Checkpoint.super.new(self, ...)
	self:setImage("levelprops/lekkerhoor", 17)
	self.anim:add("shake")
	self.anim:add("idle", 1)

	self.SFX.trigger = SFX("sfx/checkpoint")

	self.offset.y = -14
	self.solid = 0
	self.gravity = 0

	self.hitbox = self:addHitbox("solid", self.width/4, 1000)

	self.scale:set(0)
	self.origin.y = self.height
	self.moves = false

	self.checked = false
end


function Checkpoint:update(dt)
	Checkpoint.super.update(self, dt)
end


function Checkpoint:spawn()
	self.flux:to(self.scale, .3, {x = 1, y = 1})
	:oncomplete(function () self.anim:set("shake") end)
	for i=1,60 do
		self.scene:addParticle(Particles.confetti(self:centerX(), self:bottom()))
	end
	self.checked = true
	self.scene.lastCheckpoint = self
	if not DATA.lastCheckpoint or DATA.lastCheckpoint.x ~= self:centerX() then
		self.scene:playSFX(self.SFX.trigger)
	end 
	local x, y = self:center()
	DATA.lastCheckpoint = {x = x, y = y}
	DATA.lastEuros = DATA.euros
	SAVE_DATA()
end


function Checkpoint:onOverlap(e, ...)
	if not self.checked then
		if e:is(Player) then
			self:spawn()
		end
	end
	Checkpoint.super.onOverlap(self, e, ...)
end
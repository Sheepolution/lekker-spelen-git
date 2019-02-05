VeedAwards = Projectile:extend("VeedAwards")

function VeedAwards:new(x, y, split)
	VeedAwards.super.new(self, x, y)
	self:setImage("projectiles/veed_awards", 3)
	self.anim:add("top", 2)
	self.anim:add("bottom", 3)
	self.anim:add("both", 1)

	self.SFX.split = SFX("sfx/veed_split")

	self.hitbox = self:addHitbox("solid", self.width * .5, self.height * .5)

	self.rotate = _.random(-5, 5)
	self:center(x, y)

	self.speed = 400
	self.damaging = true

	self.gravity = Thing.gravity

	self.floating = false

	self.split = split
	if not self.split then
		self.scale:set(0)
		self.flux:to(self.scale, 0.5, {x = 1, y = 1})
	end
end


function VeedAwards:update(dt)
	VeedAwards.super.update(self, dt)
end


function VeedAwards:draw()
	VeedAwards.super.draw(self)
end


function VeedAwards:onOverlap(e, mine, his)
	if e:is(SolidTile) then
		if not self.split then
			self.scene:playSFX(self.SFX.split)
			local va = VeedAwards(0, 0, true)
			self.scene:addEntity(va)
			va:clone(self.last)
			va.split = true
			self.split = true

			self.velocity:set(0)
			va.velocity:set(0)

			self.gravity = 0
			va.gravity = 0

			if _.coin() then
				self.anim:set("top")
				va.anim:set("bottom")
			else
				self.anim:set("bottom")
				va.anim:set("top")
			end

			if _.coin() then
				self.velocity.x = self.speed
				va.velocity.x = -self.speed
				self.rotate = 3
				va.rotate = -3
			else
				self.velocity.x = -self.speed
				va.velocity.x = self.speed
				self.rotate = -3
				va.rotate = 3
			end
		else
			self:kill()
		end
	end
	return VeedAwards.super.onOverlap(self, e, mine, his)
end
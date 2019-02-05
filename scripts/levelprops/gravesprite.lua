GraveSprite = Thing:extend("GraveSprite")

GraveSprite.sprites = {
	dino_frog = {
		image = "dino_frog",
		width = 283,
		height = 162
	},
	old_logo = {
		image = "old_logo",
		frames = 2
	}
}


function GraveSprite:new(...)
	GraveSprite.super.new(self, ...)
	self.solid = 0
end

function GraveSprite:done()
	local sprobj = GraveSprite.sprites[self.sprite]
	if not sprobj then
		self:setImage("grave/" .. self.sprite)
	elseif sprobj.width then
		self:setImage("grave/" .. sprobj.image, sprobj.width, sprobj.height)
	elseif sprobj.frames then
		self:setImage("grave/" .. sprobj.image, sprobj.frames)
	else
		self:setImage("grave/" .. sprobj.image)
	end

	self:center(self.x, self.y)
	self.anim:add("_")
	self.angle = _.random(-.3, .3)
	self:addHitbox("solid", self.width *.75, self.height *.9)

	-- if self.float then
		self.floating = true
		self.timer = 0
		self.gravity = 0
		self.accel.y = 0
	-- end
	self.alpha = .6
end


function GraveSprite:update(dt)
	if self.floating then
		self.timer = self.timer + dt
		self.offset.y = math.sin(self.timer * PI * .25) * 20
	end
	GraveSprite.super.update(self, dt)
end


function GraveSprite:draw()
	GraveSprite.super.draw(self)
end
Koter = Thing:extend("Koter")

Koter.xCenterFloat = 570
Koter.yCenterFloat = 170

function Koter:new(...)
	Koter.super.new(self, ...)
	self:setImage("bosses/emotilord/intro/koter")

	self.floatY = Koter.yCenterFloat

	self.timer = 0

	self.gravity = 0

	self.emotes = {}

	self.transformTimer = 0
	self.transforming = false
	self.transformDistance = 200
	self.transformRotateSpeed = 1

	self.x = Koter.xCenterFloat

	self.floating = true
	self.z = -100

	self.flashHorRect = Rect(-1000, self.height/2, 2000, 0)
	self.flashVerRect = Rect(self.width/2, -1000, 0, 2000)
	self.flashRect = Rect(-1000,-1000, 3000, 3000)
	self.flashRect.alpha = 0

	self.introMusic = Asset.audio("music/koter_intro", "stream")
	self.introMusic:setVolume(GET_MUSIC_VOLUME())
end


function Koter:update(dt)
	self.timer = self.timer + dt

	self.y = self.floatY + math.sin(self.timer * PI * 0.5) * 20

	if self.transforming then
		self.transformTimer = self.transformTimer + dt * self.transformRotateSpeed
		for i,v in ipairs(self.emotes) do
			v:center(self:centerX() + math.cos(self.transformTimer + i) * self.transformDistance, self:centerY() + math.sin(self.transformTimer + i) * self.transformDistance)
		end
	end

	Koter.super.update(self, dt)
end


function Koter:draw()
	Koter.super.draw(self)
	self.flashVerRect:drawAsChild(self)
	self.flashHorRect:drawAsChild(self)
	self.flashRect:draw()
end


function Koter:startTransform()
	local names = {
	"appie",
	"bips",
	"djensen",
	"koppie",
	"lekker1",
	"lekker2",
	"lekker3",
	"lekkeroh",
	"likken",
	"oncto",
	"pils",
	"sicko",
	"sonic",
	"spugen"
	}

	local delay = 3
	self.introMusic:play()

	for i,v in ipairs(names) do
		local s =  Sprite(0, 0, "bosses/emotilord/intro/" ..v)
		s.scale:set(0)
		self.flux:to(s.scale, 0.4, {x=2, y=2}):delay(i/4)
		self.flux:to(s.scale, 3, {x=0, y=0}):delay(#names/4+delay)
		self.scene:addScenery(s)
		table.insert(self.emotes, s)
	end

	self.flux:to(self, 4, { transformRotateSpeed = 10 } ):delay(#names/4):ease("quadin")
	self.flux:to(self, 3, { transformDistance = 0 } ):delay(#names/4 + delay)
	self.tick:delay(#names/4 + delay + 2, function ()
		local a = Emotilord()
		
		self.flux:to(self.flashHorRect, 1, {y = -500, height = 1000 }):ease("quadin")
		:delay(.4)
		self.flux:to(self.flashVerRect, 1, {x = -500, width = 1000 }):ease("quadin")
		:oncomplete(function ()
			self.visible = falsea
			self.flashHorRect.alpha = 0
			self.flashVerRect.alpha = 0
			self.flashRect.alpha = 1
			a.scale:set(1, 1)
			self.flux:to(self.flashRect, 1, {alpha = 0 }):delay(1)
		end)
		:delay(.4)

		-- a.rotating = false
		a.scale:set(0, 0)
		a:center(self:center())
		self.scene:addEntity(a)
		a.timer = self.timer
		-- self.flux:to(a.scale, 3, {x=1, y=1})
		-- :oncomplete(function ()
		self.tick:delay(3.4, function ()
			a.rotating = true
			for i,v in ipairs(self.emotes) do
				v.destroyed = true
			end
			self:destroy()
			self.scene:event("koter_title")
			a:startMove()
		end)
	end)

	self.transforming = true
end
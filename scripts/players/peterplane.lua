PeterPlane = PlayerPlane:extend("PeterPlane")

function PeterPlane:new(...)
	PeterPlane.super.new(self, ...)
	self:setImage("peter_plane", 3)
	self.anim:add("idle")


	if DATA.options.controller.singleplayer then
		self.keys = {
			left = {"j"},
			right = {"l"},
			up = {"i"},
			down = {"k"},
			shoot = {"g"}
		}
	else 
		self.keys = {
			left = {"left"},
			right = {"right"},
			up = {"up"},
			down = {"down"},
			shoot = {"g"}
		}
	end

	self.SFX.hurt = SFX("sfx/hurt_peter")
	self.SFX.shoot = SFX("sfx/shoot_peter")

	self.id = "peter"
	self.player_id = 1
	
	self.hitbox = self:addHitbox("solid", self.width * .6, self.height * .6)

	self.autoFlip.x = false
	self.gravity = 0
	self.z = ZMAP.Peter
	self.speed = 300
end


function PeterPlane:update(dt)
	PeterPlane.super.update(self, dt)
end


function PeterPlane:draw()
	PeterPlane.super.draw(self)
end

TimonPlane = PlayerPlane:extend("TimonPlane")

function TimonPlane:new(...)
	TimonPlane.super.new(self, ...)
	self:setImage("timon_plane", 3)
	self.anim:add("idle")

	self.keys = {
		left = {"a"},
		right = {"d"},
		up = {"w"},
		down = {"s"},
		shoot = {"k"}
	}

	self.SFX.hurt = SFX("sfx/hurt_timon")
	self.SFX.shoot = SFX("sfx/shoot_timon")

	self.id = "timon"
	self.player_id = 2

	self.hitbox = self:addHitbox("solid", self.width * .6, self.height * .6)

	self.autoFlip.x = false
	self.gravity = 0
	self.z = ZMAP.Timon
	self.speed = 350
end


function TimonPlane:update(dt)
	TimonPlane.super.update(self, dt)
end


function TimonPlane:draw()
	TimonPlane.super.draw(self)
end

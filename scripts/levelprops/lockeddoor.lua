require "levelprops/triggers/triggerwall"

LockedDoor = TriggerWall:extend("LockedDoor")

function LockedDoor:new(...)
	LockedDoor.super.new(self, ...)

	self.SFX.unlock = SFX("sfx/unlock_door")

	self.handSprite = Sprite(0, 0, "levelprops/lekkerdeal", 8)
	self.handSprite.anim:add("shake", "2>8"):onComplete(function ()
		self.appearing = false
		self.flux:to(self, 0.5, {alpha = 0}):delay(1)
	end)
	self.handSprite.anim:add("idle", 1)

	self.locked = true
	self.z = ZMAP.LockedDoor
end


function LockedDoor:update(dt)
	self.handSprite:update(dt)
	LockedDoor.super.update(self, dt)
end


function LockedDoor:draw()
	self.handSprite.x = -self.width-13
	self.handSprite.y = -self.height/2-20
	if self.handSprite.visible then
		self.handSprite:drawAsChild(self, {"offset", "alpha"}, true)
	end

	for i=0,self.rows-1 do
		for j=0,self.columns-1 do
			if self.tiles[(self.longestType == "columns" and j or i)+1] then
				self.offset.x = 32 * j
				self.offset.y = 32 * i
				LockedDoor.super.draw(self)
			end
		end
	end
end


function LockedDoor:onOverlap(e, mine, his)
	if self.locked then
		if e:is(Player) and e.holdingKey then
			e:releaseKey()
			self.handSprite.anim:set("shake")
			self.scene:playSFX(self.SFX.unlock)
			self.locked = false
		elseif e.carryingPeter then
			self:onOverlap(e.partner)
		end
	end
	return LockedDoor.super.onOverlap(self, e, mine, his)
end
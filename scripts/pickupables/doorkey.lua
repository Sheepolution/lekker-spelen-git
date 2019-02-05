DoorKey = Thing:extend("DoorKey")


function DoorKey:new(...)
	DoorKey.super.new(self, ...)
	self:setImage("levelprops/hand_key", 2)
	self.anim:add("pickedup", 2)
	self.anim:add("idle", 1)
	
	self.SFX.pickup = SFX("sfx/pickup_key")

	self.border:set(1)
	self.border.color = {255, 255, 255}
end


function DoorKey:update(dt)
	DoorKey.super.update(self, dt)
end


function DoorKey:draw()
	DoorKey.super.draw(self)
end


function DoorKey:onOverlap(e, mine, his)
	if e.teleporting then return end

	if e.canPickUpKeys and not e.draggingSomething then
		e:pickUpKey()
		self.scene:playSFX(self.SFX.pickup)
		self:destroy()
	end

	if e.carryingPeter then
		self:onOverlap(e.partner)
	end

	return DoorKey.super.onOverlap(self, e, mine, his)
end

function DoorKey:onPickedUp()
	-- Game.doorKeys = Game.doorKeys + 1
	-- self.anim:set("pickedup")
	-- DoorKey.super.onPickedUp(self)
end
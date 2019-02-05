Portrait = Sprite:extend()

function Portrait:new(x, y, name)
	Portrait.super.new(self, x, y)
	self:setImage("textbox/portraits/" .. name, 34, 31)
	self.name = name
	local faces = {"neutral", "sad", "angry", "smug"}
	for i=1,self.anim:getNumberOfFrames() do
		self.anim:add(faces[i], i)
	end
	self.anim:set("neutral")
	self.flux = flux.group()
end


function Portrait:update(dt)
	self.flux:update(dt)
end


function Portrait:set(a)
	if self.anim:has(a) then
		self.anim:set(a)
	else
		warning("Trying to set non-existing emotion " .. a .. " on Portrait " .. self.name )
	end

	-- if self.anim then
	-- 	self.x = self.start_x
	-- 	self.anim:stop()
	-- end

	self.offset.x = -30
	self.tween = self.flux:to(self.offset, 0.1, {x = 0}):oncomplete(function () self.tween = nil end)
end


function Portrait:__tostring()
	return lume.tostring(self, "Portrait")
end
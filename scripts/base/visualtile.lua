local VisualTile = Sprite:extend("VisualTile")

function VisualTile:new(map, x, y, img, width, height, tiles)
	VisualTile.super.new(self, 0, 0)
	self:setImage(img, width + 2, height + 2)
	self.scale:set(1.005) --To hide bleeding
	self.tiles = buddies.new(tiles)
	self.map = map
	self.anim:add("frames", "1>" .. self.anim:getNumberOfFrames())
	self.anim:stop()

	self.positions = {}
end


function VisualTile:done()
	-- if #self.positions > 0 then return end
	for i,v in ipairs(self.tiles) do
		local x, y = self.map:getTilePos(v.pos)
		table.insert(self.positions, {x = x, y = y, value = v.value})
	end
end


function VisualTile:add(tile)
	self.tiles:add(tile)
end


function VisualTile:draw()
	if not self.visible then return end
	if DEBUG and Key:isDown("tab") then return end
	for i,v in ipairs(self.positions) do
		self.anim:setFrame(v.value)
		if self.scene.camera then
			local x, y = self.scene.camera:toCameraCoords(v.x, v.y)
			if x >= -self.width and x < WIDTH then
				self:set(v.x, v.y)
				self:drawImageSimple()
				-- VisualTile.super.draw(self)
			end
		else 
			self:set(v.x, v.y)
			self:drawImageSimple()
		end
		-- VisualTile.super.draw(self)
	end
end


function VisualTile:__tostring()
	return lume.tostring(self, "VisualTile")
end

return VisualTile
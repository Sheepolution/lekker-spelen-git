local Scene = Object:extend()

function Scene:new()
	self.entities = buddies.new()
	self.scenery = buddies.new()
	self.particles = buddies.new()
	self.everything = buddies.new(true, self.entities, self.scenery, self.particles)

	self.coil = coil.group()
	self.flux = flux.group()
	self.tick = tick.group()
	self.wrap = wrap.new(self)

	self._cache = {}
end

function Scene:postNew()
	if self.map then
		self.collisionTiles = {}
		self.collisionTilesSize = 50
		local total = (self.map.currentRoom.width * 2) / self.collisionTilesSize
		self.collisionTilesColumns = total
		self.collisionTilesRows = 12
		self:resetCollisionTiles()
		self.notInCollisionTiles = {}
	end
end

local function has_something(e)
	return not e:is(SolidTile)
end

function Scene:update(dt)
	self.everything:update(dt)

	if SAFE_COLL then
		for i=1,2 do
			self.entities:others(function (a, b) a:resolveCollision(b) end)
			if self.map then
				local tiles = self.map:getSolidTiles()
				for i,v in ipairs(tiles) do
					self.entities:resolveCollision(v)
				end
			end
		end
	end

	if not SAFE_COLL then
		for i=1,1 do
			self:resetCollisionTiles()
			self.entities:setCollisionTiles(dt)

			if self.map then
				local tiles = self.map:getSolidTiles()
				for i,v in ipairs(tiles) do
					v.scene = self
					v:setCollisionTiles(dt)
				end
			end

			for q,v in pairs(self.collisionTiles) do
				for q,w in pairs(v) do
					for i=1,#w-1 do
						for j=i+1,#w do
							w[i]:resolveCollision(w[j])
						end
					end
				end
			end
		end
	end

	self.everything:removeIf(function (e) return e.destroyed end)

	if self.camera then
		self.camera:update(dt)
	end

	self.coil:update(dt)
	self.flux:update(dt)
	self.tick:update(dt)
end


function Scene:draw()
	local t = self.everything:clone()
	
	if self.map then
		t:add(unpack(self.map:getVisualTiles()))
	end

	t:sort("z")
	self.everythingSortedToDraw = t

	if self.camera then self.camera:attach() end
		self:drawInCamera()
	if self.camera then self.camera:detach() self.camera:draw() end
end


function Scene:drawInCamera()
	local t = self.everythingSortedToDraw
	t:draw()
	if DEBUG then
		if Key:isDown("tab") then
			if self.map then
				local tiles = self.map:getSolidTiles()
				for i,v in ipairs(tiles) do
					v:drawDebug()
				end
			end
			t:drawDebug()
			if not SAFE_COLL then
				for i,v in pairs(self.collisionTiles) do
					for j,w in pairs(v) do
						love.graphics.setColor(color1 and 0 or 255, color2 and 0 or 255, 255)
						love.graphics.rectangle("line", (j-1) * self.collisionTilesSize, (i-1) * self.collisionTilesSize, self.collisionTilesSize, self.collisionTilesSize )
						love.graphics.print(#w, (j-1) * self.collisionTilesSize + self.collisionTilesSize * .5, (i-1) * self.collisionTilesSize + self.collisionTilesSize * .5)
						love.graphics.setColor(255, 255, 255)
					end
				end
			end
		end
	end

	if self.map then
		self.map:drawBorder()
	end
end


function Scene:addMap(map_url)
	self.map = Tilemap(map_url)
end


function Scene:addEntity(...)
	for i,v in ipairs({...}) do
		self:finishObject(v)
		self.entities:add(v)
	end
	return ({...})[1]
end


function Scene:addScenery(...)
	for i,v in ipairs({...}) do
		self:finishObject(v)
		self.scenery:add(v)
	end
	return ({...})[1]
end


function Scene:addLoadedEntity(v)
	if v._HAS_SCENE then return end
	-- local count = self.entities:count(function (e) return v == e end)
	-- if count > 0 then return end
	v._HAS_SCENE = true
	self.entities:add(v)
	if not v.scene then
		self:finishObject(v)
	end 
	return v
end


function Scene:removeEntity(v)
	if not v._HAS_SCENE then return end
	v._HAS_SCENE = false
	self.entities:remove(v)
	-- self.entities:removeIf(function (e) return e == v end)
end


function Scene:finishObject(obj)
	obj.scene = self
	obj._HAS_SCENE = true
	obj:done()
end

--TODO: Move this to emit in Entity/Sprite
function Scene:addParticle(name, ...)
	local p = type(name) == "table" and name or Particles[name](...)
	p.scene = self
	self.particles:add(p)
end


function Scene:findEntity(f)
	return self.entities:find(f)[1]
end


function Scene:findEntities(f)
	return self.entities:find(f)
end


function Scene:findEntitiesOfType(a, f)
	local t
	if f then
		t = self.entities:find(function (x) return x:is(a) and f(x) end)
	else
		t = self.entities:find(function (x) return x:is(a) end)
	end
	return t
end


function Scene:findEntityOfType(a, f)
	return self:findEntitiesOfType(a, f)[1]
end


function Scene:findNearestEntity(p, f)
	local d = math.huge
	local d2, e
	for i,v in ipairs(self.entities:find(f)) do
		d2 = v:getDistance(p)
		if d2 < d then
			e = v
			d = d2
		end
	end
	return e, d
end


function Scene:findNearestEntityOfType(p, a, f)
	local d = math.huge
	local d2, e
	for i,v in ipairs(self:findEntitiesOfType(a, f)) do
		d2 = v:getDistance(p)
		if d2 < d then
			e = v
			d = d2
		end
	end
	return e, d
end


function Scene:resetCollisionTiles()
	self.collisionTiles = {}
	-- for i=1,self.collisionTilesRows do
	-- 	self.collisionTiles[i] = {}
	-- 	for j=1,self.collisionTilesColumns do
	-- 		self.collisionTiles[i][j] = {}
	-- 	end
	-- end
end


-- local dirs = {
-- {-1,-1}, {0,-1}, {1,-1},	
-- {-1, 0}, {0, 0}, {1, 0},
-- {-1, 1}, {0,-1}, {1, 1}
-- }

function Scene:coordsToCollisionTiles(obj, left, right, top, bottom)
	-- print(left, top, right, bottom)
	local x1, y1 = self:getCollisionTilePos(left, top)
	local x2, y2 = self:getCollisionTilePos(right, bottom)

	local is_tile = obj:is(SolidTile)

	local add = is_tile and 0 or 1

	for i=y1-add,y2+add do
		if i > 0 and i <= self.collisionTilesRows then
			for j=x1-add,x2+add do
				if j > 0 and j <= self.collisionTilesColumns then
					local skip = false
					if not self.collisionTiles[i] then if is_tile then skip = true end self.collisionTiles[i] = {} end
					if not self.collisionTiles[i][j] then if is_tile then skip = true else self.collisionTiles[i][j] = {} end end
					if not skip then
						table.insert(self.collisionTiles[i][j], obj)
					end
				end
			end
		end
	end
end


function Scene:getCollisionTilePos(x, y)
	x = math.floor(x / self.collisionTilesSize)
	y = math.floor(y / self.collisionTilesSize)
	return x+1, y+1
end


function Scene:__tostring()
	return lume.tostring(self, "Scene")
end

return Scene
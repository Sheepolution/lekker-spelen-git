Tilemap = Object:extend("Tilemap")

function Tilemap:new(scene, map)
	self.scene = scene

	self.currentRoom = nil
	self.currentID = nil
	
	self.newRoomHandler = nil
	self.objectHandler = nil
	self.layerHandler = nil

	self.mergeTiles = true

	self.entities = buddies.new()

	if map then
		self:loadMap(map)
	end

	self._cache = {}
end


function Tilemap:update(dt)
	if self.follow then
		self:preloadObjectsNearFollow()
		self:preloadRoomsNearFollow()
		if not self:overlapsWithRoom(self.follow) then
			self:enableFollowRoom()
		end
	end
end


function Tilemap:draw()
	for i,v in ipairs(self.rooms) do
		Data.add("drawcalls", -1)
		v.rects:draw("line")
	end
	for i,v in ipairs(self.tiles) do
		v:drawDebug()
	end
end


function Tilemap:drawBorder()
	for i,v in ipairs(self.rooms) do
		if v ~= self.currentRoom then
			for i,rect in ipairs(v.rects) do
				rect:draw()
			end
		end
	end
end


function Tilemap:loadMap(name)
	-- Loading map
	local map = love.filesystem.read("assets/maps/" .. name .. ".json")
	assert(map, "The room assets/maps/" .. name .. ".json doesn't exist")
	
	self.mapData = json.decode(map)

	-- Some map data
	self.columns = self.mapData.width
	self.tileWidth = self.mapData.tilewidth
	self.tileHeight = self.mapData.tileheight

	self.layers = self.mapData.layers
	self.mapProperties = self:getProperties(self.mapData.properties)

	-- Set the background if there is one
	if self.mapProperties.background then
		self.background = Asset.image(self.mapProperties.background)

		--TODO: Add option in tilemap
		self.backgroundRepeat = true
	end

	-- Load the tilesets
	for i,v in ipairs(self.mapData.tilesets) do
		local set = {}
		local tileset_json = love.filesystem.read("assets/maps/" .. v.source)

		set = json.decode(tileset_json)
		set.properties = self:getProperties(set.properties)
		set.image = set.image:gsub(".-images/", ""):gsub("%.png", "")
		set.firstgid = v.firstgid
		set.source = v.source
		set.tiles = set.tiles or {properties = {}}
		local newtiles = {}
		for i,v in ipairs(set.tiles) do
			newtiles[v.id+1] = {}
			newtiles[v.id+1].properties = self:getProperties(v.properties) 
		end
		set.tiles = newtiles

		self.mapData.tilesets[i] = set
	end

	-- Find a layer named rooms
	local rooms = _.match(self.layers, function (a) return a.name == "rooms" end)

	--TODO if not rooms then createRoom with all tiles

	-- If the tilemap has rooms..
	if rooms then

		-- Split the map into rooms
		self:splitMapInRooms(rooms)

		for i,v in ipairs(self.layers) do
			v.properties = self:getProperties(v.properties)
			if v.name == "objects" then
				for i,obj in ipairs(v.objects) do
					-- if obj.name == self.followName then
					-- 	self.follow = obj
					-- end
				end
			end
		end

		for i,v in ipairs(self.rooms) do
			self:fillRoom(i)
		end

		if self.follow then
			self:enableFollowRoom(true)
		else
			-- TODO:Load room with "start" or something
			self:fillRoom(1, true)
			self.rooms[1].active = true
			self.currentRoom = self.rooms[1]
			if self.scene.camera then
				self.scene.camera:setBounds(self.currentRoom.left, self.currentRoom.top, self.currentRoom.right - self.currentRoom.left, self.currentRoom.bottom - self.currentRoom.top)
			end
		end
	else

		--if not then load everything
		--TODO: Add this function
		-- self:loadAll()
	end
end

-- TODO: Rooms niet splitten op de helft. Tenzij je offset gebruikt.
function Tilemap:splitMapInRooms(rooms)
	self.rooms = {}
	local merge = {}

	for i,v in ipairs(rooms.objects) do
		local r = Rect()
		r.color = {0, 0, 0}
		r.x, r.y = v.x, v.y
		r.width, r.height = v.width, v.height
		
		local data = {}

		data.start = self:positionToIndex(v.x, v.y)
		data.stop = self:positionToIndex(v.x + v.width - self.tileWidth, v.y + v.height - self.tileHeight)

		data.left, data.top = self:positionToMap(v.x, v.y)
		data.right, data.bottom = self:positionToMap(v.x + v.width - self.tileWidth, v.y + v.height - self.tileHeight)

		r.numbers = self:getNumbersInRoom(data)

		if v.properties then
			r.tag = v.properties.tag
		end

		if r.tag then
		 	if not merge[r.tag] then merge[r.tag] = {} end
			table.insert(merge[r.tag], r)
		else
			table.insert(self.rooms, self:createRoom({r}))
		end
	end

	-- Merge the rooms with tags
	for k,v in pairs(merge) do
		local room = self:createRoom(v)
		table.insert(self.rooms, room)
	end
end


function Tilemap:createRoom(t)
	local room = {}

	room.ready = false
	room.active = false
	room.rects = buddies.new(unpack(t))
	room.numbers = {}
	room.id = #self.rooms + 1
	room.map = {
		tiles = {},
		visuals = {},
		entities = {}
	}

	-- CLEANUP: This is pretty ugly
	-- TODO Misschien gewoon volledige uitschruiven, of met een functie doen ofzo. Dit is best wel onduidelijk inderdaad.

	local props1 = {"left", "top"}
	local props2 = {"right", "bottom"}

	for i,r in ipairs(t) do
		room.numbers = _.concat(room.numbers, r.numbers)
		if room.left then
			for i,v in ipairs(props1) do
				local a = r[v](r)
				if a < room[v] then
					room[v] = a
				end
			end
			for i,v in ipairs(props2) do
				local a = r[v](r)
				if a > room[v] then
					room[v] = a
				end
			end
		else
			for i,v in ipairs(props1) do
				room[v] = r[v](r)
			end
			for i,v in ipairs(props2) do
				room[v] = r[v](r)
			end
		end
	end

	room.width = room.right - room.left
	room.height = room.bottom - room.top

	-- Doing this will cause the numbers to go out of order, so don't.
	-- room.numbers = _.set(room.numbers)

	return room
end


-- TODO: Zet er op z'n minst even commentaar bij
function Tilemap:getNumbersInRoom(room_data)
	local t = {}
	for i=room_data.start, room_data.stop do
		local x = self:getMapX(i)
		if x >= room_data.left and x <= room_data.right then
			table.insert(t, i)
		end
	end

	return t
end


function Tilemap:enableFollowRoom(first)
	local room, i = _.match(self.rooms, function (a)
		--Search for the room that we need to init
		return self:overlapsWithRoom(a, self.follow) and a ~= self.currentRoom
	end)

	if i then
		self:disableRoom()

		if not room.ready then
			self:fillRoom(i)
		end

		room.active = true
		self.currentRoom = room

		self.scene.camera:setBounds(self.currentRoom.left, self.currentRoom.top, self.currentRoom.right - self.currentRoom.left, self.currentRoom.bottom - self.currentRoom.top)
		-- self:loadRoom(i)
	end
end


function Tilemap:disableRoom(i)
	local room = self.rooms[i] or self.currentRoom
	-- room.active = false
end


function Tilemap:fillRoom(i, first)
	local prev = self.currentID
	self.currentID = i
	local room = self.rooms[i]

	if room.ready then return end

	-- print("Filling room " .. i, first)

	for i,layer in ipairs(self.mapData.layers) do
		if layer.type == "tilelayer" then
			if layer.properties.type == "solid" then
				self:handleSolidLayer(layer, room)
			else
				self:handleVisualLayer(layer, room)
			end
		else
			if layer.name ~= "rooms" then
				self:handleObjectLayer(layer, room)
			end
		end
	end

	for i,v in ipairs(room.map.visuals) do
		v:done()
	end

	room.ready = true
	room.active = true
end


function Tilemap:preloadRoom(i)
	if not self.rooms[i].ready then
		self:fillRoom(i)
	end
	self.rooms[i].active =true
end


function Tilemap:destroyRoom(i, new)
	self.rooms[i].map = {
		tiles = {},
		visuals = {},
		entities = {}
	}
	self.rooms[i].ready = false
	self.rooms[i].active = false
end

-- TODO: Fix die properties. En gewoon alles fixen eigenlijk.
function Tilemap:handleSolidLayer(layer, room)
	local room = room or self.currentRoom

	if room.ready then return end

	-- For positions we already handled
	local ignores = {}

	-- TODO: Add randomseed as property
	math.randomseed(1)

	-- TODO: Maak een room aan als je er geen hebt. Als in je hebt standaard 1 room gewoon.
	for n,tile_position in ipairs(room.numbers) do
		tile_value = layer.data[tile_position]

		if tile_value ~= 0 and not ignores[tile_position] then

			-- Some numbers appear multiple times in a room
			ignores[tile_position] = true

			local tileset
			local tile_data
			local tile

			-- Get the correct tileset used based on the first gid.
			for i,set in ipairs(self.mapData.tilesets) do
				if tile_value >= set.firstgid then
					tileset = set
				end
				if tile_value < set.firstgid or i == #self.mapData.tilesets then
					tile_value = tile_value - tileset.firstgid + 1
					break
				end
			end

			tile_data = tileset.tiles[tile_value] or { properties = {}}

			local typ = tile_data.properties.type or "SolidTile"
			typ = _.value(typ)

			--Merge tiles
			local xlen, ylen = 1, 1
			local j = 1

			-- TODO: Maak hier een property van. Layer of tilemap?
			if self.mergeTiles then
				while true do
					if layer.data[tile_position + j]
					and layer.data[tile_position + j] == tile_value
					and self:getTileX(tile_position + j) < room.right then
						-- Check if you're at the end of the map/reading the next line
						-- if (j > 1) then
							if self:getTileY(tile_position) ~= self:getTileY(tile_position + j) or tile_position + j == #layer.data then
								break
							end
						-- end
						ignores[tile_position + j] = true
						xlen = xlen + 1
					else
						break
					end
					j = j + 1
				end

				j = 1

				local lwidth = layer.width

				while xlen == 1 do
					if layer.data[tile_position + j * lwidth]
					and layer.data[tile_position + j * lwidth] == tile_value
					and self:getTileY(tile_position + j * lwidth) < room.bottom then
						ignores[tile_position + j * layer.width] = true
						ylen = ylen + 1
					else
						break
					end
					j = j + 1
				end
			end
			---------

			tile = typ(self:getTileX(tile_position), self:getTileY(tile_position),
			self.tileWidth * xlen, self.tileHeight * ylen, tile_value)
			tile.room = room

			for k,v in pairs(layer.properties) do
				tile[k] = _.value(v)
			end

			for k,v in pairs(tileset.properties) do
				tile[k] = _.value(v)
			end

			for k,v in pairs(tile_data.properties) do
				tile[k] = _.value(v)
			end

			table.insert(room.map.tiles, tile)
			tile:done()
		end
	end
	math.randomseed()
end


function Tilemap:handleVisualLayer(layer, room)
	local room = room or self.currentRoom

	if room.ready then return end

	-- For positions we already handled
	local ignores = {}

	local visual_tiles = room.map.visuals

	-- TODO: Add randomseed as property
	math.randomseed(1)

	-- TODO: Maak een room aan als je er geen hebt. Als in je hebt standaard 1 room gewoon.
	for n,tile_position in ipairs(room.numbers) do
		tile_value = layer.data[tile_position]

		if tile_value ~= 0 and not ignores[tile_position] then

			-- Some numbers appear multiple times in a room
			ignores[tile_position] = true

			local tileset
			local tileset_number
			local tile_data
			local tile
			local visual_tile

			-- Get the correct tileset used based on the first gid.
			for i,set in ipairs(self.mapData.tilesets) do
				if tile_value >= set.firstgid then
					tileset = set
				end
				if tile_value < set.firstgid or i == #self.mapData.tilesets then
					tile_value = tile_value - tileset.firstgid + 1
					tileset_number = i
					break
				end
			end

			local visual_id = layer.id .. "_" .. tileset_number

			--For when tiles have multiple images (grass1, grass2..)
			-- if tile. and tilesetprops.amount then
			-- 	img = tileset.image:sub(1, -2)
			-- 	img = img .. math.random(tonumber(tilesetprops.amount))
			-- else
				local img = tileset.image
			-- end

			tile_data = tileset.tiles[tile_value] or {properties = {}}

			local typ = tile_data.properties.type or "VisualTile"
			typ = _.value(typ)

			if not visual_tiles[visual_id] then
				tile = typ(self, self:getTileX(tile_position), self:getTileY(tile_position), img,
				self.tileWidth, self.tileHeight)

				tile.offset:set(layer.offsetx, layer.offsety)
				tile.scene = self.scene

				visual_tiles[visual_id] = tile
				tile.room = room
				table.insert(room.map.visuals, tile)

				local layer_props = self:getProperties(layer.properties)

				for k,v in pairs(layer_props) do
					tile[k] = _.value(v)
				end

				if tileset.properties then
					for k,v in pairs(tileset.properties) do
						tile[k] = _.value(v)
					end
				end
			else
				tile = visual_tiles[visual_id]
			end

			for k,v in pairs(layer.properties) do
				tile[k] = _.value(v)
			end
			
			for k,v in pairs(tile_data.properties) do
				tile[k] = _.value(v)
			end

			tile:add({pos=tile_position, value=tile_value})
		end
	end

	for i,v in pairs(visual_tiles) do
		-- v:done()
	end

	math.randomseed()
end


-- TODO: Wtf doet deze functie? Doe even commentaar plaatsen
-- Oh dit is zodat je kan zeggen obj.velocity.x = 100 denk ik?
-- Moet ie local zijn though? Dan zijn er wel meer functies die local kunnen zijn volgens mij
local function prop(obj, name, value)
	local list = _.split(name, ".")
	for i,v in ipairs(list) do
		if i < #list then
			obj = obj[v]
		end
	end
	obj[list[#list]] = value
end


function Tilemap:getProperties(properties)
	if not properties then return {} end

	local fixed_properties = {}

	for i,property in ipairs(properties) do
		local name, typ, value  = property.name, property.type, property.value
		if typ == "int" or typ == "float" then
			typ = "number"
		elseif typ == "color" then
			typ = "table"
			local r, g, b, a = _.color(value, 255)
			value = {r, g, b, a}
		end
		if type(value) == "string" and type ~= "string" then
			value = _.convert(value, typ)
		end
		fixed_properties[name] = value
	end

	return fixed_properties
end


function Tilemap:handleObjectLayer(layer, room)
	for i,v in ipairs(layer.objects) do
		if self:overlapsWithRoom(room, v) then

			assert(GLOBAL[v.name], "The class " .. v.name .. " does not exist.")
			local ent = GLOBAL[v.name](v.x, v.y)
			ent.mapObject = v
			if ent.width == 0 then
				ent.width = v.width
				ent.height = v.height
			end
			
			--Set properties
			if v.properties then

				local props = self:getProperties(v.properties)

				-- if props.pass then 
					-- ent.mapObject = v
					-- props.pass = false
				-- end

				for k,p in pairs(props) do
					prop(ent, k, _.value(p))
				end
			end

			if layer.properties.scenery then
				self.scene:addScenery(ent)
			else
				if ent._static then
					self.scene:addEntity(ent)
				else
					self.entities:add(ent)
				end
				-- end
				-- self.scene:addEntity(ent)
			end

			-- self.objectHandler(ent)
		end
	end
end


function Tilemap:handleEventsLayer(layer)
	for i,v in ipairs(layer.objects) do
		if self:overlapsWithRoom(v) then
			local event = Event(v.name, v.x, v.y, v.width, v.height)
			if v.properties then
				for k,p in pairs(v.properties) do
					prop(event, k, _.value(p))
				end
			end

			self.eventHandler(event)
		end
	end
end


function Tilemap:getSolidTiles()
	local t = {}
	for i,v in ipairs(self.rooms) do
		if v.active then
			for i,s in ipairs(v.map.tiles) do
				table.insert(t, s)
			end
		end
	end
	return t
end


function Tilemap:getVisualTiles()
	return _.list(self.currentRoom.map.visuals)
end


function Tilemap:getTileX(i)
	i = i - 1
	return (i % self.columns) * self.tileWidth
end


function Tilemap:getTileY(i)
	i = i - 1
	return math.floor(i/self.columns) * self.tileHeight
end


function Tilemap:getTilePos(i)
	return self:getTileX(i), self:getTileY(i)
end


function Tilemap:getMapX(i)
	i = i - 1
	return (i % self.columns)
end


function Tilemap:getMapY(i)
	i = i - 1
	return math.floor(i/self.columns)
end


function Tilemap:getMapPos(i)
	return self:getMapX(i), self:getMapY(i)
end

--CLEANUP: Unused function
-- TODO: Dit is misschien ook wel een mooie om je 10000 collision probleem op te lossen.
-- Gewoon uitrekenen met welke tiles de collision overlapt en die op een manier aanpassen.
function Tilemap:positionToTile(x, y)
	x = math.floor(x / self.tileWidth) * self.tileWidth
	y = math.floor(y / self.tileHeight) * self.tileHeight
	return x, y
end


function Tilemap:positionToMap(x, y)
	x = math.floor(x / self.tileWidth)
	y = math.floor(y / self.tileHeight)
	return x, y
end


function Tilemap:positionToIndex(x, y)
	x = math.floor(x / self.tileWidth)
	y = math.floor(y / self.tileHeight)
	return y * self.columns + x + 1
end


function Tilemap:setFollow(follow)
	self.follow = follow
end


function Tilemap:getTiles()
	return self.tiles
end


function Tilemap:overlapsWithRoom(room, obj)
	if not obj then obj = room room = self.currentRoom end
	return _.any(room.rects, function (x) return x:overlaps(obj) end)
end

-- TODO: Gezien je halve tiles rooms gaat fixen moet je dit misschien ook fixen dat dit eerder gebeurt?
-- Misschien ook dat je kan instellen hoe snel het gebeurt.
function Tilemap:preloadRoomsNearFollow()
	for i,v in ipairs(self.rooms) do
		local success = false
		if not self:overlapsWithRoom(v, self.follow) then
			for j,rect in ipairs(v.rects) do
				--If the player is overlapping horizontally
				if rect:overlapsX(self.follow) then
					--If the distance is lower than a tileWidth/Height
					if  math.abs(self.follow:bottom() - rect:top()) < self.tileHeight or
					   	math.abs(self.follow:top() - rect:bottom()) < self.tileHeight then
					   	--Then preload this room
						self:preloadRoom(i)
						success = true
					end
				elseif rect:overlapsY(self.follow) then
					if  math.abs(self.follow:right() - rect:left()) < self.tileWidth or
					   	math.abs(self.follow:left() - rect:right()) < self.tileWidth then
						self:preloadRoom(i)
						success = true
					end
				end
			end
		else
			success = true
		end

		if not success then
			--You're not near this room. Disable it.
			self:disableRoom(i)
		end
	end
end


function Tilemap:preloadObjectsNearFollow()
	for i,v in _.ripairs(self.entities) do
		if v.destroyed then
			table.remove(self.entities, i)
		else
			local distance = self.follow:getDistance(v)
			if distance < 1000 then
				self.scene:addLoadedEntity(v)
			else
				self.scene:removeEntity(v)
			end
		end
	end
end


function Tilemap:setObjectHandler(f)
	self.objectHandler = f
end


function Tilemap:setEventHandler(f)
	self.eventHandler = f
end


function Tilemap:setNewRoomHandler(f)
	self.newRoomHandler = f
end


function Tilemap:setLayerHandler(f)
	self.layerHandler = f
end

return Tilemap
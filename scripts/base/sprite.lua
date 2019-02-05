local Sprite = Rect:extend()

Sprite._quadCache = {}
local borderShader = Shader.new("border")

function Sprite:new(x, y, img, w, h)
	Sprite.super.new(self, x, y)

	self.anim = Animation()
	
	self.offset = Point(0, 0)
	self._offset = Point(0, 0)
	self.scale = Point(1, 1)
	self.origin = Point(0, 0)
	self.shear = Point(0, 0)
	self.border = Point(0, 0)
	self.border.color = {255, 255, 255}
	self.border.auto = true
	self.alpha = 1
	self.color = {255,255,255}
	self.angle = 0
	self.angleOffset = 0
	self.rotate = 0
	self.flip = {x = false, y = false}
	self.visible = true
	self.mirror = false
	self.parent = nil

	self.shader = nil
	self._shaders = {}
	self.shaderTimer = 0

	self._frames = {}
	if img then self:setImage(img, w, h) end

	self.coil = coil.group()
	self.flux = flux.group()
	self.tick = tick.group()
	self.wrap = wrap.new(self)
end


function Sprite:update(dt)
	self._offset:set(0)
	self.anim:update(dt)
	self.angle = self.angle + self.rotate * dt
	if self.angle < -PI then self.angle = self.angle + PI * 2 end
	if self.angle > PI then self.angle = self.angle - PI * 2 end
	
	if self.shader then
		for i,v in ipairs(self._shaders[self.shader].names) do
			if Shader.has(v, "rnd") then
				self:send(v .. "_rnd", math.random())
			end

			if Shader.has(v, "time") then
				self.shaderTimer = self.shaderTimer + dt
				self:send(v .. "_time", self.shaderTimer)
			end
		end
	end
	
	self.coil:update(dt)
	self.flux:update(dt)
	self.tick:update(dt)
end


function Sprite:draw(img, x, y, r, sx, sy, ox, oy, kx, ky)
	if self.visible and self.alpha > 0 then
		love.graphics.push("all")
		love.graphics.translate(
			x or self.x + self.origin.x + self._offset.x + self.offset.x, 
			y or self.y + self.origin.y + self._offset.y + self.offset.y)
		
		love.graphics.rotate(self.angle + self.angleOffset)
		love.graphics.scale(
			self.flip.x and -(sx or self.scale.x) or (sx or self.scale.x),
			self.flip.y and -(sy or self.scale.y) or (sy or self.scale.y))

		if self.border.auto then
			self:drawBorder(img, x, y, r, sx, sy, ox, oy, kx, ky)
		end

		love.graphics.setColor(self.color[1]/255,self.color[2]/255,self.color[3]/255, self.alpha)
		if self.blend then love.graphics.setBlendMode(self.blend) end
		if self.shader then love.graphics.setShader(self._shaders[self.shader].shader) end

		self:drawImage(img, x, y, r, sx, sy, ox, oy, kx, ky)
		
		love.graphics.pop()
	end

	love.graphics.setColor(255,255,255,255)
end


function Sprite:drawImage(img, x, y, r, sx, sy, ox, oy, kx, ky)
	if img then
		love.graphics.draw(img, 
		x or 0, y or 0,
		r or 0,
		sx or 1, sy or 1, 
		ox or self.origin.x, oy or self.origin.y,
		kx or self.shear.x, ky or self.shear.y)
	elseif self.image then
		if self.anim.frame < 1 or self.anim.frame > #self.anim._current.frames then
			warning("Frame out of range! Frame: " .. self.anim.frame .. ", Max: " .. #self.anim._current.frames .. " Anim: " .. self.anim:get())
		end

		love.graphics.draw(img or self.image, self._frames[self.anim._current.frames and self.anim._current.frames[self.anim.frame] or 1], 
		0, 0,
		0,
		1, 1, 
		self.origin.x, self.origin.y,
		self.shear.x, self.shear.y)
	else
		love.graphics.push()
		love.graphics.translate(-self.x, -self.y)
		Sprite.super.draw(self)
		love.graphics.pop()
	end
end


function Sprite:drawImageSimple(x, y, r, sx, sy, ox, oy, kx, ky)
	if self.anim.frame < 1 or self.anim.frame > #self.anim._current.frames then
		warning("Frame out of range! Frame: " .. self.anim.frame .. ", Max: " .. #self.anim._current.frames .. " Anim: " .. self.anim:get())
	end

	love.graphics.draw(self.image, self._frames[self.anim._current.frames and self.anim._current.frames[self.anim.frame] or 1], 
	x or self.x + self.offset.x + self.origin.x, y or self.y + self.offset.y + self.origin.y,
	r or self.r,
	sx or self.scale.x, sy or self.scale.y, 
	ox or self.origin.x, oy or self.origin.y,
	kx or self.shear.x, ky or self.shear.y)
end


function Sprite:drawBorder(img, x, y, r, sx, sy, ox, oy, kx, ky)
	if self.border.x ~= 0 or self.border.y ~= 0 then
		borderShader:send("border_color", self.border.color)
		love.graphics.setShader(borderShader)
		for i=-self.border.x,self.border.x,self.border.x do
			for j=-self.border.y,self.border.y,self.border.y do
				love.graphics.translate(i, j)
				self:drawImage(img, x, y, r, sx, sy, ox, oy, kx, ky)
				love.graphics.translate(-i, -j)
			end
		end
		love.graphics.setShader()
	end
end


function Sprite:drawDebug()
	-- love.graphics.setColor(255,0,0)
	-- love.graphics.setLineWidth(0.2)
	-- love.graphics.rectangle("line",self.x, self.y, self.width, self.height)
	-- love.graphics.circle("fill",self.x, self.y, 1, 10)
	-- -- love.graphics.circle("fill",self:centerX(), self:centerY(), 1, 10)
	-- love.graphics.circle("fill",self.x + self.origin.x, self.y +  self.origin.y, 1, 10)
end


function Sprite:setImage(url, width, height, margin, byframes)
	self.image = Asset.image(url)
	self.imageData = Asset.imageData(url)
	self._frames = {}

	self.image:setFilter("nearest")

	margin = margin and margin or (height and 1 or 0)

	if not width then width = 1 end

	local imgWidth, imgHeight
	imgWidth = self.image:getWidth()
	imgHeight = self.image:getHeight()

	if not height or byframes then
		height = imgHeight
		width = imgWidth/width
		if width > math.floor(width) then
			warning(tostring(self) .. " - Width is not an even number?", 4)
		end
	else 
		width = width or imgWidth
		height = height or imgHeight
	end

	local hor = imgWidth/width
	local ver = imgHeight/height
	if width then
		assert(math.floor(hor) == hor, "The given width (" .. width ..") doesn't round up with the image width (" .. imgWidth ..")", 2)
		assert(math.floor(ver) == ver, "The given height (" .. height ..") doesn't round up with the image height (" .. imgHeight ..")", 2)
	end

	if Sprite._quadCache[url] then
		self._frames = Sprite._quadCache[url]
	else
		local t = {}
		for i=0,ver-1 do
			for j=0,hor-1 do
				table.insert(self._frames, love.graphics.newQuad(margin + j * (width), margin + i * (height), width-margin, height-margin, imgWidth, imgHeight) )
			end
		end
		Sprite._quadCache[url] = self._frames
	end

	self.width = width-margin*2
	self.height = height-margin*2

	self:centerOrigin()

	self.anim:_setFrames(#self._frames)
	return self
end


--TODO: Make this how you give borders to everything
local dirs = {{-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1},	{0, 1},	{1, 1}}

local cache = {}
function Sprite:addBorder()
	if cache[self.image] then return end
	cache[self.image] = 1
	local img_data = self.image:getData()
	local new_img = love.image.newImageData(img_data:getWidth(), img_data:getHeight())

	img_data:mapPixel(function (x, y, r, g, b, a)
		if a > 0 and x > 0 and y > 0 and x < img_data:getWidth()-1 and y < img_data:getHeight()-1 then
			for i,v in ipairs(dirs) do
				new_img:setPixel(x+v[1], y+v[2], 255, 0, 0, 255)
			end
		end
		return r, g, b, a
	end)

	img_data:mapPixel(function (x, y, r, g, b, a)
		if a > 0 then
			new_img:setPixel(x, y, r, g, b, a)
		end
		return r, g, b, a
	end)

	img_data:paste(new_img, 0, 0, 0, 0, new_img:getWidth(), new_img:getHeight())

	self.image:refresh()
end


function Sprite:centerOrigin()
	self.origin.x = self.width/2
	self.origin.y = self.height/2
end


function Sprite:centerOffset()
	self.offset.x = -self.width/2
	self.offset.y = -self.height/2
end


function Sprite:addOffset(x, y)
	if not y then
		if type(x) == "table" then
			y = x.y
			x = x.x
		else
			y = x
		end
	end
	
	self._offset.x = self._offset.x + x
	self._offset.y = self._offset.y + (y or x)
end


function Sprite:setFilter(filter)
	self.image:setFilter(filter)
end


function Sprite:setBlend(blend)
	self.blend = blend
end


function Sprite:addShader(name, ...)
	local list = {...}
	if not ... then list = {name} end
	self._shaders[name] = {shader = Shader.new(unpack(list)), names = list}
	self.shader = name
end


function Sprite:setShader(name)
	self.shader = name
end


function Sprite:send(extern, ...)
	assert(self.shader, "You haven't set a shader!", 2)
	if not extern:find("_") then
		local names = self._shaders[self.shader].names
		if #names == 1 then
			extern = names[1] .. "_" .. extern
		else
			for i,v in ipairs(names) do
				if Shader.has(v, extern) then
					self._shaders[self.shader].shader:send(v .. "_" .. extern, ...)
				end
			end
			return
		end
	end

	if self.shader then
		self._shaders[self.shader].shader:send(extern, ...)
	end
end


local function clone_props (obj, k, v)
	if k == "offset" then
		obj.offset:set(v.x, v.y)
	elseif k == "flip" then
		obj.flip.x = v.x
		obj.flip.y = v.y
	elseif k == "color" then
		obj.color = {unpack(v)}
	else
		obj[k] = v
	end
end

function Sprite:drawAsChild(p, props, kind)
	-- kind = true means copy NO properties except the properties in props
	-- kind = false means copy ALL properties except the properties in props

	if kind == nil then
		if props then
			if props == true then
				kind = "all"
			elseif props == false then
				kind = "none"
			else
				kind = "specific"
			end
		else
			kind = "none"
		end
	elseif not kind then
		kind = "all_except"
	elseif kind then
		kind = "none_except"
	end

	local all_props = {"offset", "flip", "visible", "color", "alpha"}

	local parent = p or self.parent
	assert(parent, "Please assign a parent", 2)

	if parent then

		local px, py = parent:center()
		local nx, ny = px - self.width/2, py - self.height/2

		if kind == "none" then
			love.graphics.push()
			love.graphics.translate(nx, ny)
			local x, y = self.x, self.y
			self.x = parent.flip.x and -x or x
			self.y = parent.flip.y and -y or y
			self:draw()
			love.graphics.pop()
			self.x, self.y = x, y
		else
			local x, y = self.x, self.y
			local offset_x, offset_y = self.offset.x, self.offset.y
			local flip_x, flip_y = self.flip.x, self.flip.y
			local visible = self.visible
			local color = {unpack(self.color)}
			local alpha = self.alpha
			local px, py = parent:center()

			if kind == "specific" then
				for k,v in pairs(props) do
					self[k] = v
				end
			elseif kind == "none_except" then
				for i,v in ipairs(props) do
					clone_props(self, v, parent[v])
				end
			elseif kind == "all_except" then
				for i,v in ipairs(all_props) do
					if not _.any(props, function (a) return a == v end) then
						clone_props(self, v, parent[v])
					end
				end
			elseif kind == "all" then
				for i,v in ipairs(all_props) do
					clone_props(self, v, parent[v])
				end
			end

			if parent.flip.x then
				self.x = -x
			end

			if parent.flip.y then
				self.y = -y
			end

			love.graphics.push()
			love.graphics.translate(nx, ny)
			self:draw()
			love.graphics.pop()

			self.x, self.y = x, y
			self.offset:set(offset_x, offset_y)
			self.flip.x, self.flip.y = flip_x, flip_y
			self.visible = visible
			self.color = color
			self.alpha = alpha
		end
	end
end


function Sprite:oldDrawAsChild(p, nooffset)
	local parent = p or self.parent
	assert(parent, "Please assign a parent", 2)
	if parent then
		local offset = (parent.offset ~= nil and not nooffset ) and parent.offset or {x=0, y=0}
		local x, y = self.x, self.y
		love.graphics.push()
		local px, py = parent:center()
		love.graphics.translate(px + offset.x - self.width/2, py + offset.y - self.height/2)
		if parent.flip.x then
			self.x = -x
		end
		if parent.flip.y then
			self.y = -y
		end

		self.color = p.color
		self.alpha = p.alpha
		self.visible = p.visible
		self:draw()
		love.graphics.pop()
		self.x = x
		self.y = y
	end
end


function Sprite:__tostring()
	return lume.tostring(self, "Sprite")
end

return Sprite
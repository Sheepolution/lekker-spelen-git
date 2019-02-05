local HitboxGroup = Object:extend()
local Hitbox = require "base.hitbox"
local HCbox = require "base.hcbox"

function HitboxGroup:new(p, name, hc)
	self.parent = p
	self.name = name
	self.list = {}
	self.hitboxClass = hc and HCbox or Hitbox
end


function HitboxGroup:update(dt)
	for i,v in ipairs(self.list) do
		v:update(dt)
	end
end


function HitboxGroup:draw()
	for i,v in ipairs(self.list) do
		v:draw()
	end
end


function HitboxGroup:kill()
	for i,v in ipairs(self.list) do
		v:kill()
	end
end

-- function HitboxGroup:find(hb)
-- 	if type(hb) == "string" then
-- 		for i=#self.list,1,-1 do
-- 			if self.list[i].name == hb then
-- 				return i, self.list[i]
-- 			end
-- 		end
-- 	else
-- 		for i=#self.list,1,-1 do
-- 			if self.list[i] == hb then
-- 				return i, hb
-- 			end
-- 		end
-- 	end
-- end 


function HitboxGroup:add(x, y, width, height, proptype)
	local hb
	if type(x) == "table" then
		hb = x
		table.insert(self.list, x)
		x.name = self.name
	else
		hb = self.hitboxClass(self.parent, self.name, x, y, width, height, proptype)
		table.insert(self.list, hb)
	end
	return hb
end


-- function HitboxGroup:has(name)
-- 	local i, hb = self:find(name)
-- 	return i ~= nil
-- end


-- function HitboxGroup:get(name)
-- 	local i, hb = self:find(name)
-- 	if hb then return hb else return false end
-- end


-- function HitboxGroup:remove(hb)
-- 	local i, hb = self:find(hb)
-- 	if i then
-- 		table.remove(self.list, i)
-- 	end
-- end


function HitboxGroup:len()
	return #self.list
end


function HitboxGroup:update(dt)
	for i,v in ipairs(self.list) do
		v:update(dt)
	end
end


function HitboxGroup:overlaps(hb, last)
	return self:_doFunc("overlaps", hb, last)
end


function HitboxGroup:overlapsX(hb, last)
	return self:_doFunc("overlapsY", hb, last)
end


function HitboxGroup:overlapsY(hb, last)
	return self:_doFunc("overlapsY", hb, last)
end


function HitboxGroup:setProps(props)
	for i,hb in ipairs(self.list) do
		for k,v in pairs(props) do
			hb[k] = v
		end
	end
end


function HitboxGroup:_doFunc(f, hb, last)
	local t = {}
	if hb:is(HitboxGroup) then
		for i,v in ipairs(self.list) do
			for j,w in ipairs(hb.list) do
				if v[f](v, w, last) then
					table.insert(t, {v, w})
				end
			end
		end
	else
		for i,v in ipairs(self.list) do
			if v[f](v, hb, last) then
				table.insert(t, {v, hb})
			end
		end
	end
	return t
end


function HitboxGroup:__tostring()
	return lume.tostring(self, "HitboxGroup")
end


return HitboxGroup
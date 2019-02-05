-- Utils, using lume as base.
Utils = require "libs.lume"

local math_floor = math.floor
local math_ceil = math.ceil
local math_random = math.random
local math_atan2 = math.atan2 or math.atan
local math_sqrt = math.sqrt
local math_abs = math.abs

local print_cache = {}
local last_print

function Utils.xprint(...)
	local info = debug.getinfo(2, "Sl")
	local t = { info.short_src .. ":" .. info.currentline .. ":" }
	local j = 0
	local str = info.short_src .. info.currentline
	local pr = print_cache[str]
	if not pr then
		for line in love.filesystem.lines(info.short_src) do
			j = j + 1
			if j == info.currentline then
				pr = line
				print_cache[str] = line
			end
		end
	end
	pr = pr:match("print%(([^%)]+)%)") .. ","
	local has_self = pr:find("self")
	for i = 1, select("#", ...) do
		local x = select(i, ...)
		if type(x) == "number" then
			x = string.format("%g", lume.round(x, .01))
		end
		local x = tostring(x)
		if has_self then
			local name = pr:match("^([^,]+),")
			local stripped_name = name:gsub(" ", ""):gsub("self.", "")
			x = stripped_name .. "=" .. x
			pr = pr:sub(name:len()+2)
		end
		t[#t + 1] = x
	end
	local to_print = table.concat(t, " ")
	if to_print ~= last_print then
		last_print = to_print
		oldprint(to_print)
	end
end


function Utils.print(...)
	local info = debug.getinfo(2, "Sl")
	local t = { info.short_src .. ":" .. info.currentline .. ":" }
	local j = 0
	local str = info.short_src .. info.currentline
	local pr = print_cache[str]
	if not pr then
		for line in love.filesystem.lines(info.short_src) do
			j = j + 1
			if j == info.currentline then
				pr = line
				print_cache[str] = line
			end
		end
	end
	-- pr = pr:match("print%(([^%)]+)%)") .. ","
	local has_self = false --pr:find("self")
	for i = 1, select("#", ...) do
		local x = select(i, ...)
		if type(x) == "number" then
			x = string.format("%g", lume.round(x, .01))
		end
		local x = tostring(x)
		if has_self then
			oldprint(pr)
			local name = pr:match("^([^,]+),")
			local stripped_name = pr:gsub(" ", ""):gsub("self.", "")
			x = stripped_name .. "=" .. x
			pr = pr:sub(name:len()+2)
		end
		t[#t + 1] = x
	end
	local to_print = table.concat(t, " ")
	oldprint(to_print)
end


-- Creates a list of numbers
function Utils.numbers(a, b, ignore)
	if not b then b = a a = 1 end
	local t = {}
	for i=a,b, a > b and -1 or 1 do
		if not ignore or not lume.find(ignore, i) then
			table.insert(t, i)
		end
	end
	return t
end


-- Traces back to t on error
function Utils.assert(v, message, t)
	if not v then error(message, (t or 1) +1) end
	return v
end


-- Simple coin flip
function Utils.coin()
	return math_random(1,2) == 1
end

-- Sign coin, either -1 or 1
function Utils.scoin()
	return math_random(1,2) == 1 and 1 or -1
end


-- Sin and cos but always positiveJkkk
function Utils.absincos(t)
	return 0.5 + math.sin(t)/2, 0.5 + math.cos(t)/2
end


-- Treat all values as absolute and get the highest value.
function Utils.absmax(...)
	local highest = ({...})[1]
	local cur = math.abs(highest)
	local abs_highest = cur

	for i,v in ipairs({...}) do
		if cur > abs_highest then
			highest = v
			abs_highest = cur
		end
	end
	return highest
end


-- Treat all values as absolute and get the lowest value.
function Utils.absmin(...)
	local lowest = ({...})[1]
	local cur = math.abs(lowest)
	local abs_lowest = cur

	for i,v in ipairs({...}) do
		if cur < abs_lowest then
			lowest = v
			abs_lowest = cur
		end
	end
	return lowest
end


-- Same as sign but 0 = 0 instead of 1
function Utils.xsign(x)
	return x == 0 and 0 or x < 0 and -1 or 1
end


local pi = math.pi

function Utils.rotate(a1, a2, v)
	if a1 == a2 then return a1 end
	local diff = Utils.anglediff(a1, a2)
	if math_abs(diff) < math_abs(v) then
		return a2
	else
		return a1 + (diff < 0 and -1 or 1) * v
	end
end


function Utils.angledir(a1, a2)
	local diff = Utils.anglediff(a1, a2)
	return diff < 0 and -1 or 1
end


function Utils.anglediff(a1, a2)
	local diff = a2 - a1
	diff = diff > pi and diff - 2 * pi or diff < -pi and diff + 2 * pi or diff
	return diff
end

-- bool to sign
function Utils.boolsign(a)
	return a and 1 or -1
end

-- sign to bool
function Utils.signbool(x)
	return x >= 0
end


function Utils.tostring(a, n)
	if Key:isDown("tab") and pcall(a._str, a) then
		return n  .. " | " .. a:_str()
	else
		return n
	end
end

-- Auto converts the value of a string
-- TODO: Rename to autoConvert or something
function Utils.value(v)
	local a = tonumber(v)
	if a then return a end
	if type(v) == "boolean" then return v end
	a = v == "true" and true or v == "false" and false or nil
	if a ~= nil then return a end
	a = _G[v]
	if a ~= nil then return a end
	if v:sub(1, 1) == "{" then return Utils.dostring("return " .. v) end
	return v
end


function Utils.convert(v, typ)
	if not typ then return Utils.value(v) end
	if typ == "string" then return v end
	if typ == "number" then return tonumber(v) end
	if typ == "table" then return Utils.dostring("return" ..  v) end
	if typ == "bool" then return v == "true" end
	return nil
end


function Utils.debug(n, ...)
	local info = debug.getinfo(2  + n, "Sl")
	local t = { info.short_src .. ":" .. info.currentline .. ":" }
	for i = 1, select("#", ...) do
		local x = select(i, ...)
		if type(x) == "number" then
			x = string.format("%g", lume.round(x, .01))
		end
		local x = tostring(x)
		t[#t + 1] = x
	end
	oldprint(table.concat(t, " "))
end


function Utils.is(a, ...)
	for i,v in ipairs({...}) do
		if a == v then
			return true
		end
	end
	return false
end


function Utils.wrap(obj, f, ...)
	local args = {...}
	return function () return obj[f](obj, unpack(args)) end
end


function Utils.chance(c)
	return _.random(100) < c
end


function Utils.list(t)
	local nt = {}
	for k,v in pairs(t) do
		nt[#nt+1] = v
	end
	return nt
end


function Utils.sum(t)
	local s = 0
	for i,v in ipairs(t) do
		s = s + v
	end
	return s
end


function Utils.average(t)
	return Utils.sum(t) / #t
end


function Utils.secondsToClock(seconds)
	seconds = math.floor(seconds)
	if seconds <= 0 then
		return "00:00:00";
	else
		hours = string.format("%02.f", math.floor(seconds/3600));
		mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		return hours..":"..mins..":"..secs
	end
end


function Utils.rgbdirs()
	return
		math.random(-1, 1),
		math.random(-1, 1),
		math.random(-1, 1),
		math.random(-1, 1),
		math.random(-1, 1),
		math.random(-1, 1)
end


return Utils
local wrap = {}
wrap.__index = wrap

function wrap.new(obj)
	return setmetatable({obj = obj}, wrap)
end


function wrap:__index(f)
	return function (obj, ...)
		local a = {...}
		return function ()
			return self.obj[f](self.obj, unpack(a))
		end
	end
end


function wrap:__call(t)
	return function ()
		for k,v in pairs(t) do
			self.obj[k] = v
		end
	end
end

return wrap
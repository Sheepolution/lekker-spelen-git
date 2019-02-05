local Once = {}

function Once.new(obj)
	return setmetatable({_obj = obj, _used = {}},  Once)
end


function Once:__call(f, ...)
	if not self._used[f] then
		self._used[f] = true
		return self._obj[f](self._obj, ...)
	end
end


function Once:back(f, bf, ...)
	if self._used[f] then
		self._used[f] = nil
		if bf then
			return self._obj[bf](self._obj, ...)
		end
	end
end

return Once
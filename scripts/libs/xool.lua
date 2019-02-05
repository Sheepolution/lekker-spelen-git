local xool = {}
xool.__index = xool

function xool.new()
	return setmetatable({ state = 0 }, xool)
end

function xool:__call(a)
	local oldstate = self.state
	if a then
		self.state = 2
		return oldstate > 0
	elseif a == nil then
		self.state = self.state == 2 and 1 or 0
		return oldstate == 1
	end
	
	return self.state > 0
end

return xool
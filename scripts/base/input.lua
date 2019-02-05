local Input = Object:extend()

Input.double_press_time = 0.23 

function Input:new()
	self._pressed = {}
	self._released = {}
	self._custom = {
		w = {"w"},
		a = {"a"},
		s = {"s"},
		d = {"d"},
		g = {"g"},
		h = {"h"},
		k = {"k"},
		l = {"l"},
		i = {"i"},
		o = {"o"},
		t = {"t"},
		y = {"y"},
		start = {"start"},
		escape = {"escape"},
		["return"] = {"return"},
		left = {"left"},
		right = {"right"},
		up = {"up"},
		down = {"down"}

	}
	self._lastPressed = {}
end


function Input:reset()
	for i,v in ipairs(self._pressed) do
		self._lastPressed[v] = Input.double_press_time
	end
	for i,v in ipairs(self._released) do
		self._lastPressed[v] = Input.double_press_time
	end
	self._pressed = {}
	self._released = {}
end


function Input:update(dt)
	for k,v in pairs(self._lastPressed) do
		local t = v - dt
		self._lastPressed[k] = t
		if t <= 0 then
			self._lastPressed[k] = nil
		end
	end
end


function Input:isPressed(...)
	return lume.any({...}, function (a) return self._custom[a] and lume.any(self._custom[a], function (b) return lume.find(self._pressed, b) end) end)
end

function Input:isDoublePressed(...)
	return lume.any({...}, function (a) return self._custom[a] and lume.any(self._custom[a], function (b) return lume.find(self._pressed, b) and self._lastPressed[b] end) end)
end


function Input:isReleased(...)
	return lume.any({...}, function (a) return self._custom[a] and lume.any(self._custom[a], function (b) return lume.find(self._released, b) end) end)
end


function Input:isDown(...)
	return lume.any({...}, function (a) return self._custom[a] and lume.any(self._custom[a], function (b) return love.keyboard.isDown(b) or self:_controllerIsDown(b) end) end)
end


function Input:set(name, t)
	self._custom[name] = t
end


function Input:isAnyPressed()
	return #self.pressed > 0
end


function Input:_inputpressed(input)
	table.insert(self._pressed, input)
	if not self._custom[input] then
		self._custom[input] = {input}
	end
end


function Input:_inputreleased(input)
	table.insert(self._released, input)
end


function Input:_str()
	return "pressed: " .. (unpack(self._pressed) or " ") .. ", released: " .. (unpack(self._released) or " ")
end


function Input:_controllerIsDown(a)
	local treshhold = .15
	-- if a == "a" or a == "d" or a == "w" or a == "s"
	-- 	or a == "left" or a == "right" or a == "up" or a == "down"
	-- 	or a == "g" or a == "h" or a == "k" or a == "l"
	-- 	or a == "t" or a == "y" or a == "i" or a == "o" then
		for i,v in ipairs(love.joystick.getJoysticks()) do
			local id = v:getID()
			local xvalue, yvalue  = v:getAxis( 1 ), v:getAxis(2)
			if id == 1 then
				if a == "g" then
					return v:isGamepadDown("a")
				elseif a == "h" then
					return v:isGamepadDown("b")
				elseif a == "t" then
					return v:isGamepadDown("x")
				elseif a == "y" then
					return v:isGamepadDown("y")
				end

				if a == "left" then

					return v:isGamepadDown("dpleft") or xvalue < -treshhold
				elseif a == "right" then
					return v:isGamepadDown("dpright") or xvalue > treshhold
				end

				if a == "up" then
					return yvalue < -treshhold
				elseif a == "down" then
					return yvalue > treshhold
				end			
			else
				if a == "k" then
					return v:isGamepadDown("a")
				elseif a == "l" then
					return v:isGamepadDown("b")
				elseif a == "i" then
					return v:isGamepadDown("x")
				elseif a == "o" then
					return v:isGamepadDown("y")
				end


				if a == "a" then
					return v:isGamepadDown("dpleft") or xvalue < -treshhold
				elseif a == "d" then
					return v:isGamepadDown("dpright") or xvalue > treshhold
				end

				if a == "w" then
					return yvalue < -treshhold
				elseif a == "s" then
					return yvalue > treshhold
				end				
			end
		end
	-- end
end


function Input:rumble(id, strength, length)
	if DATA.options.controller.singleplayer then return end
	-- print("rumble time!")
	for i,v in ipairs(love.joystick.getJoysticks()) do
		local joy_id = v:getID()
		-- print("joy_id", joy_id)
		if joy_id == 1 then
			-- print("id", id)
			if id == 1 then
				-- print("kan ie trillen?", v:isVibrationSupported( ))
				-- print("set that vibration babyy!!")
				local vib = v:setVibration(strength or .25, strength or .25, length or .25)
				-- print("vib?", vib)
			end
		else
			if id ~= 1 then
				local vib = v:setVibration(strength or .25, strength or .25, length or .25)
			end
		end
	end
end


function Input:__tostring()
	return lume.tostring(self, "Input")
end

return Input
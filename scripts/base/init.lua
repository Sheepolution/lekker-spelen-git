DEFAULT_FILTER = "nearest"
love.graphics.setDefaultFilter(DEFAULT_FILTER, DEFAULT_FILTER)

local oldrandomseed = math.randomseed
local currentrandomseed = 0

local rnd_count = 0

function math.randomseed(v)
	v = v or os.time()
	if not v then
		rnd_count = rnd_count + 1
		v = v * rnd_count
	end
	currentrandomseed = v
	oldrandomseed(v)
end


function math.getrandomseed()
	return currentrandomseed
end

math.randomseed()

GLOBAL = _G
PI = math.pi
TAU = PI * 2

SCREEN_WIDTH = love.graphics.getWidth()
SCREEN_HEIGHT = love.graphics.getHeight()

local SCALE = 2
WIDTH = 1920/SCALE
HEIGHT = 1080/SCALE

AXIS = {
	{
		 x = 0,
		 y = 0
	},
	{
		 x = 0,
		 y = 0
	}
}

TIMER = 0
DT = 1/60

require "base.error"

--Tools
Shader = require "base.shader"
Asset = require "base.asset"
Mouse = require("base.mouse")()
Key = require("base.input")()

--Classes
Point = require "base.point"
Rect = require "base.rect"
Circle = require "base.circle"
Sprite = require "base.sprite"
Animation = require "base.animation"
Text = require "base.text"
Entity = require "base.entity"
Button = require "base.button"
Once = require "base.once"
Tilemap = require "base.tilemap"
SolidTile = require "base.solidtile"
VisualTile = require "base.visualtile"
-- Camera = require "base.camera"
Scene = require "base.scene"
Particle = require "base.particle"

Debug = require "base.debug"

Cursors = {}
Cursors.hand = love.mouse.getSystemCursor("hand")

local base = {}

function base.beginstep(dt)

	for i,v in ipairs(love.joystick.getJoysticks()) do
		if DATA.options.controller.singleplayer then break end
		local id = v:getID()
		local xvalue, yvalue  = v:getAxis(1), v:getAxis(2)
		if id == 1 then
			local x, y = AXIS[1].x, AXIS[1].y
			local nx, ny = xvalue, yvalue
			AXIS[1].x = math.abs(xvalue)
			AXIS[1].y = math.abs(yvalue)

			print(math.abs(y), math.abs(ny))
			if math.abs(x) < .15 and math.abs(nx) >= .15 then
				if nx < -.15 then
					base.keypressed("left")
				elseif nx > .15 then
					base.keypressed("right")
				end
			end

			if math.abs(y) < .15 and math.abs(ny) >= .15 then
				if ny < -.15 then
					base.keypressed("up")
				elseif ny > .15 then
					base.keypressed("down")
				end
			end

			if v:isGamepadDown("dpleft") then
				AXIS[1].x = -1
			elseif v:isGamepadDown("dpright") then
				AXIS[1].x = 1
			end

			if v:isGamepadDown("dpup") then
				AXIS[1].y = -1
			elseif v:isGamepadDown("dpdown") then
				AXIS[1].y = 1
			end

		else
			AXIS[2].x = math.abs(xvalue)
			AXIS[2].y = math.abs(yvalue)

			if v:isGamepadDown("dpleft") then
				AXIS[2].x = -1
			elseif v:isGamepadDown("dpright") then
				AXIS[2].x = 1
			end

			if v:isGamepadDown("dpup") then
				AXIS[2].y = -1
			elseif v:isGamepadDown("dpdown") then
				AXIS[2].y = 1
			end
		end
	end

	if DATA.options.controller.singleplayer then
		if love.keyboard.isDown("j", "l") then
			AXIS[1].x = 1
		end
		if love.keyboard.isDown("i", "k") then
			AXIS[1].y = 1
		end
	else
		if love.keyboard.isDown("left", "right") then
			AXIS[1].x = 1
		end
		if love.keyboard.isDown("up", "down") then
			AXIS[1].y = 1
		end
	end

	if love.keyboard.isDown("a", "d") then
		AXIS[2].x = 1
	end
	if love.keyboard.isDown("w", "s") then
		AXIS[2].y = 1
	end

	-- Debug.update(dt)
	-- WIDTH = love.graphics.getWidth()/SCALE
	-- HEIGHT = love.graphics.getHeight()/SCALE
	TIMER = TIMER + dt
	Mouse:update()
	-- Debug.reset()
end


function base.endstep(dt)
	Key:reset()
	Mouse:reset()
end


function base.draw()
	love.graphics.origin()
	-- Debug.draw()
end


function base.keypressed(key)
	-- imgui.KeyPressed(key)
	-- if not imgui.GetWantCaptureKeyboard() then
		-- Pass event to the game
		Key:_inputpressed(key)
	-- end
end


function base.keyreleased(key)
	-- imgui.KeyReleased(key)
	-- if not imgui.GetWantCaptureKeyboard() then
		-- Pass event to the game
		Key:_inputreleased(key)
	-- end
end


function base.mousepressed(x, y, button)
	-- imgui.MousePressed(button)
    -- if not imgui.GetWantCaptureMouse() then
		Mouse:_inputpressed(button)
	-- end
end


function base.mousereleased(x, y, button)
	-- imgui.MouseReleased(button)
	-- if not imgui.GetWantCaptureMouse() then
		Mouse:_inputreleased(button)
	-- end
end


function love.mousemoved(x, y)
    -- imgui.MouseMoved(x, y)
    -- if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    -- end
end


function base.textinput()
	-- imgui.TextInput(t)
    -- if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
    -- end
end



function base.wheelmoved(x, y)
    -- imgui.WheelMoved(y)
    -- if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
		local a = y == 0 and x or y
		Mouse:_inputpressed(a >= 0 and "wu" or "wd")
    -- end
end

-- First time working with gamepads and didn't have time to build in proper controller mapping.
-- So I'm hacking it in instead.
function base.gamepadpressed(joystick, button)
	local id, instanceid = joystick:getID()

	if id == 1 then
		if button == "a" then
			base.keypressed("g")
		elseif button == "b" then
			base.keypressed("h")
		elseif button == "x" then
			base.keypressed("t")
		elseif button == "y" then
			base.keypressed("y")
		elseif button == "start" then
			base.keypressed("start")
			base.keypressed("return")
		elseif button == "back" then
			base.keypressed("escape")
		elseif button == "dpright" then
			base.keypressed("right")
		elseif button == "dpleft" then
			base.keypressed("left")
		elseif button == "dpdown" then
			base.keypressed("down")
		elseif button == "dpup" then
			base.keypressed("up")
		end

	else
		if button == "a" then
			base.keypressed("k")
		elseif button == "b" then
			base.keypressed("l")
		elseif button == "x" then
			base.keypressed("i")
		elseif button == "y" then
			base.keypressed("o")
		end
	end
end


function base.gamepadreleased(joystick, button)
	local id, instanceid = joystick:getID()
	if id == 1 then
		if button == "a" then
			base.keyreleased("g")
		elseif button == "b" then
			base.keyreleased("h")
		end
	else
		if button == "a" then
			base.keyreleased("k")
		elseif button == "b" then
			base.keyreleased("l")
		end
	end
end


function base.gamepadaxis(joystick, axis, value)
	-- local id, instanceid = joystick:getID()
	-- -- print(axis, value)
	-- -- print(axis == "leftx", value == -1)
	-- if axis == "leftx" then
	-- 	if id == 1 then
	-- 		if value == -1 then
	-- 			base.keypressed("left")
	-- 		elseif value == 1 then
	-- 			base.keypressed("right")
	-- 		end
	-- 	else
	-- 		if value == -1 then
	-- 			base.keypressed("a")
	-- 		elseif value == 1 then
	-- 			base.keypressed("d")
	-- 		end
	-- 	end
	-- end

end



function base.resize(width, height)
	local scale = math.min(width / WIDTH, height / HEIGHT)
	width, height = WIDTH * scale, HEIGHT * scale
	CANVAS = love.graphics.newCanvas(width, height)
	CANVAS:setFilter("nearest", "nearest")
end



function toGameCoords(x, y)
	local gx, gy = WIDTH, HEIGHT
	local wx, wy = love.graphics.getDimensions()
	local sx, sy = wx / gx, wy / gy
	local s = math.min(sx, sy)
	local ox, oy = 0, 0
	if sx > sy then
	ox = (wx - gx * s) / 2
	else
	oy = (wy - gy * s) / 2
	end
	return _.clamp((x - ox) / s, 0, WIDTH),
	     _.clamp((y - oy) / s, 0, HEIGHT)
end


function warning(msg, tb)
	_.debug(tb or 1, "[WARNING] -", msg)
end


function info(msg, tb)
	_.debug(tb or 1, "[INFO] -", msg)
end

--prints table
function tprint(...)
	local s = ""
	for i,v in ipairs({...}) do
		s = s .. _.serialize(v) .. "  "
	end
	print(s)
end

--prints on n stacks back
function bprint(n, ...)
	_.debug(n, ...)
end

--prints if a is true
function printif(a, ...)
	if not a then return end
	_.debug(1, ...)
end

function requireDir(dir)
	local files = love.filesystem.getDirectoryItems(dir)
	local path = dir:gsub("/",".")
	for i,v in ipairs(files) do
		local d = dir .. "/" .. v
		local info = love.filesystem.getInfo(d)
		if info.type == "directory" then
			requireDir(d)
		else
			if v:find(".lua") then
				require(path .. "." .. v:match("[^.]+"))
			end
		end
	end
end


function setScale(scale)
	if scale == SCALE then return end

	SCALE = scale
	love.window.setMode((1920/RES)*SCALE, (1080/RES)*SCALE)
end

return base
-- Release or debug mode?
RELEASE = arg[2] ~= "debug"
DEBUG = not RELEASE

-- Fix paths
local paths  = love.filesystem.getRequirePath()
love.filesystem.setRequirePath(paths .. ";scripts/?.lua;scripts/?/init.lua;")

love.mouse.setVisible(false)

NOOP = function () end

-- require "steady"

-- Set utils
_ = require("base.utils")
oldprint = print
print = DEBUG and _.print or NOOP
xprint = DEBUG and _.xprint or NOOP
assert = _.assert

-- Load libs and base
local libs = require "libs"
local base = require "base"

local sm, pause

local push = require "libs.push"

local old_ms_list_update = {}
local new_ms_list_update = {}

local old_ms_list_draw = {}
local new_ms_list_draw = {}

local ms_timer = 0


local start_timer = 0

function RESET_SCREEN(first)
	local windowWidth, windowHeight, flags = love.window.getMode( )
	local size = .5
	-- CScreen.init(1920, 1080, true)
	local gameWidth, gameHeight = 1920/2, 1080/2 --fixed game resolution
	if first or flags.fullscreen then
		windowWidth, windowHeight = 1920*size, 1080*size
	end

	local full = false
	push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen=DATA.options.screen.fullscreen, pixelperfect=DATA.options.screen.pixelperfect, resizable=true, vsync = DATA.options.screen.vsync})
end

function love.load()

	require "state"

	-- Require all files
	for i,v in ipairs(require "require") do
		local succes, msg = pcall(require, v)
		if not succes then
			if msg:match("not found:") then
				requireDir("scripts/" .. v)
			else
				error(msg)
			end
		end
	end

	RESET_SCREEN(true)
	push:setBorderColor(12/255, 12/255, 12/255)

	NON_PUSH_DRAWS = {}

	sm = StateManager()
end

SAFE_COLL = false

SAFE_COLL_TIMER = 0

function love.update(t)
	start_timer = love.timer.getTime()

	COL_CHECKS = 0

	ms_timer = ms_timer + t
	if ms_timer > 1 then
		ms_timer = ms_timer - 1
		old_ms_list_update = new_ms_list_update
		old_ms_list_draw = new_ms_list_draw
		new_ms_list_update = {}
		new_ms_list_draw = {}
	end

	if t > 0.016666667 then
		SAFE_COLL_TIMER = SAFE_COLL_TIMER + t
		if SAFE_COLL_TIMER > 5 then
			SAFE_COLL_TIMER = 5
			SAFE_COLL = true
		end
	else
		SAFE_COLL_TIMER = SAFE_COLL_TIMER - t

		if SAFE_COLL_TIMER <= 0 then
			SAFE_COLL = false
			SAFE_COLL_TIMER = 0
		end 
	end

	local dt = math.min(t, 0.016666667)

	if pause then dt = 0 end

	if DEBUG then
		dt = dt * Debug.speed
	end

	libs.update(dt)
	base.beginstep(dt)

	local speed = 1

	if DEBUG then
		if Key:isPressed("q") then
			love.event.quit()
		end

		if Key:isPressed("f5") then
			love.load()
		end

		if Key:isPressed("f6") then
			lurker.scan()
		end

		if Key:isDown("pause") then
			dt = 0
		end

		if Key:isPressed("`") then
			-- Debug.visible = not Debug.visible
		end

		if Key:isDown("tab") then
			if Key:isDown("1") then
				-- if Key:isDown("lshift") then
					dt = dt * .25
				-- else
					-- speed = 1
				-- end	
			elseif Key:isDown("2") then
				speed = 2
			elseif Key:isDown("3") then
				speed = 3
			elseif Key:isDown("4") then
				speed = 4
			elseif Key:isDown("5") then
				speed = 5
			elseif Key:isDown("6") then
				speed = 6
			end
		end
	end

	for i=1,speed do
		sm:update(dt)
		base.endstep(dt)
	end
	table.insert(new_ms_list_update, love.timer.getTime() - start_timer)
end


function love.draw()
	start_timer = love.timer.getTime()
	push:start()
	sm:draw()
	push:finish()
    love.graphics.setScissor(push._OFFSET.x, push._OFFSET.y, push._WWIDTH*push._SCALE.x, push._WHEIGHT*push._SCALE.y)
	love.graphics.push()
    love.graphics.scale(push._SCALE.x, push._SCALE.y)
	for i,v in ipairs(NON_PUSH_DRAWS) do
		v()
	end
	love.graphics.pop()
	love.graphics.setScissor()


	NON_PUSH_DRAWS = {}
	-- love.graphics.pop()

	if DEBUG then
	-- 	Debug.add("drawcalls", love.graphics.getStats().drawcalls)
	-- end


	-- love.graphics.origin()

	-- base.draw()
		if Key:isDown("tab") then
			love.graphics.setColor(0, 0, 0)
			love.graphics.rectangle("fill", 0, 0, 200, 100)
			love.graphics.setColor(255, 255, 255)
			table.insert(new_ms_list_draw, love.timer.getTime() - start_timer)
			love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 0)
			love.graphics.print("Current update MS: ".. _.round(_.average(old_ms_list_update)*1000, 0.000001) , 10, 30)
			love.graphics.print("Current draw MS: ".. _.round(_.average(old_ms_list_draw)*1000, 0.000001) , 10, 50)
			love.graphics.print("Collision checks:" .. COL_CHECKS, 10, 70)
			-- love.graphics.print("Current MS: ".. (love.timer.getTime() - start_timer) * 1000, 10, 30)
		end
	end
end


function love.resize(width, height)
end


function love.keypressed(key)
	if DEBUG then
		if key == "pause" then
			pause = not pause
		end
	end
	base.keypressed(key)
end


function love.keyreleased(key)
	base.keyreleased(key)
end


function love.mousepressed(x, y, button)
	base.mousepressed(x, y, button)
end


function love.mousereleased(x, y, button)
	base.mousereleased(x, y, button)
end


function love.resize(w, h)
  	push:resize(w, h)
end


function love.wheelmoved(x, y)
	base.wheelmoved(x, y)
end


function love.gamepadpressed(joystick, button)
	base.gamepadpressed(joystick, button)
end


function love.gamepadreleased(joystick, button)
	base.gamepadreleased(joystick, button)
end


function love.gamepadaxis( joystick, axis, value )
	base.gamepadaxis(joystick, axis, value)
end



function love.quit()
end
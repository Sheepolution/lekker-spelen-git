lume = require "libs.lume"
-- autobatch = require "libs.autobatch"
-- lurker = require "libs.lurker"
Object = require "libs.classic"
flux = require "libs.flux"
tick = require "libs.tick"
coil = require "libs.coil"
json = require "libs.json"
Camera = require "libs.stalker-x"
-- HC = require "libs.HC"
-- My own :)
buddies = require "libs.buddies"
step = require "libs.step"
xool = require "libs.xool"
wrap = require "libs.wrap"

local libs = {}

function libs.update(dt)
	tick.update(dt)
	flux.update(dt)
	coil.update(dt)
end

return libs
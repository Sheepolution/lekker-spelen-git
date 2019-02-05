StateManager = Object:extend()

local Intro = require "base.intro"

function StateManager:new()
	State = self
	self.state = Intro()
end


function StateManager:update(dt)
	self.state:update(dt)

end


function StateManager:draw()
	self.state:draw()
end


function StateManager:endIntro()
	self.state = Menu()
end


function StateManager:toState(state)
	self.state = state
end

return StateManager
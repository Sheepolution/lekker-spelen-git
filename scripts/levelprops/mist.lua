Mist = Entity:extend("Mist")

function Mist:new(...)
	Mist.super.new(self, ...)
	self:setImage("grave/mist1")
	self.alpha = 0

	self.solid = 0

	self.z = -1000

	local move
	move = function ()
		self.flux:to(self, 1, {alpha = .41}):ease("linear")
		:after(1, {alpha = 0}):ease("linear")
		:delay(8)

		self.flux:to(self, 10, {x = self.x + 300}):ease("linear")
		:oncomplete(function ()
			self.x = self.x - 300
			move()
		end)
	end
	move()
end


function Mist:update(dt)
	Mist.super.update(self, dt)
end


function Mist:draw()
	Mist.super.draw(self)
end
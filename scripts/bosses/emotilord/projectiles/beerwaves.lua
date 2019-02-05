local BeerWaves = Thing:extend("BeerWaves")

function BeerWaves:new(x, y, dir)
	BeerWaves.super.new(self, x, y)
	self:setImage("bosses/emotilord/beerwaves", 4)
	self.anim:add("idle")

	self.gravity = 0
	self.solid = 0

	self.alpha = 0

	self.flux:to(self, 2, {alpha = 0.8})
	:delay(0.5)

	self.flux:to(self, 5, {y = 230})
	:delay(3):ease("quadinout")

	self.y = 495

	self.z = -100

	self.damaging = true
	
	self.hitbox = self:addHitbox("solid", 0, 1500, 3000, 3000)
end


function BeerWaves:update(dt)
	BeerWaves.super.update(self, dt)
end


function BeerWaves:draw()
	for i=0,30 do
		self.offset.x = self.width * i
		BeerWaves.super.draw(self)
	end
	love.graphics.setColor(254/255, 231/255, 97/255, self.alpha)
	love.graphics.rectangle("fill", 0, self.y + self.height, 1000, 1000)
end


function BeerWaves:back()
	self.damaging = false
	self:tween(0.4, nil, 600)
	:oncomplete(function () self:destroy() end)
end

return BeerWaves
Shirt = Entity:extend("Shirt")

Shirt.prizeList = {
	25,
	25,
	50,
	25,
	25
}

Shirt.heartsList = {
	1,
	1,
	3,
	1,
	1
}


function Shirt:new(x, y, shirt)
	Shirt.super.new(self, x, y)
	self:setImage("shirts/shirts", 5)
	self.anim:add("idle", shirt)
	self.solid = 0

	self.shirtID = shirt

	self.price = Shirt.prizeList[self.shirtID]
	self.hearts = Shirt.heartsList[self.shirtID]

	self.hitbox = self:addHitbox("solid", 100, 500)

	self.priceText = Text(60, -90, "x" .. self.price, "sheepixel", 32)
	self.heartsText = Text(60, -55, "+" .. self.hearts, "sheepixel", 32)

	self.spriteEuro = Sprite(-10, -143, "pickupables/lekkereuro", 24)
	self.spriteEuro.anim:add("idle")
	self.spriteEuro.border:set(1)
	self.spriteEuro.color = {255, 255, 255}

	self.spriteHeart = Sprite(-10, -110, "pickupables/lekkerlief", 26)
	self.spriteHeart.anim:add("idle", "1>12")
	self.spriteHeart.border:set(1)
	self.spriteHeart.color = {255, 255, 255}

	self.spriteBuyButton = Sprite(-30, 96, "xbutton")
	self.buyText = Text(40, 150, "Kopen", "sheepixel", 32)
	self.spriteBuyButton.border:set(1)
	self.spriteBuyButton.border.color = {255, 255, 255}

	self.border:set(2)
	self.border.color = {255, 255, 255}
	self.border.auto = false

	self.sprites = buddies.new(self)

	self.hittingPlayer = {}

	self.bought = false 
end


function Shirt:update(dt)
	Shirt.super.update(self, dt)
	self.spriteEuro:update(dt)
	self.spriteHeart:update(dt)
	if #self.hittingPlayer > 0 then
		for i,v in ipairs(self.hittingPlayer) do
			if v.inControl then
				if Key:isPressed(unpack(v.keys.buy)) then
					if Game.euros >= self.price then
						Game:buyShirt(self, self.shirtID, v)
						self.bought = true
						break
					end
				end
			end
		end
	end

	self.hittingPlayer = {}
end


function Shirt:draw()
	if #self.hittingPlayer > 0 and not self.bought then
		if Game.euros >= self.price then
			self.sprites:call(function (e) e.border.color = {255, 255, 255} end)
			self.spriteBuyButton:drawAsChild(self)
			self.buyText:drawAsChild(self)
		else
			self.sprites:call(function (e) e.border.color = {150, 30, 30} end)
		end

		self.priceText:drawAsChild(self)
		self.heartsText:drawAsChild(self)
		self.spriteEuro:drawAsChild(self)
		self.spriteHeart:drawAsChild(self)
	end
	
	self.border.auto = #self.hittingPlayer > 0
	Shirt.super.draw(self)
end


function Shirt:onOverlap(e, mine, his)
	if e:is(Player) then
		table.insert(self.hittingPlayer, e)
	end

	return Shirt.super.onOverlap(self, e, mine, his)
end
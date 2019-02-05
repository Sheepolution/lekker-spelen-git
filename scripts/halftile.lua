HalfTile = SolidTile:extend("HalfTile")

function HalfTile:new(x, y, width, height)
	HalfTile.super.new(self, x, y)
	self.width = width or 1
	self.height = height or 1
	self.addIgnoreOverlap(HalfTile)
	self.solid = 2
	self.visible = false
	self.immovable = {x = true, y = true}
	self.y = self.y + height/2
	self.height = self.height/2
end

HalfTile.test = "kaas"
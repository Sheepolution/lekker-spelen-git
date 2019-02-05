local SolidTile = Entity:extend("SolidTile")

function SolidTile:new(x, y, width, height)
	SolidTile.super.new(self, x, y)
	self.width = width or 1
	self.height = height or 1
	self.addIgnoreOverlap(SolidTile)
	self.solid = 2
	self.visible = false
	self.immovable = {x = true, y = true}
end

return SolidTile
MenuButton = Sprite:extend("MenuButton")

MenuButton.defaultColorSpecial = {20, 184, 102}
MenuButton.selectedColorSpecial = {79, 219, 149}
MenuButton.defaultColor = {75, 54, 124}
MenuButton.selectedColor = {152, 122, 208}

function MenuButton:new(y, text)
	MenuButton.super.new(self, 0, y)
	self.width = 300
	self.height = 50
	self:centerX(WIDTH/2)
	self.radius = 3
	self.color = {75, 54, 124}
	self.text = self:createText(text)
	self.selected = false
end


function MenuButton:update(dt)
	MenuButton.super.update(self, dt)
end


function MenuButton:draw()
	if self.visible then
		self.color = {24, 20, 37}
		local offset = self.offset.y 
		self.offset.y = offset + 5
		MenuButton.super.draw(self)
		self.offset.y = offset
		
		if self.selected then
			self.color = self.special and MenuButton.selectedColorSpecial or MenuButton.selectedColor
		else
			self.color = self.special and MenuButton.defaultColorSpecial or MenuButton.defaultColor
		end
		MenuButton.super.draw(self)

		self.text.offset.y = self.offset.y
		self.text:drawAsChild(self, {"x"}, false)
	end
end


function MenuButton:activate()
	if self.func then
		self.func()
	end
end

function MenuButton:unactivate()
	if self.bfunc then
		self.bfunc()
	end
end


function MenuButton:createText(txt)
	local text = Text(0, -1, txt, "sheepixel", 48)
	text.align.x = "center"
	text.font:setFilter("linear", "linear")
	text.limit = WIDTH
	text.x = -self.x
	text.shadow.y = 2
	text.color = {255, 255, 255}

	return text
end


function MenuButton:select()
	self.selected = true
	self.offset.y = -5
	self.flux:to(self.offset, .1, {y = 0})
end


function MenuButton:deselect()
	self.selected = false
end
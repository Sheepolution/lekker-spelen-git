Pause = Scene:extend("Pause")

function Pause:new(parent)
	Pause.super.new(self)
	self.buttons = buddies.new()

	self.buttons:add(self:addScenery(MenuButton(190, "Verder")))
	self.buttons:add(self:addScenery(MenuButton(305, "Naar hoofdmenu")))
	self.buttons:centerX(WIDTH/2)

	self.buttons[1].selected = true
	self.selected = 1

	self.buttons[1].func = function ()
		self.parent:unpause()
	end

	self.buttons[2].func = function ()
		SAVE_DATA()
		State:toState(Menu())
	end

	self.overlayRect = Rect(-100, -100, 2000, 2000)
	self.overlayRect.color = {0, 0, 0}
	self.overlayRect.alpha = .75
	self.z = -100000000

	self.parent = parent

	self.selectSFX = SFX("sfx/textbox/char")
end


function Pause:update(dt)
	if Key:isPressed("return", "g") then
		if not self.buttons[self.selected].analog then
			self.buttons[self.selected]:activate()
		end
	elseif Key:isPressed("down") then
		self.selectSFX:play()
		self.buttons[self.selected]:deselect()
		self.selected = self.selected + 1
		if self.selected > #self.buttons then
			self.selected = 1
		end
		self.buttons[self.selected]:select()
	elseif Key:isPressed("up") then
		self.selectSFX:play()
		self.buttons[self.selected]:deselect()
		self.selected = self.selected - 1
		if self.selected < 1 then
			self.selected = #self.buttons
		end
		self.buttons[self.selected]:select()
	end

	Pause.super.update(self, dt)
end


function Pause:draw()
	self.overlayRect:draw()
	Pause.super.draw(self)
end


function Pause:show()
end

function Pause:hide()
end
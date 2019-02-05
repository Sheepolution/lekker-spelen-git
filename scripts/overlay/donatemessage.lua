DonateMessage = Sprite:extend("DonateMessage")

function DonateMessage:new(...)
	DonateMessage.super.new(self, ...)
	self:setImage("lekker_spelen/donate_images/lekker_gier", 152, 152)
	self.anim:add("idle", nil, 25)

	self.x = self.x - self.width/2

	local dc = {
		white = {1, 1, 1},
		small = {173/255, 253/255 ,28/255}
	}

	self.textDonater = Text(-100, 30, {dc.small, "Sheepolution", dc.white, " verspilde ", dc.small, "€3", dc.white, "!"}, "roboto-black", 16)
	self.textDonater.border:set(.5)
	self.textDonater.border.color = {0, 0, 0}
	self.textDonater.font:setFilter("linear", "linear")
	self.textDonater.align.x = "center"
	self.textDonater.limit = 300

	self.textMessage = Text(-50, 50, "Hey jongens als jullie op de A knop drukken dan kan je springen. Dit zou nog wel eens van pas kunnen komen.", "roboto-regular", 14)
	self.textMessage.border:set(.5)
	self.textMessage.border.color = {0, 0, 0}
	self.textMessage.font:setFilter("linear", "linear")
	self.textMessage.align.x = "center"
	self.textMessage.limit = 250

	self.messages = {
		"Hallo? Doen de donaties het nog wel? Mannen, als je B indrukt en loslaat kan je de ander naar je toe laten teleporteren. Dit zou nog wel eens van pas kunnen komen.",
		"Mannen, deze shirtjes zijn zo goed. Door ze te dragen krijg je meer hartjes aan het begin van een level.",
		"Gefeliciteerd mannen, jullie hebben een checkpoint te pakken. Mochten jullie digitale dierenlichamen sterven dan zullen jullie gewoon terugkeren naar dat punt. Hoe dat werkt? Weet ik veel.",
		"Hey mannen, mochten jullie vast komen te zitten, dan kunnen jullie teleporteren naar de laatste checkpoint door beiden X ingedrukt te houden. Dit moeten jullie waarschijnlijk nog vaak gebruiken.",
		"Oja, mochten jullie het nog niet doorhebben jullie kunnen trouwens van plek verwisselen als jullie beiden B ingedrukt houden. Klinkt erg handig als je het mij vraagt.",
		"Oja, Peter, als je Y indrukt wanneer je bij Timon staat ga je op hem zitten. Timon loopt, Peter springt."
	}

	self.audioMessages = {
		Asset.audio("donation_messages/1_teleport"),
		Asset.audio("donation_messages/shop_shirts"),
		Asset.audio("donation_messages/2_checkpoint"),
		Asset.audio("donation_messages/3_back_to_checkpoint"),
		Asset.audio("donation_messages/3_swapping"),
		Asset.audio("donation_messages/5_sitting"),
		Asset.audio("donation_messages/5_sitting_faster")
	}

	self.y = self.y + 150

	self.donationSound = Asset.audio("sfx/donation_coin")
end


function DonateMessage:update(dt)
	DonateMessage.super.update(self, dt)
end


function DonateMessage:draw()
	DonateMessage.super.draw(self)
	table.insert(NON_PUSH_DRAWS, function ()
		self.textDonater.alpha = self.alpha
		self.textDonater.border.alpha = self.alpha
		self.textMessage.alpha = self.alpha
		self.textMessage.border.alpha = self.alpha
		self.textDonater:drawAsChild(self)
		self.textMessage:drawAsChild(self)
	end)
end


function DonateMessage:donate(i)
	if DATA.options.game.speedrun then return end
	self.scene:playAudio(self.donationSound)
		self.textMessage:write(self.messages[i])
	self.tick:delay(1, function ()
		self.scene:playAudio(self.audioMessages[i])
	end)
	self.flux:to(self, 0.4, {y = self.y - 150}):ease("backout")
	self.flux:to(self, 1, {alpha = 0}):delay(8)
	:oncomplete(function ()
		self.y = self.y + 150
		self.alpha = 1
	end)
end
require "levelprops/triggers/overlaptrigger"

DonationTrigger = OverlapTrigger:extend("DonationTrigger")

function DonationTrigger:new(...)
	DonationTrigger.super.new(self, ...)

end

function DonationTrigger:onTrigger()
	self.scene.donateMessage:donate(self.donation)
	self:destroy()
end
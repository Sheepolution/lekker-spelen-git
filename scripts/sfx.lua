SFX = Object:extend("SFX")

function SFX:new(url, max)
	self.url = url
	self.sounds = {}
	self.max = max or 0
end

function SFX:play()
	for i,v in _.ripairs(self.sounds) do
		if not v:isPlaying() then
			v:setVolume(GET_SFX_VOLUME())
			v:play()
			return v
		end
	end


	if self.max > 0 and #self.sounds >= self.max then
		return nil
	end

	local sound = Asset.audio(self.url, "static", true)
	table.insert(self.sounds, sound)
	sound:setVolume(GET_SFX_VOLUME())
	sound:play()
	return sound
end

function SFX:stop()
	for i,v in ipairs(self.sounds) do
		v:stop()
	end
end
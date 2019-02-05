local Asset = {}

local imgCache = {}
local imgDataCache = {}
local fontCache = {}
local audioCache = {}

function Asset.image(url, force)
	local img
	if force or not imgCache[url] then
		img = love.graphics.newImage("assets/images/" .. url .. ".png")
		imgCache[url] = img
	else
		img = imgCache[url]
	end
	return img
end


function Asset.imageData(url, force)
	local img
	if force or not imgDataCache[url] then
		img = love.image.newImageData("assets/images/" .. url .. ".png")
		imgDataCache[url] = img
	else
		img = imgDataCache[url]
	end
	return img
end


function Asset.font(url, size, force)
	local font
	if force or not fontCache[url] or not fontCache[url][size] then
		font = love.graphics.newFont("assets/fonts/" .. url .. ".ttf", size)
		if not fontCache[url] then
			fontCache[url] = {}
		end
		fontCache[url][size] = font
	else
		font = fontCache[url][size]
	end
	return font
end


local audio_formats = {
	".mp3",
	".ogg",
	".wav"
}

function Asset.audio(url, static, force)
	local aud
	if force or not audioCache[url] then
		for i,v in ipairs(audio_formats) do
			local furl = "assets/audio/" .. url .. v
			local info  = love.filesystem.getInfo(furl)
			if info then
				aud = love.audio.newSource(furl, static or "static")
				audioCache[url] = aud
			end
		end
		assert(aud, "No audio found named " .. url, 2)
	else
		aud = audioCache[url]
		aud:stop()
	end
	return aud
end

return Asset
GameManager = Scene:extend()

VERSION = "1.1.2"

CURRENT_LEVEL = 1
RESTART = false

function SAVE_DATA()
	love.filesystem.write("data.txt", _.serialize(DATA))
end

function GET_NEW_DATA()
	local fastest = -1
	
	if DATA then fastest = DATA.fastestTime or -1 end

	local DATA = {
		shirts = {
			false,
			false,
			false,
			false,
			false
		},
		version = "1.1.2",
		deaths = 0,
		time = 0,
		fastestTime = -1,
		baseHealth = 3,
		euros = 0,
		lastEuros = 0,
		lastCheckpoint = nil,
		level = 0,
		options = {
			screen = {
				fullscreen = true,
				pixelperfect = true,
				vsync = true
			},
			audio = {
				master_volume = 5,
				music_volume = 5,
				sfx_volume = 5,
			},
			controller = {
				rumble = true,
				singleplayer = false
			},
			game = {
				speedrun = false
			}
		}
	}

	DATA.fastestTime = fastest

	return DATA
end


local info = love.filesystem.getInfo("data.txt")
if info then
	DATA = _.deserialize(love.filesystem.read("data.txt"))
	if not DATA.version then
		DATA = GET_NEW_DATA()
		SAVE_DATA()
	end
else
	DATA = GET_NEW_DATA()
	SAVE_DATA()
end


love.audio.setVolume(DATA.options.audio.master_volume/5)

LEVELS = {
	"level1",
	"shop",
	"level2",
	"shop",
	"richard",
	"level3",
	"shop",
	"level4_intro",
	"level4",
	"shop",
	"lekkerchat_intro",
	"lekkerchat",
	"level5",
	"shop",
	"level6",
	"shop",
	"emotilord"
}

function GameManager:new()
	GM = self
	self.currentLevelName = LEVELS[CURRENT_LEVEL]
	-- self.currentLevelName = CURRENT_LEVEL
	self.level = Level(self.currentLevelName, RESTART or DATA.lastCheckpoint ~= nil)
	self.nextLevel = nil
end


function GameManager:update(dt)
	self.level:update(dt)

	if DEBUG then
		if Key:isPressed("f2") then
			DATA.lastCheckpoint = nil
			CURRENT_LEVEL = CURRENT_LEVEL + 1
			self:goToLevel(LEVELS[CURRENT_LEVEL])
		end
		if Key:isPressed("f1") then
			DATA.lastCheckpoint = nil
			CURRENT_LEVEL = CURRENT_LEVEL - 1
			self:goToLevel(LEVELS[CURRENT_LEVEL])
		end

		-- if Key:isPressed("f3") then
		-- 	self.level:gainHealth()
		-- end
	end

	if self.nextLevel then
		self:goToNextLevel()
		self.nextLevel = nil
	end
end


function GameManager:draw()
	self.level:draw()
end


function GameManager:goToLevel(name)
	if self.level then
		if self.level.currentTheme then
			self.level.currentTheme:stop()
		end
	end
	self.currentLevelName = name
	self.level = Level(self.currentLevelName)
end


function GameManager:reloadLevel()
	self.level = Level(self.currentLevelName, true)
end


function GameManager:getStartHealth()
	-- if DEBUG then return 20 end
	return DATA.baseHealth
	-- if true then return 3 end
	-- if CURRENT_LEVEL == 1 then
	-- 	return 3
	-- elseif CURRENT_LEVEL == 2 then
	-- 	return 4
	-- elseif CURRENT_LEVEL == 3 then
	-- 	return 6
	-- elseif CURRENT_LEVEL == 4 then
	-- 	return 7
	-- else
	-- 	return 20
	-- end
end


function GameManager:goToNextLevel()
	DATA.lastCheckpoint = nil
	DATA.lastEuros = DATA.euros
	self.level:kill()
	CURRENT_LEVEL = CURRENT_LEVEL + 1
	DATA.level = CURRENT_LEVEL
	SAVE_DATA()
	self.currentLevelName = LEVELS[CURRENT_LEVEL]
	self.level = Level(self.currentLevelName)
end


function GET_MUSIC_VOLUME()
	return .3 * (DATA.options.audio.music_volume/5)
end


function GET_SFX_VOLUME()
	return .5 * (DATA.options.audio.sfx_volume/5)
end


local currentsong = nil

function PLAY_SONG(song)
	if currentsong and currentsong:isPlaying() then
		currentsong:stop()
	end

	currentsong = Asset.audio(song)
	currentsong:setVolume(DATA.options.audio.music_volume)
	currentsong:play()
end


return GameManager
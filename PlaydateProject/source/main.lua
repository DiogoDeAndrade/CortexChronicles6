import "CoreLibs/graphics"
import "level"
import "fight"
import "playerdata"
import "menuscreen"
import "storyscreen"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geom <const> = pd.geometry

story1 = { "Previously on the Cortex Chronicles...", 
		   "Rowan: We need to go in, if this is deployed we'll never be able to get rid of it!", 
		   "Nyx: Do we even know what we're up against?", 
		   "Rowan: Not really... We only found the lab today... You think that's going to be a problem?", 
		   "back:story02.png",
		   "rect:240,0,160,50",
		   "Nyx: Hope not..." }

playerData = PlayerData()

Screen.addScreen("Logo", MenuScreen("logo", "MainMenu", nil))
Screen.addScreen("MainMenu", MenuScreen("title", "Story01", nil))
Screen.addScreen("Story01", StoryScreen("story01", "Level01", story1, geom.rect.new(150, 0, 250, 80)))
Screen.addScreen("Level01", Level("Level01"))
Screen.addScreen("Level02", Level("Level02"))
Screen.addScreen("Level03", Level("Level03"))
Screen.addScreen("Fight", Fight())
Screen.addScreen("GameOver", MenuScreen("gameover", nil, { { image = playerData.button_retry, screen = "{param}" }, { image = playerData.button_quit, screen = "MainMenu" } }))

Screen.gotoScreen("Level03", nil, 0.5)
--Screen.gotoScreen("Logo")
frame = 1

function playdate.update()
	--print("------ Frame " .. frame .. " ------")
	frame += 1
	Screen.run()
end

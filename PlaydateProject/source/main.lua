import "CoreLibs/graphics"
import "level"
import "fight"
import "playerdata"
import "menuscreen"

local pd <const> = playdate
local gfx <const> = pd.graphics

playerData = PlayerData()

Screen.addScreen("Level01", Level("Level01"))
Screen.addScreen("Level02", Level("Level02"))
Screen.addScreen("Level03", Level("Level03"))
Screen.addScreen("Fight", Fight())
Screen.addScreen("GameOver", MenuScreen("gameover", nil, { { image = playerData.button_retry, screen = "{param}" }, { image = playerData.button_quit, screen = "mainmenu" } }))

Screen.gotoScreen("Level03")
frame = 1

function playdate.update()
	--print("------ Frame " .. frame .. " ------")
	frame += 1
	Screen.run()
end

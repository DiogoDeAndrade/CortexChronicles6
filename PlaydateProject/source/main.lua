import "CoreLibs/graphics"
import "level"
import "fight"
import "playerdata"
import "imagescreen"

local pd <const> = playdate
local gfx <const> = pd.graphics

playerData = PlayerData()

Screen.addScreen("Level01", Level("Level01"))
Screen.addScreen("Fight", Fight())
Screen.addScreen("GameOver", ImageScreen("gameover", "mainmenu"))
Screen.gotoScreen("Level01")
frame = 1

function playdate.update()
	--print("------ Frame " .. frame .. " ------")
	frame += 1
	Screen.run()
end

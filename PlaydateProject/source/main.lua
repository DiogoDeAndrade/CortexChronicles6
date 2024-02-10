import "CoreLibs/graphics"
import "level"

local pd <const> = playdate
local gfx <const> = pd.graphics

currentScreen = Level("Level01")
frame = 1

function playdate.update()
	--print("------ Frame " .. frame .. " ------")
	frame += 1
	currentScreen:run();
end

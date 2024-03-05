import "CoreLibs/graphics"
import "level"
import "playerdata"
import "menuscreen"
import "storyscreen"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geom <const> = pd.geometry

storyStart = { "Previously on the Cortex Chronicles...", 
		   "Rowan: We need to go in, if this is deployed we'll never be able to get rid of it!", 
		   "Nyx: Do we even know what we're up against?", 
		   "Rowan: Not really... We only found the lab today... You think that's going to be a problem?", 
		   "back:story02.png",
		   "rect:240,0,160,50",
		   "Nyx: Hope not..." 
		}

storyEnd = { "...",
             "Nyx: -polite cough-",
             "back:story04.png",
			 "rect:150,190,250,50",
			 "Cogwell: What? Who are you? SECURITY!",
			 "Nyx: Sorry, Doc, don't think they're comming, it's just me and you...",
			 "Cogwell: Hrumph... Let me guess... You're one of those pesky freedom fighters the Prime Nexus is worried about?",
			 "Cogwell: You don't look that impressive... no ofense, of course...",
			 "back:story05.png",
			 "rect:240,0,160,50",
			 "Nyx: None taken... Anyway, if you know who we are, you know what we want...",
			 "Nyx: Destroy the MoodMorph research... we can't let you deploy it...",
			 "back:story04.png",
			 "rect:150,190,250,50",
			 "Cogwell: You're insane... that's my life work! I won't do it!",
			 "back:story06.png",
			 "Nyx: Yeah... I guessed that much...",
			 "Nyx: You Cortex lovers are all the same!"
		}

credits = { "Code, story, game design by\nDiogo de Andrade\n\nArt by\nDall-E 3\nOpenGameArt.org LPC art\nDiogo de Andrade\n\nMusic by\nklavo1985" }

--playdate.display.setRefreshRate(0)

playerData = PlayerData()

logoScreen = MenuScreen("logo", "MainMenu", nil, nil, 3)
menuScreen = MenuScreen("title", nil, { { image = playerData.button_start, screen = "Story01" }, { image = playerData.button_credits, screen = "Credits" } }, nil)
menuScreen.startDuration = 2
menuScreen.yMenu = 150
creditsScreen = StoryScreen("bgcredits", "MainMenu", credits, geom.rect.new(2, 2, 180, 100))
startStoryScreen = StoryScreen("story01", "Level01", storyStart, geom.rect.new(150, 0, 250, 80))
level1 = Level("Level01")
level2 = Level("Level02")
level3 = Level("Level03")
level4 = Level("Level04")
gameOverScreen = MenuScreen("gameover", nil, { { image = playerData.button_retry, screen = "{param}" }, { image = playerData.button_quit, screen = "MainMenu" } }, nil)
endStoryScreen = StoryScreen("story03", "EndEnd", storyEnd, geom.rect.new(150, 0, 250, 40), nil)
endScreen = MenuScreen("end", "MainMenu", nil, nil)

Screen.addScreen("Logo", logoScreen)
Screen.addScreen("MainMenu", menuScreen)
Screen.addScreen("Credits", creditsScreen)
Screen.addScreen("Story01", startStoryScreen)
Screen.addScreen("Level01", level1)
Screen.addScreen("Level02", level2)
Screen.addScreen("Level03", level3)
Screen.addScreen("Level04", level4)
Screen.addScreen("GameOver", gameOverScreen)
Screen.addScreen("End", endStoryScreen)
Screen.addScreen("EndEnd", endScreen)

--Screen.gotoScreen("Level04", nil, 0.5)
--Screen.gotoScreen("MainMenu")
--Screen.gotoScreen("Credits")
Screen.gotoScreen("Logo")
frame = 1

function playdate.update()
	--print("------ Frame " .. frame .. " ------")
	frame += 1
	Screen.run()
end

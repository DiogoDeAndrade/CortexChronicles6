import "CoreLibs/graphics"
import "level"
import "fight"
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

playerData = PlayerData()

Screen.addScreen("Logo", MenuScreen("logo", "MainMenu", nil))
Screen.addScreen("MainMenu", MenuScreen("title", "Story01", nil))
Screen.addScreen("Story01", StoryScreen("story01", "Level01", storyStart, geom.rect.new(150, 0, 250, 80)))
Screen.addScreen("Level01", Level("Level01"))
Screen.addScreen("Level02", Level("Level02"))
Screen.addScreen("Level03", Level("Level03"))
Screen.addScreen("Fight", Fight())
Screen.addScreen("GameOver", MenuScreen("gameover", nil, { { image = playerData.button_retry, screen = "{param}" }, { image = playerData.button_quit, screen = "MainMenu" } }))
Screen.addScreen("End", StoryScreen("story03", "EndEnd", storyEnd, geom.rect.new(150, 0, 250, 40)))
Screen.addScreen("EndEnd", MenuScreen("end", "MainMenu", nil))

Screen.gotoScreen("End", nil, 0.5)
--Screen.gotoScreen("Logo")
frame = 1

function playdate.update()
	--print("------ Frame " .. frame .. " ------")
	frame += 1
	Screen.run()
end

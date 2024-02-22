import "CoreLibs/graphics"
import "screen"
import "path"
import "character"
import "player"
import "enemy"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('MenuScreen').extends(Screen)

function MenuScreen:init(backgroundImageName, defaultScene, buttonList)
    MenuScreen.super.init(self)

    self.image = gfx.image.new("sprites/" .. backgroundImageName .. ".png")
    self.defaultScene = defaultScene
    
    self.buttonList = buttonList
    self.selected = 1
end

function MenuScreen:start(currentScreenName)
    MenuScreen.super.start(self)

    self.currentScreenName = currentScreenName
end

function MenuScreen:update()
    MenuScreen.super.update(self)

    if defaultScene ~= nil then
        if playdate.buttonIsPressed(playdate.kButtonB) then
            Screen.gotoScreen(self.nextScene, nil)
        end
    end
end

function MenuScreen:render()
end

function MenuScreen:afterRender()
    gfx.setDrawOffset(0, 0)
    self.image:draw(0,0)

    if self.buttonList ~=nil then
        local y = 100
        for i, button in ipairs(self.buttonList) do
            local sx, sy = button.image:getSize()

            if i == self.selected then
                gfx.setImageDrawMode(gfx.kDrawModeInverted)
            else
                gfx.setImageDrawMode(gfx.kDrawModeCopy)
            end

            button.image:draw(200 - sx * 0.5, y)
            y += sy + 2
        end

        gfx.setImageDrawMode(gfx.kDrawModeCopy)

        if pd.buttonJustPressed(pd.kButtonUp) then
            self.selected -= 1
            if (self.selected < 1) then
                self.selected = #self.buttonList
            end
        end
        if pd.buttonJustPressed(pd.kButtonDown) then
            self.selected = (self.selected % #self.buttonList) + 1
        end
        if (pd.buttonJustPressed(pd.kButtonA)) or (pd.buttonJustPressed(pd.kButtonB)) then
            local nextScreen = self.buttonList[self.selected].screen
            if nextScreen == "{param}" then
                nextScreen = self.currentScreenName
            end

            Screen.gotoScreen(nextScreen)
        end
    end
end

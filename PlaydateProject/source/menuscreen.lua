import "CoreLibs/graphics"
import "screen"
import "path"
import "character"
import "player"
import "enemy"
import "playerData"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('MenuScreen').extends(Screen)

function MenuScreen:init(backgroundImageName, defaultScene, buttonList, transitionTime, waitTime)
    MenuScreen.super.init(self)

    self.image = gfx.image.new("sprites/" .. backgroundImageName .. ".png")
    self.defaultScene = defaultScene
    
    self.buttonList = buttonList
    self.selected = 1

    if transitionTime == nil then
        self.transitionTime = 1
    else
        self.transitionTime = transitionTime
    end

    if waitTime ~= nil then
        self.waitTime = waitTime
    end

    self.startDuration = 0
    self.yMenu = 100
end

function MenuScreen:start(currentScreenName)
    MenuScreen.super.start(self)

    self.currentScreenName = currentScreenName

    self.inputEnable = false
    self.startTime = self.startDuration
end

function MenuScreen:update()
    MenuScreen.super.update(self)

    if self.startTime > 0 then
        self.startTime -= self.deltaTime
    else
        if self.inputEnable then
            if self.defaultScene ~= nil then
                if playdate.buttonIsPressed(playdate.kButtonA) or playdate.buttonIsPressed(playdate.kButtonB) then
                    if self.callback ~= nil then
                        self.callback(self.defaultScene)
                    end

                    if Screen.gotoScreen(self.defaultScene, nil, self.transitionTime) then
                        playerData:playSound("select")
                    end
                end
            end

            if self.buttonList ~=nil then
                if pd.buttonJustPressed(pd.kButtonUp) then
                    self.selected -= 1
                    if (self.selected < 1) then
                        self.selected = #self.buttonList
                    end
                    playerData:playSound("option")
                end
                if pd.buttonJustPressed(pd.kButtonDown) then
                    self.selected = (self.selected % #self.buttonList) + 1
                    playerData:playSound("option")
                end
                if (pd.buttonJustPressed(pd.kButtonA)) or (pd.buttonJustPressed(pd.kButtonB)) then
                    local nextScreen = self.buttonList[self.selected].screen

                    if self.callback ~= nil then
                        self.callback(nextScreen)
                    end

                    if nextScreen == "{param}" then
                        nextScreen = self.currentScreenName
                    end
                        
                    if Screen.gotoScreen(nextScreen, self.transitionTime) then
                        playerData:playSound("select")
                    end
                end
            end
        else
            if not playdate.buttonIsPressed(pd.kButtonA) and 
            not playdate.buttonIsPressed(pd.kButtonB) and 
            not playdate.buttonIsPressed(pd.kButtonUp) and 
            not playdate.buttonIsPressed(pd.kButtonDown) then
                self.inputEnable = true
            end
        end

        if self.waitTime ~= nil then
            self.waitTime -= self.deltaTime
            if self.waitTime < 0 then
                if self.callback ~= nil then
                    self.callback(self.defaultScene)
                end

                Screen.gotoScreen(self.defaultScene, nil, self.transitionTime)
            end
        end
    end
end

function MenuScreen:render()
    
end

function MenuScreen:afterRender()
    gfx.setDrawOffset(0, 0)
    self.image:draw(0,0)

    if self.startTime <= 0 then
        if self.buttonList ~=nil then
            local y = self.yMenu
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
        end
    end
end

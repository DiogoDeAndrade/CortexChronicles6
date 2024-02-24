import "CoreLibs/graphics"
import "screen"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geom <const> = pd.geometry

class('StoryScreen').extends(Screen)

function StoryScreen:init(backgroundImageName, nextScene, storyText, storyRect)
    StoryScreen.super.init(self)

    self.image = gfx.image.new("sprites/" .. backgroundImageName .. ".png")
    self.nextScene = nextScene
    self.storyText = storyText
    self.transitionTime = 1
    self.storyRect = storyRect
end

function StoryScreen:start(param)
    StoryScreen.super.start(self)

    self.inputEnable = false
    self.storyIndex = 1
end

function StoryScreen:update()
    StoryScreen.super.update(self)

    if self.inputEnable then
        if playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonB) then
            if self.storyText ~= nil and self.storyIndex >= #self.storyText then
                Screen.gotoScreen(self.nextScene, nil, self.transitionTime)
            else
                self:nextText()
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
end

function StoryScreen:nextText()
    self.storyIndex += 1
    if self.storyIndex > #self.storyText then
        return
    end
    
    local text = self.storyText[self.storyIndex]
    local cmd = string.sub(text, 1, 5)
    if cmd == "back:" then
        -- Change background 
        self.image = gfx.image.new("sprites/" .. string.sub(text, 6))
    elseif cmd == "rect:" then
        local x, y, width, height = string.match(text, "rect:(%d+),%s*(%d+),%s*(%d+),%s*(%d+)")
        self.storyRect = geom.rect.new(tonumber(x), tonumber(y), tonumber(width), tonumber(height))
    else
        return
    end

    self:nextText()
end

function StoryScreen:render()
    
end

function StoryScreen:afterRender()
    gfx.setDrawOffset(0, 0)
    self.image:draw(0,0)

    if self.storyText ~= nil then
        if self.storyIndex <= #self.storyText then
            local text = string.upper(self.storyText[self.storyIndex])
            self:drawWithBorder(self.storyRect.x, self.storyRect.y, self.storyRect.width, self.storyRect.height)
            gfx.setColor(playdate.graphics.kColorWhite)
            local w, h, textWasTruncated = gfx.drawTextInRect(text, self.storyRect.x+4, self.storyRect.y+4, self.storyRect.width - 8, self.storyRect.height - 8, nil, "...", gfx.kTextAlignmentLeft)
        end
    end
end

function StoryScreen:drawWithBorder(x, y, width, height)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(x, y , width, height)
    gfx.setColor(gfx.kColorWhite)
    gfx.drawRect(x, y , width, height)
    gfx.drawRect(x + 2, y + 2, width - 4, height - 4)
end

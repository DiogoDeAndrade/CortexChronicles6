import "CoreLibs/graphics"
import "screen"
import "path"
import "character"
import "player"
import "enemy"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Fight').extends(Screen)

function Fight:init(baseName)
    Fight.super.init(self)

    self.backColor = gfx.kColorBlack
end

function Fight:start(enemy)
    Fight.super.start(self)
    
    self.enemy = enemy
end

function Fight:update()
    Fight.super.update(self)

    if playdate.buttonIsPressed(playdate.kButtonB) then
        Screen.popScreen()

        self.enemy:kill()
    end
end

function Fight:render()

    gfx.setLineWidth(5)
    gfx.drawLine(-200, -100, 200, 100)
    gfx.setLineWidth(1)
end

function Fight:afterRender()
end

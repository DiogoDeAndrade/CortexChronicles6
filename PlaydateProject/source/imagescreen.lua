import "CoreLibs/graphics"
import "screen"
import "path"
import "character"
import "player"
import "enemy"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('ImageScreen').extends(Screen)

function ImageScreen:init(imageName, nextScene)
    ImageScreen.super.init(self)

    self.image = gfx.image.new("sprites/" .. imageName .. ".png")
    self.nextScene = nextScene
end

function ImageScreen:start(param)
    ImageScreen.super.start(self)
end

function ImageScreen:update()
    ImageScreen.super.update(self)

    if playdate.buttonIsPressed(playdate.kButtonB) then
        Screen.gotoScreen(self.nextScene, nil)
    end
end

function ImageScreen:render()
end

function ImageScreen:afterRender()
    gfx.setDrawOffset(0, 0)
    self.image:draw(0,0)
end

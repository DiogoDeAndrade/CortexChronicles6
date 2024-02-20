import "CoreLibs/sprites"
import "playerdata"

local pd <const> = playdate
local gfx <const> = pd.graphics
local pt2 <const> = playdate.geometry.point
local vec2 <const> = playdate.geometry.vector2D

class('Door').extends(gfx.sprite)

function Door:init(x, y, radius, isFinalExit, nextLevel, requiredKey)

    Door.super.init(self)

    self:moveTo(x,y)
    self:setCenter(0.5, 1.0)
    self:setImage(playerData.closedDoor)

    self.pos = pt2.new(x,y)
    self.radius = radius
    self.isFinalExit = isFinalExit
    self.nextLevel = nextLevel
    self.requiredKey = requiredKey
    self.open = self.requiredKey == 0
end

function Door:update()
    self:setZIndex(self.pos.y)
    
    if self.open then
        self:setImage(playerData.openDoor)
    else
        self:setImage(playerData.closedDoor)
    end

    Door.super.update(self)
end

function Door:afterRender()
end

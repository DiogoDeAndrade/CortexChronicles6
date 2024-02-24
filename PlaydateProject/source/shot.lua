import "CoreLibs/sprites"
import "character"
import "playerdata"

local pd <const> = playdate
local gfx <const> = pd.graphics
local pt2 <const> = playdate.geometry.point
local vec2 <const> = playdate.geometry.vector2D

class('Shot').extends()

function Shot:init(pos, velocity, duration, radius, levelScreen)

    Shot.super.init(self)

    self.pos = pos
    self.oldPos = self.pos
    self.velocity = velocity
    self.timer = duration
    self.radius = radius
    self.levelScreen = levelScreen
end

function Shot:render()
    --gfx.fillRect(self.pos.x - self.radius, self.pos.y - self.radius, self.radius * 2 + 1, self.radius * 2 + 1)
    gfx.setLineWidth(self.radius)

    gfx.drawLine(self.pos.x, self.pos.y, self.oldPos.x, self.oldPos.y)

    gfx.setLineWidth(1)
end

function Shot:update(deltaTime)
    self.oldPos = self.pos
    self.pos += self.velocity * deltaTime * 0.001
    self.timer -= deltaTime
end

function Shot:hitPlayer()
    local player = self.levelScreen.player
    if player ~= nil then
        if player:isDead() then
            return false
        end
        
        local seg = self.oldPos .. self.pos

        local pos = seg:closestPointOnLineToPoint(player.pos)
        if player.pos:distanceToPoint(pos) < 8 then
            return true
        end
    end

    return false
end

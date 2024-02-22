import "CoreLibs/sprites"
import "character"
import "playerdata"

local pd <const> = playdate
local gfx <const> = pd.graphics
local pt2 <const> = playdate.geometry.point
local vec2 <const> = playdate.geometry.vector2D

class('Shot').extends()

function Shot:init(pos, velocity, duration, radius)

    Shot.super.init(self)

    self.pos = pos
    self.oldPos = self.pos
    self.velocity = velocity
    self.timer = duration
    self.radius = radius
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

import "CoreLibs/sprites"
import "character"

local pd <const> = playdate
local gfx <const> = pd.graphics
local pt2 <const> = playdate.geometry.point
local vec2 <const> = playdate.geometry.vector2D

class('Enemy').extends(Character)

function Enemy:init(name, path, moveSpeed)
    local nyx_table = gfx.imagetable.new("sprites/nyx")

    Enemy.super.init(self, 10, 0, nyx_table, path)

    self.name = name
    self.moveSpeed = moveSpeed
end

function Enemy:update()

    self.distance += self.moveSpeed
    if self.distance < 0 then
        self.distance = 0
    elseif self.distance > self.path.totalLength then
        if self.path.isLoop then
            self.distance -= self.path.totalLength
        else
            self.distance = self.path.totalLength
        end
    end

    Enemy.super.update(self)
end

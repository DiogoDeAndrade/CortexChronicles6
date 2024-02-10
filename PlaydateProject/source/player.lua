import "CoreLibs/sprites"
import "character"

local pd <const> = playdate
local gfx <const> = pd.graphics
local pt2 <const> = playdate.geometry.point
local vec2 <const> = playdate.geometry.vector2D

class('Player').extends(Character)

function Player:init(path, levelScreen)
    local nyx_table = gfx.imagetable.new("sprites/nyx")

    Player.super.init(self, 10, 0, nyx_table, path, levelScreen)
    
    self.moveSpeed = 40
end

function Player:update()
    -- Get crank delta
    local change, acceleratedChange = pd.getCrankChange()

    
    self.distance += self.moveSpeed * (change / 360)
    if self.distance < 0 then
        self.distance = 0
    elseif self.distance > self.path.totalLength then
        self.distance = self.path.totalLength
    end

    Player.super.update(self)
end

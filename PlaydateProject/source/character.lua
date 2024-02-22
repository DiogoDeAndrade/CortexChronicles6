import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics
local pt2 <const> = playdate.geometry.point
local vec2 <const> = playdate.geometry.vector2D

class('Character').extends(gfx.sprite)

function Character:init(x, y, characterSheet, path, levelScreen)
    Character.super.init(self)

    self.characterAnim = true
    self.characterSheet = characterSheet
    self.dir = 0
    self.animFrame = 0
    self.lastUpdateTime = pd.getCurrentTimeMilliseconds()
    self.path = path
    self.distance = 0
    self.pos = pt2.new(x,y)
    self.prevPos = pt2.new(x,y)
    self.lastMove = vec2.new(0,0)
    self.moveSpeed = 20
    self.levelScreen = levelScreen

    self:moveTo(x,y)
    self:setFrame(1)
    self:setZIndex(0)
    self:setCenter(0.5, 1.0)

    if (self.path ~= nil) then
        self.pos = self.path:computePositionAlongPath(self.distance)
        self.prevPos = self.pos:copy()
        self:moveTo(self.pos)
        self.dir = 1
    end
end

function Character:getHeadPos()
    local headPos = self.pos:copy()
    headPos.y -= 14
    
    return headPos
end

function Character:setFrame(index)
    self:setImage(self.characterSheet:getImage(index))
end

function Character:update()
    local currentPos = self.pos
    local currentTime = pd.getCurrentTimeMilliseconds()
    self.deltaTime = currentTime - self.lastUpdateTime
    self.lastUpdateTime = currentTime

    self:setZIndex(self.pos.y)

    if self.levelScreen.state == Level.STATE_NORMAL then
        if self.characterAnim then
            if self.deltaTime >= 100 then -- Check if 100 ms have passed
                self.animFrame = (self.animFrame + 1) % 3
            end

            self:setFrame(self.dir * 3 + self.animFrame + 1)
        end

        if (self.path ~= nil) then
            self.pos = self.path:computePositionAlongPath(self.distance)
            self:moveTo(self.pos)

            local lastDeltaPos = self.pos - self.prevPos
            if lastDeltaPos:magnitudeSquared() > 0 then
                self.lastMove = lastDeltaPos:copy()
                self.prevPos = self.pos:copy()

                -- Change dir
                if math.abs(self.lastMove.x) > math.abs(self.lastMove.y) then
                    -- Move horizontal
                    if self.lastMove.x > 0 then
                        self.dir = 1
                    else
                        self.dir = 3
                    end
                else
                    -- Move vertical
                    if self.lastMove.y > 0 then
                        self.dir = 2
                    else
                        self.dir = 0
                    end
                end
            else
                self:setFrame(self.dir * 3 + 1)
            end
        end
    end

    Character.super.update(self)

    self.currentVelocity = (self.pos - currentPos) / (self.deltaTime * 0.001)
end

function Character:afterRender()
end
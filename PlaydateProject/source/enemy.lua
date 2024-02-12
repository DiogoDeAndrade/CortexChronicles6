import "CoreLibs/sprites"
import "character"
import "playerdata"

local pd <const> = playdate
local gfx <const> = pd.graphics
local pt2 <const> = playdate.geometry.point
local vec2 <const> = playdate.geometry.vector2D

local gAngle <const> = { math.rad(-90), math.rad(0), math.rad(90), math.rad(180) }
local gForward <const> = { vec2.new(0, -1), vec2.new(1, 0), vec2.new(0, 1), vec2.new(-1, 0) }

local PATROL <const> = 1
local START_CHASE <const> = 2
local CHASE <const> = 3
local DEAD <const> = -1

class('Enemy').extends(Character)

function Enemy:init(name, path, moveSpeed, difficulty, levelScreen)

    Enemy.super.init(self, 10, 0, playerData.guard_sprites, path, levelScreen)

    self.name = name
    self.moveSpeed = moveSpeed
    self.fov = 30
    self.fovRad = math.rad(self.fov)
    self.near = 20
    self.far = 80
    self.state = PATROL

    self.fovPolygon = pd.geometry.polygon.new(4)
    self.fovPolygon:close()

    self.difficulty = difficulty
    self.health = self:getMaxHealth()

end

function Enemy:getMaxHealth()
    return self.difficulty * 15
end

function Enemy:getHeadPos()
    local headPos = self.pos:copy()
    headPos.y -= 14
    
    return headPos
end

function Enemy:updateFOVPolygon()
        -- Update FOV polygon
        local basePos = self:getHeadPos()
        local baseAngle = gAngle[self.dir + 1]
        local forward1 = vec2.new(math.cos(baseAngle - self.fovRad), math.sin(baseAngle - self.fovRad))
        local forward2 = vec2.new(math.cos(baseAngle + self.fovRad), math.sin(baseAngle + self.fovRad))

        self.fovPolygon:setPointAt(1, basePos + forward1 * self.near)
        self.fovPolygon:setPointAt(2, basePos + forward1 * self.far)
        self.fovPolygon:setPointAt(3, basePos + forward2 * self.far)
        self.fovPolygon:setPointAt(4, basePos + forward2 * self.near)
end

function Enemy:update()

    if self.levelScreen.state == Level.STATE_NORMAL then
        if self.state == PATROL then
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

            self:updateFOVPolygon()

            -- Check if player is inside the fov
            local player = self.levelScreen.player
            if player ~= nil then
                local playerPos = player.pos
                local headPos = self:getHeadPos()

                -- Check distance
                local toPlayer = playerPos - headPos
                local dist = toPlayer:magnitude()
                if dist > (self.near - 10) and dist < (self.far + 10) then
                    toPlayer:normalize()
                    local angle = math.abs(toPlayer:angleBetween(gForward[self.dir + 1]))
                    if (angle < self.fov) then
                        -- Override path, now go towards the path of the player
                        self.state = START_CHASE
                        self.targetPoint, self.targetDistance = player.path:getClosestPoint(self.pos)
                        self.path = nil
                    end
                end
            end
        elseif self.state == START_CHASE then
            -- Move towards at chase speed (twice the normal speed)
            local totalMovement = self.moveSpeed * 2
            local distToTarget = self.targetPoint:distanceToPoint(self.pos)
            if distToTarget < totalMovement then
                self.state = CHASE
                self.path = self.levelScreen.player.path
                self.distance = self.targetDistance
                self.pos = self.targetPoint
            else
                local toTarget = (self.targetPoint - self.pos):normalized()
                self.pos = self.pos + toTarget * totalMovement
                self:moveTo(self.pos)
            end

            Enemy.super.update(self)
        elseif self.state == CHASE then

            local deltaDistance = self.levelScreen.player.distance - self.distance

            if deltaDistance > 0 then
                self.distance += self.moveSpeed
            else
                self.distance -= self.moveSpeed
            end

            if math.abs(deltaDistance) < 5 then
                -- FIGHT SEQUENCE ACTIVE
                self.levelScreen:switchToFightMode(self)
            end

            Enemy.super.update(self)
        else
            self:setFrame(13)
        end
    end
end

function Enemy:afterRender()
    if self.state == PATROL then
        gfx.setDitherPattern(0.75, gfx.image.kDitherTypeBayer8x8)

        gfx.fillPolygon(self.fovPolygon)

        gfx.setColor(gfx.kColorBlack)
    end
end

function Enemy:kill()
    self.state = DEAD
    self:setFrame(13)
end

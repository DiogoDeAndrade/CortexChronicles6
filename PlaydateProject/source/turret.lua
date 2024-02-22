import "CoreLibs/sprites"
import "character"
import "playerdata"
import "shot"

local pd <const> = playdate
local gfx <const> = pd.graphics
local pt2 <const> = playdate.geometry.point
local vec2 <const> = playdate.geometry.vector2D

local SCAN_MOVE <const> = 1
local SCAN_WAIT <const> = 2
local SCAN_TARGET <const> = 3
local DEAD <const> = -1

class('Turret').extends(Enemy)

function Turret:init(name, x, y, baseAngle, scanDuration, scanPause, scanAngularRange, difficulty, levelScreen)

    Turret.super.init(self, name, nil, 0, difficulty, levelScreen)

    self.characterAnim = false
    self.name = name
    self.fov = 30
    self.fovRad = math.rad(self.fov)
    self.near = 5
    self.far = 100
    self.baseAngle = math.rad(baseAngle)
    self.angle = self.baseAngle

    self.fovPolygon = pd.geometry.polygon.new(4)
    self.fovPolygon:close()

    self.scanDuration = scanDuration * 1000
    self.scanPause = scanPause * 1000
    self.scanAngularRange = scanAngularRange
    self.x = x
    self.y = y
    self.pos = pt2.new(x, y)

    self:moveTo(x, y)
    self:setImage(playerData.turret)

    self.state = SCAN_WAIT
    self.timer = self.scanPause
    self.currentAngle = 0
    self.targetAngle = -math.rad(self.scanAngularRange)
    self.angleInc = 2 * math.rad(self.scanAngularRange) / self.scanDuration

    self.shots = {}
    self.cooldown = 0
end

function Turret:updateFOVPolygon()
    -- Update FOV polygon
    local basePos = self:getHeadPos()
    local baseAngle = self.angle
    local forward1 = vec2.new(math.cos(baseAngle - self.fovRad), math.sin(baseAngle - self.fovRad))
    local forward2 = vec2.new(math.cos(baseAngle + self.fovRad), math.sin(baseAngle + self.fovRad))

    self.fovPolygon:setPointAt(1, basePos + forward1 * self.near)
    self.fovPolygon:setPointAt(2, basePos + forward1 * self.far)
    self.fovPolygon:setPointAt(3, basePos + forward2 * self.far)
    self.fovPolygon:setPointAt(4, basePos + forward2 * self.near)
end

function Turret:update()
    Enemy.super.update(self)

    -- Bypass enemy animation code, go straight to character animation code, the 
    -- following called Character.update()
    if self.state ~= DEAD then
        self:updateFOVPolygon()

        -- Animate scanner
        if self.state == SCAN_WAIT then
            self.timer -= self.deltaTime
            if self.timer <= 0 then
                self.state = SCAN_MOVE
                self.timer = 0
            end
        elseif self.state == SCAN_MOVE then
            if self.targetAngle < self.currentAngle then
                self.currentAngle -= self.angleInc * self.deltaTime
                if self.currentAngle <= self.targetAngle then
                    self.state = SCAN_WAIT
                    self.timer = self.scanPause
                    self.currentAngle = self.targetAngle
                    self.targetAngle = -self.targetAngle
                end
            else
                self.currentAngle += self.angleInc * self.deltaTime
                if self.currentAngle >= self.targetAngle then
                    self.state = SCAN_WAIT
                    self.timer = self.scanPause
                    self.currentAngle = self.targetAngle
                    self.targetAngle = -self.targetAngle
                end
            end

            self.angle = self.baseAngle + self.currentAngle
        elseif self.state == SCAN_TARGET then
            local player = self.levelScreen.player
            if player ~= nil then
                local headPos = self:getHeadPos()
                local playerPos = player.pos
        
                -- Check distance (linear distance along the vector)
                local shotSpeed = 200
                local time = 1000

                local toPlayer = playerPos - headPos
                local playerDist = toPlayer:magnitude()

                if playerDist > (shotSpeed * time * 0.001) then
                    self.state = SCAN_MOVE
                else
                    toPlayer:normalize()
                    self.angle = math.atan(toPlayer.y, toPlayer.x)

                    playerPos = player.pos + player.currentVelocity * (playerDist / shotSpeed)
                    toPlayer = playerPos - headPos
                    toPlayer:normalize()

                    -- Shoot towards the player
                    if self.cooldown <= 0 then
                        local shot = Shot(self:getHeadPos(), toPlayer * shotSpeed, time, 2)
                        table.insert(self.shots, shot)
                        self.cooldown = 100
                    end
                end
            end
        end

        if (self.state == SCAN_WAIT) or (self.state == SCAN_MOVE) then
            -- Check LOS
            local forward = vec2.new(math.cos(self.angle), math.sin(self.angle))
            if self:checkPlayerLOS(forward) then
                self.state = SCAN_TARGET
            end
        end
    end

    self.cooldown -= self.deltaTime
    for i, shot in ipairs(self.shots) do
        shot:update(self.deltaTime)
        if shot.timer <= 0 then
            table.remove(self.shots, i)
        else
            local player = self.levelScreen.player
            if player ~= nil then
                if shot.pos:distanceToPoint(player.pos) < 4 then
                    Screen.gotoScreen("GameOver", Screen.currentScreen.baseName)
                end
            end
        end
    end

end

function Turret:afterRender()
    if self.state ~= DEAD then
        gfx.setDitherPattern(0.75, gfx.image.kDitherTypeBayer8x8)

        gfx.fillPolygon(self.fovPolygon)

        gfx.setColor(gfx.kColorBlack)

        for i, shot in ipairs(self.shots) do
            shot:render()
        end
    end
end

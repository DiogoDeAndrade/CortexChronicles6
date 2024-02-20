import "CoreLibs/sprites"
import "character"
import "playerdata"

local pd <const> = playdate
local gfx <const> = pd.graphics
local pt2 <const> = playdate.geometry.point
local vec2 <const> = playdate.geometry.vector2D

class('Player').extends(Character)

function Player:init(path, levelScreen)

    Player.super.init(self, 10, 0, playerData.nyx_sprites, path, levelScreen)
    
    self.moveSpeed = 40
    self.keys = { }
end

function Player:update()
    if self.levelScreen.state == Level.STATE_NORMAL then
        -- Get crank delta
        local change, acceleratedChange = pd.getCrankChange()

        if (change == 0) then
            -- Debug code, should remove it on the final build
            if pd.buttonIsPressed(pd.kButtonLeft) then
                change = -25
            elseif pd.buttonIsPressed(pd.kButtonRight) then
                change = 25
            end
        end

        if change ~= 0 then
            local newDistance = self.distance + self.moveSpeed * (change / 360)
            if newDistance < 0 then
                newDistance = 0
            elseif newDistance > self.path.totalLength then
                newDistance = self.path.totalLength
            end

            -- Check if we're moving closer to a door
            if (self.path ~= nil) then
                local newPos = self.path:computePositionAlongPath(newDistance)
                
                local closestDoor, newDist = self.levelScreen:getClosestDoor(newPos)
                if (closestDoor ~= nil) then
                    if closestDoor.open then
                        -- Check if exit
                        self.distance = newDistance
                        if newDist < closestDoor.radius and closestDoor.isFinalExit then
                            -- Exit here!
                            Screen.gotoScreen(closestDoor.nextLevel)
                        end
                    else
                        -- Check old and new distance to this door
                        local oldDist = self.pos:distanceToPoint(closestDoor.pos)
                        if (newDist < oldDist) and (newDist < closestDoor.radius) then
                            -- Can't move there
                            if self:hasKey(closestDoor.requiredKey) then
                                closestDoor.open = true
                                self:removeKey(closestDoor.requiredKey)
                            end
                        else
                            -- Move to new position
                            self.distance = newDistance    
                        end
                    end
                else
                    self.distance = newDistance
                end
            else
                self.distance = newDistance
            end
        end
    end

    Player.super.update(self)
end


function Player:afterRender()
    if #self.keys > 0 then
        local h = self:getHeadPos()
        h.y -= 10
        playerData.keycard:drawAnchored(h.x, h.y, 0.5, 1.0)
    end
end

function Player:addKey(keyId)
    for _, item in ipairs(self.keys) do
        if item == keyId then
            return
        end
    end

    table.insert(self.keys, keyId)
end

function Player:hasKey(keyId)
    for _, item in ipairs(self.keys) do
        if item == keyId then
            return true
        end
    end

    return false
end

function Player:removeKey(keyId)
    for i, item in ipairs(self.keys) do
        if item == keyId then
            table.remove(self.keys, i)
            return
        end
    end
end

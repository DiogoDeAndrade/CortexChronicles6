import "CoreLibs/graphics"
import "screen"
import "path"
import "character"
import "player"
import "enemy"
import "playerdata"
import "door"
import "turret"
import "shadow"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Level').extends(Screen)

Level.STATE_NORMAL = 0
Level.STATE_FIGHT = 1
Level.STATE_STRANGLE = 2

Level.SUBSTATE_BLOCK = 0
Level.SUBSTATE_STRIKE = 1
Level.SUBSTATE_NYXHIT = 2
Level.SUBSTATE_NYXMISS = 3
Level.SUBSTATE_NYXFAIL = 4
Level.SUBSTATE_NYXBLOCK = 5
Level.SUBSTATE_GUARDHIT = 6
Level.SUBSTATE_GAMEOVER = 7

function Level:init(baseName)
    Level.super.init(self)

    self.baseName = baseName
end

function Level:start()
    self.tilesheet = gfx.imagetable.new("tilemaps/" .. self.baseName)

    self:read_tilemap("tilemaps/" .. self.baseName .. "_tilemap.bin")

    self:read_paths("paths/" .. self.baseName .. "_paths.bin")

    self:read_level_data("levels/" .. self.baseName .. ".bin")

    self.player = Player(self.paths["Master"], self)
    self:addObject(self.player)

    Level.super.start(self)

    self.state = Level.STATE_NORMAL
    self.substate = Level.SUBSTATE_BLOCK
    self.startStamina = playerData.stamina
end

function Level:close()
    Level.super.close(self)

    if self.player ~= nil then
        self.player = nil
    end
    self.enemies = {}
    self.doors = {}
    self.paths = {}
    self.shadows = {}
end

function Level:read_tilemap(filename)

    local file, err = playdate.file.open(filename, playdate.file.kFileRead)

    if not file then
        print("Failed to open file: " .. err)
        return
    end

    local data, bytesRead = file:read(24)
    local sizeX, sizeY, tileSizeX, tileSizeY, offsetX, offsetY = string.unpack("I4I4I4I4I4I4", data)

    data = file:read(sizeX * sizeY)

    file:close()

    self.sizeX = sizeX
    self.sizeY = sizeY
    self.tileSizeX = tileSizeX
    self.tileSizeY = tileSizeY
    self.offsetX = -offsetX + 400 / 2
    self.offsetY = -offsetY + 240 / 2

    self.map = gfx.tilemap.new()
    self.map:setImageTable(self.tilesheet)
    self.map:setSize(sizeX, sizeY)

    local tileIndices = {}
    for i = 1, sizeX * sizeY do
        local byte = data:byte(i)
        table.insert(tileIndices, byte)
    end

    self.map:setTiles(tileIndices, sizeX)
end

function Level:read_paths(filename)

    local file, err = playdate.file.open(filename, playdate.file.kFileRead)

    if not file then
        print("Failed to open file: " .. err)
        return
    end

    self.paths = {}

    local data, bytesRead = file:read(4)
    local count = string.unpack("I4", data)
    for i=1,count do
        local path = Path(file)
        self.paths[path.name] = path
    end
end

function Level:read_level_data(filename)
    local file, err = playdate.file.open(filename, playdate.file.kFileRead)

    if not file then
        print("Failed to open file: " .. err)
        return
    end

    self.enemies = {}
    self.doors = {}
    self.shadows = {}

    -- Load enemies
    local data, bytesRead = file:read(4)
    local count = string.unpack("I4", data)
    for i=1,count do
        data = file:read(4)
        local len = string.unpack("I4", data)
        local enemyName = file:read(len)

        data = file:read(4)
        local len = string.unpack("I4", data)
        local pathName = file:read(len)

        data = file:read(4)
        local moveSpeed = string.unpack("f", data)
        data = file:read(4)
        local difficulty = string.unpack("f", data)

        data = file:read(4)
        local keyId = string.unpack("I4", data)

        local enemy = Enemy(enemyName, self.paths[pathName], moveSpeed, difficulty, self)
        enemy:setKey(keyId)
        self:addObject(enemy)

        table.insert(self.enemies, enemy)
    end

    -- Load turrets
    local data, bytesRead = file:read(4)
    local count = string.unpack("I4", data)
    for i=1,count do
        data = file:read(4)
        local len = string.unpack("I4", data)
        local turretName = file:read(len)

        data = file:read(4)
        local x = string.unpack("f", data)
        data = file:read(4)
        local y = -string.unpack("f", data)
        data = file:read(4)
        local rotation = -90 - string.unpack("f", data)
        data = file:read(4)
        local scanDuration = string.unpack("f", data)
        data = file:read(4)
        local scanPause = string.unpack("f", data)
        data = file:read(4)
        local scanAngularRange = string.unpack("f", data)
        data = file:read(4)
        local difficulty = string.unpack("f", data)

        local turret = Turret(turretName, x, y, rotation, scanDuration, scanPause, scanAngularRange, difficulty, self)
        self:addObject(turret)

        table.insert(self.enemies, turret)
    end

    -- Load doors
    data, bytesRead = file:read(4)
    count = string.unpack("I4", data)
    for i=1,count do
        data = file:read(4)
        local x = string.unpack("f", data)

        data = file:read(4)
        local y = -string.unpack("f", data)

        data = file:read(4)
        local radius = string.unpack("f", data)

        data = file:read(4)
        local isFinalExit = string.unpack("I4", data) == 1
        
        data = file:read(4)
        local len = string.unpack("I4", data)
        local nextLevel = file:read(len)

        data = file:read(4)
        local requiredKey = string.unpack("I4", data)

        local door = Door(x, y, radius, isFinalExit, nextLevel, requiredKey)
        self:addObject(door)

        table.insert(self.doors, door)
    end

    -- Load shadows
    data, bytesRead = file:read(4)
    count = string.unpack("I4", data)
    for i=1,count do
        local path = Path(file)

        local shadow = Shadow(path)
        self:addObject(shadow)

        table.insert(self.shadows, shadow)
    end
end

function Level:debugCamera()
    -- Adjust the camera based on D-pad input
    local moveSpeed = 5  -- Adjust this value to control the camera speed

    if playdate.buttonIsPressed(playdate.kButtonUp) then
        self.camera_center.y = self.camera_center.y - moveSpeed
    end
    if playdate.buttonIsPressed(playdate.kButtonDown) then
        self.camera_center.y = self.camera_center.y + moveSpeed
    end
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        self.camera_center.x = self.camera_center.x - moveSpeed
    end
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        self.camera_center.x = self.camera_center.x + moveSpeed
    end
end

local allSprites

function Level:update()
    Level.super.update(self)

    --self:debugCamera()
    self.camera_center = self.player.pos:copy()

    -- Check if the camera is outside of the visible area (extents of the tilemap)
    local minX = self.offsetX
    local maxX = self.offsetX + self.sizeX * self.tileSizeX - 400
    local minY = self.offsetY
    local maxY = self.offsetY + self.sizeY * self.tileSizeY - 240

    if (self.camera_center.x < minX) then
        self.camera_center.x = minX
    elseif (self.camera_center.x > maxX) then
        self.camera_center.x = maxX
    end
     if (self.camera_center.y < minY) then
        self.camera_center.y = minY
    elseif (self.camera_center.y > maxY) then
        self.camera_center.y = maxY
    end

    local camera_stutter = 1
    if camera_stutter > 5 then
        self.camera_center.x = math.floor(self.camera_center.x / camera_stutter) * camera_stutter
        self.camera_center.y = math.floor(self.camera_center.y / camera_stutter) * camera_stutter
    end

    if self.state == Level.STATE_FIGHT then
        if self.subState == Level.SUBSTATE_BLOCK or
           self.subState == Level.SUBSTATE_ATTACK then
            if self.startTime > 0 then
                self.startTime -= self.deltaTime
            else
                self.attackTime += self.deltaTime
                if self.attackTime >= self.attackTotalTime then
                    self:failFight(true)
                end
            end
            
            _, pressed, _ = pd.getButtonState()
            if pressed ~= 0 then
                if pd.buttonJustPressed(self.key.keyCode) then
                    self:successFight()
                else
                    -- Fail defense or attack
                    self:failFight(false)
                end
            end
        elseif self.subState == Level.SUBSTATE_NYXHIT or
               self.subState == Level.SUBSTATE_NYXMISS or
               self.subState == Level.SUBSTATE_NYXFAIL or
               self.subState == Level.SUBSTATE_NYXBLOCK or
               self.subState == Level.SUBSTATE_GUARDHIT then
            self.attackTime += self.deltaTime
            if self.attackTime > 1 then
                if (playerData.stamina <= 0) then
                    self:switchToGameOver()
                elseif self.subState == Level.SUBSTATE_NYXBLOCK then
                    self.subState = Level.SUBSTATE_ATTACK
                elseif self.subState == Level.SUBSTATE_GUARDHIT then
                    self.subState = Level.SUBSTATE_ATTACK
                    if self.activeEnemy.health <= 0 then
                        self:killActiveEnemy()
                    end
                else
                    self.subState = Level.SUBSTATE_BLOCK
                end
                self:setupSequence()
            end
        end
    end

    if self.state == Level.STATE_STRANGLE then
        if self.startTime > 0 then
            self.startTime -= self.deltaTime
        else
            self.strangleTime += self.deltaTime
            
            if self.strangleTime >= self.strangleTotalTime then
                self:switchToFightMode(self.activeEnemy)
                self.activeEnemy.health = self.activeEnemy:getMaxHealth()
            else
                local change, acceleratedChange = pd.getCrankChange()

                self.activeEnemy.health -= math.abs(change) * self.deltaTime / self.activeEnemy.difficulty

                if self.activeEnemy.health <= 0 then
                    self:killActiveEnemy()
                    self.player:holdUntilCrankStop()
                end
            end
        end
    end
end

function Level:killActiveEnemy()
    self.state = Level.STATE_NORMAL
    self.activeEnemy:kill()
    if self.activeEnemy.keyId ~= 0 then
        self.player:addKey(self.activeEnemy.keyId)
        self.activeEnemy.keyId = 0
    end
end

function Level:successFight()
    -- Every attack consume some stamina, if stamina is above 20
    if playerData.stamina > 20 then
        playerData.stamina -= 5
    end

    if self.subState == Level.SUBSTATE_ATTACK then
        self.activeEnemy.health -= 5
        self.subState = Level.SUBSTATE_GUARDHIT
        self.nyxImage = self:getRandomImage(playerData.nyxStrikeImages)
        self.guardImage = self:getRandomImage(playerData.guardHitImages)
    else
        self.subState = Level.SUBSTATE_NYXBLOCK
        self.nyxImage = self:getRandomImage(playerData.nyxBlockImages)
        self.guardImage = self:getRandomImage(playerData.guardStrikeImages)
    end
    self.attackTime = 0
end

function Level:failFight(timeUp)
    if self.subState == Level.SUBSTATE_ATTACK then
        -- Was attacking, lose stamina if the stamina is above 10
        if playerData.stamina > 10 then
            playerData.stamina -= 10
        end
        if timeUp then
            self.subState = Level.SUBSTATE_NYXMISS
        else
            self.subState = Level.SUBSTATE_NYXFAIL
        end
        self.attackTime = 0
    else
        playerData.stamina -= 25
        self.nyxImage = self:getRandomImage(playerData.nyxHitImages)
        self.guardImage = self:getRandomImage(playerData.guardStrikeImages)
        self.subState = Level.SUBSTATE_NYXHIT
        self.attackTime = 0
    end
end

function Level:render()

    self.map:draw(self.offsetX - 400 / 2, self.offsetY - 240 / 2)

    gfx.setLineWidth(5)
    gfx.setDitherPattern(0.9, gfx.image.kDitherTypeBayer8x8)
    for path_name, path in pairs(self.paths) do
        path:render()
    end
    gfx.setLineWidth(1)
    gfx.setColor(gfx.kColorBlack)
end

function Level:afterRender()
    Level.super.afterRender(self)

    if self.state == Level.STATE_FIGHT then
        gfx.pushContext()
            gfx.setDrawOffset(0, 0)
            self:drawWithBorder(60, 40, 280, 160)
            
            local majorDisplace = 50
            local hitDisplace = 30
            if self.subState == Level.SUBSTATE_BLOCK or
               self.subState == Level.SUBSTATE_ATTACK then
                local t = self.attackTime / self.attackTotalTime
                self.guardImage:drawAnchored(280 - majorDisplace * t, 190, 0.5, 1.0)
                self.nyxImage:drawAnchored(120 + majorDisplace * t, 190, 0.5, 1.0)
                self.key.image:drawAnchored(200, 60, 0.5, 0.5)
                self.guardLastPos = 280 - majorDisplace * t

                self:drawWithBorder(60, 20, 280, 20)
                gfx.fillRect(64 + t * 272 * 0.5, 24, (1 - t) * 272, 12)
            elseif self.subState == Level.SUBSTATE_NYXHIT then
                local t = self.attackTime / 1
                self.guardImage:drawAnchored(230, 190, 0.5, 1.0)
                self.nyxImage:drawAnchored(170 - hitDisplace * t, 190, 0.5, 1.0)

                playerData.hitImage:drawAnchored(200, 120, 0.5, 0.5)
            elseif self.subState == Level.SUBSTATE_NYXFAIL then
                self.guardImage:drawAnchored(230, 190, 0.5, 1.0)
                self.nyxImage:drawAnchored(170, 190, 0.5, 1.0)

                playerData.failImage:drawAnchored(200, 120, 0.5, 0.5)
            elseif self.subState == Level.SUBSTATE_NYXMISS then
                self.guardImage:drawAnchored(230, 190, 0.5, 1.0)
                self.nyxImage:drawAnchored(170, 190, 0.5, 1.0)

                playerData.missImage:drawAnchored(200, 120, 0.5, 0.5)
            elseif self.subState == Level.SUBSTATE_NYXBLOCK then
                local t = self.attackTime / 1
                self.guardImage:drawAnchored(self.guardLastPos, 190, 0.5, 1.0)
                self.nyxImage:drawAnchored(self.guardLastPos - 30, 190, 0.5, 1.0)

                playerData.blockImage:drawAnchored(200, 120, 0.5, 0.5)
            elseif self.subState == Level.SUBSTATE_GUARDHIT then
                local t = self.attackTime / 1
                self.guardImage:drawAnchored(self.guardLastPos + hitDisplace * t, 190, 0.5, 1.0)
                self.nyxImage:drawAnchored(self.guardLastPos - 30, 190, 0.5, 1.0)

                playerData.hitImage:drawAnchored(200, 120, 0.5, 0.5)
            end

            self:drawHealth(40, 40, 20, 160, playerData.stamina, 100)
            self:drawHealth(340, 40, 20, 160, self.activeEnemy.health, self.activeEnemy:getMaxHealth())
            
        gfx.popContext()
    end

    if self.state == Level.STATE_STRANGLE then
        gfx.pushContext()
            gfx.setDrawOffset(0, 0)
            self:drawWithBorder(60, 40, 280, 160)
            
            local t = self.strangleTime / self.strangleTotalTime

            self:drawWithBorder(60, 20, 280, 20)
            gfx.fillRect(64 + t * 272 * 0.5, 24, (1 - t) * 272, 12)

            self:drawHealth(40, 40, 20, 160, playerData.stamina, 100)
            self:drawHealth(340, 40, 20, 160, self.activeEnemy.health, self.activeEnemy:getMaxHealth())

            local lim = 5.0 * t
            local dx = lim * (math.random() * 2 - 1)
            local dy = lim * (math.random() * 2 - 1)
            playerData.strangleImage:drawAnchored(200 + dx, 120 + dy, 0.5, 0.5)

        gfx.popContext()
    end
end

function Level:drawHealth(x, y, width, height, current, max)
    local t = current / max
    if t < 0 then
        t = 0
    end
    local barHeight = (height - 8) * t
    
    self:drawWithBorder(x, y, width, height)
    gfx.fillRect(x + 4, y + height - 4 - barHeight, width - 8, barHeight)
end

function Level:drawWithBorder(x, y, width, height)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(x, y , width, height)
    gfx.setColor(gfx.kColorWhite)
    gfx.drawRect(x, y , width, height)
    gfx.drawRect(x + 2, y + 2, width - 4, height - 4)
end

function Level:switchToFightMode(enemy)
    self.state = Level.STATE_FIGHT
    self.subState = Level.SUBSTATE_BLOCK
    self.activeEnemy = enemy
    self.startTime = 1

    self:setupSequence()
end

function Level:getRandomImage(array)
    local index = math.random(1, #array)
    return array[index]
end

function Level:setupSequence()
    if self.subState == Level.SUBSTATE_BLOCK then
        self.nyxImage = self:getRandomImage(playerData.nyxBlockImages)
        self.guardImage = self:getRandomImage(playerData.guardAttackImages)
        self.key = math.random(1, #playerData.defenseKeys)
        self.key = playerData.defenseKeys[self.key]
    else
        self.nyxImage = self:getRandomImage(playerData.nyxAttackImages)
        self.guardImage = self:getRandomImage(playerData.guardBlockImages)
        self.key = math.random(1, #playerData.attackKeys)
        self.key = playerData.attackKeys[self.key]
    end

    self.attackTime = 0
    self.attackTotalTime = 1 / self.activeEnemy.difficulty
end

function Level:getClosestDoor(pos)
    local retDoor = nil
    local retDist = 10000000

    for i, door in ipairs(self.doors) do
        local dist = door.pos:distanceToPoint(pos)
        if dist < retDist then
            retDoor = door
            retDist = dist
        end
    end

    return retDoor, retDist
end

function Level:isPlayerInShadow()
    for i, shadow in ipairs(self.shadows) do
        if shadow:inShadow(self.player.pos) then
            return true
        end
    end

    return false
end

function Level:isPlayerBehindEnemy()
    if self.player == nil then
        return nil
    end

    local playerPos = self.player.pos    
    for i, enemy in ipairs(self.enemies) do
        if not enemy:isDead() and enemy:isBehind(playerPos) then
            return enemy
        end
    end

    return nil
end

function Level:switchToStrangleMode(enemy)
    self.state = Level.STATE_STRANGLE
    self.startTime = 1
    self.activeEnemy = enemy
    self.strangleTime = 0
    self.strangleTotalTime = 2
end

function Level:switchToGameOver()
    self.player:kill()
    
    Screen.gotoScreen("GameOver", self.baseName, 1)

    Screen.screens["GameOver"].callback = function(nextScreen)
        if nextScreen == "{param}" then
            playerData.stamina = self.startStamina
        else
            playerData.stamina = playerData.maxStamina
        end
        Screen.screens["GameOver"].callback = nil
    end

    self.subState = Level.SUBSTATE_GAMEOVER
end

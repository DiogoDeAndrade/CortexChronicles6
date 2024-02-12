import "CoreLibs/graphics"
import "screen"
import "path"
import "character"
import "player"
import "enemy"
import "playerdata"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Level').extends(Screen)

Level.STATE_NORMAL = 0
Level.STATE_FIGHT = 1
Level.SUBSTATE_BLOCK = 0
Level.SUBSTATE_STRIKE = 1
Level.SUBSTATE_NYXHIT = 2
Level.SUBSTATE_NYXMISS = 3
Level.SUBSTATE_NYXFAIL = 4
Level.SUBSTATE_NYXBLOCK = 5
Level.SUBSTATE_GUARDHIT = 6

function Level:init(baseName)
    Level.super.init(self)

    self.baseName = baseName
    self.state = Level.STATE_NORMAL
end

function Level:start()
    self.tilesheet = gfx.imagetable.new("tilemaps/" .. self.baseName)

    self:read_tilemap("tilemaps/" .. self.baseName .. "_tilemap.bin")

    self:read_paths("paths/" .. self.baseName .. "_paths.bin")

    self:read_enemies("levels/" .. self.baseName .. ".bin")

    self.player = Player(self.paths["Master"], self)
    self:addObject(self.player)

    Level.super.start(self)
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

function Level:read_enemies(filename)
    local file, err = playdate.file.open(filename, playdate.file.kFileRead)

    if not file then
        print("Failed to open file: " .. err)
        return
    end

    self.enemies = {}

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

        local difficulty = 1.0

        local enemy = Enemy(enemyName, self.paths[pathName], moveSpeed, difficulty, self)
        self:addObject(enemy)

        table.insert(self.enemies, enemy)
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
                    Screen.gotoScreen("GameOver", nil)
                elseif self.subState == Level.SUBSTATE_NYXBLOCK then
                    self.subState = Level.SUBSTATE_ATTACK
                elseif self.subState == Level.SUBSTATE_GUARDHIT then
                    self.subState = Level.SUBSTATE_ATTACK
                    if self.activeEnemy.health <= 0 then
                        self.state = Level.STATE_NORMAL
                        self.activeEnemy:kill()
                    end
                else
                    self.subState = Level.SUBSTATE_BLOCK
                end
                self:setupSequence()
            end
        end
    end
end

function Level:successFight()
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
        -- Was attacking, don't lose stamina, but cede the attack
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

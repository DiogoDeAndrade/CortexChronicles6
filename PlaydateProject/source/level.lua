import "CoreLibs/graphics"
import "screen"
import "path"
import "character"
import "player"
import "enemy"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Level').extends(Screen)

function Level:init(baseName)
    Level.super.init(self)

    self.tilesheet = gfx.imagetable.new("tilemaps/" .. baseName)

    self:read_tilemap("tilemaps/" .. baseName .. "_tilemap.bin")

    self:read_paths("paths/" .. baseName .. "_paths.bin")

    self:read_enemies("levels/" .. baseName .. ".bin")

    self.player = Player(self.paths["Master"])
    self.player:add()
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

        local enemy = Enemy(enemyName, self.paths[pathName], moveSpeed)
        enemy:add()

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

function Level:update()
    Level.super.update(self)

    --self:debugCamera()
    self.camera_center = self.player.pos

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
end

function Level:render()

    self.map:draw(self.offsetX - 400 / 2, self.offsetY - 240 / 2)

    for path_name, path in pairs(self.paths) do
        path:render()
    end
end

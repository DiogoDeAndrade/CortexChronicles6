import "CoreLibs/graphics"
import "screen"

local pd <const> = playdate
local gfx <const> = pd.graphics
local pt2 <const> = playdate.geometry.point
local vec2 <const> = playdate.geometry.vector

class('Path').extends()

function Path:init(file)
    self.name = ""
    self.points = {}
    self.isLoop = false
    if file ~= nil then
        self:loadFromFile(file)

        self.totalLength = self:computeLength()
    end
end

function Path:loadFromFile(file)
    data = file:read(4)
    local len = string.unpack("I4", data)
    self.name = file:read(len)
    data = file:read(4)
    self.isLoop = string.unpack("I4", data)
    if self.isLoop ~= 0 then
        self.isLoop = true
    else
        self.isLoop = false
    end

    data = file:read(4)
    len = string.unpack("I4", data)
    self.points = {}
    for i = 1,len do
        data = file:read(8)
        x, y = string.unpack("ff", data)
        table.insert(self.points, pt2.new(x, -y))
    end
end

function Path:render()
    local len = #self.points
    for i=1, len - 1 do
        local p1 = self.points[i]
        local p2 = self.points[i + 1]
        gfx.drawLine(p1 .. p2)
    end
end

function Path:getPoint(index)
    return self.points[index]
end

function Path:computeLength()
    local len = #self.points
    local length = 0

    for i = 2, len do
        length += self.points[i - 1]:distanceToPoint(self.points[i])
    end

    return length
end

function Path:computePositionAlongPath(distance)
    local current = 2
    local len = #self.points

    while (current <= len) do
        local distToNext = self.points[current - 1]:distanceToPoint(self.points[current])
        if (distToNext < distance) then
            current += 1
            distance -= distToNext
        else
            local delta = (self.points[current] - self.points[current - 1]):normalized()
            
            return self.points[current - 1] + delta * distance
        end
    end

    return self.points[len]:copy()
end

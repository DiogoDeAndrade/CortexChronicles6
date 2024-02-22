import "CoreLibs/sprites"
import "playerdata"

local pd <const> = playdate
local gfx <const> = pd.graphics
local pt2 <const> = playdate.geometry.point
local vec2 <const> = playdate.geometry.vector2D

class('Shadow').extends(gfx.sprite)

function Shadow:init(path)

    Shadow.super.init(self)

    self.path = path

    -- Create polygon
    self.shadowPolygon = pd.geometry.polygon.new(#self.path.points)
    for i, pt in ipairs(self.path.points) do
        self.shadowPolygon:setPointAt(i, pt)
    end
    self.shadowPolygon:close()

    local x,y, width, height = self.shadowPolygon:getBounds()
    
    self.polyImage = gfx.image.new(width, height)
    

    gfx.pushContext(self.polyImage)
    gfx.setDrawOffset(-x, -y)
    gfx.setDitherPattern(0.9, gfx.image.kDitherTypeBayer8x8)
    gfx.fillPolygon(self.shadowPolygon)
    gfx.popContext()

    self:setZIndex(1000)
    self:moveTo(x, y)
    self:setCenter(0.0, 0.0)
    self:setImage(self.polyImage)

    self.pos = pt2.new(x,y)
end

function Shadow:update()
    Shadow.super.update(self)
end

function Shadow:afterRender()
end

function Shadow:inShadow(pos)
    return self.shadowPolygon:containsPoint(pos)
end

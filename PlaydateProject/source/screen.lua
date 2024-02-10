import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics
local pt2 <const> = playdate.geometry.point

class('Screen').extends()

function Screen:init()
    self.backColor = gfx.kColorWhite
    self.camera_center = pt2.new(0,0)

    self.backgroundImage = gfx.image.new(400, 240)

    self.backgroundSprite = gfx.sprite.new(self.backgroundImage)
	self.backgroundSprite:setZIndex(-32768)
	self.backgroundSprite:setCenter(0, 0)
    self.backgroundSprite:setIgnoresDrawOffset(true)
	self.backgroundSprite:add()
end

function Screen:update()
end

function Screen:render()
end

function Screen:run()
    self:update()

    -- Update background
    gfx.pushContext(self.backgroundImage)
	gfx.clear(self.backColor)

    -- Apply the camera offset for background
    gfx.setDrawOffset(-self.camera_center.x + 400 / 2, -self.camera_center.y + 240 / 2)

    -- Draw background with Screen:render
    self:render()

    gfx.popContext()

    -- Apply the camera offset
    gfx.setDrawOffset(-self.camera_center.x + 400 / 2, -self.camera_center.y + 240 / 2)

    gfx.sprite.update()

    gfx.setDrawOffset(0, 0)
end

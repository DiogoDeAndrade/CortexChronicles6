import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = playdate.graphics
local pt2 <const> = playdate.geometry.point

class('Screen').extends()

function Screen:init()
    self.backColor = gfx.kColorWhite

    self.backgroundImage = gfx.image.new(400, 240)

    self.backgroundSprite = gfx.sprite.new(self.backgroundImage)
	self.backgroundSprite:setZIndex(-32768)
	self.backgroundSprite:setCenter(0, 0)
    self.backgroundSprite:setIgnoresDrawOffset(true)

    self.visible = false

    self.sprites = {}
end

function Screen:addObject(sprite)
    table.insert(self.sprites, sprite)
end

function Screen:removeAllObjects()
    for _, spr in ipairs(self.sprites) do
        spr:remove()
    end

    self.sprites = {}
end

function Screen:start(param)
    self.camera_center = pt2.new(0,0)
    self.startTime = pd.getCurrentTimeMilliseconds()
    self.lastFrameTime = self.startTime
    self.currentTime = 0
end

function Screen:close()
end

function Screen:setVisible(visible)
    if self.visible == visible then
        return
    end
    if visible then
        self.backgroundSprite:add()
        for _, spr in ipairs(self.sprites) do
            spr:add()
        end
    else
        self.backgroundSprite:remove()
        for _, spr in ipairs(self.sprites) do
            spr:remove()
        end
    end
    self.visible = visible
end

function Screen:update()
end

function Screen:render()
end

function Screen:afterRender()
    gfx.sprite.performOnAllSprites(function(sprite)
        if sprite:isa(Character) then
            sprite:afterRender()
        end
    end)
end

-----------------------------------------------------------
-- SINGLETON STUFF
Screen.stack = { }
Screen.isTransitioning = false

function Screen.run()
    Screen.isTransitioning = false

    local t = pd.getCurrentTimeMilliseconds()
    Screen.currentScreen.deltaTime = (t - Screen.currentScreen.lastFrameTime) * 0.001
    Screen.currentScreen.currentTime += Screen.currentScreen.deltaTime
    Screen.currentScreen.lastFrameTime = t

    Screen.currentScreen:update()

    -- Update background
    gfx.pushContext(Screen.currentScreen.backgroundImage)
	gfx.clear(Screen.currentScreen.backColor)

    -- Apply the camera offset for background
    gfx.setDrawOffset(-Screen.currentScreen.camera_center.x + 400 / 2, -Screen.currentScreen.camera_center.y + 240 / 2)

    -- Draw background with Screen:render
    Screen.currentScreen:render()

    gfx.popContext()

    -- Apply the camera offset again (pop context removes this)
    gfx.setDrawOffset(-Screen.currentScreen.camera_center.x + 400 / 2, -Screen.currentScreen.camera_center.y + 240 / 2)

    gfx.sprite.update()

    Screen.currentScreen:afterRender()

    gfx.setDrawOffset(0, 0)
end

function Screen.addScreen(name, screen)
    if Screen.screens == nil then
        Screen.screens = {}
    end
    Screen.screens[name] = screen
end

function Screen.gotoScreen(name, param)
    if Screen.currentScreen ~= nil then
        Screen.currentScreen:setVisible(false)
        Screen.currentScreen:close()
    end

    Screen.stack = {}

    Screen.currentScreen = Screen.screens[name]

    Screen.currentScreen:start(param)
    Screen.currentScreen:setVisible(true)
end

function Screen.pushScreen(name, param)
    if not Screen.isTransitioning then
        Screen.isTransitioning = true

        if Screen.currentScreen ~= nil then
            Screen.currentScreen:setVisible(false)
        end

        table.insert(Screen.stack, Screen.currentScreen)

        Screen.currentScreen = Screen.screens[name]

        Screen.currentScreen:start(param)
        Screen.currentScreen:setVisible(true)
    end
end

function Screen.popScreen()
    if not Screen.isTransitioning then
        Screen.isTransitioning = true

        if Screen.currentScreen ~= nil then

            Screen.currentScreen:setVisible(false)
            Screen.currentScreen:close()
        end

        ss = Screen.stack[#Screen.stack]
        table.remove(Screen.stack)

        Screen.currentScreen = ss
        Screen.currentScreen:setVisible(true)
    end 
end

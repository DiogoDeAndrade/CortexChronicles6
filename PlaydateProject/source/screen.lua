import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

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
	self.backgroundSprite:add()
end

function Screen:start(param)
    self.camera_center = pt2.new(0,0)
end

function Screen:close()
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

class('ScreenState').extends()

function ScreenState:init(screen)
    self.sprites = gfx.sprite.getAllSprites()
    
    gfx.sprite.removeAll()

    self.prevScreen = screen
end

ScreenState.stack = { }
Screen.isTrasitioning = false

function Screen.run()
    Screen.isTrasitioning = false

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
        Screen.currentScreen:close()
        gfx.sprite.removeAll()
    end

    Screen.stack = {}

    Screen.currentScreen = Screen.screens[name]

    Screen.currentScreen:start(param)
end

function Screen.pushScreen(name, param)
    if not Screen.isTrasitioning then
        Screen.isTrasitioning = true

        ss = ScreenState(Screen.currentScreen)

        table.insert(ScreenState.stack, ss)

        Screen.currentScreen = Screen.screens[name]

        Screen.currentScreen:start(param)
    end
end

function Screen.popScreen()
    if not Screen.isTrasitioning then
        Screen.isTrasitioning = true

        if Screen.currentScreen ~= nil then
            Screen.currentScreen:close()
        end

        ss = ScreenState.stack[#ScreenState.stack]
        table.remove(ScreenState.stack)

        Screen.currentScreen = ss.prevScreen
        for i=1,#ss.sprites do
            ss.sprites[i]:add()
        end
    end 
end

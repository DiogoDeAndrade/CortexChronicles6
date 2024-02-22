import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('PlayerData').extends()

if playerData == nil then
    playerData = PlayerData()
end

function PlayerData:init()
    self.nyx_sprites = gfx.imagetable.new("sprites/nyx")
    self.guard_sprites = gfx.imagetable.new("sprites/guard")

    self.nyxAttackImages = {
        gfx.image.new("sprites/nyx_attack01.png"),
    }
    self.nyxHitImages = {
        gfx.image.new("sprites/nyx_hit01.png"),
    }
    self.nyxStrikeImages = {
        gfx.image.new("sprites/nyx_strike01.png"),
    }
    self.nyxBlockImages = {
        gfx.image.new("sprites/nyx_block01.png"),
        gfx.image.new("sprites/nyx_block02.png"),
    }
    self.guardAttackImages = {
        gfx.image.new("sprites/guard_attack01.png"),
        gfx.image.new("sprites/guard_attack02.png"),
    }
    self.guardStrikeImages = {
        gfx.image.new("sprites/guard_strike01.png"),
    }
    self.guardHitImages = {
        gfx.image.new("sprites/guard_hit01.png"),
    }
    self.guardBlockImages = {
        gfx.image.new("sprites/guard_block01.png"),
    }
    self.hitImage = gfx.image.new("sprites/hit.png")
    self.missImage = gfx.image.new("sprites/miss.png")
    self.failImage = gfx.image.new("sprites/fail.png")
    self.blockImage = gfx.image.new("sprites/block.png")

    self.attackKeys = {
        { keyCode = playdate.kButtonA, image = gfx.image.new("sprites/button_a.png") },
        { keyCode = playdate.kButtonUp, image = gfx.image.new("sprites/button_up.png") },
        { keyCode = playdate.kButtonRight, image = gfx.image.new("sprites/button_right.png") },
    }
    self.defenseKeys = {
        { keyCode = playdate.kButtonB, image = gfx.image.new("sprites/button_b.png") },
        { keyCode = playdate.kButtonDown, image = gfx.image.new("sprites/button_down.png") },
        { keyCode = playdate.kButtonLeft, image = gfx.image.new("sprites/button_left.png") },
    }

    self.keycard = gfx.image.new("sprites/keycard.png")
    self.closedDoor = gfx.image.new("sprites/door.png")
    self.openDoor = gfx.image.new("sprites/door_open.png")
    self.turret = gfx.image.new("sprites/turret.png")

    self.button_retry = gfx.image.new("sprites/retry.png")
    self.button_quit = gfx.image.new("sprites/quit.png")

    self.stamina = 100
end

import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics
local snd <const> = pd.sound

class('PlayerData').extends()

if playerData == nil then
    playerData = PlayerData()
end

function PlayerData:init()
    print("Initializing player data...")

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

    self.bButtonPrompt = gfx.image.new("sprites/prompt_b.png")

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
    self.button_start = gfx.image.new("sprites/start.png")
    self.button_credits = gfx.image.new("sprites/credits.png")

    self.strangleImage = gfx.image.new("sprites/strangle.png")

    self.maxStamina = 100
    self.stamina = self.maxStamina

    self.font, error = gfx.font.new('fonts/blocky')
    gfx.setFont(self.font)
    if error ~= nil then
        print(error)
    end

    self.volume = 0.5

    self.sounds = {}
    self.sounds["select"] = snd.sampleplayer.new('audio/select.wav')
    self.sounds["option"] = snd.sampleplayer.new('audio/option.wav')
    self.sounds["skip"] = snd.sampleplayer.new('audio/skip.wav')
    self.sounds["step_player"] = snd.sampleplayer.new('audio/step.wav')
    self.sounds["step_enemy"] = snd.sampleplayer.new('audio/step.wav')
    self.sounds["block"] = snd.sampleplayer.new('audio/block.wav')
    self.sounds["death"] = snd.sampleplayer.new('audio/death.wav')
    self.sounds["hit"] = snd.sampleplayer.new('audio/hit.wav')
    self.sounds["kill"] = snd.sampleplayer.new('audio/kill.wav')
    self.sounds["miss"] = snd.sampleplayer.new('audio/miss.wav')
    self.sounds["door"] = snd.sampleplayer.new('audio/door.wav')
    self.sounds["gun"] = snd.sampleplayer.new('audio/gun.wav')
    self.sounds["strangle"] = snd.sampleplayer.new('audio/strangle.wav')
    
    self.music = snd.fileplayer.new()
    
    local success, errorString = self.music:load("audio/futuristic_music")
    if not success then
        print("Failed to load music: ", success, errorString)
    end

    success, errorString = self.music:play(0);
    if not success then
        print(errorString)
    end

    self.music:setVolume(0.25)
end

function PlayerData:playSound(sndName, volume, pitch)
    local v, p
    if (volume ~= nil) then
        v = volume
    else
        v = 1.0
    end
    if (pitch ~= nil) then
        p = pitch
    else
        p = 1.0
    end

    v = v * self.volume

    local snd = self.sounds[sndName]
    snd:playAt(0, v, v, p)
end

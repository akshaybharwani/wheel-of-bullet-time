local pd <const> = playdate

class('SfxPlayer').extends()

local sfxPath <const> = "audio/sfx/"
local sampleplayer <const> = pd.sound.sampleplayer.new
local sp <const> = function(path)
    return sampleplayer(sfxPath..path)
end

SFX_FILES = {
    game_start = sp("game_start"),
    danger = sp("danger"),
    debris_collected = sp("debris_collected"),
    enemy_dead_type1 = sp("enemy_dead_type1"),
    enemy_dead_type3 = sp("enemy_dead_type3"),
    enemy_dead_type5 = sp("enemy_dead_type5"),
    enemy_hit = sp("enemy_hit"),
    enemy_selfdestruct = sp("enemy_selfdestruct"),
    game_over = sp("game_over"),
    gun_activated = sp("gun_activated"),
    gun_bullet = sp("gun_bullet"),
    gun_turning = sp("gun_turning"),
    gun_vacuum_debris = sp("gun_vacuum_debris"),
    gun_vacuum_empty = sp("gun_vacuum_empty"),
    recycler_lost = sp("recycler_lost"),
    recyclers_spawning = sp("recyclers_spawning"),
    recyclers_working = sp("recyclers_working"),
    warning_sirens = sp("warning_sirens")
}

function SfxPlayer:init(sfx)
    self.player = sfx
end

function SfxPlayer:play()
    self.player:play()
end

function SfxPlayer:playLooping()
    self.player:play(0)
end

function SfxPlayer:stop()
    self.player:stop()
end

function SfxPlayer:isPlaying()
    return self.player:isPlaying()
end
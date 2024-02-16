local pd <const> = playdate
local gfx <const> = pd.graphics

class('MusicPlayer').extends(gfx.sprite)

local musicPath <const> = "audio/music/"
local fileplayer <const> = pd.sound.fileplayer.new
local fp <const> = function(path)
    return fileplayer(musicPath..path)
end

MUSIC_FILES = {
    gameOver = fp("BGM_gameover_oneshot"),
    timeFlowing = fp("BGM_ingame_timeflowing_loop"),
    timeStopped = fp("BGM_ingame_timestopped_loop")
}

local audioConstants = AUDIO_CONSTANTS
local maxVolume = audioConstants.maxVolume
local fadeSeconds = audioConstants.fadeSeconds

function MusicPlayer:init()
    for _, track in pairs(MUSIC_FILES) do
        track:setStopOnUnderrun(false)
    end

    self.gunNeutralState = GUN_NEUTRAL_STATE

    NOTIFICATION_CENTER:subscribe(NOTIFY_GAME_OVER, self, function()
        self:playSong(MUSIC_FILES.gameOver, true, false)
    end)

    -- TODO: Improve this so that there is a central class handling time flowing, like for timeDisplay
    NOTIFICATION_CENTER:subscribe(NOTIFY_GAME_STARTED, self, function()
        if GUN_CURRENT_STATE == self.gunNeutralState then
            self:playSong(MUSIC_FILES.timeStopped, true, true)
        end
        --[[ else
            self:playSong(MUSIC_FILES.timeFlowing, true, true)
        end ]]
    end)

    NOTIFICATION_CENTER:subscribe(NOTIFY_GUN_STATE_CHANGED, self, function(currentState)
        if not IS_GAME_STARTED then
            return
        end

        if GUN_CURRENT_STATE == self.gunNeutralState then
            if not MUSIC_FILES.timeStopped:isPlaying() then
                self:playSong(MUSIC_FILES.timeStopped, false, true)
            end
        else
            if MUSIC_FILES.timeStopped:isPlaying() then
                self.currentSong:pause()
            end
            --[[ if not MUSIC_FILES.timeFlowing:isPlaying() then
                self:playSong(MUSIC_FILES.timeFlowing, true, true)
            end ]]
        end
    end)

    --[[ self.lowPassFilter = pd.sound.twopolefilter.new(pd.sound.kFilterLowPass)
    self.lowPassFilter:setResonance(0.65)
    self.lowPassFilter:setFrequency(500) ]]
end

function MusicPlayer:playSong(song, isFadeIn, isLooping)
    self.nextSong = song

    if isFadeIn then
        if self.currentSong then
            self.currentSong:setVolume(0, 0, fadeSeconds, function()
                self:playNextSong(isLooping)
            end, self)
            return
        end
    end

    self:playNextSong(isLooping)
end

function MusicPlayer:playNextSong(isLooping)
    if self.currentSong then
        self.currentSong:stop()
    end
    self.currentSong = self.nextSong
    self.currentSong:setVolume(maxVolume)
    if isLooping then
        self.currentSong:play(0)
    else
        self.currentSong:play()
    end
end

--[[ function MusicPlayer:addLowPass()
    -- pd.sound.addEffect(self.lowPassFilter)
end

function MusicPlayer:removeLowPass()
    -- pd.sound.removeEffect(self.lowPassFilter)
end ]]
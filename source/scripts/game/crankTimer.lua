import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('CrankTimer').extends(gfx.sprite)

function CrankTimer:init(duration, repeats, callback)
    self.timer = 0
    self.duration = duration
    self.callback = callback
    self.repeats = repeats
    self:add()
end

function CrankTimer:update()
    if not WAS_GAME_ACTIVE_LAST_CHECK then
        return
    end
    self.timer += DELTA_TIME
    if self.timer >= self.duration then
        self.callback()
        
        if self.repeats then
            self.timer = 0
        else
            -- TODO: this doesn't immediately remove the timer, check satellite.lua
            self:remove()
        end
    end
end

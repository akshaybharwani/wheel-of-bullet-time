local pd <const> = playdate
local gfx <const> = pd.graphics

class('Background').extends(gfx.sprite)

function Background:init(delay)
    Background.super.init(self)

    local backgroundTimer = pd.timer.new(delay)
    backgroundTimer.timerEndedCallback = function(timer)
        -- TODO: Need to enable input and everything else here
        self:showBackground()
    end

    self:add()
end

function Background:showBackground()
    local backgroundImage = gfx.image.new("images/background/background_01")
    if assert(backgroundImage) then
        gfx.sprite.setBackgroundDrawingCallback(
            function(x, y, width, height)
                backgroundImage:draw(0, 0)
            end
        )
    end
end

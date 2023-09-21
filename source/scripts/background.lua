import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Background').extends(gfx.sprite)

local titleTime = 5000

function Background:init()
    Background.super.init(self)

    local titleImage = gfx.image.new("images/Title")

    self.titleSprite = gfx.sprite.new(titleImage)
    self.titleSprite:moveTo(200, 120)
    self.titleSprite:setZIndex(1000)

    local backgroundTimer = pd.timer.new(titleTime)
    backgroundTimer.timerEndedCallback = function(timer)
        -- TODO: Need to enable input and everything else here
        self:showBackground()
        self.titleSprite:remove()
    end

    self:add()
    self.titleSprite:add()
end

function Background:showBackground()
    local backgroundImage = gfx.image.new("images/background_01")
    if assert(backgroundImage) then
        gfx.sprite.setBackgroundDrawingCallback(
            function(x, y, width, height)
                backgroundImage:draw(0, 0)
            end
        )
    end
end

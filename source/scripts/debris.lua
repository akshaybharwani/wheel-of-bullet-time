import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

local debrisActiveDuration = 1000

local rotationChance = 0.5

local debrisImagePath = "images/debris"

class("Debris").extends(gfx.sprite)

function Debris:init(x, y)
    Debris.super.init(self)

    self.type = "debris"

    self:setImage(gfx.image.new(debrisImagePath))
    local shouldRotate = math.random() < rotationChance

    if shouldRotate then
        self:setRotation(90)
    end
    self:moveTo(x, y)
    self:add()

    -- maybe this should be controlled by the manager? as this could result
    -- in countless timers
    self.activeAnimator = pd.timer.new(debrisActiveDuration)
    self.activeAnimator.timerEndedCallback = function(timer)
        self:remove()
    end
end

function Debris:collect()

end

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/recyclerConnector"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Recycler").extends(gfx.sprite)

local recyclerImagePath = "images/recycler"

local ammoGenerationTime = 500

function Recycler:init(x, y, connectorY)
    Recycler.super.init(self)
    self.type = "gun-element"
    self.debrisCount = 0

    self.connector = RecyclerConnector(x, y, connectorY)
    self:setImage(gfx.image.new(recyclerImagePath))
    self:setCollideRect(0, 0, self:getSize())

    self:moveTo(x, y)
    self:add()
end

function Recycler:getHit()
    -- show damaged states
    self.connector:remove()
    -- should remove itself from the active targets and active recyclers
    self:remove()
end

function Recycler:generateAmmo()
    self.debrisCount += 1
    local ammoTimer = pd.timer.new(ammoGenerationTime)
    ammoTimer.timerEndedCallback = function(timer)
        CURRENT_BULLET_COUNT += 1
        self.debrisCount -= 1
    end
end

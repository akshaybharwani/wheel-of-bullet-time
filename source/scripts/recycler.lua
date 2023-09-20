import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/recyclerConnector"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Recycler").extends(gfx.sprite)

local recyclerImagePath = "images/recycler/recycler"

local ammoGenerationTime = 500
local debrisTravelTime = 1000

function Recycler:init(x, y, connectorY)
    Recycler.super.init(self)
    self.type = "gun-element"
    self.available = true

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
    for i = 1, #ACTIVE_TARGETS do
        if ACTIVE_TARGETS[i] == self then
            table.remove(ACTIVE_TARGETS, i)
            break
        end
    end
    self:remove()
end

function Recycler:sendDebris()
    self.available = false

    local ammoTimer = pd.timer.new(ammoGenerationTime)
    ammoTimer.timerEndedCallback = function(timer)
        -- TODO: Animate this
        CURRENT_BULLET_COUNT += 1
        self.available = true
    end
end

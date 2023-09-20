import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/recyclerConnector"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local Animator = gfx.animator

class("Recycler").extends(gfx.sprite)

local recyclerImagePath = "images/recycler/recycler"
local collectedDebrisImagePath = "images/recycler/debris_mini"
local generatedAmmoImagePath = "images/recycler/bullet_mini"
local recyclingImagePath = "images/recycler/UI_recycling"

local ammoGenerationTime = 500
local debrisTravelTime = 1000

function Recycler:init(x, y, connectorY, isLeftToGun)
    Recycler.super.init(self)
    self.type = "gun-element"
    self.available = true
    self.isLeftToGun = isLeftToGun

    self.collectedDebrisSprite = gfx.sprite.new(gfx.image.new(collectedDebrisImagePath))
    self.generatedAmmoSprite = gfx.sprite.new(gfx.image.new(generatedAmmoImagePath))
    self.recyclingSprite = gfx.sprite.new(gfx.image.new(recyclingImagePath))
    self.recyclingSprite:moveTo(x, y)
    self.recyclingSprite:setZIndex(101)

    self:moveTo(x, y)
    self:setImage(gfx.image.new(recyclerImagePath))
    self:setCollideRect(0, 0, self:getSize())
    self.connector = RecyclerConnector(self, connectorY)

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

function Recycler:sendDebrisToRecycler()
    self.available = false
    self.recyclingSprite:add()
    local connector = self.connector
    local initialX, initialY = 0, 0

    if connector.verticalConnector ~= nil then
        local horizontalConnector = connector.horizontalConnector
        if self.isLeftToGun then
            local x1, y1, x2, y2 = connector.horizontalConnector:unpack()
            initialX, initialY = x2, y2
            horizontalConnector = geo.lineSegment.new(x2, y2, x1, y1)
        end
        local connectorParts = { horizontalConnector, connector.verticalConnector }
        self.connectorAnimation = Animator.new(debrisTravelTime, connectorParts, playdate.easingFunctions.linear)
    else
        local connectorLine = connector.horizontalConnector
        local x1, y1, x2, y2 = connector.horizontalConnector:unpack()
        if self.isLeftToGun then
            initialX, initialY = x2, y2
            connectorLine = geo.lineSegment.new(x2, y2, x1, y1)
        end

        self.connectorAnimation = Animator.new(debrisTravelTime, connectorLine,
            playdate.easingFunctions.linear)
    end
    self.collectedDebrisSprite:moveTo(initialX, initialY - self.collectedDebrisSprite:getSize())
    self.collectedDebrisSprite:add()
end

function Recycler:reverseLineSegment(ls)
    local x1, y1, x2, y2 = ls:unpack()
    return geo.lineSegment.new(x2, y2, x1, y1)
end

function Recycler:update()
    if self.connectorAnimation ~= nil then
        if self.connectorAnimation:ended() ~= true then
            local p = self.connectorAnimation:currentValue()
            local x1, y1 = p:unpack()
            self.collectedDebrisSprite:moveTo(x1, y1 - self.collectedDebrisSprite:getSize())
        else
            self.connectorAnimation = nil
            self.collectedDebrisSprite:remove()
            local ammoTimer = pd.timer.new(ammoGenerationTime)
            ammoTimer.timerEndedCallback = function(timer)
                -- TODO: Animate this
                CURRENT_BULLET_COUNT += 1
                self.available = true
                self.recyclingSprite:remove()
            end
        end
    end
end

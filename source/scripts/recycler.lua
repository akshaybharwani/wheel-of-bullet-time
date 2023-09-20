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

function Recycler:setupDebrisToRecyclerAnimation()
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
        self.debrisToRecyclerAnimator = Animator.new(debrisTravelTime, connectorParts, playdate.easingFunctions.linear)
    else
        local connectorLine = connector.horizontalConnector
        local x1, y1, x2, y2 = connector.horizontalConnector:unpack()
        if self.isLeftToGun then
            initialX, initialY = x2, y2
            connectorLine = geo.lineSegment.new(x2, y2, x1, y1)
        end

        self.debrisToRecyclerAnimator = Animator.new(debrisTravelTime, connectorLine,
            playdate.easingFunctions.linear)
    end
    self.collectedDebrisSprite:moveTo(initialX, initialY - self.collectedDebrisSprite:getSize())
end

function Recycler:setupAmmoToGunAnimation()
    local connector = self.connector
    local initialX, initialY = 0, 0

    if connector.verticalConnector ~= nil then
        local verticalConnector = connector.verticalConnector
        local x1, y1, x2, y2 = connector.verticalConnector:unpack()
        initialX, initialY = x2, y2
        verticalConnector = geo.lineSegment.new(x2, y2, x1, y1)
        local horizontalConnector = connector.horizontalConnector
        if not self.isLeftToGun then
            x1, y1, x2, y2 = connector.horizontalConnector:unpack()
            horizontalConnector = geo.lineSegment.new(x2, y2, x1, y1)
        end
        local connectorParts = { verticalConnector, horizontalConnector }
        self.ammoToGunAnimator = Animator.new(debrisTravelTime, connectorParts, playdate.easingFunctions.linear)
    else
        local connectorLine = connector.horizontalConnector
        local x1, y1, x2, y2 = connector.horizontalConnector:unpack()
        if not self.isLeftToGun then
            initialX, initialY = x2, y2
            connectorLine = geo.lineSegment.new(x2, y2, x1, y1)
        end

        self.ammoToGunAnimator = Animator.new(debrisTravelTime, connectorLine,
            playdate.easingFunctions.linear)
    end
    self.collectedDebrisSprite:moveTo(initialX, initialY - self.collectedDebrisSprite:getSize())
end

function Recycler:sendDebrisToRecycler()
    self.available = false
    self.recyclingSprite:add()
    if self.debrisToRecyclerAnimator == nil then
        self:setupDebrisToRecyclerAnimation()
    end
    self.collectedDebrisSprite:add()
end

function Recycler:sendAmmoToGun()
    if self.ammoToGunAnimator == nil then
        self:setupAmmoToGunAnimation()
    end
    self.generatedAmmoSprite:add()
end

function Recycler:update()
    if self.debrisToRecyclerAnimator ~= nil then
        if self.debrisToRecyclerAnimator:ended() ~= true then
            local p = self.debrisToRecyclerAnimator:currentValue()
            local x1, y1 = p:unpack()
            self.collectedDebrisSprite:moveTo(x1, y1 - self.collectedDebrisSprite:getSize())
        else
            self.debrisToRecyclerAnimator = nil
            self.collectedDebrisSprite:remove()
            local ammoTimer = pd.timer.new(ammoGenerationTime)
            ammoTimer.timerEndedCallback = function(timer)
                self:sendAmmoToGun()
            end
        end
    elseif self.ammoToGunAnimator ~= nil then
        if self.ammoToGunAnimator:ended() ~= true then
            local p = self.ammoToGunAnimator:currentValue()
            local x1, y1 = p:unpack()
            self.generatedAmmoSprite:moveTo(x1, y1 - self.generatedAmmoSprite:getSize())
        else
            self.ammoToGunAnimator = nil
            self.generatedAmmoSprite:remove()
            CURRENT_BULLET_COUNT += 1
            self.available = true
            self.recyclingSprite:remove()
        end
    end
end

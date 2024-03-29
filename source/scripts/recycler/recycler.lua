import "scripts/recycler/recyclerConnector"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local Animator = gfx.animator

class("Recycler").extends(gfx.sprite)

local recyclerImageTablePath = "images/recycler/recycler-table-32-32"
local collectedDebrisImagePath = "images/recycler/debris_mini"
local generatedAmmoImagePath = "images/recycler/bullet_mini"
local recyclingUIImagePath = "images/recycler/UI_recycling"

local recyclerConstants = RECYCLER_CONSTANTS

local maxHP = recyclerConstants.maxHP
local debrisTravelDuration = recyclerConstants.debrisTravelDuration
local ammoGenerationDuration = recyclerConstants.ammoGenerationDuration
local bulletCountToGenerate = recyclerConstants.bulletCountToGenerate

function Recycler:init(x, y, connectorY, isLeftToGun)
    Recycler.super.init(self)
    self.notifyBulletCountUpdated = NOTIFY_BULLET_COUNT_UPDATED

    self.deathSound = SfxPlayer(SFX_FILES.recycler_lost)
    self.workingSound = SfxPlayer(SFX_FILES.recyclers_working)

    self.type = GUN_TYPE_NAME
    self.available = true
    self.currentHP = maxHP

    self.isLeftToGun = isLeftToGun
    self.currentBulletCountToGenerate = 1

    self.recyclerImageTable = gfx.imagetable.new(recyclerImageTablePath)
    self.collectedDebrisSprite = gfx.sprite.new(gfx.image.new(collectedDebrisImagePath))
    self.collectedDebrisSpriteSize = self.collectedDebrisSprite:getSize()
    self.generatedAmmoSprite = gfx.sprite.new(gfx.image.new(generatedAmmoImagePath))
    self.generatedAmmoSpriteSize = self.generatedAmmoSprite:getSize()
    self.recyclingSprite = gfx.sprite.new(gfx.image.new(recyclingUIImagePath))

    self.recyclingSprite:moveTo(x, y)
    self.recyclingSprite:setZIndex(GUN_Z_INDEX)

    self:setImage(self.recyclerImageTable:getImage(1))
    self:setCollideRect(0, 0, self:getSize())
    self:setGroups(GUN_GROUP)
    self:setCollidesWithGroups({ ENEMY_GROUP })
    self:moveTo(x, y)
    self:setZIndex(GUN_Z_INDEX)

    self.connector = RecyclerConnector(self, connectorY)
end

function Recycler:update()
    if self.debrisToRecyclerAnimator ~= nil then
        if not self.debrisToRecyclerAnimator:ended() then
            local p = self.debrisToRecyclerAnimator:currentValue()
            local x1, y1 = p:unpack()
            self.collectedDebrisSprite:moveTo(x1, y1 - self.collectedDebrisSpriteSize)
        else
            self.debrisToRecyclerAnimator = nil
            self.recyclingSprite:add()
            self.collectedDebrisSprite:remove()
            self.currentBulletCountToGenerate = 1
            self:setupAmmoGenerationTimer()
        end
    elseif self.ammoToGunAnimator ~= nil then
        if not self.ammoToGunAnimator:ended() then
            local p = self.ammoToGunAnimator:currentValue()
            local x1, y1 = p:unpack()
            self.generatedAmmoSprite:moveTo(x1, y1 - self.generatedAmmoSpriteSize)
        else
            self.ammoToGunAnimator = nil
            self.generatedAmmoSprite:remove()
            -- TODO: these values could be updated in a better central place?
            CURRENT_BULLET_COUNT += 1
            DEBRIS_NOT_RECYCLED_COUNT -= 1
            NOTIFICATION_CENTER:notify(self.notifyBulletCountUpdated)
            -- ! HACK: improve the entire recycler and connector stuff
            if self.currentBulletCountToGenerate < bulletCountToGenerate then
                self.currentBulletCountToGenerate += 1
                self:setupAmmoGenerationTimer()
            else
                self.available = true
            end
        end
    end
end

function Recycler:addSprite()
    self:add()
    self.connector:addSprite()
end

function Recycler:getHit()
    if self.currentHP > 0 then
        self.currentHP -= 1
    end
    if self.currentHP <= 0 then
        self.deathSound:play()
        -- TODO: could animate this retracting
        self:clearCollideRect()
        self.connector:remove()

        -- should remove itself from the active targets and active recyclers
        for i = 1, #ACTIVE_TARGETS do
            if ACTIVE_TARGETS[i] == self then
                table.remove(ACTIVE_TARGETS, i)
                break
            end
        end
        for i = 1, #ACTIVE_RECYCLERS do
            if ACTIVE_RECYCLERS[i] == self then
                table.remove(ACTIVE_RECYCLERS, i)
                break
            end
        end
    end
    self:setImage(self.recyclerImageTable:getImage(maxHP + 1 - self.currentHP))
end

function Recycler:setupAmmoGenerationTimer()
    local ammoTimer = pd.timer.new(ammoGenerationDuration)
    ammoTimer.timerEndedCallback = function(timer)
        self:sendAmmoToGun()
    end
end

-- TODO: change all this animation to AnimatedSprite

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
        self.debrisToRecyclerAnimator = Animator.new(debrisTravelDuration, connectorParts, playdate.easingFunctions.linear)
    else
        local connectorLine = connector.horizontalConnector
        local x1, y1, x2, y2 = connector.horizontalConnector:unpack()
        if self.isLeftToGun then
            initialX, initialY = x2, y2
            connectorLine = geo.lineSegment.new(x2, y2, x1, y1)
        end

        self.debrisToRecyclerAnimator = Animator.new(debrisTravelDuration, connectorLine,
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
        self.ammoToGunAnimator = Animator.new(debrisTravelDuration, connectorParts, playdate.easingFunctions.linear)
    else
        local connectorLine = connector.horizontalConnector
        local x1, y1, x2, y2 = connector.horizontalConnector:unpack()
        if not self.isLeftToGun then
            initialX, initialY = x2, y2
            connectorLine = geo.lineSegment.new(x2, y2, x1, y1)
        end

        self.ammoToGunAnimator = Animator.new(debrisTravelDuration, connectorLine,
            playdate.easingFunctions.linear)
    end
    self.generatedAmmoSprite:moveTo(initialX, initialY - self.generatedAmmoSprite:getSize())
end

function Recycler:sendDebrisToRecycler()
    self.available = false
    if self.debrisToRecyclerAnimator == nil then
        self:setupDebrisToRecyclerAnimation()
    end
    self.collectedDebrisSprite:add()
end

function Recycler:sendAmmoToGun()
    self.workingSound:play()
    if self.currentBulletCountToGenerate == bulletCountToGenerate then
        self.recyclingSprite:remove()
    end
    if self.ammoToGunAnimator == nil then
        self:setupAmmoToGunAnimation()
    end
    self.generatedAmmoSprite:add()
end

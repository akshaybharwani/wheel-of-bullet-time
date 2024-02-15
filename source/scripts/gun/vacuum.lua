import "scripts/gun/vacuumVapor"

local pd <const> = playdate
local gfx <const> = pd.graphics

local utils <const> = UTILITIES

-- TODO: Shooter and Vacuum can base the same script

class("Vacuum").extends(AnimatedSprite)

TOP_VACUUM_VAPOR_POSITION = nil

local gunVacuumConstants = GUN_VACUUM_CONSTANTS
local vacuumLength = gunVacuumConstants.vacuumLength
local vacuumVaporDistance = gunVacuumConstants.vacuumVaporDistance
local vacuumVaporCount = gunVacuumConstants.vacuumVaporCount
local gunConstants = GUN_CONSTANTS
local maxHP = gunConstants.maxHP

local imagetablePath = "images/gun/gun_vacuum-table-64-64"
local imagetable = gfx.imagetable.new(imagetablePath)

function Vacuum:init(gun)
    Vacuum.super.init(self, imagetable)
    TOP_VACUUM_VAPOR_POSITION = nil
    self.gunVacuumState = GUN_VACUUM_STATE

    self.isGunDisabled = false
    self.isVacuumingDebris = false
    self.vacuumEmptySound = SfxPlayer(SFX_FILES.gun_vacuum_empty)
    self.vacuumDebrisSound = SfxPlayer(SFX_FILES.gun_vacuum_debris)

    self.imagetable = imagetable
    self.gun = gun

    for i = 0, maxHP do
        local stateName = tostring(maxHP - i)
        local firstFrameIndex = i * 3 + 1
        self:addState(stateName, firstFrameIndex, firstFrameIndex + 2,
        {tickStep = gunConstants.animationFPS})
    end

    self:moveTo(gun.x, gun.y)
    self:setZIndex(GUN_Z_INDEX)
    self:playAnimation()
    self:setVisible(false)

    self:setupVacuumVapor()
    self:setVacuumLine()

    self:subscribeEvents()
end

function Vacuum:update()

    if GUN_CURRENT_STATE == self.gunVacuumState then
        self:updateGunTopSprite()
    end

    if self.isGunDisabled then
        return
    end

    if IS_GAME_OVER then
        return
    end

    if WAS_GUN_ROTATED then
        self:updateVacuumVapors()
    end

    if not WAS_GAME_ACTIVE_LAST_CHECK then
        return
    end

    if GUN_CURRENT_STATE == self.gunVacuumState then
        self:checkForCollisions()
        self:playVacuumingSound()
    end
end

function Vacuum:subscribeEvents()
    NOTIFICATION_CENTER:subscribe(NOTIFY_GUN_WAS_HIT, self, function()
        self:changeState(tostring(self.gun.currentHP))
        self:updateGunTopSprite()
    end)
    NOTIFICATION_CENTER:subscribe(NOTIFY_GUN_IS_DISABLED, self, function(_)
        self.isGunDisabled = true
        self:stopVacuumingSound()
        if #self.vacuumVapors > 0 then
            for i = 1, #self.vacuumVapors do
                self.vacuumVapors[i]:remove()
            end
        end
    end)
    NOTIFICATION_CENTER:subscribe(NOTIFY_GUN_STATE_CHANGED, self, function(currentState)
        if currentState ~= self.gunVacuumState then
            self:stopVacuumingSound()
            self:setVisible(false)
        end
    end)
end

function Vacuum:setupVacuumVapor()
    self.vacuumVapors = {}
    for i = 1, vacuumVaporCount, 1 do
        local distanceFromGun = i * vacuumVaporDistance
        table.insert(self.vacuumVapors, VacuumVapor(GUN_BASE_X, GUN_BASE_Y - distanceFromGun, distanceFromGun))
    end
    TOP_VACUUM_VAPOR_POSITION = { x = self.vacuumVapors[#self.vacuumVapors].x, y = self.vacuumVapors[#self.vacuumVapors].y }
end

function Vacuum:updateVacuumVapors()
    self:setVacuumLine()
    -- this is so that vacuumVapors only update positions after creation of vacuumLine
    -- maybe there is a better way
    for i = 1, #self.vacuumVapors, 1 do
        self.vacuumVapors[i]:updatePosition(self.vacuumLine)
    end

    for i = 2, #self.vacuumVapors, 1 do
        if self.vacuumVapors[i].y < self.vacuumVapors[i - 1].y then
            TOP_VACUUM_VAPOR_POSITION = { x = self.vacuumVapors[i].x, y = self.vacuumVapors[i].y }
        else
            TOP_VACUUM_VAPOR_POSITION = { x = self.vacuumVapors[i - 1].x, y = self.vacuumVapors[i - 1].y }
        end
    end
end

function Vacuum:checkForCollisions()
    if self.isVacuumingDebris then
        self.isVacuumingDebris = false
    end
    self:checkVacuumVaporCollisions()
end

function Vacuum:checkVacuumVaporCollisions()
    local debrisCollided = {}
    -- TODO: this looks too expensive. collider rect cant be rotated, so cant be used. revisit to improve
    for i = 1, #self.vacuumVapors do
        local collisions = self.vacuumVapors[i]:overlappingSprites()
        for j = 1, #collisions do
            local other = collisions[j]
            if other.type == DEBRIS_TYPE_NAME
            and not utils.tableContains(debrisCollided, other) then
                other:moveTowardsGun()
                table.insert(debrisCollided, other)
                if not self.isVacuumingDebris then
                    self.isVacuumingDebris = true
                end
            end
        end
    end
end

function Vacuum:setVacuumLine()
    -- refer Examples/Single File Examples/crank.lua
    local angleRad = math.rad(GUN_CURRENT_ROTATION_ANGLE)
    local x2 = vacuumLength * math.sin(angleRad)
    local y2 = -1 * vacuumLength * math.cos(angleRad)

    x2 += GUN_BASE_X
    y2 += GUN_BASE_Y

    self.vacuumLine = pd.geometry.lineSegment.new(GUN_BASE_X, GUN_BASE_Y, x2, y2)
end

function Vacuum:updateGunTopSprite()
    self:updateAnimation()
    self.gun:setTopSprite(self.imagetable:getImage(self:getCurrentFrameIndex()))
end

function Vacuum:playVacuumingSound()
    if self.isVacuumingDebris then
        if self.vacuumEmptySound:isPlaying() then
            self.vacuumEmptySound:stop()
        end
        if not self.vacuumDebrisSound:isPlaying() then
            self.vacuumDebrisSound:playLooping()
        end
    else
        if not self.vacuumEmptySound:isPlaying() then
            self.vacuumEmptySound:play()
        end
        if self.vacuumDebrisSound:isPlaying() then
            self.vacuumDebrisSound:stop()
        end
    end
end

function Vacuum:stopVacuumingSound()
    if self.vacuumEmptySound:isPlaying() then
        self.vacuumEmptySound:stop()
    end
    if self.vacuumDebrisSound:isPlaying() then
        self.vacuumDebrisSound:stop()
    end
end

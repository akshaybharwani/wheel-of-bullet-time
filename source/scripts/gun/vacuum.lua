import "scripts/gun/vacuumVapor"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- TODO: Shooter and Vacuum can base the same script

class("Vacuum").extends(AnimatedSprite)

TOP_VACUUM_VAPOR_POSITION = nil

local vacuumLine = nil
local vacuumVapors = nil

local gunVacuumConstants = GUN_VACUUM_CONSTANTS
local gunConstants = GUN_CONSTANTS
local maxHP = gunConstants.maxHP

local imagetablePath = "images/gun/gun_vacuum-table-64-64"
local imagetable = gfx.imagetable.new(imagetablePath)

function Vacuum:init(gun)
    Vacuum.super.init(self, imagetable)
    TOP_VACUUM_VAPOR_POSITION = nil

    self.isGunDisabled = false
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

    NOTIFICATION_CENTER:subscribe(NOTIFY_GUN_WAS_HIT, self, function()
        self:changeState(tostring(self.gun.currentHP))
        self:updateGunTopSprite()
    end)
    NOTIFICATION_CENTER:subscribe(NOTIFY_GUN_IS_DISABLED, self, function()
        self.isGunDisabled = true
    end)
end

function Vacuum:setupVacuumVapor()
    self.vacuumVapors = {}
    for i = 1, gunVacuumConstants.vacuumVaporCount, 1 do
        local distanceFromGun = i * gunVacuumConstants.vacuumVaporDistance
        table.insert(self.vacuumVapors, VacuumVapor(GUN_BASE_X, GUN_BASE_Y - distanceFromGun, distanceFromGun))
    end
    vacuumVapors = self.vacuumVapors
    TOP_VACUUM_VAPOR_POSITION = { x = vacuumVapors[#vacuumVapors].x, y = vacuumVapors[#vacuumVapors].y }
end

function Vacuum:checkForCollisions()
    for i = 1, #self.vacuumVapors do
        local vacuumVapor = self.vacuumVapors[i]
        if vacuumVapor ~= nil then
            local collisions = vacuumVapor:overlappingSprites()
            for i = 1, #collisions do
                local other = collisions[i]
                if other.type == DEBRIS_TYPE_NAME then
                    other:moveTowardsGun()
                end
            end
        end
    end
end

function Vacuum:setVacuumLine()
    -- refer Examples/Single File Examples/crank.lua
    local angleRad = math.rad(GUN_CURRENT_ROTATION_ANGLE)
    local x2 = gunVacuumConstants.vacuumLength * math.sin(angleRad)
    local y2 = -1 * gunVacuumConstants.vacuumLength * math.cos(angleRad)

    x2 += GUN_BASE_X
    y2 += GUN_BASE_Y

    vacuumLine = pd.geometry.lineSegment.new(GUN_BASE_X, GUN_BASE_Y, x2, y2)
end

function Vacuum:update()
    if self.isGunDisabled then
        return
    end

    if IS_GAME_OVER then
        return
    end

    -- TODO: double checks for this and shooter. consolidate
    if WAS_GAME_ACTIVE_LAST_CHECK then
        self:updateGunTopSprite()
    end

    if not self.gun.available then
        if #self.vacuumVapors > 0 then
            for i = 1, #self.vacuumVapors do
                self.vacuumVapors[i]:remove()
            end
        end
        return
    end

    if WAS_GAME_ACTIVE_LAST_CHECK and (GUN_CURRENT_STATE == GUN_VACUUM_STATE) then
        self:checkForCollisions()
    end

    if WAS_GUN_ROTATED then
        self:setVacuumLine()
        -- this is so that vacuumVapors only update positions after creation of vacuumLine
        -- maybe there is a better way
        for i = 1, #self.vacuumVapors, 1 do
            self.vacuumVapors[i]:updatePosition(vacuumLine)
        end

        for i = 2, #self.vacuumVapors, 1 do
            if self.vacuumVapors[i].y < self.vacuumVapors[i - 1].y then
                TOP_VACUUM_VAPOR_POSITION = { x = self.vacuumVapors[i].x, y = self.vacuumVapors[i].y }
            else
                TOP_VACUUM_VAPOR_POSITION = { x = self.vacuumVapors[i - 1].x, y = self.vacuumVapors[i - 1].y }
            end
        end
    end
end

function Vacuum:updateGunTopSprite()
    if (GUN_CURRENT_STATE == GUN_VACUUM_STATE) then
        self:updateAnimation()
        self.gun:setTopSprite(self.imagetable:getImage(self:getCurrentFrameIndex()))
    else
        self:setVisible(false)
    end
end

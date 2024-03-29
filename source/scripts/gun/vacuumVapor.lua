local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry

class("VacuumVapor").extends(AnimatedSprite)

local gunVacuumConstants = GUN_VACUUM_CONSTANTS
local vacuumVaporSpeed = gunVacuumConstants.vacuumVaporSpeed
local animationFPS = gunVacuumConstants.vacuumVaporAnimationFPS

local vacuumVaporPadding = 10

local vacuumVaporImagePath = "images/gun/vacuum-table-32-32"
local vacuumVaporImageTable = gfx.imagetable.new(vacuumVaporImagePath)

function VacuumVapor:init(x, y, distanceFromGun)
    VacuumVapor.super.init(self, vacuumVaporImageTable)
    self.distanceFromGun = distanceFromGun
    local vaporSize = vacuumVaporImageTable:getImage(1):getSize()
    self:moveTo(x, y - vaporSize / 2)
    self:setVelocity(GUN_BASE_X, GUN_BASE_Y)
    -- TODO: Add random rotation to this based on rules
    self:addState("shrink", 1, 5, {tickStep = animationFPS})
    self:setZIndex(BACKGROUND_Z_INDEX + 1)
    self:setCollideRect(0, 0, vaporSize, vaporSize)
    self:setGroups(VACUUM_GROUP)
    self:setCollidesWithGroups({ DEBRIS_GROUP })
    self:playAnimation()
end

function VacuumVapor:update()
    if WAS_GAME_ACTIVE_LAST_CHECK and (GUN_CURRENT_STATE == GUN_VACUUM_STATE) then
        self:updateAnimation()
        self:setVisible(true)
        self:moveTowardsGun()
    else
        self:setVisible(false)
    end
end

function VacuumVapor:updatePosition(vacuumLine)
    local vaporPointX, vaporPointY = vacuumLine:pointOnLine(self.distanceFromGun):unpack()
    self:moveTo(vaporPointX, vaporPointY)
    self:setVelocity(GUN_BASE_X, GUN_BASE_Y)
end

function VacuumVapor:moveTowardsGun()
    local topVacuumVaporPosition = TOP_VACUUM_VAPOR_POSITION
    if geo.distanceToPoint(GUN_BASE_X, GUN_BASE_Y, self.x, self.y) < vacuumVaporPadding then
        if (topVacuumVaporPosition) then
            self:moveTo(topVacuumVaporPosition.x, topVacuumVaporPosition.y)
        else
            self:remove()
        end
    else
        local nextX, nextY = self.x + self.dx * DELTA_TIME, self.y + self.dy * DELTA_TIME
        self:moveTo(nextX, nextY)
    end
end

function VacuumVapor:setVelocity(x, y)
    local distance = pd.geometry.distanceToPoint(self.x, self.y, x, y)
    self.speed = vacuumVaporSpeed
    local nx = x - self.x
    local ny = y - self.y
    self.dx = (nx / distance) * self.speed
    self.dy = (ny / distance) * self.speed
end
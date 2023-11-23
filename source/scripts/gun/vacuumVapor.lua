import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/libraries/AnimatedSprite"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry

class("VacuumVapor").extends(AnimatedSprite)

local vacuumVaporSpeed = 32
local animationFPS = 20
local vacuumVaporImagePath = "images/gun/vacuum-table-32-32"
local vacuumVaporImageTable = gfx.imagetable.new(vacuumVaporImagePath)

local vacuumVaporPadding = 10

function VacuumVapor:init(x, y, distanceFromGun)
    VacuumVapor.super.init(self, vacuumVaporImageTable)
    self.distanceFromGun = distanceFromGun
    local vaporSize = vacuumVaporImageTable:getImage(1):getSize()
    self:moveTo(x, y - vaporSize / 2)
    self:setVelocity(GUN_BASE_X, GUN_BASE_Y)
    -- TODO: Add random rotation to this based on rules
    self:addState("shrink", 1, 5, {tickStep = animationFPS})
    self:setZIndex(-101)
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
    if geo.distanceToPoint(GUN_BASE_X, GUN_BASE_Y, self.x, self.y) < vacuumVaporPadding then
        if (TOP_VACUUM_VAPOR_POSITION) then
            self:moveTo(TOP_VACUUM_VAPOR_POSITION.x, TOP_VACUUM_VAPOR_POSITION.y)
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
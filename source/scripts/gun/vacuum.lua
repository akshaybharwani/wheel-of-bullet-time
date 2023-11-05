import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/libraries/AnimatedSprite"
import "scripts/gun/vacuumVapor"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- TODO: Shooter and Vacuum can base the same script

class("Vacuum").extends(AnimatedSprite)

TOP_VACUUM_VAPOR_POSITION = nil

local vacuumVaporFlipStates = { gfx.kImageUnflipped, gfx.kImageFlippedX, gfx.kImageFlippedY, gfx.kImageFlippedXY}

local vacuumLine = nil
local vacuumVapors = nil

local gunVacuumConstants = GUN_VACUUM_CONSTANTS
local gunConstants = GUN_CONSTANTS

local imagetablePath = "images/gun/gun_vacuum-table-64-64"
local imagetable = gfx.imagetable.new(imagetablePath)

function Vacuum:init(gun)
    Vacuum.super.init(self, imagetable)

    self.imagetable = imagetable
    self.gun = gun

    self:setupVacuumVapor()
    self:setVacuumLine()

    self:addState("maxHPState", 1, 3, {tickStep = gunConstants.animationFPS})
    self:moveTo(gun.x, gun.y)
    self:setZIndex(GUN_Z_INDEX)
    self:playAnimation()
    self:setVisible(false)
end

function Vacuum:setupVacuumVapor()
    self.vacuumVapors = {}
    for i = 1, gunVacuumConstants.vacuumVaporCount, 1 do
        -- TODO: this is not actually rotating the sprites. Fix it.
        local vacuumVaporFlipStateIndex = math.random(1, #vacuumVaporFlipStates)
        local distanceFromGun = i * gunVacuumConstants.vacuumVaporDistance
        table.insert(self.vacuumVapors, VacuumVapor(GUN_BASE_X, GUN_BASE_Y - distanceFromGun, vacuumVaporFlipStates[vacuumVaporFlipStateIndex], distanceFromGun))
    end
    vacuumVapors = self.vacuumVapors
    TOP_VACUUM_VAPOR_POSITION = { x = vacuumVapors[#vacuumVapors].x, y = vacuumVapors[#vacuumVapors].y }
end

function Vacuum:collectDebris()
    -- TODO: sometimes vacuum wont collect some debris and they stay hanging in game
    for i = 1, #self.collidedSprites do
        local collidedObject = self.collidedSprites[i]
        if collidedObject.type == DEBRIS_TYPE_NAME then
            collidedObject:collect()
            return
        end
    end
end

function Vacuum:checkForCollisions()
    for i = 1, #ACTIVE_DEBRIS do
        local debris = ACTIVE_DEBRIS[i]
        if debris ~= nil then
            local debrisPoint = pd.geometry.point.new(debris:getPosition())
            local linePoint = vacuumLine:closestPointOnLineToPoint(debrisPoint)
            -- HACK: magic number 6 to give advantage to players (and temporary fix debris not collecting bug)
            if debrisPoint:distanceToPoint(linePoint) <= gunVacuumConstants.vacuumAreaWidth / 2 + 6 then
                debris:moveTowardsGun()
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
    if WAS_GAME_ACTIVE_LAST_CHECK then
        if (GUN_CURRENT_STATE == GUN_VACUUM_STATE) then
            self:updateAnimation()
            self.gun:setTopSprite(self.imagetable:getImage(self:getCurrentFrameIndex()))
            self:checkForCollisions()
        else
            self:setVisible(false)
        end
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

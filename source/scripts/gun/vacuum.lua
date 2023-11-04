import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/crank"
import "CoreLibs/animation"
import "scripts/gun/vacuumVapor"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Vacuum").extends(gfx.sprite)

local vacuumVaporFlipStates = { gfx.kImageUnflipped, gfx.kImageFlippedX, gfx.kImageFlippedY, gfx.kImageFlippedXY}

local vacuumAreaWidth = 32
local vacuumLength = 1000

local vacuumVaporDistance = 32
local vacuumVaporCount = 10

local gunVacuumAnimationLoop = nil

local vacuumLine = nil

TOP_VACUUM_VAPOR_POSITION = nil

local vacuumVapors = nil

local gunVacuumImageTablePath = "images/gun/gun_vacuum"

function Vacuum:init(x, y)
    Vacuum.super.init(self)
    self:setupVacuumVapor()
    self:setupAnimation()
    self:setVacuumLine()
    self:add()
end

function Vacuum:setupVacuumVapor()
    self.vacuumVapors = {}
    for i = 1, vacuumVaporCount, 1 do
        local vacuumVaporFlipStateIndex = math.random(1, #vacuumVaporFlipStates)
        local distanceFromGun = i * vacuumVaporDistance
        table.insert(self.vacuumVapors, VacuumVapor(GUN_BASE_X, GUN_BASE_Y - distanceFromGun, vacuumVaporFlipStates[vacuumVaporFlipStateIndex], distanceFromGun))
    end
    vacuumVapors = self.vacuumVapors
    local vacuumVapors = self.vacuumVapors
    TOP_VACUUM_VAPOR_POSITION = { x = vacuumVapors[#vacuumVapors].x, y = vacuumVapors[#vacuumVapors].y }
end

function Vacuum:setupAnimation()
    -- TODO: change to use AnimatedSprite
    local animationImageTable = gfx.imagetable.new(gunVacuumImageTablePath)
    gunVacuumAnimationLoop = gfx.animation.loop.new()
    gunVacuumAnimationLoop.paused = true
    gunVacuumAnimationLoop:setImageTable(animationImageTable)
end

function Vacuum:collectDebris()
    -- TODO: sometimes vacuum wont collect some debris and they stay hanging in game
    for i = 1, #self.collidedSprites do
        local collidedObject = self.collidedSprites[i]
        if collidedObject.type == "debris" then
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
            if debrisPoint:distanceToPoint(linePoint) <= vacuumAreaWidth / 2 + 6 then
                debris:moveTowardsGun()
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

    vacuumLine = pd.geometry.lineSegment.new(GUN_BASE_X, GUN_BASE_Y, x2, y2)
end

function Vacuum:update()
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

    if WAS_GAME_ACTIVE_LAST_CHECK then
        if (GUN_CURRENT_STATE == GUN_VACUUM_STATE) then
            gunVacuumAnimationLoop.paused = false
            GUN_TOP_SPRITE:setImage(gunVacuumAnimationLoop:image())
            self:checkForCollisions()
        end
    else
        gunVacuumAnimationLoop.paused = true
        self:setVisible(false)
    end
end

function playdate.AButtonUp()
	for i = 1, #vacuumVapors, 1 do
        print(vacuumVapors[i].x .. ", " .. vacuumVapors[i].y)
    end
end

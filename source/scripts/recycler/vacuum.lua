import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/crank"
import "CoreLibs/animation"
import "scripts/recycler/vacuumVapor"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Vacuum").extends(gfx.sprite)

local vacuumVaporFlipStates = { gfx.kImageUnflipped, gfx.kImageFlippedX, gfx.kImageFlippedY, gfx.kImageFlippedXY}

local vacuumAreaWidth = 32
local vacuumLength = 500

local vacuumVaporDistance = 32
local vacuumVaporCount = 10

local gunVacuumAnimationLoop = nil

TOP_VACUUM_VAPOR_POSITION = nil

local vacuumLine = nil

function Vacuum:init(x, y)
    Vacuum.super.init(self)
    -- switched to using vacuum vapors, so remove this
    --[[ local vacuumImage = gfx.image.new(vacuumAreaWidth, vacuumLength)
    gfx.pushContext(vacuumImage)
    gfx.drawRect(0, 0, vacuumAreaWidth, vacuumLength)
    gfx.popContext()
    self:setImage(vacuumImage)
    self:setCollideRect(0, 0, self:getSize())
    self:setGroups(DEBRIS_GROUP)
    self:setCollidesWithGroups({ DEBRIS_GROUP }) 
    self:moveTo(MAX_SCREEN_WIDTH / 2, GUN_BASE_Y)
    self:setCenter(0.5, 1) ]]
    self:setupVacuumVapor()
    self:setupAnimation()
    self:add()
end

function Vacuum:setupVacuumVapor()
    self.vacuumVapors = {}
    for i = 1, vacuumVaporCount, 1 do
        local vacuumVaporFlipStateIndex = math.random(1, #vacuumVaporFlipStates)
        table.insert(self.vacuumVapors, VacuumVapor(GUN_BASE_X, GUN_BASE_Y - i * vacuumVaporDistance, vacuumVaporFlipStates[vacuumVaporFlipStateIndex]))
    end
    local topVacuumVapor = self.vacuumVapors[vacuumVaporCount]
    TOP_VACUUM_VAPOR_POSITION = { x = topVacuumVapor.x, y = topVacuumVapor.y}
end

function Vacuum:setupAnimation()
    local animationImageTable = gfx.imagetable.new("images/recycler/gun_vacuum")
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

function Vacuum:checkGunState()
    if (GUN_CURRENT_STATE == GUN_VACUUM_STATE) then
        gunVacuumAnimationLoop.paused = false
        GUN_TOP_SPRITE:setImage(gunVacuumAnimationLoop:image())
        self:checkForCollisions()
    else
        self:setVisible(false)
    end
end

function Vacuum:update()
    if (GUN_CURRENT_STATE == GUN_VACUUM_STATE) then
        self:setVacuumLine()
        -- this is so that vacuumVapors only update positions after creation of vacuumLine
        -- maybe there is a better way
        for i = 1, #self.vacuumVapors, 1 do
            self.vacuumVapors[i]:updatePosition(vacuumLine)
        end
    end
    
    if not IS_GAME_ACTIVE then
        gunVacuumAnimationLoop.paused = true
        return
    end
    self:checkGunState()
end

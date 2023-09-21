import "CoreLibs/crank"
import "CoreLibs/animation"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Vacuum").extends(gfx.sprite)

local vacuumAreaWidth = 32
local vacuumLength = 500

local gunVacuumAnimationLoop = nil

function Vacuum:init(x, y)
    Vacuum.super.init(self)
    local vacuumImage = gfx.image.new(vacuumAreaWidth, vacuumLength)
    gfx.pushContext(vacuumImage)
    gfx.drawRect(0, 0, vacuumAreaWidth, vacuumLength)
    gfx.popContext()
    self:setImage(vacuumImage)
    self:setCollideRect(0, 0, self:getSize())
    self:setGroups(DEBRIS_GROUP)
    self:setCollidesWithGroups({ DEBRIS_GROUP })
    self:moveTo(MAX_SCREEN_WIDTH / 2, GUN_BASE_Y)
    self:setCenter(0.5, 1)
    self:setupAnimation()
    self:add()
    self:setVisible(false)
end

function Vacuum:setupAnimation()
    local animationImageTable = gfx.imagetable.new("images/gun_vacuum")
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
    self:setVisible(true)
    -- refer Examples/Single File Examples/crank.lua
    local angleRad = math.rad(GUN_CURRENT_ROTATION_ANGLE)
    local x2 = vacuumLength * math.sin(angleRad)
    local y2 = -1 * vacuumLength * math.cos(angleRad)

    x2 += GUN_BASE_X
    y2 += GUN_BASE_Y

    local vacuumLine = pd.geometry.lineSegment.new(GUN_BASE_X, GUN_BASE_Y, x2, y2)

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

function Vacuum:checkGunState()
    if (GUN_CURRENT_STATE == GUN_VACUUM_STATE) then
        gunVacuumAnimationLoop.paused = false
        GUN_TOP_SPRITE:setImage(gunVacuumAnimationLoop:image())
        -- does this require any timer like shooting a bullet every 36 degree rotation?
        self:checkForCollisions()
    else
        self:setVisible(false)
    end
end

function Vacuum:update()
    self:setRotation(GUN_CURRENT_ROTATION_ANGLE)
    if not IS_GAME_ACTIVE then
        gunVacuumAnimationLoop.paused = true
        return
    end
    self:checkGunState()
end

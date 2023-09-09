import "CoreLibs/crank"
import "CoreLibs/animation"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Vacuum").extends(gfx.sprite)

local vacuumAreaWidth = 32
local vacuumLength = 300

local gunVacuumAnimationLoop = nil

function Vacuum:init(x, y)
    Vacuum.super.init(self)
    local vacuumImage = gfx.image.new(vacuumAreaWidth, MAX_SCREEN_HEIGHT)
    gfx.pushContext(vacuumImage)
        gfx.drawRect(0, 0, vacuumAreaWidth, MAX_SCREEN_HEIGHT)
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

    for i = 1, #self.collidedSprites do
        local collidedObject = self.collidedSprites[i]
        if collidedObject.type == "debris" then

            collidedObject:collect()
            return
        end
    end

    -- show animation of debris collection
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
            if debrisPoint:distanceToPoint(linePoint) <= vacuumAreaWidth / 2 then
                debris:collect()
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

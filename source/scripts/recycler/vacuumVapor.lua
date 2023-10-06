import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/plugins/AnimatedSprite"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("VacuumVapor").extends(AnimatedSprite)

local vacuumVaporSpeed = 32
local animationFPS = 20
local vacuumVaporImagePath = "images/recycler/vacuum-table-32-32"
local vacuumVaporImageTable = gfx.imagetable.new(vacuumVaporImagePath)

local vacuumVaporPadding = 20

function VacuumVapor:init(x, y, flip)
    VacuumVapor.super.init(self, vacuumVaporImageTable)
    self:moveTo(x, y - vacuumVaporImageTable:getImage(1):getSize() / 2)
    self:setVelocity(GUN_BASE_X, GUN_BASE_Y)
    local tickStep = animationFPS
    self:addState("shrink", 1, 5, {tickStep = tickStep})
    self.states.shrink.flip = flip
    self:playAnimation()
end

function VacuumVapor:update()
    if (GUN_CURRENT_STATE == GUN_VACUUM_STATE) then
        if IS_GAME_ACTIVE then
            self:resumeAnimation()
            self:setVisible(true)
            self:moveTowardsGun()
        else
            self:pauseAnimation()
        end
    else
        self:pauseAnimation()
        self:setVisible(false)
    end

    self:updateAnimation()
end

function VacuumVapor:updatePosition(vacuumLine)
    local vacuumVaporPoint = pd.geometry.point.new(self:getPosition())
    local linePoint = vacuumLine:closestPointOnLineToPoint(vacuumVaporPoint)
    self:moveTo(linePoint.x, linePoint.y)
    self:setVelocity(GUN_BASE_X, GUN_BASE_Y)
end

function VacuumVapor:moveTowardsGun()
    if self.y < GUN_BASE_Y and self.y > GUN_BASE_Y - vacuumVaporPadding then
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
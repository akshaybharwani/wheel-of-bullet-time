import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/plugins/AnimatedSprite"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry

class("VacuumVapor").extends(AnimatedSprite)

local vacuumVaporSpeed = 32
local animationFPS = 20
local vacuumVaporImagePath = "images/recycler/vacuum-table-32-32"
local vacuumVaporImageTable = gfx.imagetable.new(vacuumVaporImagePath)

local vacuumVaporPadding = 10

function VacuumVapor:init(x, y, flip, distanceFromGun)
    VacuumVapor.super.init(self, vacuumVaporImageTable)
    self.distanceFromGun = distanceFromGun
    self:moveTo(x, y - vacuumVaporImageTable:getImage(1):getSize() / 2)
    self:setVelocity(GUN_BASE_X, GUN_BASE_Y)
    local tickStep = animationFPS
    self:addState("shrink", 1, 5, {tickStep = tickStep})
    self.states.shrink.flip = flip
    self:playAnimation()
end

function VacuumVapor:update()
    if WAS_GAME_ACTIVE_LAST_CHECK and (GUN_CURRENT_STATE == GUN_VACUUM_STATE) then
        self:resumeAnimation()
        self:setVisible(true)
        self:moveTowardsGun()
    else
        self:pauseAnimation()
        self:setVisible(false)
    end

    self:updateAnimation()
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
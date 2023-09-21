import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

local rotationChance = 0.5
local debrisToRecycleDuration = 1000

local debrisImagePath = "images/debris"

class("Debris").extends(gfx.sprite)

function Debris:init(x, y, debrisManager)
    Debris.super.init(self)

    self.type = "debris"
    self.debrisManager = debrisManager

    self:setImage(gfx.image.new(debrisImagePath))
    local shouldRotate = math.random() < rotationChance
    self:setCollideRect(0, 0, self:getSize())
    self:setGroups(DEBRIS_GROUP)
    self:setCollidesWithGroups({ DEBRIS_GROUP })
    if shouldRotate then
        self:setRotation(90)
    end
    self:moveTo(x, y)
    self:setVelocity(GUN_BASE_X, GUN_BASE_Y)
    self:add()
end

function Debris:moveTowardsGun()
    if self.x < GUN_BASE_X and self.x > GUN_BASE_X - 10
        and self.y < GUN_BASE_Y and self.y > GUN_BASE_Y - 10 then
        self.debrisManager:removeDebris(self)
        self:remove()
    else
        local nextX, nextY = self.x + self.dx * DELTA_TIME, self.y + self.dy * DELTA_TIME
        self:moveTo(nextX, nextY)
    end
end

function Debris:setVelocity(x, y)
    local distance = pd.geometry.distanceToPoint(self.x, self.y, x, y)
    self.speed = distance / (debrisToRecycleDuration / 1000)
    local nx = x - self.x
    local ny = y - self.y
    self.dx = (nx / distance) * self.speed
    self.dy = (ny / distance) * self.speed
end

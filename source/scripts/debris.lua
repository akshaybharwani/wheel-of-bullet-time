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
    self:add()
end

function Debris:update()
    if self.recycleAnimator then
        if self.recycleAnimator:ended() then
            self:remove()
            return
        end
        self:moveTo(self.recycleAnimator:currentValue())
    end
end

function Debris:collect()
    local debrisPoint = pd.geometry.point.new(self.x, self.y)
    local gunPoint = pd.geometry.point.new(GUN_BASE_X, GUN_BASE_Y)
    self.recycleAnimator = gfx.animator.new(debrisToRecycleDuration, debrisPoint, gunPoint)
    self.debrisManager:removeDebris(self)
end

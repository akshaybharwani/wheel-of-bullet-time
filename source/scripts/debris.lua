import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

local rotationChance = 0.5

local debrisImagePath = "images/debris"

class("Debris").extends(gfx.sprite)

function Debris:init(x, y)
    Debris.super.init(self)

    self.type = "debris"

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
        self:moveTo(self.recycleAnimator:currentValue())
    end
end

function Debris:collect()
    print("collecting")
    local debrisPoint = pd.geometry.point.new(self.x, self.y)
    local gunPoint = pd.geometry.point.new(GUN_BASE_X, GUN_BASE_Y)
    self.recycleAnimator = gfx.animator.new(300, debrisPoint, gunPoint)
    --self:remove()
    -- use primitive shape to show debris animation going to the recycler
    -- remove debris
end

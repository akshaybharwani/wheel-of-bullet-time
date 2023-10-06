import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/plugins/AnimatedSprite"

local pd <const> = playdate
local gfx <const> = pd.graphics

local rotationChance = 0.5
local debrisToRecycleDuration = 1000

local debrisImagePath = "images/enemies/debris"
local debrisSpawnImagePath = "images/enemies/debris_spawn-table-16-16"
local spawnAnimationFPS = 8

local debrisDetectionPadding = 20

class("Debris").extends(gfx.sprite)

function Debris:init(x, y, debrisManager)
    Debris.super.init(self)

    self.type = "debris"
    self.debrisManager = debrisManager

    self:setImage(gfx.image.new(debrisImagePath))
    self.shouldRotate = math.random() < rotationChance

    self:setCollideRect(0, 0, self:getSize())
    self:setGroups(DEBRIS_GROUP)
    self:setCollidesWithGroups({ DEBRIS_GROUP })
    if self.shouldRotate then
        self:setRotation(90)
    end
    self:moveTo(x, y)
    self:setVelocity(GUN_BASE_X, GUN_BASE_Y)
    self:setupSpawnAnimation(x, y)
    self:add()
    self:setVisible(false)
end

function Debris:moveTowardsGun()
    if self.spawning then
        return
    end

    if self.y < GUN_BASE_Y and self.y > GUN_BASE_Y - debrisDetectionPadding then
        self.debrisManager:removeDebris(self)
        self:remove()
    else
        local nextX, nextY = self.x + self.dx * DELTA_TIME, self.y + self.dy * DELTA_TIME
        self:moveTo(nextX, nextY)
    end
end

function Debris:setVelocity(x, y)
    local distance = pd.geometry.distanceToPoint(self.x, self.y, x, y)
    -- why divide by 1000?
    self.speed = distance / (debrisToRecycleDuration / 1000)
    local nx = x - self.x
    local ny = y - self.y
    self.dx = (nx / distance) * self.speed
    self.dy = (ny / distance) * self.speed
end

function Debris:setupSpawnAnimation(x, y)
    local imageTable = gfx.imagetable.new(debrisSpawnImagePath)
    self.spawnSprite = AnimatedSprite.new(imageTable)
    self.spawnSprite:addState("spawning", 1, 11, {tickStep = spawnAnimationFPS})
    self.spawnSprite.states.spawning.loop = false
    if self.shouldRotate then
        self.spawnSprite:setRotation(90)
    end
    self.spawnSprite.states.spawning.onAnimationEndEvent = function ()
        self:setVisible(true)
        self.spawnSprite:remove()
        self.spawning = false
    end
    self.spawnSprite:moveTo(x, y)
    self.spawnSprite:playAnimation()
    self.spawning = true
end
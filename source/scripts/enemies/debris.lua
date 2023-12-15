local pd <const> = playdate
local gfx <const> = pd.graphics

local debrisConstants = DEBRIS_CONSTANTS
local startSpeed = debrisConstants.startSpeed
local maxSpeed = debrisConstants.maxSpeed
local acceleration = debrisConstants.acceleration

local debrisImagePath = "images/enemies/debris"
local debrisSpawnImagePath = "images/enemies/debris_spawn-table-16-16"

local rotationChance = 0.5
local debrisDetectionPadding = 20

class("Debris").extends(gfx.sprite)

function Debris:init(x, y, debrisManager)
    Debris.super.init(self)

    self.type = DEBRIS_TYPE_NAME
    self.debrisManager = debrisManager

    self:setImage(gfx.image.new(debrisImagePath))
    self.shouldRotate = math.random() < rotationChance

    self.speed = startSpeed
    self:setCollideRect(0, 0, self:getSize())
    self:setGroups(DEBRIS_GROUP)
    self:setCollidesWithGroups({ VACUUM_GROUP })
    if self.shouldRotate then
        self:setRotation(90)
    end
    self:moveTo(x, y)
    self:setupDistanceToTarget(GUN_BASE_X, GUN_BASE_Y)
    self:setVelocity()
    self:setupSpawnAnimation(x, y)
    self:add()
    self:setVisible(false)
    NOTIFICATION_CENTER:subscribe(NOTIFY_GUN_STATE_CHANGED, self, function(currentState)
        if currentState ~= GUN_VACUUM_STATE and self.speed ~= startSpeed then
            self.speed = startSpeed
        end
    end)
end

function Debris:moveTowardsGun()
    if self.spawning then
        return
    end

    if self.y < GUN_BASE_Y and self.y > GUN_BASE_Y - debrisDetectionPadding then
        self.debrisManager:removeDebris(self)
        self:remove()
    else
        local nextX, nextY = self.x + self.dx, self.y + self.dy
        self:moveTo(nextX, nextY)
        if self.speed < maxSpeed then
            self.speed += acceleration * DELTA_TIME
            self:setVelocity()
        end
    end
end

function Debris:setupDistanceToTarget(x, y)
    local distanceToTarget = pd.geometry.distanceToPoint(self.x, self.y, x, y)
    local nx = x - self.x
    local ny = y - self.y
    self.horizontalDistanceToTarget = (nx / distanceToTarget)
    self.verticalDistanceToTarget = (ny / distanceToTarget)
end

function Debris:setVelocity()
    self.dx = self.horizontalDistanceToTarget * self.speed
    self.dy = self.verticalDistanceToTarget * self.speed
end

function Debris:setupSpawnAnimation(x, y)
    local imageTable = gfx.imagetable.new(debrisSpawnImagePath)
    self.spawnSprite = AnimatedSprite.new(imageTable)
    self.spawnSprite:addState("spawning", 1, 11, {tickStep = debrisConstants.spawnAnimationFPS})
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
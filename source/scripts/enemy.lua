import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/debrisManager"
import "scripts/crankTimer"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry

class("Enemy").extends(gfx.sprite)

local minSpeed, maxSpeed = 5, 10
local explosionDuration = 1000
local hitDuration = 100

local minTotalPatrolDuration, maxTotalPatrolDuration = 2, 5
local minPatrolSegmentDuration, maxPatrolSegmentDuration = 1, 2

function Enemy:init(enemyType, debrisManager)
    Enemy.super.init(self)

    self.debrisManager = debrisManager
    self.hp = enemyType.hp
    self.type = "enemy"
    self.speed = math.random(minSpeed, maxSpeed)
    self.shieldColliderSize = enemyType.shieldColliderSize

    self.explosionSprite = gfx.sprite.new(gfx.image.new(enemyType.explosionImagePath))

    self.enemyBaseImage = gfx.image.new(enemyType.baseImagePath)
    self:setImage(self.enemyBaseImage)

    self:setupShieldCollider()

    self:setupHitAnimator()

    self:setStartingPosition()
    self:add()
    self:setupPatroling()
end

function Enemy:update()
    if self.explosionAnimator then
        return
    end

    if not IS_GAME_ACTIVE then
        return
    end

    self:move()
end

function Enemy:setupPatroling()
    self:setNewPatrolPoint()
    self.segmentPatrolTimer = CrankTimer(math.random(minPatrolSegmentDuration, maxPatrolSegmentDuration), function()
        self:setNewPatrolPoint()
    end)
    self.totalPatrolTimer = CrankTimer(math.random(minTotalPatrolDuration, maxTotalPatrolDuration), function()
        self:setTarget()
        self.segmentPatrolTimer:remove()
        self.totalPatrolTimer:remove()
    end)
end

function Enemy:setStartingPosition()
    local halfWidth = self.width / 2
    local halfHeight = self.height / 2
    local startY = -halfHeight
    local startXPositions = { -halfWidth, math.random(halfWidth, MAX_SCREEN_WIDTH - halfWidth),
        MAX_SCREEN_WIDTH + halfWidth }
    local startX = startXPositions[math.random(1, #startXPositions)]
    if startX == -halfWidth or startX == MAX_SCREEN_WIDTH + halfWidth then
        startY = math.random(-halfHeight, MAX_SCREEN_HEIGHT / 2 - halfHeight)
    end

    self:moveTo(startX, startY)
end

function Enemy:move()
    local nextX, nextY        = self.x + self.dx * DELTA_TIME * 10, self.y + self.dy * DELTA_TIME * 10
    local _, _, collisions, _ = self:moveWithCollisions(nextX, nextY)

    for i = 1, #collisions do
        local other = collisions[i].other
        if other.type == "gun-element" then
            other:getHit()
            self:explode()
            return
        end
    end

    --[[ if self.y > MAX_SCREEN_HEIGHT then
        self:remove()
    end ]]
end

function Enemy:setNewPatrolPoint()
    local nextX = math.random(16, MAX_SCREEN_WIDTH - 16)
    local nextY = math.random(16, MAX_SCREEN_HEIGHT / 2)
    self:setVelocity(nextX, nextY)
end

function Enemy:setTarget()
    local target = ACTIVE_TARGETS[math.random(1, #ACTIVE_TARGETS)]
    self:setVelocity(target.x, target.y)
end

function Enemy:setVelocity(x, y)
    local distance = geo.distanceToPoint(self.x, self.y, x, y)
    local nx = x - self.x
    local ny = y - self.y
    self.dx = nx / distance * self.speed
    self.dy = ny / distance * self.speed
end

function Enemy:getHit()
    self.hp -= 1
    if self.hp <= 0 then
        self:shatter()
    else
        self.hitAnimator:reset()
        self.hitAnimator:start()
        self:setVisible(false)
    end
end

function Enemy:shatter()
    self.debrisManager:spawnDebris(self.x, self.y)
    self:remove()
end

function Enemy:explode()
    self.explosionAnimator = pd.timer.new(explosionDuration)
    self.explosionAnimator.timerEndedCallback = function(timer)
        self:remove()
        self.explosionSprite:remove()
    end
    self.explosionSprite:moveTo(self.x, self.y)
    self.explosionSprite:add()
    self:setVisible(false)
end

function Enemy:setupShieldCollider()
    local shieldColliderSize = self.shieldColliderSize
    local shieldColliderOrigin = self.width / 2 - shieldColliderSize / 2
    self:setCollideRect(shieldColliderOrigin, shieldColliderOrigin, shieldColliderSize,
        shieldColliderSize)
end

function Enemy:setupHitAnimator()
    self.hitAnimator = pd.timer.new(hitDuration)
    self.hitAnimator.discardOnCompletion = false
    self.hitAnimator:pause()
    self.hitAnimator.timerEndedCallback = function(timer)
        self:setVisible(true)
    end
end

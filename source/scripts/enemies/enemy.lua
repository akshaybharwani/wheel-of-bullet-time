import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/enemies/debrisManager"
import "scripts/game/crankTimer"
import "scripts/libraries/AnimatedSprite"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry

class("Enemy").extends(gfx.sprite)

local enemyConstants = ENEMY_CONSTANTS

local minSpeed, maxSpeed = enemyConstants.minSpeed, enemyConstants.maxSpeed
local hitAnimationDuration = enemyConstants.hitAnimationDuration
local explosionAnimationLoopCount = enemyConstants.explosionAnimationLoopCount
local explosionAnimationFPS = enemyConstants.explosionAnimationFPS

local minTotalPatrolDuration, maxTotalPatrolDuration = enemyConstants.minTotalPatrolDuration, enemyConstants.maxTotalPatrolDuration
local minPatrolSegmentDuration, maxPatrolSegmentDuration = enemyConstants.minPatrolSegmentDuration, enemyConstants.minPatrolSegmentDuration

function Enemy:init(enemyType, debrisManager)
    Enemy.super.init(self)

    self.enemyType = enemyType
    self.debrisManager = debrisManager
    self.hp = enemyType.hp
    self.type = ENEMY_TYPE_NAME
    self.speed = math.random(minSpeed, maxSpeed)
    self.shieldColliderSize = enemyType.shieldColliderSize

    self:setupExplosionAnimation()

    self.enemyBaseImage = gfx.image.new(enemyType.baseImagePath)
    self:setImage(self.enemyBaseImage)

    self:setupShieldCollider()

    self:setupHitAnimator()

    self:setStartingPosition()
    self:add()
    self:setupPatroling()
end

function Enemy:update()
    if self.exploding then
        return
    end

    if not IS_GAME_ACTIVE then
        return
    end

    self:move()
end

function Enemy:setupExplosionAnimation()
    local imageTable = self.enemyType.explosionImageTable
    self.explosionSprite = AnimatedSprite.new(imageTable)
    self.explosionSpriteHeight = imageTable:getImage(1).height
    self.explosionSprite:addState("exploding", nil, nil, {tickStep = explosionAnimationFPS})
    self.explosionSprite.states.exploding.loop = explosionAnimationLoopCount
    self.exploding = false
    self.explosionSprite.states.exploding.onAnimationEndEvent = function (self)
        self:remove()
    end
end

function Enemy:setupPatroling()
    self:setNewPatrolPoint()
    self.segmentPatrolTimer = CrankTimer(math.random(minPatrolSegmentDuration, maxPatrolSegmentDuration), true, function()
        self:setNewPatrolPoint()
    end, true)
    self.totalPatrolTimer = CrankTimer(math.random(minTotalPatrolDuration, maxTotalPatrolDuration), true, function()
        if #ACTIVE_TARGETS > 0 then
            self:setTarget()
        else
            self:setVelocity(self.x, 440)
        end
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
        local target = collisions[i].other
        if target.type == GUN_TYPE_NAME then
            target:getHit()
            self:explode(target)
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

function Enemy:explode(target)
    self:setVisible(false)

    -- magic number 220, might want to revisit
    self.explosionSprite:moveTo(target.x, 220 - self.explosionSpriteHeight / 2)
    self.explosionSprite:playAnimation()
    self.exploding = true
end

function Enemy:setupShieldCollider()
    local shieldColliderSize = self.shieldColliderSize
    local shieldColliderOrigin = self.width / 2 - shieldColliderSize / 2
    self:setCollideRect(shieldColliderOrigin, shieldColliderOrigin, shieldColliderSize,
        shieldColliderSize)
    self:setGroups(ENEMY_GROUP)
    self:setCollidesWithGroups({ BULLET_GROUP, GUN_GROUP })
end

function Enemy:setupHitAnimator()
    self.hitAnimator = pd.timer.new(hitAnimationDuration)
    self.hitAnimator.discardOnCompletion = false
    self.hitAnimator:pause()
    self.hitAnimator.timerEndedCallback = function(timer)
        self:setVisible(true)
    end
end

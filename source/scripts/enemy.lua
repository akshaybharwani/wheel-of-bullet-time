import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/debrisManager"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Enemy").extends(gfx.sprite)

local minSpeed, maxSpeed = 2, 6
local explosionDuration = 1000
local hitDuration = 100

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

    local startX = math.random(self.width / 2, MAX_SCREEN_WIDTH - self.width / 2)
    local startY = self.height / 2
    self:moveTo(startX, startY)
    self:add()
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

function Enemy:move()
    local nextX, nextY        = self.x, self.y + (self.speed * DELTA_TIME * 10)
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

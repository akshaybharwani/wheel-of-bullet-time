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

function Enemy:init(enemyType)
    Enemy.super.init(self)

    self.hp = enemyType.hp
    self.type = "enemy"
    self.speed = math.random(minSpeed, maxSpeed)

    self.explosionSprite = gfx.sprite.new(gfx.image.new(enemyType.explosionImagePath))

    self.hitAnimator = pd.timer.new(hitDuration)
    self.hitAnimator.discardOnCompletion = false
    self.hitAnimator:pause()
    self.hitAnimator.timerEndedCallback = function(timer)
        self.enemyBaseImage:setInverted(false)
        self.isHit = false
    end

    self.enemyBaseImage = gfx.image.new(enemyType.baseImagePath)
    self:setImage(self.enemyBaseImage)
    self:setCollideRect(0, 0, enemyType.shieldColliderSize, enemyType.shieldColliderSize)

    local startX = math.random(self.width / 2, maxScreenWidth - self.width / 2)
    local startY = self.height / 2
    self:moveTo(startX, startY)
    self:add()
end

function Enemy:update()
    if self.explosionAnimator then
        return
    end

    if self.isHit then
        self.enemyBaseImage:setInverted(true)
    end

    if pd.getCrankChange() == 0 then
        return
    end

    self:move()
end

function Enemy:move()
    local nextX, nextY        = self.x, self.y + (pd.getFPS() * self.speed * deltaTime)
    local _, _, collisions, _ = self:moveWithCollisions(nextX, nextY)

    for i = 1, #collisions do
        local other = collisions[i].other
        if other.type == "gun-element" then
            other:getHit()
            self:explode()
            return
        end
    end

    if self.y > maxScreenHeight then
        self:remove()
    end
end

function Enemy:getHit()
    self.hp -= 1
    if self.hp <= 0 then
        self:shatter()
    else
        self.hitAnimator:start()
        self.isHit = true
    end
end

function Enemy:shatter()
    -- TODO: create debris objects
    spawnDebris(self.x, self.y)
    self:remove()
end

function Enemy:explode()
    self.explosionAnimator = pd.timer.new(explosionDuration)
    self.explosionAnimator.discardOnCompletion = true
    self.explosionAnimator.timerEndedCallback = function(timer)
        self:remove()
        self.explosionSprite:remove()
    end
    self.explosionSprite:moveTo(self.x, self.y)
    self.explosionSprite:add()
    self:setVisible(false)
end

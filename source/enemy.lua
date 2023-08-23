import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

local maxScreenWidth = pd.display.getWidth()
local maxScreenHeight = pd.display.getHeight()

class("Enemy").extends(gfx.sprite)

local minSpeed, maxSpeed = 2, 6

enemyA = {
    hp = 1,
    attackColliderSize = 22,
    shieldColliderSize = 26,
    baseImagePath = "images/enemy_a",
    explostionImagePath = "images/enemy_explosionattack_a" }

function Enemy:init(enemyType)
    Enemy.super.init(self)

    self.hp = enemyType.hp
    self.type = "enemy"
    self.speed = math.random(minSpeed, maxSpeed)

    self:setImage(gfx.image.new(enemyType.baseImagePath))
    self:setCollideRect(0, 0, enemyType.attackColliderSize, enemyType.attackColliderSize)

    local startX = math.random(self.width / 2, maxScreenWidth - self.width / 2)
    local startY = 0
    self:moveTo(startX, startY)
    self:add()
end

function Enemy:update()
    if pd.getCrankChange() == 0 then
        return
    end

    local nextX, nextY        = self.x, self.y + self.speed
    local _, _, collisions, _ = self:moveWithCollisions(nextX, nextY)

    --[[ if self.x < 0 or self.x > 400 or self.y < 0 or self.y > 240 or self.removeme then
        self:explode()
    end ]]
end

function Enemy:getHit()
    self.hp -= 1
    if self.hp <= 0 then
        self:explode()
    else
        -- make enemy blink quickly to show hit
    end
end

function Enemy:explode()
    -- TODO: show explosion animation
    self:remove()
end

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Enemy").extends(gfx.sprite)

local minSpeed, maxSpeed = 2, 6

function Enemy:init(enemyType)
    Enemy.super.init(self)

    self.hp = enemyType.hp
    self.type = "enemy"
    self.speed = math.random(minSpeed, maxSpeed)

    self:setImage(gfx.image.new(enemyType.baseImagePath))
    self:setCollideRect(0, 0, enemyType.shieldColliderSize, enemyType.shieldColliderSize)

    local startX = math.random(self.width / 2, maxScreenWidth - self.width / 2)
    local startY = self.height / 2
    self:moveTo(startX, startY)
    self:add()
end

function Enemy:update()
    if pd.getCrankChange() == 0 then
        return
    end

    local nextX, nextY        = self.x, self.y + self.speed
    local _, _, collisions, _ = self:moveWithCollisions(nextX, nextY)

    for i = 1, #collisions do
        local other = collisions[i].other
        if other.type == "target" then
            other:getHit()
            self:explode()
            return
        end
    end
end

function Enemy:getHit()
    self.hp -= 1
    if self.hp <= 0 then
        self:shatter()
    else
        -- TODO: make enemy blink quickly to show hit
    end
end

function Enemy:shatter()
    -- TODO: create debris objects
    self:remove()
end

function Enemy:explode()
    -- TODO: show explosion animation
    self:remove()
end

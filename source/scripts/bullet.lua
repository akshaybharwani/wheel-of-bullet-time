import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Bullet").extends(gfx.sprite)

local bulletSpeed = 16
local bulletTrailDistance = 8

function Bullet:init(startX, startY, angle)
    Bullet.super.init(self)

    -- need to subract 90 as the default angle of the gun is up
    self.angleRad = math.rad(angle - 90)
    self.dx = bulletSpeed * math.cos(self.angleRad)
    self.dy = bulletSpeed * math.sin(self.angleRad)

    self:setImage(gfx.image.new("images/bullet_body"))
    self:setCollideRect(0, 0, self:getSize())
    self:moveTo(startX, startY)
    self:add()

    self.bulletTrailSprite = gfx.sprite.new(gfx.image.new("images/bullet_trail"))
    self.bulletTrailSprite:moveTo(startX - bulletTrailDistance * math.cos(self.angleRad),
        startY - bulletTrailDistance * math.sin(self.angleRad))
    self.bulletTrailSprite:add()
end

function Bullet:update()
    if pd.getCrankChange() == 0 then
        return
    end

    local nextX, nextY  = self.x + self.dx, self.y + self.dy
    local _, _, collisions, _ = self:moveWithCollisions(nextX, nextY)
    self.bulletTrailSprite:moveTo(nextX - bulletTrailDistance * math.cos(self.angleRad),
        nextY - bulletTrailDistance * math.sin(self.angleRad))

    for i = 1, #collisions do
        local other = collisions[i].other
        if other.type == "enemy" then
            other:getHit()
            self:removeBullet()
            return
        end
    end

    if self.x < 0 or self.x > 400 or self.y < 0 or self.y > 240 or self.removeme then
        self:removeBullet()
    end
end

function Bullet:removeBullet()
    self.bulletTrailSprite:remove()
    self:remove()
end

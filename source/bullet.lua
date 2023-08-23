import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

--#region playdate essential constants
local pd <const> = playdate
local gfx <const> = pd.graphics
--#endregion

class("Bullet").extends(gfx.sprite)

local bulletSpeed = 5

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

    local nextX, nextY  = self.x + self.dx, self.y + self.dy
    local _, _, collisions, _ = self:moveWithCollisions(nextX, nextY)
    self.bulletTrailSprite:moveTo(nextX - bulletTrailDistance * math.cos(self.angleRad),
        nextY - bulletTrailDistance * math.sin(self.angleRad))
    --[[ for i = 1, #collisions do
        if collisions[i].other:getTag() == kLeftWallTag then
            rightScore += 1
            self:moveTo(screenWidth / 2, screenHeight / 2)
            pointSound:playNote("C5", 1, 0.5)
            return
        elseif collisions[i].other:getTag() == kRightWallTag then
            leftScore += 1
            self:moveTo(screenWidth / 2, screenHeight / 2)
            pointSound:playNote("C5", 1, 0.5)
            return
        end

        if collisions[i].normal.x ~= 0 then
            bounceSound:playNote("G4", 1, 0.2)
            self.xSpeed *= -1
        end

        if collisions[i].normal.y ~= 0 then
            bounceSound:playNote("G4", 1, 0.2)
            self.ySpeed *= -1
        end
    end ]]
end

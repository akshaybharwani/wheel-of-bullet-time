local pd <const> = playdate
local gfx <const> = pd.graphics

class("Bullet").extends(gfx.sprite)

local bulletConstants = BULLET_CONSTANTS

local bulletBodyImagePath = "images/gun/bullet_body"
local bulletTrailImagePath = "images/gun/bullet_trail"

function Bullet:init(shooter, startX, startY, angle)
    Bullet.super.init(self)

    self.shooter = shooter
    self.isGunDisabled = false
    -- need to subract 90 as the default angle of the gun is up
    self.angleRad = math.rad(angle - 90)
    self.dx = bulletConstants.bulletSpeed * math.cos(self.angleRad)
    self.dy = bulletConstants.bulletSpeed * math.sin(self.angleRad)

    self:setImage(gfx.image.new(bulletBodyImagePath))
    self:setCollideRect(0, 0, self:getSize())
    self:setGroups(BULLET_GROUP)
    self:setCollidesWithGroups({ ENEMY_GROUP })
    self:moveTo(startX, startY)
    self:add()

    self.bulletTrailSprite = gfx.sprite.new(gfx.image.new(bulletTrailImagePath))
    self.bulletTrailSprite:moveTo(startX - bulletConstants.bulletTrailDistance * math.cos(self.angleRad),
        startY - bulletConstants.bulletTrailDistance * math.sin(self.angleRad))
    self.bulletTrailSprite:add()

    NOTIFICATION_CENTER:subscribe(NOTIFY_GUN_IS_DISABLED, self, function()
        -- ? remove the bullet or let it move after gun is disabled?
        self.isGunDisabled = true
        self:removeBullet()
    end)
end

function Bullet:update()
    if self.isGunDisabled then
        return
    end

    if IS_GAME_OVER then
        return
    end

    if not IS_GAME_ACTIVE then
        return
    end

    local nextX, nextY  = self.x + self.dx, self.y + self.dy
    local _, _, collisions, _ = self:moveWithCollisions(nextX, nextY)
    self.bulletTrailSprite:moveTo(nextX - bulletConstants.bulletTrailDistance * math.cos(self.angleRad),
        nextY - bulletConstants.bulletTrailDistance * math.sin(self.angleRad))

    for i = 1, #collisions do
        local other = collisions[i].other
        if other.type == ENEMY_TYPE_NAME then
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
    self.shooter:removeBullet(self)
    self.bulletTrailSprite:remove()
    self:remove()
end

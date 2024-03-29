import "scripts/gun/bullet"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Shooter").extends(AnimatedSprite)

CURRENT_BULLET_COUNT = 0
ACTIVE_BULLETS = {}

local gunShooterConstants = GUN_SHOOTER_CONSTANTS
local gunConstants = GUN_CONSTANTS
local maxHP = gunConstants.maxHP
local maxFiringCooldown = gunShooterConstants.maxFiringCooldown / 1000 -- as using DELTA_TIME which is in s and not ms

local imagetablePath = "images/gun/gun_shooting-table-64-64"
local imagetable = gfx.imagetable.new(imagetablePath)

function Shooter:init(gun)
    Shooter.super.init(self, imagetable)
    CURRENT_BULLET_COUNT = 0
    ACTIVE_BULLETS = {}
    self.notifyBulletCountUpdated = NOTIFY_BULLET_COUNT_UPDATED
    self.gunShootingState = GUN_SHOOTING_STATE
    self.currentFiringCooldown = maxFiringCooldown

    self.isGunDisabled = false
    self.gunActivatedSound = SfxPlayer(SFX_FILES.gun_activated)
    self.bulletSound = SfxPlayer(SFX_FILES.gun_bullet)

    self.imagetable = imagetable
    self.gun = gun

    for i = 0, maxHP do
        local stateName = tostring(maxHP - i)
        local firstFrameIndex = i * 3 + 1
        self:addState(stateName, firstFrameIndex, firstFrameIndex + 2,
        {tickStep = gunConstants.animationFPS})
    end

    self:moveTo(gun.x, gun.y)
    self:setZIndex(GUN_Z_INDEX)
    self:playAnimation()
    self:setVisible(false)

    self:subscribeEvents()
end

function Shooter:update()
    -- TODO: too many variants of gunDisabled variables, consolidate

    if GUN_CURRENT_STATE == self.gunShootingState then
        self:updateGunTopSprite()
        self:playShootingSound()
    end

    if self.isGunDisabled then
        return
    end

    if IS_GAME_OVER then
        return
    end

    self:setFiringCooldown()

    if not WAS_GAME_ACTIVE_LAST_CHECK then
        return
    end

    if GUN_CURRENT_STATE == self.gunShootingState then
        self:checkForShootingBullet()
    end
end

function Shooter:subscribeEvents()
    NOTIFICATION_CENTER:subscribe(NOTIFY_GUN_WAS_HIT, self, function()
        self:changeState(tostring(self.gun.currentHP))
        self:updateGunTopSprite()
    end)
    NOTIFICATION_CENTER:subscribe(NOTIFY_GUN_IS_DISABLED, self, function(_)
        self:stopShootingSound()
        self.isGunDisabled = true
    end)
    NOTIFICATION_CENTER:subscribe(NOTIFY_GUN_STATE_CHANGED, self, function(currentState)
        if currentState ~= self.gunShootingState then
            self:stopShootingSound()
            self:setVisible(false)
        end
    end)
end

function Shooter:setFiringCooldown()
    self.currentFiringCooldown = math.max(0, self.currentFiringCooldown - DELTA_TIME)
end

function Shooter:shootBullet(startX, startY, angle)
    local bullet = Bullet(self, startX, startY, angle)
    table.insert(ACTIVE_BULLETS, bullet)
    self.bulletSound:play()
end

function Shooter:checkForShootingBullet()
    if CURRENT_CRANK_SHOOTING_TICKS == 1 then
        if (self.currentFiringCooldown == 0 and CURRENT_BULLET_COUNT > 0) then
            self:shootBullet(self.gun.x, self.gun.y, GUN_CURRENT_ROTATION_ANGLE)
            CURRENT_BULLET_COUNT -= 1
            NOTIFICATION_CENTER:notify(self.notifyBulletCountUpdated)
            self.currentFiringCooldown = maxFiringCooldown
        end
    end
end

function Shooter:updateGunTopSprite()
    self:updateAnimation()
    -- TODO: this seems resource intensive?
    self.gun:setTopSprite(self.imagetable:getImage(self:getCurrentFrameIndex()))
end

function Shooter:playShootingSound()
    if not self.gunActivatedSound:isPlaying() then
        self.gunActivatedSound:playLooping()
    end
end

function Shooter:stopShootingSound()
    if self.gunActivatedSound:isPlaying() then
        self.gunActivatedSound:stop()
    end
end

function Shooter:removeBullet(bullet)
    for i = 1, #ACTIVE_BULLETS do
        if ACTIVE_BULLETS[i] == bullet then
            table.remove(ACTIVE_BULLETS, i)
            break
        end
    end
end

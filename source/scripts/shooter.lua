import "CoreLibs/crank"
import "CoreLibs/animation"
import "scripts/bullet"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Shooter").extends(gfx.sprite)

local gunShootingAnimationLoop = nil

local maxFiringCooldown = 0.5
local currentFiringCooldown = maxFiringCooldown

local startingBulletCount = 10
CURRENT_BULLET_COUNT = startingBulletCount

-- crank
local angleAcuumulator = 0

function Shooter:init(x, y)
    Shooter.super.init(self)

    self:moveTo(x, y)
    self:setupAnimation()
    self:add()
end

function Shooter:setFiringCooldown()
    currentFiringCooldown = math.max(0, currentFiringCooldown - DELTA_TIME)
end

function Shooter:setupAnimation()
    local animationImageTable = gfx.imagetable.new("images/gun_shooting")
    gunShootingAnimationLoop = gfx.animation.loop.new()
    gunShootingAnimationLoop.paused = true
    gunShootingAnimationLoop:setImageTable(animationImageTable)
end

function Shooter:shootBullet(startX, startY, angle)
    Bullet(startX, startY, angle)
end

function Shooter:checkGunState()
    if (GUN_CURRENT_STATE == GUN_SHOOTING_STATE) then
        gunShootingAnimationLoop.paused = false
        GUN_TOP_SPRITE:setImage(gunShootingAnimationLoop:image())

        if (CURRENT_CRANK_SHOOTING_TICKS == 1) then
            if (currentFiringCooldown == 0 and CURRENT_BULLET_COUNT > 0) then
                self:shootBullet(GUN_BASE_X, GUN_BASE_Y, GUN_CURRENT_ROTATION_ANGLE)
                CURRENT_BULLET_COUNT -= 1
                currentFiringCooldown = maxFiringCooldown
            end
        end
    end
end

function Shooter:update()
    self:setFiringCooldown()

    if not IS_GAME_ACTIVE then
        gunShootingAnimationLoop.paused = true
        return
    end
    self:checkGunState()
end

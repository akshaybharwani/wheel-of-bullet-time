import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/libraries/AnimatedSprite"
import "scripts/gun/bullet"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Shooter").extends(AnimatedSprite)

CURRENT_BULLET_COUNT = 0

local gunShooterConstants = GUN_SHOOTER_CONSTANTS
local gunConstants = GUN_CONSTANTS
local maxFiringCooldown = gunShooterConstants.maxFiringCooldown
local currentFiringCooldown = maxFiringCooldown

local imagetablePath = "images/gun/gun_shooting-table-64-64"
local imagetable = gfx.imagetable.new(imagetablePath)

function Shooter:init(gun)
    Shooter.super.init(self, imagetable)

    self.imagetable = imagetable
    self.gun = gun

    self:moveTo(gun.x, gun.y)
    self:setZIndex(GUN_Z_INDEX)
    self:addState("maxHPState", 1, 3, {tickStep = gunConstants.animationFPS})
    self:playAnimation()
    self:setVisible(false)
end

function Shooter:setFiringCooldown()
    currentFiringCooldown = math.max(0, currentFiringCooldown - DELTA_TIME)
end

function Shooter:shootBullet(startX, startY, angle)
    Bullet(startX, startY, angle)
end

function Shooter:update()
    self:setFiringCooldown()

    if WAS_GAME_ACTIVE_LAST_CHECK then
        if GUN_CURRENT_STATE == GUN_SHOOTING_STATE then
            self:updateAnimation()

            self.gun:setTopSprite(self.imagetable:getImage(self:getCurrentFrameIndex()))

            if (CURRENT_CRANK_SHOOTING_TICKS == 1) then
                if (currentFiringCooldown == 0 and CURRENT_BULLET_COUNT > 0) then
                    self:shootBullet(GUN_BASE_X, GUN_BASE_Y, GUN_CURRENT_ROTATION_ANGLE)
                    CURRENT_BULLET_COUNT -= 1
                    currentFiringCooldown = maxFiringCooldown
                end
            end
        else
            self:setVisible(false)
        end
    end
end

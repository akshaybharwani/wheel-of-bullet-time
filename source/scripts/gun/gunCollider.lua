local pd <const> = playdate
local gfx <const> = pd.graphics

class('GunCollider').extends(gfx.sprite)

local gunConstants = GUN_CONSTANTS

local colliderSizeX = gunConstants.colliderSizeX
local colliderSizeY = gunConstants.colliderSizeY
local colliderPosition = gunConstants.colliderPosition

function GunCollider:init(gun)
    GunCollider.super.init(self)
    self.gun = gun
    self.type = GUN_TYPE_NAME
    self:setBounds(GUN_BASE_X - colliderPosition, GUN_BASE_Y - colliderPosition,
    colliderSizeX, colliderSizeY)
    self:setCollideRect(0, 0, colliderSizeX, colliderSizeY)
    self:setGroups(GUN_GROUP)
    self:setCollidesWithGroups({ ENEMY_GROUP })
    self:moveTo(GUN_BASE_X, GUN_BASE_Y)
    self:add()
    table.insert(ACTIVE_TARGETS, self.colliderSprite)
end

function GunCollider:getHit()
    if self.gun.currentHP > 0 then
        self.gun.currentHP -= 1
        NOTIFICATION_CENTER:notify(NOTIFY_GUN_WAS_HIT)
    end
    if self.gun.currentHP <= 0 then
        self.gun.available = false
        self:clearCollideRect()
        for i = 1, #ACTIVE_TARGETS do
            if ACTIVE_TARGETS[i] == self then
                table.remove(ACTIVE_TARGETS, i)
                break
            end
        end
    end
end
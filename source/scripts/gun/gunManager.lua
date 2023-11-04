import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/gun/shooter"
import "scripts/gun/vacuum"
import "scripts/recycler/recyclerManager"
import "scripts/gun/bulletDisplay"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('GunManager').extends(gfx.sprite)

local gunMaxRotationAngle = 85
local gunRotationSpeed = 3 -- Screen updates 30 times per second by default

local gunPadding = 20

-- TODO: should be a better way to maintain these variables
GUN_BASE_SIZE = 64
GUN_BASE_X, GUN_BASE_Y = 0, 0
GUN_CURRENT_ROTATION_ANGLE = 0
RECYCLER_SIZE = 32

GUN_NEUTRAL_STATE, GUN_SHOOTING_STATE, GUN_VACUUM_STATE = 0, 1, 2
GUN_CURRENT_STATE = GUN_NEUTRAL_STATE

CURRENT_CRANK_SHOOTING_TICKS = 0

ACTIVE_TARGETS = {}

WAS_GUN_ROTATED = false

local crankShootingTicks = 10 -- for every 360 ÷ ticksPerRevolution. So every 36 degrees for 10 ticksPerRevolution

local maxHP = GUN_CONSTANTS.maxHP

local gunTopDefaultImagePath = "images/gun/gun_top_default"
local gunBaseImagePath = "images/gun/base"

function GunManager:init()
    GunManager.super.init(self)

    self.type = GUN_TYPE_NAME
    self.hp = maxHP

    -- draw common gunBase Image
    local gunBaseImage = gfx.image.new(gunBaseImagePath)
    self.gunBaseSprite = gfx.sprite.new(gunBaseImage)

    GUN_BASE_X = MAX_SCREEN_WIDTH / 2
    GUN_BASE_Y = MAX_SCREEN_HEIGHT - (self.gunBaseSprite.width / 2)

    self.gunBaseSprite:moveTo(GUN_BASE_X, GUN_BASE_Y)
    self.gunBaseSprite:setZIndex(GUN_Z_INDEX)

    -- HACK: this should not be refering to a direct image
    local gunTopDefaultImage = gfx.image.new(gunTopDefaultImagePath)
    self:setImage(gunTopDefaultImage)
    self:setCollideRect(0, 0, self:getSize())
    self:setGroups(GUN_GROUP)
    self:setCollidesWithGroups({ ENEMY_GROUP })
    table.insert(ACTIVE_TARGETS, self)
    self:moveTo(GUN_BASE_X, GUN_BASE_Y)
    self:setZIndex(GUN_Z_INDEX)

    self:add()
    self.gunBaseSprite:add()

    Shooter(self)
    Vacuum(self)
    BulletDisplay()
end

function isOverlappingGunElements(pairs, x, gunStartX, gunEndX)
    -- logic to check if it doesn't overlap gun base
    if (x - RECYCLER_SIZE / 2 <= gunEndX + gunPadding
            and x + RECYCLER_SIZE / 2 >= gunStartX - gunPadding) then
        return true
    end

    for _, pair in ipairs(pairs) do
        local distanceBetweenX = math.abs(pair.x - x)
        if distanceBetweenX < RECYCLER_SIZE then
            return true
        end
    end
    return false
end

function GunManager:update()
    self:readRotationInput()

    if IS_GAME_ACTIVE then
        local crankChange = pd.getCrankChange()
        -- should update this to use an angle accumulator for more accuracy
        CURRENT_CRANK_SHOOTING_TICKS = pd.getCrankTicks(crankShootingTicks)

        if (crankChange > 0) then
            GUN_CURRENT_STATE = GUN_SHOOTING_STATE
        elseif (crankChange < 0) then
            GUN_CURRENT_STATE = GUN_VACUUM_STATE
        end
    end

    -- runtime rotation is very expensive
    -- this will change when we have pre-rendered rotated sprites
    if WAS_GUN_ROTATED then
        self:setRotation(GUN_CURRENT_ROTATION_ANGLE)
    end
end

function GunManager:readRotationInput()
    WAS_GUN_ROTATED = false
    if pd.buttonIsPressed("RIGHT") then
        if (GUN_CURRENT_ROTATION_ANGLE < gunMaxRotationAngle) then
            WAS_GUN_ROTATED = true
            GUN_CURRENT_ROTATION_ANGLE += gunRotationSpeed
        end
    elseif pd.buttonIsPressed("LEFT") then
        if (GUN_CURRENT_ROTATION_ANGLE > -gunMaxRotationAngle) then
            WAS_GUN_ROTATED = true
            GUN_CURRENT_ROTATION_ANGLE -= gunRotationSpeed
        end
    end
end

function GunManager:setTopSprite(sprite)
    self:setImage(sprite)
end

-- TODO: could consolidate methods like getHit for 'gun-element's in a base class

function GunManager:getHit()
    if self.hp > 0 then
        self.hp -= 1
    end
    if self.hp <= 0 then
        for i = 1, #ACTIVE_TARGETS do
            if ACTIVE_TARGETS[i] == self then
                table.remove(ACTIVE_TARGETS, i)
                break
            end
        end
    end

    print(self.hp)
end

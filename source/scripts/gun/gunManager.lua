import "scripts/gun/shooter"
import "scripts/gun/vacuum"
import "scripts/recycler/recyclerManager"
import "scripts/gun/bulletDisplay"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('GunManager').extends(gfx.sprite)

-- TODO: should be a better way to maintain these variables
GUN_BASE_SIZE = 64
GUN_BASE_X, GUN_BASE_Y = 0, 0
RECYCLER_SIZE = 32

GUN_NEUTRAL_STATE, GUN_SHOOTING_STATE, GUN_VACUUM_STATE = 0, 1, 2
GUN_CURRENT_STATE = GUN_NEUTRAL_STATE
GUN_CURRENT_ROTATION_ANGLE = 0
CURRENT_CRANK_SHOOTING_TICKS = 0
ACTIVE_TARGETS = {}
-- TODO: change to Signal events
WAS_GUN_ROTATED = false

local crankShootingTicks = 10 -- for every 360 ÷ ticksPerRevolution. So every 36 degrees for 10 ticksPerRevolution

local gunTopDefaultImagePath = "images/gun/gun_top_default"
local gunBaseImagePath = "images/gun/base"

local gunConstants = GUN_CONSTANTS

local maxRotationAngle = gunConstants.maxRotationAngle
local rotationSpeed = gunConstants.rotationSpeed -- Screen updates 30 times per second by default
local maxHP = gunConstants.maxHP

local gunPadding = 20

function GunManager:init()
    GunManager.super.init(self)
    CURRENT_CRANK_SHOOTING_TICKS = 0
    WAS_GUN_ROTATED = false
    ACTIVE_TARGETS = {}
    GUN_CURRENT_STATE = GUN_NEUTRAL_STATE
    GUN_CURRENT_ROTATION_ANGLE = 0

    self.gunTurningSound = SfxPlayer(SFX_FILES.gun_turning)

    self.type = GUN_TYPE_NAME
    self.available = true
    self.currentHP = maxHP

    -- draw common gunBase Image
    local gunBaseImage = gfx.image.new(gunBaseImagePath)
    self.gunBaseSprite = gfx.sprite.new(gunBaseImage)

    GUN_BASE_X = SCREEN_WIDTH / 2
    GUN_BASE_Y = SCREEN_HEIGHT - (self.gunBaseSprite.width / 2)

    -- HACK: this should not be refering to a direct image
    local gunTopDefaultImage = gfx.image.new(gunTopDefaultImagePath)

    self.gunBaseSprite:moveTo(GUN_BASE_X, GUN_BASE_Y)
    self.gunBaseSprite:setZIndex(GUN_Z_INDEX)

    self:setImage(gunTopDefaultImage)
    self:setCollideRect(0, 0, self:getSize())
    self:setGroups(GUN_GROUP)
    self:setCollidesWithGroups({ ENEMY_GROUP })
    self:moveTo(GUN_BASE_X, GUN_BASE_Y)
    self:setZIndex(GUN_Z_INDEX)

    self:add()
    self.gunBaseSprite:add()

    table.insert(ACTIVE_TARGETS, self)

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
    if IS_GUN_DISABLED or IS_GAME_OVER then
        return
    end
    
    if not IS_GAME_SETUP_DONE then
        return
    end

    self:readRotationInput()

    -- TODO: revisit this. not sure if this is entirely correct according to specs
    if IS_GAME_ACTIVE then
        local crankChange = pd.getCrankChange()
        -- should update this to use an angle accumulator for more accuracy
        CURRENT_CRANK_SHOOTING_TICKS = pd.getCrankTicks(crankShootingTicks)

        if crankChange > 0 and GUN_CURRENT_STATE ~= GUN_SHOOTING_STATE then
            GUN_CURRENT_STATE = GUN_SHOOTING_STATE
            NOTIFICATION_CENTER:notify(NOTIFY_GUN_STATE_CHANGED, GUN_SHOOTING_STATE)
        elseif crankChange < 0 and GUN_CURRENT_STATE ~= GUN_VACUUM_STATE then
            GUN_CURRENT_STATE = GUN_VACUUM_STATE
            NOTIFICATION_CENTER:notify(NOTIFY_GUN_STATE_CHANGED, GUN_VACUUM_STATE)
        elseif crankChange == 0 and GUN_CURRENT_STATE ~= GUN_NEUTRAL_STATE then
            GUN_CURRENT_STATE = GUN_NEUTRAL_STATE
            NOTIFICATION_CENTER:notify(NOTIFY_GUN_STATE_CHANGED, GUN_NEUTRAL_STATE)
        end
    end

    -- runtime rotation is very expensive
    -- this will change when we have pre-rendered rotated sprites
    if WAS_GUN_ROTATED then
        if not self.gunTurningSound:isPlaying() then
            self.gunTurningSound:play()
        end
        self:setRotation(GUN_CURRENT_ROTATION_ANGLE)
    else
        if self.gunTurningSound:isPlaying() then
            self.gunTurningSound:stop()
        end
    end
end

function GunManager:readRotationInput()
    WAS_GUN_ROTATED = false
    if pd.buttonIsPressed(pd.kButtonRight) then
        if (GUN_CURRENT_ROTATION_ANGLE < maxRotationAngle) then
            WAS_GUN_ROTATED = true
            GUN_CURRENT_ROTATION_ANGLE += rotationSpeed
        end
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
        if (GUN_CURRENT_ROTATION_ANGLE > -maxRotationAngle) then
            WAS_GUN_ROTATED = true
            GUN_CURRENT_ROTATION_ANGLE -= rotationSpeed
        end
    end
end

function GunManager:setTopSprite(sprite)
    self:setImage(sprite)
end

-- TODO: could consolidate methods like getHit for 'gun-element's in a base class

function GunManager:getHit()
    if self.currentHP > 0 then
        self.currentHP -= 1
        NOTIFICATION_CENTER:notify(NOTIFY_GUN_WAS_HIT)
    end
    if self.currentHP <= 0 then
        self.available = false
        self:clearCollideRect()
        for i = 1, #ACTIVE_TARGETS do
            if ACTIVE_TARGETS[i] == self then
                table.remove(ACTIVE_TARGETS, i)
                break
            end
        end
    end
end

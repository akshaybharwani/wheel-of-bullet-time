import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/shooter"
import "scripts/vacuum"
import "scripts/recyclerManager"
import "scripts/bulletDisplay"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('GunManager').extends(gfx.sprite)

local gunMaxRotationAngle = 85
local gunRotationSpeed = 3 -- Screen updates 30 times per second by default

-- TODO: should be a better way to maintain these variables
GUN_BASE_SIZE = 64
GUN_BASE_X, GUN_BASE_Y = 0, 0
GUN_CURRENT_ROTATION_ANGLE = 0
RECYCLER_SIZE = 32

GUN_NEUTRAL_STATE, GUN_SHOOTING_STATE, GUN_VACUUM_STATE = 0, 1, 2
GUN_CURRENT_STATE = GUN_NEUTRAL_STATE

CURRENT_CRANK_SHOOTING_TICKS = 0

GUN_TOP_SPRITE = nil

local crankShootingTicks = 10 -- for every 360 ÷ ticksPerRevolution. So every 36 degrees for 10 ticksPerRevolution

function GunManager:init()
    GunManager.super.init(self)

    -- draw common gunBase Image
    local gunBaseImage = gfx.image.new("images/base")
    self:setImage(gunBaseImage)
    GUN_BASE_X = MAX_SCREEN_WIDTH / 2
    GUN_BASE_Y = MAX_SCREEN_HEIGHT - (self.width / 2)
    self:moveTo(GUN_BASE_X, GUN_BASE_Y)
    self:add()

    GUN_TOP_SPRITE = gfx.sprite.new()
    GUN_TOP_SPRITE:moveTo(GUN_BASE_X, GUN_BASE_Y)
    GUN_TOP_SPRITE:add()

    Shooter(GUN_BASE_X, GUN_BASE_Y)
    Vacuum(GUN_BASE_X, GUN_BASE_Y)
    BulletDisplay()
end

function isOverlappingGunElements(pairs, x, gunStartX, gunEndX)
    -- logic to check if it doesn't overlap gun base
    if (x - RECYCLER_SIZE / 2 <= gunEndX
            and x + RECYCLER_SIZE / 2 >= gunStartX) then
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
    if GUN_TOP_SPRITE then
        GUN_TOP_SPRITE:setRotation(GUN_CURRENT_ROTATION_ANGLE)
    end
end

function GunManager:readRotationInput()
    if pd.buttonIsPressed("RIGHT") then
        if (GUN_CURRENT_ROTATION_ANGLE < gunMaxRotationAngle) then
            GUN_CURRENT_ROTATION_ANGLE += gunRotationSpeed
        end
    elseif pd.buttonIsPressed("LEFT") then
        if (GUN_CURRENT_ROTATION_ANGLE > -gunMaxRotationAngle) then
            GUN_CURRENT_ROTATION_ANGLE -= gunRotationSpeed
        end
    end
end

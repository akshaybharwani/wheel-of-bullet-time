import "CoreLibs/crank"
import "CoreLibs/animation"

local pd <const> = playdate
local gfx <const> = pd.graphics

local maxScreenWidth = 400
local maxScreenHeight = 240

-- weopon
local weaponBaseSprite = nil

local weaponBaseSize = 64
local weaponBaseX, weaponBaseY = nil, nil

local weaponShootingAnimationLoop = nil

local weaponHeadRotationAngle = 0

local weaponMaxAngle = 85
local weaponRotationSpeed = 3 -- Screen updates 30 times per second by default

-- crank
local crankShootingTicks = 10

-- bullet
local bulletSpeed = 16

function setupWeapon()
    drawWeapon()
end

function drawWeapon()
    -- Weapon base
    local weaponBaseImage = gfx.image.new("images/base")
    assert(weaponBaseImage)
    weaponBaseSprite = gfx.sprite.new(weaponBaseImage)
    weaponBaseX = maxScreenWidth / 2
    weaponBaseY = maxScreenHeight - (weaponBaseSize / 2)
    weaponBaseSprite:moveTo(weaponBaseX, weaponBaseY)
    weaponBaseSprite:add()

    -- Weapon Shooting Animation
    local weaponShootingImageTable = gfx.imagetable.new("images/gun_shooting")
    weaponShootingAnimationLoop = gfx.animation.loop.new()
    weaponShootingAnimationLoop.paused = true
    weaponShootingAnimationLoop:setImageTable(weaponShootingImageTable)

    -- TODO: Weapon Vaccum Animation
end

function updateWeaponHead()
    if pd.buttonIsPressed("RIGHT") then
        if (weaponHeadRotationAngle < weaponMaxAngle) then
            weaponHeadRotationAngle += weaponRotationSpeed
        end
    elseif pd.buttonIsPressed("LEFT") then
        if (weaponHeadRotationAngle > -weaponMaxAngle) then
            weaponHeadRotationAngle -= weaponRotationSpeed
        end
    end

    --[[ local centerX, centerY = maxScreenWidth / 2, maxScreenHeight - weaponBaseSize

    local pointX, pointY = 200, 180
    local rotationAngle = math.rad(weaponHeadRotationAngle)

    -- Rotate the point around the center by the specified angle
    local rotatedX, rotatedY = rotatePoint(pointX, pointY, centerX, centerY, rotationAngle)

    -- Use the rotated coordinates to draw the line
    gfx.drawLine(centerX, centerY, rotatedX, rotatedY) ]]

    local currentShootingImage = weaponShootingAnimationLoop:image()
    currentShootingImage:drawRotated(weaponBaseX, weaponBaseY, weaponHeadRotationAngle)

    -- Get Crank input
    local currentCrankPosition = pd.getCrankPosition()
    local currentCrankShootingTicks = pd.getCrankTicks(crankShootingTicks)
    if (currentCrankShootingTicks == 1) then
        weaponShootingAnimationLoop.paused = false
        -- shoot(weaponBaseX, weaponBaseY, rotationAngle)
        print("shoot" .. tostring(currentCrankPosition))
    elseif (currentCrankShootingTicks == -1) then
        weaponShootingAnimationLoop.paused = true
        print("vaccum" .. tostring(currentCrankPosition))
    else
        weaponShootingAnimationLoop.paused = true
    end
end

function shoot(x, y, angle)
    local bulletImage = gfx.image.new("images/bullet_body")
    assert(bulletImage)
    local bulletSprite = gfx.sprite.new(bulletImage)
    bulletSprite:moveTo(x, y + 1)
    -- bulletSprite:setVelocity(bulletSpeed, bulletSpeed)
    bulletSprite:add()
end

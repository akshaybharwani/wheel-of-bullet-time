import "CoreLibs/crank"
import "CoreLibs/animation"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- gun
local gunBaseSprite = nil
local gunBaseSize = 64
local gunBaseX, gunBaseY = nil, nil

local gunVacuumAnimationLoop = nil
local gunShootingAnimationLoop = nil

local gunHeadRotationAngle = 0

local gunMaxAngle = 85
local gunRotationSpeed = 3 -- Screen updates 30 times per second by default

-- crank
local crankShootingTicks = 10

-- bullet
local bulletSpeed = 16

function setupGun()
    drawGun()
    setupGunAnimation()
end

function drawGun()
    drawGunBase()
end

function drawGunBase()
    local gunBaseImage = gfx.image.new("images/base")
    assert(gunBaseImage)
    gunBaseSprite = gfx.sprite.new(gunBaseImage)
    gunBaseX = maxScreenWidth / 2
    gunBaseY = maxScreenHeight - (gunBaseSize / 2)
    gunBaseSprite:moveTo(gunBaseX, gunBaseY)
    gunBaseSprite:add()
end

function setupGunAnimation()
    -- Gun Shooting Animation
    local animationImageTable = gfx.imagetable.new("images/gun_shooting")
    gunShootingAnimationLoop = gfx.animation.loop.new()
    gunShootingAnimationLoop.paused = true
    gunShootingAnimationLoop:setImageTable(animationImageTable)

    -- Gun Vaccum Animation
    animationImageTable = gfx.imagetable.new("images/gun_vacuum")
    gunVacuumAnimationLoop = gfx.animation.loop.new()
    gunVacuumAnimationLoop.paused = true
    gunVacuumAnimationLoop:setImageTable(animationImageTable)
end

function updateGunHead()
    -- read Gun Input
    if pd.buttonIsPressed("RIGHT") then
        if (gunHeadRotationAngle < gunMaxAngle) then
            gunHeadRotationAngle += gunRotationSpeed
        end
    elseif pd.buttonIsPressed("LEFT") then
        if (gunHeadRotationAngle > -gunMaxAngle) then
            gunHeadRotationAngle -= gunRotationSpeed
        end
    end

    local currentShootingImage = gunShootingAnimationLoop:image()
    currentShootingImage:drawRotated(gunBaseX, gunBaseY, gunHeadRotationAngle)

    -- Get Crank input
    local currentCrankPosition = pd.getCrankPosition()
    local currentCrankShootingTicks = pd.getCrankTicks(crankShootingTicks)
    if (currentCrankShootingTicks == 1) then
        gunShootingAnimationLoop.paused = false
        gunVacuumAnimationLoop.paused = true
        -- shoot(gunBaseX, gunBaseY, rotationAngle)
        -- print("shoot" .. tostring(currentCrankPosition))
    elseif (currentCrankShootingTicks == -1) then
        gunShootingAnimationLoop.paused = true
        gunVacuumAnimationLoop.paused = false
        -- print("vaccum" .. tostring(currentCrankPosition))
    else
        gunShootingAnimationLoop.paused = true
        gunVacuumAnimationLoop.paused = true
    end
end

function shoot(x, y, angle)
    local bulletImage = gfx.image.new("images/bullet_body")
    assert(bulletImage)
    local bulletSprite = gfx.sprite.new(bulletImage)
    bulletSprite:moveTo(x, y + 1)
    bulletSprite:add()
end

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

local gunRotationAngle = 0

local gunMaxRotationAngle = 85
local gunRotationSpeed = 3 -- Screen updates 30 times per second by default

-- crank
local lastCrankPosition = nil
local crankShootingTicks = 10 -- for every 360 ÷ ticksPerRevolution. So every 36 degrees for 10 ticksPerRevolution
local crankChangeTimeDivisor = 10 -- this will be divided from the current FPS

-- bullet
local bulletSpeed = 16

function setupGun()
    setupCrankInputTimer()
    drawGun()
    setupGunAnimation()
end

function setupCrankInputTimer()
    local crankTimer = pd.frameTimer.new(pd.getFPS() / crankChangeTimeDivisor)
    crankTimer.repeats = true
    crankTimer.updateCallback = readCrankInput
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

function updateGun()
    readRotationInput()
end

function readRotationInput()
    if pd.buttonIsPressed("RIGHT") then
        if (gunRotationAngle < gunMaxRotationAngle) then
            gunRotationAngle += gunRotationSpeed
        end
    elseif pd.buttonIsPressed("LEFT") then
        if (gunRotationAngle > -gunMaxRotationAngle) then
            gunRotationAngle -= gunRotationSpeed
        end
    end
end

function readCrankInput(crankTimer)
    local currentCrankPosition = pd.getCrankPosition()
    local crankChange = pd.getCrankChange()
    local currentCrankShootingTicks = pd.getCrankTicks(crankShootingTicks)

    local gunTopImage = gunShootingAnimationLoop:image()

    if (currentCrankPosition ~= lastCrankPosition) then
        if (crankChange > 0) then
            gunTopImage = gunShootingAnimationLoop:image()
        else
            gunTopImage = gunVacuumAnimationLoop:image()
        end
        lastCrankPosition = currentCrankPosition
    else
        -- TODO: what to show when there is no crank change?
    end

    gunTopImage:drawRotated(gunBaseX, gunBaseY, gunRotationAngle)

    if (currentCrankShootingTicks == 1) then
        gunShootingAnimationLoop.paused = false
        gunVacuumAnimationLoop.paused = true
        -- shoot(gunBaseX, gunBaseY, rotationAngle)
        -- print("shoot" .. tostring(currentCrankPosition))
    elseif (currentCrankShootingTicks == -1) then
        gunShootingAnimationLoop.paused = true
        gunVacuumAnimationLoop.paused = false
        -- print("vacuum" .. tostring(currentCrankPosition))
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

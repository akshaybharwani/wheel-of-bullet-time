import "CoreLibs/crank"
import "CoreLibs/animation"
import "scripts/bullet"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- gun
local gunVacuumAnimationLoop = nil
local gunShootingAnimationLoop = nil

local gunCurrentRotationAngle = 0
local gunMaxRotationAngle = 85
local gunRotationSpeed = 3 -- Screen updates 30 times per second by default

local maxFiringCooldown = 0.5
local currentFiringCooldown = maxFiringCooldown

-- crank
local lastCrankPosition = nil
local crankShootingTicks = 10 -- for every 360 ÷ ticksPerRevolution. So every 36 degrees for 10 ticksPerRevolution
local crankChangeTimeDivisor = 10 -- this will be divided from the current FPS

function setFiringCooldown()
    currentFiringCooldown = math.max(0, currentFiringCooldown - deltaTime)
end

function drawGunBase()
    local gunBaseImage = gfx.image.new("images/base")
    assert(gunBaseImage)
    local gunBaseSprite = gfx.sprite.new(gunBaseImage)
    gunBaseX = maxScreenWidth / 2
    gunBaseY = maxScreenHeight - (gunBaseSprite.width / 2)
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

function readRotationInput()
    if pd.buttonIsPressed("RIGHT") then
        if (gunCurrentRotationAngle < gunMaxRotationAngle) then
            gunCurrentRotationAngle += gunRotationSpeed
        end
    elseif pd.buttonIsPressed("LEFT") then
        if (gunCurrentRotationAngle > -gunMaxRotationAngle) then
            gunCurrentRotationAngle -= gunRotationSpeed
        end
    end
end

local function shootBullet(startX, startY, angle)
    local bullet = Bullet(startX, startY, angle)
end

local function readCrankInput(crankTimer)
    local currentCrankPosition = pd.getCrankPosition()
    local crankChange = pd.getCrankChange()
    local currentCrankShootingTicks = pd.getCrankTicks(crankShootingTicks)

    local gunTopImage = gunShootingAnimationLoop:image() -- the Gun top toggles between Vacuum and

    if (currentCrankPosition ~= lastCrankPosition) then
        if (crankChange > 0) then
            gunTopImage = gunShootingAnimationLoop:image()
            gunShootingAnimationLoop.paused = false
            gunVacuumAnimationLoop.paused = true
        else
            gunTopImage = gunVacuumAnimationLoop:image()
            gunShootingAnimationLoop.paused = true
            gunVacuumAnimationLoop.paused = false
        end
    else
        gunShootingAnimationLoop.paused = true
        gunVacuumAnimationLoop.paused = true
    end
    lastCrankPosition = currentCrankPosition
    gunTopImage:drawRotated(gunBaseX, gunBaseY, gunCurrentRotationAngle)

    if (currentCrankShootingTicks == 1) then
        if (currentFiringCooldown == 0) then
            shootBullet(gunBaseX, gunBaseY, gunCurrentRotationAngle)
            currentFiringCooldown = maxFiringCooldown
        end
    elseif (currentCrankShootingTicks == -1) then
        -- vacuum action
    end
end

function setupCrankInputTimer()
    local crankTimer = pd.frameTimer.new(pd.getFPS() / crankChangeTimeDivisor)
    crankTimer.repeats = true
    crankTimer.updateCallback = readCrankInput
end

import "CoreLibs/crank"
import "CoreLibs/animation"
import "scripts/bullet"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Gun").extends(gfx.sprite)

-- gun
local gunVacuumAnimationLoop = nil
local gunShootingAnimationLoop = nil

local maxFiringCooldown = 0.5
local currentFiringCooldown = maxFiringCooldown

-- crank
local lastCrankPosition = nil
local angleAcuumulator = 0
local crankShootingTicks = 10 -- for every 360 ÷ ticksPerRevolution. So every 36 degrees for 10 ticksPerRevolution
local crankCheckWaitDuration = 100

-- vacuum
local vacuumAreaWidth = 32
local vacuumSprite = nil

function Gun:init()
    Gun.super.init(self)

    local gunBaseImage = gfx.image.new("images/base")
    self:setImage(gunBaseImage)
    gunBaseX = maxScreenWidth / 2
    gunBaseY = maxScreenHeight - (self.width / 2)
    self:moveTo(gunBaseX, gunBaseY)
    self:add()

    self:setupVacuumArea()
    self:setupCrankInputTimer()
    self:setupGunAnimation()
end

function Gun:setFiringCooldown()
    currentFiringCooldown = math.max(0, currentFiringCooldown - deltaTime)
end

function Gun:setupVacuumArea()
    local vacuumImage = gfx.image.new(vacuumAreaWidth, 180)
    gfx.pushContext(vacuumImage)
        gfx.drawRect(0, 0, vacuumAreaWidth, 180)
    gfx.popContext()
    vacuumSprite = gfx.sprite.new(vacuumImage)
    vacuumSprite:moveTo(maxScreenWidth / 2, 120 - 32)
end

function Gun:setupGunAnimation()
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

local function shootBullet(startX, startY, angle)
    Bullet(startX, startY, angle)
end

local function vacuum()
    -- rotate vacuum with the gun
    -- refactor gun and everything gun related to be easy to work with
    vacuumSprite:setRotation(gunCurrentRotationAngle)
    vacuumSprite:add()
    -- calculate current vacuum area based on gun's rotation
    -- show vacuum graphics
        -- show additional vacuum animations
    -- check for debris objects overlapping the area
    -- show animation of debris collection
end

local function readCrankInput(crankTimer)
    local currentCrankPosition = pd.getCrankPosition()
    local crankChange = pd.getCrankChange()
    local currentCrankShootingTicks = pd.getCrankTicks(crankShootingTicks)

    local gunTopImage = gunShootingAnimationLoop:image() -- the Gun top toggles between Vacuum and

    if (currentCrankPosition ~= lastCrankPosition) then
        if (crankChange > 0) then
            vacuumSprite:remove()
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
        -- vacuum()
    end
end

function Gun:setupCrankInputTimer()
    local crankTimer = pd.frameTimer.new(crankCheckWaitDuration)
    crankTimer.repeats = true
    crankTimer.updateCallback = readCrankInput
end

function Gun:update()
    Gun:setFiringCooldown()
end

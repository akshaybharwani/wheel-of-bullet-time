import "CoreLibs/crank"

local pd <const> = playdate
local gfx <const> = pd.graphics

local maxScreenWidth = 400
local maxScreenHeight = 240

local weaponBaseSize = 20
local weaponHeadRotationAngle

local weaponMaxAngle = 85
-- Screen updates 30 times per second by default
local weaponRotationSpeed = 3

-- crank
local crankShootingTicks = 10

function createWeaponHead()
    weaponHeadRotationAngle = 0
end

function updateWeaponHead()
    -- Draw Weapon
    gfx.fillRect((maxScreenWidth - weaponBaseSize) / 2,
        maxScreenHeight - weaponBaseSize,
        weaponBaseSize,
        weaponBaseSize)

    if pd.buttonIsPressed("RIGHT") then
        if (weaponHeadRotationAngle < weaponMaxAngle) then
            weaponHeadRotationAngle += weaponRotationSpeed
        end
    elseif pd.buttonIsPressed("LEFT") then
        if (weaponHeadRotationAngle > -weaponMaxAngle) then
            weaponHeadRotationAngle -= weaponRotationSpeed
        end
    end

    local pointX, pointY = 200, 180
    local centerX, centerY = maxScreenWidth / 2, maxScreenHeight - weaponBaseSize

    local rotationAngle = math.rad(weaponHeadRotationAngle)

    -- Rotate the point around the center by the specified angle
    local rotatedX, rotatedY = rotatePoint(pointX, pointY, centerX, centerY, rotationAngle)

    -- Use the rotated coordinates to draw the line
    gfx.drawLine(centerX, centerY, rotatedX, rotatedY)

    -- Get Crank input

    local currentCrankPosition = pd.getCrankPosition()
    local currentCrankShootingTicks = pd.getCrankTicks(crankShootingTicks)
    if (currentCrankShootingTicks == 1) then
        print("shoot" .. tostring(currentCrankPosition))
    elseif (currentCrankShootingTicks == -1) then
        print("vaccum" .. tostring(currentCrankPosition))
    end


end

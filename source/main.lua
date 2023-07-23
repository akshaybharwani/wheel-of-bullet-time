import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geometry <const> = pd.geometry

-- local playerX, playerY = 200, 120
-- local playerRadius = 10
-- local playerSpeed = 3

-- WeaponSize
local weaponBaseSize = 20

local maxScreenWidth = 400
local maxScreenHeight = 240

function pd.update()
    gfx.clear()
	-- Update stuff every frame
    gfx.sprite.update()
    pd.timer.updateTimers()

    -- local crankAngle = math.rad(pd.getCrankPosition())
    -- playerX += math.sin(crankAngle) * playerSpeed
    -- playerY -= math.cos(crankAngle) * playerSpeed

	-- Draw Weapon
    gfx.fillRect((maxScreenWidth - weaponBaseSize) / 2,
        maxScreenHeight - weaponBaseSize,
        weaponBaseSize, weaponBaseSize)
    -- Given points and angle
    local pointX, pointY = 200, 180
    local centerX, centerY = maxScreenWidth / 2, maxScreenHeight - weaponBaseSize
    local crankPosition = pd.getCrankPosition()
    if crankPosition > 85 and crankPosition < 270 then
        crankPosition = 85
    elseif crankPosition < 270 and crankPosition > 85 then
        crankPosition = 270
    end

    local rotationAngle = math.rad(crankPosition)

    if rotationAngle > 85 then
        rotationAngle = 85
    elseif rotationAngle < -85 then
        rotationAngle = -85
    end

    -- Rotate the point around the center by the specified angle
    local rotatedX, rotatedY = rotatePoint(pointX, pointY, centerX, centerY, rotationAngle)

    -- Use the rotated coordinates to draw the line
    gfx.drawLine(centerX, centerY, rotatedX, rotatedY)
end

-- Function to rotate a point (x, y) around another point (cx, cy) by a specified angle (in radians)
function rotatePoint(x, y, cx, cy, angle)
    local cosAngle = math.cos(angle)
    local sinAngle = math.sin(angle)
    local dx = x - cx
    local dy = y - cy

    -- Calculate the new coordinates after rotation
    local rotatedX = cx + dx * cosAngle - dy * sinAngle
    local rotatedY = cy + dx * sinAngle + dy * cosAngle

    return rotatedX, rotatedY
end

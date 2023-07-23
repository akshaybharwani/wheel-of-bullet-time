import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "weapon"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geometry <const> = pd.geometry

-- local playerX, playerY = 200, 120
-- local playerRadius = 10
-- local playerSpeed = 3

createWeaponHead()

function pd.update()
    gfx.clear()
	-- Update stuff every frame
    gfx.sprite.update()
    pd.timer.updateTimers()

    updateWeaponHead()
    pd.drawFPS(x, y)
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

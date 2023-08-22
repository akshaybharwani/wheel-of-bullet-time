import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "weapon"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geometry <const> = pd.geometry

function setupGame()
    pd.ui.crankIndicator:start()

    local backgroundImage = gfx.image.new("images/background_01")
    if assert(backgroundImage) then
        gfx.sprite.setBackgroundDrawingCallback(
            function(x, y, width, height)
                backgroundImage:draw(0, 0)
            end
        )
    end

    setupWeapon()
end

setupGame()

function pd.update()
    gfx.clear()
    -- Update stuff every frame
    gfx.sprite.update()
    -- This needs to be called after the sprites are updated
    if pd.isCrankDocked() then
        pd.ui.crankIndicator:update()
    end
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

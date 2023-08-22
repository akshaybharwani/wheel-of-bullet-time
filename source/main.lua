import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "gun"

maxScreenWidth = 400
maxScreenHeight = 240

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

    setupGun()
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

    updateGunHead()
    pd.drawFPS(x, y)
end

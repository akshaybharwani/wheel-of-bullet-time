import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/frameTimer"
import "scripts/enemyManager"
import "scripts/gunManager"

local pd <const> = playdate
local gfx <const> = pd.graphics

deltaTime = 0

maxScreenWidth = pd.display.getWidth()
maxScreenHeight = pd.display.getHeight()

local function setupBackground()
    local backgroundImage = gfx.image.new("images/background_01")
    if assert(backgroundImage) then
        gfx.sprite.setBackgroundDrawingCallback(
            function(x, y, width, height)
                backgroundImage:draw(0, 0)
            end
        )
    end
end

local function setupGame()
    pd.ui.crankIndicator:start()

    setupBackground()
    setupGun()
    setupEnemySpawn()
end

setupGame()

function pd.update()
    deltaTime = pd.getElapsedTime()
    pd.resetElapsedTime()
    gfx.clear()
    -- Update stuff every frame
    gfx.sprite.update()
    -- This needs to be called after the sprites are updated
    if pd.isCrankDocked() then
        pd.ui.crankIndicator:update()
    end
    pd.timer.updateTimers()
    pd.frameTimer.updateTimers()
    pd.drawFPS(x, y)
    updateGun()
end

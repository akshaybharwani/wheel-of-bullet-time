import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/frameTimer"
import "scripts/background"
import "scripts/enemyManager"
import "scripts/gunManager"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- globals
DELTA_TIME = 0
IS_GAME_ACTIVE = false

MAX_SCREEN_WIDTH = pd.display.getWidth()
MAX_SCREEN_HEIGHT = pd.display.getHeight()

PLAYER_GROUP = 1
ENEMY_GROUP = 2
DEBRIS_GROUP = 3

local lastCrankPosition = nil
local crankCheckWaitDuration = 100

local function checkCrankInput()
    local currentCrankPosition = pd.getCrankPosition()
    if lastCrankPosition ~= currentCrankPosition then
        IS_GAME_ACTIVE = true
    end
    lastCrankPosition = currentCrankPosition
end

local function setupCrankCheckTimer()
    local crankTimer = pd.timer.new(crankCheckWaitDuration)
    crankTimer.repeats = true
    crankTimer.timerEndedCallback = function(timer)
        checkCrankInput()
    end
end

local function setupGame()
    math.randomseed(pd.getSecondsSinceEpoch())
    pd.resetElapsedTime()
    pd.ui.crankIndicator:start()
    setupCrankCheckTimer()

    Background()
    GunManager()
    local debrisManager = DebrisManager()
    -- is this the best way to do this?
    EnemyManager(debrisManager)
end

setupGame()

function pd.update()
    DELTA_TIME = pd.getElapsedTime()
    pd.resetElapsedTime()

    pd.timer.updateTimers()
    gfx.sprite.update()

    -- gfx.clear()
    -- Update stuff every frame
    -- This needs to be called after the sprites are updated
    --[[ if pd.isCrankDocked() then
        pd.ui.crankIndicator:update()
    end ]]
    -- pd.drawFPS(x, y)

    -- reset game state after updating everything
    if IS_GAME_ACTIVE then
        IS_GAME_ACTIVE = false
    end
end

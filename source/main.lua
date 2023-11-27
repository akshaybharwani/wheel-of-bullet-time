import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/frameTimer"
import "scripts/background/background"
import "scripts/enemyManager"
import "scripts/gun/gunManager"
import "scripts/background/opening"
import "scripts/libraries/Signal"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- globals

NOTIFICATION_CENTER = Signal()

-- TODO: assuming FPS is constant 30, majorly used by AnimatedSprite
CONSTANT_FPS = 30

DELTA_TIME = 0
-- if crank was moved this frame based on crankCheckWaitDuration, this is true
IS_GAME_ACTIVE = false
-- as the crankCheckWaitDuration is non-zero, the animation relying on IS_GAME_ACTIVE will
-- continously won't work properly, this can be used to help with that
WAS_GAME_ACTIVE_LAST_CHECK = false

CURRENT_BULLET_COUNT = 0

MAX_SCREEN_WIDTH = pd.display.getWidth()
MAX_SCREEN_HEIGHT = pd.display.getHeight()

PLAYER_GROUP = 1
ENEMY_GROUP = 2
DEBRIS_GROUP = 3
BULLET_GROUP = 4
GUN_GROUP = 5
VACUUM_GROUP = 6

-- TODO: do we need types _and_ groups? Revisit

GUN_TYPE_NAME = "gun-element"
ENEMY_TYPE_NAME = "enemy"
DEBRIS_TYPE_NAME = "debris"

BACKGROUND_Z_INDEX = -100
GUN_Z_INDEX = 100
UI_Z_INDEX = 101

NOTIFY_INITIAL_DEBRIS_COLLECTED = "initialDebrisCollected"
NOTIFY_BULLET_COUNT_UPDATED = "bulletCountUpdate"

local titleConstants = TITLE_CONSTANTS
local titleDuration = titleConstants.titleDuration

-- TODO: change to use Signal event

WAS_GUN_HIT = false

local lastCrankPosition = nil
local crankCheckWaitDuration = 100

local function checkCrankInput()
    local currentCrankPosition = pd.getCrankPosition()
    if lastCrankPosition ~= currentCrankPosition then
        IS_GAME_ACTIVE = true
        WAS_GAME_ACTIVE_LAST_CHECK = true
    elseif WAS_GAME_ACTIVE_LAST_CHECK then
        WAS_GAME_ACTIVE_LAST_CHECK = false
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

    local gunManager = GunManager()
    local recyclerManager = RecyclerManager(gunManager)
    local debrisManager = DebrisManager(recyclerManager)
    NOTIFICATION_CENTER:subscribe(NOTIFY_INITIAL_DEBRIS_COLLECTED, self, function()
        -- TODO: is assigning a manager to initialization of another manager a good idea?
        EnemyManager(debrisManager)
    end)
    Opening(titleDuration, debrisManager)
    Background(titleDuration)
end

setupGame()

function pd.update()
    --gfx.clear()

    DELTA_TIME = pd.getElapsedTime()
    pd.resetElapsedTime()

    pd.timer.updateTimers()
    gfx.sprite.update()
    -- Update stuff every frame
    -- This needs to be called after the sprites are updated
    --[[ if pd.isCrankDocked() then
        pd.ui.crankIndicator:update()
    end ]]
    pd.drawFPS(x, y)

    -- reset game state after updating everything
    if IS_GAME_ACTIVE then
        IS_GAME_ACTIVE = false
    end

    -- TODO: change to use Signal event
    if WAS_GUN_HIT then
        WAS_GUN_HIT = false
    end
end

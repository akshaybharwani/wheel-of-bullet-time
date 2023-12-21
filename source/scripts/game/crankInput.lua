local pd <const> = playdate
local gfx <const> = pd.graphics

class('CrankInput').extends(gfx.sprite)

GAME_ACTIVE_ELAPSED_SECONDS = 0

local coreGameConstants = CORE_GAME_CONSTANTS
local crankCheckWaitDuration = coreGameConstants.crankCheckWaitDuration

function CrankInput:init()
    GAME_ACTIVE_ELAPSED_SECONDS = 0
    self.lastCrankPosition = nil
    self:setupCrankCheckTimer()
    NOTIFICATION_CENTER:subscribe(NOTIFY_GUN_IS_DISABLED, self, function(_)
        self.crankInputTimer:remove()
    end)
    self:add()
end

function CrankInput:checkCrankInput()
    local currentCrankPosition = pd.getCrankPosition()
    if self.lastCrankPosition ~= currentCrankPosition then
        if IS_GAME_STARTED then
            GAME_ACTIVE_ELAPSED_SECONDS += DELTA_TIME
        end
        IS_GAME_ACTIVE = true
        WAS_GAME_ACTIVE_LAST_CHECK = true
    elseif WAS_GAME_ACTIVE_LAST_CHECK then
        WAS_GAME_ACTIVE_LAST_CHECK = false
    end
    self.lastCrankPosition = currentCrankPosition
end

function CrankInput:setupCrankCheckTimer()
    self.crankInputTimer = pd.timer.new(crankCheckWaitDuration)
    self.crankInputTimer.repeats = true
    self.crankInputTimer.timerEndedCallback = function(timer)
        self:checkCrankInput()
    end
end
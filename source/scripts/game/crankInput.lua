local pd <const> = playdate
local gfx <const> = pd.graphics

class('CrankInput').extends(gfx.sprite)

GAME_ACTIVE_ELAPSED_SECONDS = 0

local coreGameConstants = CORE_GAME_CONSTANTS
local crankCheckWaitDuration = coreGameConstants.crankCheckWaitDuration

local lastCrankPosition = nil

function CrankInput:init()
    self:setupCrankCheckTimer()
    self:add()
end

function CrankInput:update()
    if IS_GAME_OVER then
        self.crankInputTimer:remove()
    end
end

function CrankInput:checkCrankInput()
    local currentCrankPosition = pd.getCrankPosition()
    if lastCrankPosition ~= currentCrankPosition then
        if IS_GAME_SETUP_DONE then
            GAME_ACTIVE_ELAPSED_SECONDS += DELTA_TIME
        end
        IS_GAME_ACTIVE = true
        WAS_GAME_ACTIVE_LAST_CHECK = true
    elseif WAS_GAME_ACTIVE_LAST_CHECK then
        WAS_GAME_ACTIVE_LAST_CHECK = false
    end
    lastCrankPosition = currentCrankPosition
end

function CrankInput:setupCrankCheckTimer()
    self.crankInputTimer = pd.timer.new(crankCheckWaitDuration)
    self.crankInputTimer.repeats = true
    self.crankInputTimer.timerEndedCallback = function(timer)
        self:checkCrankInput()
    end
end
import "scripts/game/storedDataManager"

local pd <const> = playdate
local gfx <const> = pd.graphics

local utils <const> = UTILITIES

class('GameOver').extends(gfx.sprite)

local gameOverConstants = GAME_OVER_CONSTANTS
local gameOverScoreNumberPadding = 2

local gameOverImagePath = "images/gameover"

local scorePosX = 253
local currentScorePosY = 48
local highScoreStartingPosY = 95
local highScoreYPadding = 1

function GameOver:init()
    GameOver.super.init(self)
    self.resultsAreShown = false
    self.gameOverSound = SfxPlayer(SFX_FILES.game_over)
    self:setImage(gfx.image.new(gameOverImagePath))
    self:setupWaitingToShowResultsTimer()
    self:setupGameOverText()

    -- TODO: would need to move this to a more central place when complexity increases
    self.storedDataManager = StoredDataManager()
    self:moveTo(HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT)
    self:setZIndex(BANNER_Z_INDEX)
    self:add()
    self:setVisible(false)
end

function GameOver:update()
    if self.resultsAreShown then
        if utils.checkActionButtonInput() then
            gfx.sprite.removeAll()
            GameSetup()
        end
    end

    if IS_GAME_OVER then
        return
    end

    if IS_GAME_STARTED then
        if DEBRIS_NOT_RECYCLED_COUNT <= 0 and CURRENT_BULLET_COUNT <= 0 then
            self.gameOverSound:play()
            IS_GAME_OVER = true
            self.gameOverTextSprite:setVisible(true)
            self.waitToShowResultsTimer:start()
        end
    end
end

function GameOver:setupWaitingToShowResultsTimer()
    self.waitToShowResultsTimer = pd.timer.new(gameOverConstants.waitToShowResultsDuration)
    self.waitToShowResultsTimer:pause()
    self.waitToShowResultsTimer.timerEndedCallback = function(timer)
        self:showResults()
    end
end

function GameOver:setupGameOverText()
    local gameOverText = "Game Over"
    local gameOverTextWidth, gameOverTextHeight = gfx.getTextSize(gameOverText)
    local gameOverTextImage = gfx.image.new(gameOverTextWidth, gameOverTextHeight)

    gfx.pushContext(gameOverTextImage)
        gfx.drawText(gameOverText, 0, 0)
    gfx.popContext()
    self.gameOverTextSprite = gfx.sprite.new(gameOverTextImage)
    self.gameOverTextSprite:setZIndex(UI_Z_INDEX)
    self.gameOverTextSprite:moveTo(HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT)
    self.gameOverTextSprite:add()
    self.gameOverTextSprite:setVisible(false)
end


function GameOver:showResults()
    self:setVisible(true)
    local numberWidth = utils.numbersTimeFirstImage.width
    local numberHeight = utils.numbersTimeFirstImage.height
    local halfNumberWidth = numberWidth / 2
    local halfNumberHeight = numberHeight / 2
    local gameOverScoreZIndex = BANNER_Z_INDEX + 1
    local highScores = self.storedDataManager:saveGameData()
    local minutes, seconds = utils.secondsToMinutesAndSeconds(GAME_ACTIVE_ELAPSED_SECONDS)
    utils.getFormattedTime(minutes, seconds, scorePosX + halfNumberWidth,  currentScorePosY + halfNumberHeight, gameOverScoreZIndex, gameOverScoreNumberPadding)
    local startingPosY = highScoreStartingPosY
    for i = 1, #highScores do
        if highScores[i] ~= nil then
            minutes, seconds = utils.secondsToMinutesAndSeconds(highScores[i])
            local scoreY = startingPosY + ((i - 1) * numberHeight) + halfNumberHeight
            utils.getFormattedTime(minutes, seconds, scorePosX + halfNumberWidth, scoreY, gameOverScoreZIndex, gameOverScoreNumberPadding)
            startingPosY += highScoreYPadding
        end
    end

    local showResultsTimer = pd.timer.new(gameOverConstants.showResultsDuration)
    showResultsTimer.timerEndedCallback = function(timer)
        self.resultsAreShown = true
    end
end
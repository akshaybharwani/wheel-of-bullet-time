local pd <const> = playdate
local gfx <const> = pd.graphics

local utils <const> = UTILITIES

class('TimeDisplay').extends(gfx.sprite)

local uiConstants = UI_CONSTANTS
local numberPadding = uiConstants.numberPadding

local timeDisplayConstants = TIME_DISPLAY_CONSTANTS
local playAnimationFPS = timeDisplayConstants.playAnimationFPS

local playPauseImagePath = "images/ui/UI_time_play3f_pause1f-table-16-16"
local playingAnimationState = "playing"
local pausedAnimationState = "paused"

local numberOfPaddings = 6

local totalTimeDisplayWidth = 80 + (numberPadding * numberOfPaddings)

function TimeDisplay:init()
    self.numbersTimeImagetable = utils.numbersTimeImagetable

    local numberImage = utils.numbersTimeFirstImage
    self.numberWidth = numberImage.width
    self.numberHeight = numberImage.height

    self.minutes = 00
    self.seconds = 00

    self.timeY = self.numberHeight / 2
    self.timeX = HALF_SCREEN_WIDTH - totalTimeDisplayWidth / 2 + self.numberWidth

    local imageTable = gfx.imagetable.new(playPauseImagePath)
    self.playPauseSprite = AnimatedSprite.new(imageTable)
    self.playPauseWidth, _ = imageTable:getImage(1):getSize()
    self.playPauseSprite:addState(playingAnimationState, 1, 3, {tickStep = playAnimationFPS})
    self.playPauseSprite:addState(pausedAnimationState, 4, nil).asDefault()
    self.playPauseSprite:moveTo(self.timeX, self.timeY)
    self.playPauseSprite:playAnimation()

    self.timeX += self.playPauseWidth / 2
    self.leftBracketSprite = utils.getTimeUISprite(17, self.timeX + numberPadding, self.timeY, UI_Z_INDEX)

    self.firstNumberSprite,
    self.secondNumberSprite,
    self.thirdNumberSprite,
    self.fourthNumberSprite = utils.getFormattedTime(self.minutes, self.seconds, self.timeX, self.timeY, UI_Z_INDEX, numberPadding)
    -- ! Hack: figure out a way to do this using the function itself
    local rightBracketPosX = self.timeX + (totalTimeDisplayWidth - (self.numberWidth + self.playPauseWidth)) - numberPadding
    self.rightBracketSprite = utils.getTimeUISprite(18, rightBracketPosX, self.timeY, UI_Z_INDEX)

    self:setBounds(self.timeX + self.numberWidth, 0, self.numberWidth * numberOfPaddings, self.numberHeight)
    self:setZIndex(UI_Z_INDEX - 1)
    self:add()
end

function TimeDisplay:update()
    if not IS_GAME_STARTED then
        return
    end

    if not WAS_GAME_ACTIVE_LAST_CHECK then
        if self.playPauseSprite.currentState ~= pausedAnimationState then
            self.playPauseSprite:changeState(pausedAnimationState)
        end
        return
    end

    if (self.playPauseSprite.currentState ~= playingAnimationState) then
        self.playPauseSprite:changeState(playingAnimationState)
    end

    self:updateClock()
end

function TimeDisplay:draw()
    local firstNumber = utils.getDigit(self.minutes, 2)
    self:updateNumber(self.firstNumberSprite, firstNumber)

    local secondNumber = utils.getDigit(self.minutes, 1)
    self:updateNumber(self.secondNumberSprite, secondNumber)

    local thirdNumber = utils.getDigit(self.seconds, 2)
    self:updateNumber(self.thirdNumberSprite, thirdNumber)

    local fourthNumber = utils.getDigit(self.seconds, 1)
    self:updateNumber(self.fourthNumberSprite, fourthNumber)

    -- black rectangle behind time UI
    gfx.fillRect(0, 0, self.width, self.height)
end

function TimeDisplay:updateNumber(numberSprite, number)
    numberSprite:setImage(self.numbersTimeImagetable:getImage(number + 1))
end

function TimeDisplay:updateClock()
    self.minutes, self.seconds = utils.secondsToMinutesAndSeconds(GAME_ACTIVE_ELAPSED_SECONDS)
    self:draw()
end
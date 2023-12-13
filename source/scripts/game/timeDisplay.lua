local pd <const> = playdate
local gfx <const> = pd.graphics

local utils <const> = UTILITIES

class('TimeDisplay').extends(gfx.sprite)

local uiConstants = UI_CONSTANTS
local numberPadding = uiConstants.numberPadding

local numberOfPaddings = 6

local totalTimeDisplayWidth = 64 + (numberPadding * numberOfPaddings)

function TimeDisplay:init()
    self.numbersTimeImagetable = utils.numbersTimeImagetable

    local numberImage = utils.numbersTimeFirstImage
    self.numberWidth = numberImage.width
    self.numberHeight = numberImage.height

    self.minutes = 00
    self.seconds = 00

    self.timeY = self.numberHeight / 2
    self.timeX = HALF_SCREEN_WIDTH - totalTimeDisplayWidth / 2 + self.numberWidth / 2

    self.leftBracketSprite = utils.getTimeUISprite(17, utils.getPosX(self.timeX, 0, 0), self.timeY)

    self.firstNumberSprite,
    self.secondNumberSprite,
    self.thirdNumberSprite,
    self.fourthNumberSprite = utils.getFormattedTime(self.timeX, self.timeY)
    -- ! Hack: figure out a way to do this using the function itself 
    self.rightBracketSprite = utils.getTimeUISprite(18, self.timeX + (totalTimeDisplayWidth - self.numberWidth) - numberPadding, self.timeY)

    self:setBounds(self.timeX + self.numberWidth , 0, self.numberWidth * numberOfPaddings, self.numberHeight)
    self:setZIndex(UI_Z_INDEX - 1)
    self:add()
end

function TimeDisplay:update()
    if not IS_GAME_SETUP_DONE then
        return
    end

    if not IS_GAME_ACTIVE then
        return
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
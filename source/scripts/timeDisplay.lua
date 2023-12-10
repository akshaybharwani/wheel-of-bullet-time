import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/animator"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local Animator = gfx.animator

class('TimeDisplay').extends(gfx.sprite)

local timeImagePath = "images/ui/UI_time-table-8-16"
local numbersImagePath = "images/ui/UI_numbers-table-8-16"

local gameTimerConstants = GAME_TIMER_CONSTANTS
local uiConstants = UI_CONSTANTS
local numberPadding = uiConstants.numberPadding

local totalTimeDisplayWidth = 48 + (numberPadding * 5)

function TimeDisplay:init()
    self.timeUIImagetable = gfx.imagetable.new(timeImagePath)
    print(self.timeUIImagetable:getLength())
    self.numbersImagetable = gfx.imagetable.new(numbersImagePath)

    self.timeY = gameTimerConstants.posY
    self.timeX = MAX_SCREEN_WIDTH / 2 - totalTimeDisplayWidth / 2
    self.minutes = 00
    self.seconds = 00

    self.numberWidth = self.numbersImagetable:getImage(1).width

    local firstNumber = self:getDigit(self.minutes, 2)
    self.firstNumberSprite = self:getNumberSprite(firstNumber, self.timeX + self.numberWidth)

    local secondNumber = self:getDigit(self.minutes, 1)
    self.secondNumberSprite = self:getNumberSprite(secondNumber, self.timeX + self.numberWidth * 2 + numberPadding)

    self.minuteSprite = self:getTimeUISprite(5, self.timeX + self.numberWidth * 3 + numberPadding * 3)

    local thirdNumber = self:getDigit(self.seconds, 2)
    self.thirdNumberSprite = self:getNumberSprite(thirdNumber, self.timeX + self.numberWidth * 4 + numberPadding * 4)

    local fourthNumber = self:getDigit(self.seconds, 1)
    self.fourthNumberSprite = self:getNumberSprite(fourthNumber, self.timeX + self.numberWidth * 5 + numberPadding * 5)

    self.secondsSprite = self:getTimeUISprite(6, self.timeX + self.numberWidth * 6 + numberPadding * 6)
    self:add()
end

function TimeDisplay:update()
    self:updateClock()
end

function TimeDisplay:draw()
    local firstNumber = self:getDigit(self.minutes, 2)
    self:updateNumber(self.firstNumberSprite, firstNumber)

    local secondNumber = self:getDigit(self.minutes, 1)
    self:updateNumber(self.secondNumberSprite, secondNumber)

    local thirdNumber = self:getDigit(self.seconds, 2)
    self:updateNumber(self.thirdNumberSprite, thirdNumber)

    local fourthNumber = self:getDigit(self.seconds, 1)
    self:updateNumber(self.fourthNumberSprite, fourthNumber)
end

function TimeDisplay:updateNumber(numberSprite, number)
    numberSprite:setImage(self.numbersImagetable:getImage(number + 1))
end

function TimeDisplay:getNumberSprite(number, positionX)
    local numberSprite = gfx.sprite.new(self.numbersImagetable:getImage(number + 1))
    numberSprite:moveTo(positionX, self.timeY)
    numberSprite:setZIndex(UI_Z_INDEX)
    numberSprite:add()
    return numberSprite
end

function TimeDisplay:getTimeUISprite(index, positionX)
    local timeUISprite = gfx.sprite.new(self.timeUIImagetable:getImage(index))
    timeUISprite:moveTo(positionX, self.timeY)
    timeUISprite:setZIndex(UI_Z_INDEX)
    timeUISprite:add()
    return timeUISprite
end

function TimeDisplay:minutesAndSecondsFromMilliseconds(ms)
    local  s <const> = math.floor(ms / 1000) % 60
    local  m <const> = math.floor(ms / (1000 * 60)) % 60
    return m, s
end

function TimeDisplay:addLeadingZero(num)
    if num < 10 then
        return '0'..num
    end
    return num
end

function TimeDisplay:updateClock()
    self.minutes, self.seconds = self:minutesAndSecondsFromMilliseconds(pd.getCurrentTimeMilliseconds())
    --self.minutes, self.seconds = self:addLeadingZero(self.minutes), self:addLeadingZero(self.seconds)
    self:draw()
end

function TimeDisplay:getDigit(num, digit)
	local n = 10 ^ digit
	local n1 = 10 ^ (digit - 1)
	return math.floor((num % n) / n1)
end
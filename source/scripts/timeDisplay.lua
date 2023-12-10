import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('TimeDisplay').extends(gfx.sprite)

local timeImagePath = "images/ui/UI_time-table-8-16"
local numbersImagePath = "images/ui/UI_numbers-table-8-16"

local uiConstants = UI_CONSTANTS
local numberPadding = uiConstants.numberPadding

-- 5 for the number of sprites which are going to require the padding
local totalTimeDisplayWidth = 64 + (numberPadding * 5)

function TimeDisplay:init()
    self.timeUIImagetable = gfx.imagetable.new(timeImagePath)
    self.numbersImagetable = gfx.imagetable.new(numbersImagePath)

    local numberImage = self.numbersImagetable:getImage(1)
    self.numberWidth = numberImage.width
    self.numberHeight = numberImage.height

    self.timeY = self.numberHeight / 2
    self.timeX = MAX_SCREEN_WIDTH / 2 - totalTimeDisplayWidth / 2
    self.minutes = 00
    self.seconds = 00

    self.leftBracketSprite = self:getTimeUISprite(7, self:getPosX(0, 0))

    -- TODO: look into the getDigit function and figure out why 2 is the firstNumber here
    local firstNumber = self:getDigit(self.minutes, 2)
    self.firstNumberSprite = self:getNumberSprite(firstNumber, self:getPosX(1, 0))

    local secondNumber = self:getDigit(self.minutes, 1)
    self.secondNumberSprite = self:getNumberSprite(secondNumber, self:getPosX(2, numberPadding))

    self.minuteSprite = self:getTimeUISprite(5, self:getPosX(3, numberPadding))

    local thirdNumber = self:getDigit(self.seconds, 2)
    self.thirdNumberSprite = self:getNumberSprite(thirdNumber, self:getPosX(4, numberPadding))

    local fourthNumber = self:getDigit(self.seconds, 1)
    self.fourthNumberSprite = self:getNumberSprite(fourthNumber, self:getPosX(5, numberPadding))

    self.secondsSprite = self:getTimeUISprite(6, self:getPosX(6, numberPadding))
    -- ! Hack: figure out a way to do this using the function itself 
    self.rightBracketSprite = self:getTimeUISprite(8, self.timeX + self.numberWidth * 7 + numberPadding * 6)
    
    self:setBounds(self.timeX + self.numberWidth, 0, self.numberWidth * 6, self.numberHeight)
    self:setZIndex(UI_Z_INDEX - 1)
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
    gfx.fillRect(0, 0, self.width, self.height)
end

function TimeDisplay:getPosX(sequencePosition, padding)
    return self.timeX + self.numberWidth * sequencePosition + padding * sequencePosition
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

function TimeDisplay:updateClock()
    self.minutes, self.seconds = self:minutesAndSecondsFromMilliseconds(pd.getCurrentTimeMilliseconds())
    self:draw()
end

function TimeDisplay:getDigit(num, digit)
	local n = 10 ^ digit
	local n1 = 10 ^ (digit - 1)
	return math.floor((num % n) / n1)
end
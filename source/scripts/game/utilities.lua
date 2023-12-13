local pd <const> = playdate
local gfx <const> = pd.graphics

UTILITIES = {}

-- time functions

local uiConstants = UI_CONSTANTS
local numberPadding = uiConstants.numberPadding

local numbersTimeImagePath = "images/ui/UI_numbers_and_time-table-8-16"
UTILITIES.numbersTimeImagetable = gfx.imagetable.new(numbersTimeImagePath)
UTILITIES.numbersTimeFirstImage = UTILITIES.numbersTimeImagetable:getImage(1)
local numberWidth = UTILITIES.numbersTimeFirstImage.width

function UTILITIES.secondsToMinutesAndSeconds(s)
    local m = math.floor(s / 60)
    s = s % 60
    return m, s
end

function UTILITIES.getFormattedTime(startingPositionX, positionY)
    -- TODO: look into the getDigit function and figure out why 2 is the firstNumber here
    local firstNumber = UTILITIES.getDigit(00, 2)
    local firstNumberSprite = UTILITIES.getNumberSprite(firstNumber, UTILITIES.getPosX(startingPositionX, 1, 0), positionY)

    local secondNumber = UTILITIES.getDigit(00, 1)
    local secondNumberSprite = UTILITIES.getNumberSprite(secondNumber, UTILITIES.getPosX(startingPositionX, 2, numberPadding), positionY)

    local minuteSprite = UTILITIES.getTimeUISprite(15, UTILITIES.getPosX(startingPositionX, 3, numberPadding), positionY)

    local thirdNumber = UTILITIES.getDigit(00, 2)
    local thirdNumberSprite = UTILITIES.getNumberSprite(thirdNumber, UTILITIES.getPosX(startingPositionX, 4, numberPadding), positionY)

    local fourthNumber = UTILITIES.getDigit(00, 1)
    local fourthNumberSprite = UTILITIES.getNumberSprite(fourthNumber, UTILITIES.getPosX(startingPositionX, 5, numberPadding), positionY)

    local secondsSprite = UTILITIES.getTimeUISprite(16, UTILITIES.getPosX(startingPositionX, 6, numberPadding), positionY)

    return firstNumberSprite, secondNumberSprite, thirdNumberSprite, fourthNumberSprite
end

function UTILITIES.getNumberSprite(number, positionX, positionY)
    local numberSprite = gfx.sprite.new(UTILITIES.numbersTimeImagetable:getImage(number + 1))
    numberSprite:moveTo(positionX, positionY)
    numberSprite:setZIndex(UI_Z_INDEX)
    numberSprite:add()
    return numberSprite
end

function UTILITIES.getTimeUISprite(index, positionX, positionY)
    local timeUISprite = gfx.sprite.new(UTILITIES.numbersTimeImagetable:getImage(index))
    timeUISprite:moveTo(positionX, positionY)
    timeUISprite:setZIndex(UI_Z_INDEX)
    timeUISprite:add()
    return timeUISprite
end

function UTILITIES.getPosX(startingPositionX, sequencePosition, padding)
    return startingPositionX + numberWidth * sequencePosition + padding * (sequencePosition - 1)
end

function UTILITIES.getDigit(num, digit)
	local n = 10 ^ digit
	local n1 = 10 ^ (digit - 1)
	return math.floor((num % n) / n1)
end
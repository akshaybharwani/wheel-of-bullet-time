local pd <const> = playdate
local gfx <const> = pd.graphics

UTILITIES = {}

-- time functions

local numbersTimeImagePath = "images/ui/UI_numbers_and_time-table-8-16"
UTILITIES.numbersTimeImagetable = gfx.imagetable.new(numbersTimeImagePath)
UTILITIES.numbersTimeFirstImage = UTILITIES.numbersTimeImagetable:getImage(1)
local numberWidth = UTILITIES.numbersTimeFirstImage.width

function UTILITIES.secondsToMinutesAndSeconds(s)
    local m = math.floor(s / 60)
    s = s % 60
    return m, s
end

function UTILITIES.getFormattedTime(minutes, seconds, startingPositionX, positionY, zIndex, numberPadding)
    -- TODO: look into the getDigit function and figure out why 2 is the firstNumber here
    local firstNumber = UTILITIES.getDigit(minutes, 2)
    local firstNumberSprite = UTILITIES.getNumberSprite(firstNumber, UTILITIES.getPosX(startingPositionX, 1, 0), positionY, zIndex)

    local secondNumber = UTILITIES.getDigit(minutes, 1)
    local secondNumberSprite = UTILITIES.getNumberSprite(secondNumber, UTILITIES.getPosX(startingPositionX, 2, numberPadding), positionY, zIndex)

    local minuteSprite = UTILITIES.getTimeUISprite(15, UTILITIES.getPosX(startingPositionX, 3, numberPadding), positionY, zIndex)

    local thirdNumber = UTILITIES.getDigit(seconds, 2)
    local thirdNumberSprite = UTILITIES.getNumberSprite(thirdNumber, UTILITIES.getPosX(startingPositionX, 4, numberPadding), positionY, zIndex)

    local fourthNumber = UTILITIES.getDigit(seconds, 1)
    local fourthNumberSprite = UTILITIES.getNumberSprite(fourthNumber, UTILITIES.getPosX(startingPositionX, 5, numberPadding), positionY, zIndex)

    local secondsSprite = UTILITIES.getTimeUISprite(16, UTILITIES.getPosX(startingPositionX, 6, numberPadding), positionY, zIndex)

    return firstNumberSprite, secondNumberSprite, thirdNumberSprite, fourthNumberSprite
end

function UTILITIES.getNumberSprite(number, positionX, positionY, zIndex)
    local numberSprite = gfx.sprite.new(UTILITIES.numbersTimeImagetable:getImage(number + 1))
    numberSprite:moveTo(positionX, positionY)
    numberSprite:setZIndex(zIndex)
    numberSprite:add()
    return numberSprite
end

function UTILITIES.getTimeUISprite(index, positionX, positionY, zIndex)
    local timeUISprite = gfx.sprite.new(UTILITIES.numbersTimeImagetable:getImage(index))
    timeUISprite:moveTo(positionX, positionY)
    timeUISprite:setZIndex(zIndex)
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
local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local Animator = gfx.animator

local utils <const> = UTILITIES

class('BulletDisplay').extends(gfx.sprite)

local bulletImagePath = "images/ui/UI_bullet_8x16"

local bulletDisplayConstants = BULLET_DISPLAY_CONSTANTS
local uiConstants = UI_CONSTANTS
local numberPadding = uiConstants.numberPadding
local bounceTotalDuration = bulletDisplayConstants.bounceTotalDuration
local bounceHeight = bulletDisplayConstants.bounceHeight

local totalBulletDisplayWidth = 32 + (numberPadding * 2)

local lastBulletCount = CURRENT_BULLET_COUNT

function BulletDisplay:init()

    self.numbersImageTable = utils.numbersTimeImagetable

    self.bulletSprite = gfx.sprite.new(gfx.image.new(bulletImagePath))

    self.bulletSpriteY = SCREEN_HEIGHT - self.bulletSprite.height / 2
    self.bulletSpriteX = HALF_SCREEN_WIDTH - totalBulletDisplayWidth / 2 + self.bulletSprite.width / 2

    self.bulletSprite:moveTo(self.bulletSpriteX, self.bulletSpriteY)
    self.bulletSprite:setZIndex(UI_Z_INDEX)
    self.bulletSprite:add()

    self.bulletCountString = string.format("%03d", CURRENT_BULLET_COUNT)

    self.numberWidth = utils.numbersTimeFirstImage.width

    print(self.bulletSpriteX)
    print(utils.getPosX(self.bulletSpriteX, 1, 0))
    print(utils.getPosX(self.bulletSpriteX, 2, numberPadding))
    print(utils.getPosX(self.bulletSpriteX, 3, numberPadding))

    local firstNumber = string.sub(self.bulletCountString, 1, 1)
    self.firstNumberSprite = utils.getNumberSprite(firstNumber, utils.getPosX(self.bulletSpriteX, 1, 0), self.bulletSpriteY)

    local secondNumber = string.sub(self.bulletCountString, 2, 2)
    self.secondNumberSprite = utils.getNumberSprite(secondNumber, utils.getPosX(self.bulletSpriteX, 2, numberPadding), self.bulletSpriteY)

    local thirdNumber = string.sub(self.bulletCountString, 3, 3)
    self.thirdNumberSprite = utils.getNumberSprite(thirdNumber, utils.getPosX(self.bulletSpriteX, 3, numberPadding), self.bulletSpriteY)
    self:add()

    NOTIFICATION_CENTER:subscribe(NOTIFY_BULLET_COUNT_UPDATED, self, function()
        self:updateCount()
    end)
end

function BulletDisplay:updateCount()
    self.bulletCountString = string.format("%03d", CURRENT_BULLET_COUNT)

    local firstNumber = string.sub(self.bulletCountString, 1, 1)
    if firstNumber ~= 0 then
        self:updateNumber(self.firstNumberSprite, firstNumber)
    end

    local secondNumber = string.sub(self.bulletCountString, 2, 2)
    if secondNumber ~= 0 then
        self:updateNumber(self.secondNumberSprite, secondNumber)
    end

    local thirdNumber = string.sub(self.bulletCountString, 3, 3)
    if thirdNumber ~= 0 then
        self:updateNumber(self.thirdNumberSprite, thirdNumber)
    end

    lastBulletCount = CURRENT_BULLET_COUNT
end

function BulletDisplay:updateNumber(numberSprite, number)
    numberSprite:setImage(self.numbersImageTable:getImage(number + 1))
    if (numberSprite.bounceAnimator) then
        if (numberSprite.bounceAnimator:progress() == 1) then
            numberSprite.bounceAnimator = self:getBounceAnimator(numberSprite.x, numberSprite.y)
            numberSprite:setAnimator(numberSprite.bounceAnimator)
        end
    else
        numberSprite.bounceAnimator = self:getBounceAnimator(numberSprite.x, numberSprite.y)
        numberSprite:setAnimator(numberSprite.bounceAnimator)
    end
end

function BulletDisplay:getBounceAnimator(x, y)
    local endPoint
    if (lastBulletCount < CURRENT_BULLET_COUNT) then
        endPoint = geo.point.new(x, y - bounceHeight)
    else
        endPoint = geo.point.new(x, y + bounceHeight)
    end
    local startPoint = geo.point.new(x, y)
    local bounceAnimator = Animator.new(bounceTotalDuration, startPoint, endPoint)
    bounceAnimator.reverses = true
    return bounceAnimator
end

function BulletDisplay:getNumberSprite(number, positionX)
    local numberSprite = gfx.sprite.new(self.numbersImageTable:getImage(number + 1))
    numberSprite:moveTo(positionX, self.bulletSpriteY)
    numberSprite:setZIndex(UI_Z_INDEX)
    numberSprite:add()
    return numberSprite
end
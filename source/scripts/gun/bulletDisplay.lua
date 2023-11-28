import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/animator"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry
local Animator = gfx.animator

class('BulletDisplay').extends(gfx.sprite)

local bulletImagePath = "images/ui/UI_bullet_8x16"
local numbersImagePath = "images/ui/UI_numbers-table-8-16"

local totalBulletDisplayWidth = 34

local bulletDisplayConstants = BULLET_DISPLAY_CONSTANTS
local numberPadding = bulletDisplayConstants.numberPadding
local bounceTotalDuration = bulletDisplayConstants.bounceTotalDuration
local bounceHeight = bulletDisplayConstants.bounceHeight

function BulletDisplay:init()
    self.numbersImageTable = gfx.imagetable.new(numbersImagePath)

    self.bulletSprite = gfx.sprite.new(gfx.image.new(bulletImagePath))

    self.bulletSpriteY = MAX_SCREEN_HEIGHT - self.bulletSprite.height / 2
    self.bulletSpriteX = MAX_SCREEN_WIDTH / 2 + self.bulletSprite.width / 2 - (totalBulletDisplayWidth / 2)

    self.bulletSprite:moveTo(self.bulletSpriteX, self.bulletSpriteY)
    self.bulletSprite:setZIndex(UI_Z_INDEX)
    self.bulletSprite:add()

    self.bulletCountString = string.format("%03d", CURRENT_BULLET_COUNT)

    local firstNumber = string.sub(self.bulletCountString, 1, 1)
    self.firstNumberSprite = self:getNumberSprite(firstNumber, self.bulletSpriteX + self.bulletSprite.width)

    local secondNumber = string.sub(self.bulletCountString, 2, 2)
    self.secondNumberSprite = self:getNumberSprite(secondNumber, self.bulletSpriteX + self.bulletSprite.width * 2 + numberPadding)

    local thirdNumber = string.sub(self.bulletCountString, 3, 3)
    self.thirdNumberSprite = self:getNumberSprite(thirdNumber, self.bulletSpriteX + self.bulletSprite.width * 3 + numberPadding * 2)
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
    local startPoint = geo.point.new(x, y)
    local endPoint = geo.point.new(x, y - bounceHeight)
    local bounceAnimator = Animator.new(bounceTotalDuration, startPoint, endPoint, pd.easingFunctions.inCubic)
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
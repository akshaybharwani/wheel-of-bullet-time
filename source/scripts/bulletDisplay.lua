local pd <const> = playdate
local gfx <const> = pd.graphics

class('BulletDisplay').extends(gfx.sprite)

local bulletImagePath = "images/ui/UI_bullet_8x16"
local numbersImagePath = "images/ui/UI_numbers-table-8-16"

local totalBulletDisplayWidth = 34

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
    self.firstNumber = self:getNumberSprite(firstNumber, self.bulletSpriteX + self.bulletSprite.width)

    local secondNumber = string.sub(self.bulletCountString, 2, 2)
    self.secondNumber = self:getNumberSprite(secondNumber, self.bulletSpriteX + self.bulletSprite.width * 2 + BULLET_DISPLAY_CONSTANTS.numberPadding)

    local thirdNumber = string.sub(self.bulletCountString, 3, 3)
    self.thirdNumber = self:getNumberSprite(thirdNumber, self.bulletSpriteX + self.bulletSprite.width * 3 + BULLET_DISPLAY_CONSTANTS.numberPadding * 2)
    self:add()
end

function BulletDisplay:update()
    self.bulletCountString = string.format("%03d", CURRENT_BULLET_COUNT)

    local firstNumber = string.sub(self.bulletCountString, 1, 1)
    if firstNumber ~= 0 then
        --self.timer
        self.firstNumber:setImage(self.numbersImageTable:getImage(firstNumber + 1))
    end

    local secondNumber = string.sub(self.bulletCountString, 2, 2)
    if secondNumber ~= 0 then
        self.secondNumber:setImage(self.numbersImageTable:getImage(secondNumber + 1))
    end

    local thirdNumber = string.sub(self.bulletCountString, 3, 3)
    if thirdNumber ~= 0 then
        self.thirdNumber:setImage(self.numbersImageTable:getImage(thirdNumber + 1))
    end
end

function BulletDisplay:getNumberSprite(number, positionX)
    local numberSprite = gfx.sprite.new(self.numbersImageTable:getImage(number + 1))
    numberSprite:moveTo(positionX, self.bulletSpriteY)
    numberSprite:setZIndex(UI_Z_INDEX)
    numberSprite:add()
    return numberSprite
end
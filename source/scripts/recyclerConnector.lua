import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry

class("RecyclerConnector").extends(gfx.sprite)

local connectorWidth = 3
local verticalConnectorAnimatorTime = 1000
local horizontalConnectorAnimatorTime = 1000

function RecyclerConnector:init(recycler, connectorY)
    -- TODO: very complicated to look at. Revisit to improve

    -- NOTE: Tried to change this logic to use drawLine instead as it would have the ease of accessing
    -- coordinates of different connectors for animators, but it didn't seem to work.
    -- Line would not show up. Revisit.
    self.connectorY = connectorY
    self.recycler = recycler
    if (recycler.isLeftToGun) then
        self.connnectorX = recycler.x + RECYCLER_SIZE / 2
        self.connectorLength = math.abs(self.connnectorX - (GUN_BASE_X - GUN_BASE_SIZE / 2))
    else
        self.connnectorX = GUN_BASE_X + GUN_BASE_SIZE / 2
        self.connectorLength = math.abs(self.connnectorX - (recycler.x - RECYCLER_SIZE / 2))
    end
    local connectorImage = gfx.image.new(self.connectorLength * 2, (connectorY + connectorWidth) * 2)
    -- this is to create a connector upwards from the recycler so that it doesn't overlap with others
    if connectorY ~= 0 then
        gfx.pushContext(connectorImage)
        if (recycler.isLeftToGun) then
            gfx.drawRect(0, 0, connectorWidth, connectorY)
            self.connnectorX -= connectorWidth
            self.verticalConnector = geo.lineSegment.new(self.connnectorX,
                recycler.y, self.connnectorX, recycler.y + connectorY)
        else
            gfx.drawRect(self.connectorLength, 0, connectorWidth, connectorY)
            self.verticalConnector = geo.lineSegment.new(self.connnectorX + self.connectorLength,
                recycler.y, self.connnectorX + self.connectorLength, recycler.y + connectorY)
        end
        gfx.popContext()
    else
        self.verticalConnector = nil
    end

    self.horizontalConnector = geo.lineSegment.new(self.connnectorX, recycler.y - connectorY,
    self.connnectorX + self.connectorLength, recycler.y - connectorY)
    gfx.pushContext(connectorImage)
        gfx.drawRect(0, 0, self.connectorLength + connectorWidth, connectorWidth)
    gfx.popContext()

    self:setImage(connectorImage)
    self:setCenter(0,0)
    -- recycler image is specified 32x32 but there is whitespace, figure it out
    self.spriteY = MAX_SCREEN_HEIGHT - 22 - connectorY
    self:moveTo(self.connnectorX, self.spriteY)
    self:setupConnectorAnimators()
    self:add()
end

function RecyclerConnector:setupConnectorAnimators()
    self.connectorAnimationEnded = false
    local horizontalConnectorAnimatorDelay = 0
    if self.verticalConnector ~= nil then
        horizontalConnectorAnimatorDelay += verticalConnectorAnimatorTime
        self.clipRectVerticalAnimator = pd.timer.new(verticalConnectorAnimatorTime)
        self.clipRectVerticalAnimator.startValue = 0
        self.clipRectVerticalAnimator.endValue = connectorWidth + self.connectorY
        self.clipRectVerticalAnimator.easingFunction = pd.easingFunctions.outCubic
        self.clipRectHeight = 0
        self.clipRectVerticalAnimator.updateCallback = function(timer)
            self.clipRectHeight = timer.value
        end
        self.clipRectVerticalAnimator.timerEndedCallback = function(timer)
            self.clipRectHeight = timer.endValue
        end
    else
        self.clipRectHeight = connectorWidth + self.connectorY
    end
    self.clipRectHorizontalAnimator = pd.timer.new(horizontalConnectorAnimatorTime)
    if self.recycler.isLeftToGun then
        self.clipRectHorizontalAnimator.startValue = 0
        self.clipRectHorizontalAnimator.endValue = self.connectorLength + connectorWidth
        self.clipRectX = self.connnectorX
        self.clipRectWidth = 0
    else
        self.clipRectHorizontalAnimator.startValue = self.connnectorX + self.connectorLength + connectorWidth
        self.clipRectHorizontalAnimator.endValue = self.connnectorX
        self.clipRectX = self.connnectorX + self.connectorLength + connectorWidth
        self.clipRectWidth = self.connectorLength + connectorWidth
    end
    self.clipRectHorizontalAnimator.easingFunction = pd.easingFunctions.outCubic
    self.clipRectHorizontalAnimator.delay = horizontalConnectorAnimatorDelay
    self.clipRectHorizontalAnimator.updateCallback = function(timer)
        if self.recycler.isLeftToGun then
            self.clipRectWidth = timer.value
        else
            self.clipRectX = timer.value
        end
    end
    self.clipRectHorizontalAnimator.timerEndedCallback = function(timer)
        if self.recycler.isLeftToGun then
            self.clipRectWidth = timer.value
        else
            self.clipRectX = timer.value
        end
        self.connectorAnimationEnded = true
    end
end

function RecyclerConnector:update()
    if not self.connectorAnimationEnded then
        self:setClipRect(self.clipRectX, self.spriteY, self.clipRectWidth, self.clipRectHeight)
    end
end

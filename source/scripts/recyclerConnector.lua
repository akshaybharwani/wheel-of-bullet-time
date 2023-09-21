import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("RecyclerConnector").extends(gfx.sprite)

local connectorWidth = 3

function RecyclerConnector:init(recycler, connectorY)
    -- TODO: very complicated to look at. Revisit to improve

    -- NOTE: Tried to change this logic to use drawLine instead as it would have the ease of accessing
    -- coordinates of different connectors for animators, but it didn't seem to work.
    -- Line would not show up. Revisit.
    local connnectorX = nil
    local connectorLength = nil
    if (recycler.isLeftToGun) then
        connnectorX = recycler.x + RECYCLER_SIZE / 2
        connectorLength = math.abs(connnectorX - (GUN_BASE_X - GUN_BASE_SIZE / 2))
    else
        connnectorX = GUN_BASE_X + GUN_BASE_SIZE / 2
        connectorLength = math.abs(connnectorX - (recycler.x - RECYCLER_SIZE / 2))
    end
    local connectorImage = gfx.image.new(connectorLength * 2, (connectorY + connectorWidth) * 2)
    -- this is to create a connector upwards from the recycler so that it doesn't overlap with others
    if connectorY ~= 0 then
        gfx.pushContext(connectorImage)
        if (recycler.isLeftToGun) then
            gfx.drawRect(0, 0, connectorWidth, connectorY)
            connnectorX -= connectorWidth
            self.verticalConnector = pd.geometry.lineSegment.new(connnectorX,
                recycler.y, connnectorX, recycler.y + connectorY)
        else
            gfx.drawRect(connectorLength, 0, connectorWidth, connectorY)
            self.verticalConnector = pd.geometry.lineSegment.new(connnectorX + connectorLength,
                recycler.y, connnectorX + connectorLength, recycler.y + connectorY)
        end
        gfx.popContext()
    else
        self.verticalConnector = nil
    end

    self.horizontalConnector = pd.geometry.lineSegment.new(connnectorX, recycler.y - connectorY,
    connnectorX + connectorLength, recycler.y - connectorY)
    gfx.pushContext(connectorImage)
        gfx.drawRect(0, 0, connectorLength + connectorWidth, connectorWidth)
    gfx.popContext()

    self:setImage(connectorImage)
    self:setCenter(0,0)
    -- recycler image is specified 32x32 but there is whitespace, figure it out
    self:moveTo(connnectorX, MAX_SCREEN_HEIGHT - 22 - connectorY)
    self:add()
end

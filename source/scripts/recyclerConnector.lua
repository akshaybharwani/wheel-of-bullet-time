import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("RecyclerConnector").extends(gfx.sprite)

local connectorWidth = 3

function RecyclerConnector:init(x, y, connectorY)
    -- TODO: very complicated to look at. Revisit to improve
    local connnectorX = nil
    local connectorLength = nil
    if (x < MAX_SCREEN_WIDTH / 2) then
        connnectorX = x + RECYCLER_SIZE / 2
        connectorLength = math.abs(connnectorX - (GUN_BASE_X - GUN_BASE_SIZE / 2))
    else
        connnectorX = GUN_BASE_X + GUN_BASE_SIZE / 2
        connectorLength = math.abs(connnectorX - (x - RECYCLER_SIZE / 2))
    end
    local connectorImage = gfx.image.new(connectorLength + connectorWidth, connectorY + connectorWidth)
    -- this is to create a connector upwards from the recycler so that it doesn't overlap with others
    if connectorY ~= 0 then
        gfx.pushContext(connectorImage)
        if connectorY ~= 0 then
            if (x < MAX_SCREEN_WIDTH / 2) then
                gfx.fillRect(0, 0, connectorWidth, connectorY)
                connnectorX -= connectorWidth
            else
                gfx.fillRect(connectorLength, 0, connectorWidth, connectorY)
            end
        end
        gfx.popContext()
    end

    gfx.pushContext(connectorImage)
    gfx.fillRect(0, 0, connectorLength + connectorWidth, connectorWidth)
    gfx.popContext()

    self:setImage(connectorImage)
    self:setCenter(0,0)
    -- recycler image is specified 32x32 but there is whitespace, figure it out
    self:moveTo(connnectorX, MAX_SCREEN_HEIGHT - 22 - connectorY)
    self:add()
end

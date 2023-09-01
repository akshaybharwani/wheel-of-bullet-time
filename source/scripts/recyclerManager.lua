import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/recycler"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('RecyclerManager').extends(gfx.sprite)

local maxRecyclerCount = 5
local activeRecyclers = {}

function RecyclerManager:init()
    RecyclerManager.super.init(self)

    self:spawnRecyclers()
    self:add()
end

function RecyclerManager:spawnRecyclers()
    local recyclerCenterPos = RECYCLER_SIZE / 2
    local pairs = self:generateRecyclerPositions(maxRecyclerCount, recyclerCenterPos,
        MAX_SCREEN_WIDTH - recyclerCenterPos, MAX_SCREEN_HEIGHT - recyclerCenterPos)

    for _, pair in ipairs(pairs) do
        table.insert(activeRecyclers, Recycler(pair.x, pair.y))
    end
end

function RecyclerManager:generateRecyclerPositions(maxCount, minX, maxX, maxY)
    local gunStartX = GUN_BASE_X - GUN_BASE_SIZE / 2
    local gunEndX = GUN_BASE_X + GUN_BASE_SIZE / 2
    local pairs = {}

    while #pairs < maxCount do
        local x = math.random(minX, maxX)
        local y = maxY

        if not isOverlappingGunElements(pairs, x, gunStartX, gunEndX) then
            table.insert(pairs, { x = x, y = y })
        end
    end

    return pairs
end

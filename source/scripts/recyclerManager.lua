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

    local leftToGunRecyclers = {}
    local rightToGunRecyclers = {}
    for i = 1, #pairs do
        if (pairs[i].x < MAX_SCREEN_WIDTH / 2) then
            table.insert(leftToGunRecyclers, pairs[i])
        else
            table.insert(rightToGunRecyclers, pairs[i])
        end
    end

    table.sort(leftToGunRecyclers, function(a, b)
        return a.x > b.x
    end)

    table.sort(rightToGunRecyclers, function(a, b)
        return a.x < b.x
    end)

    local recyclerConnectorY = 0
    for i = 1, #leftToGunRecyclers do
        table.insert(activeRecyclers, Recycler(leftToGunRecyclers[i].x, leftToGunRecyclers[i].y, recyclerConnectorY))
        recyclerConnectorY += 5
    end

    recyclerConnectorY = 0
    for i = 1, #rightToGunRecyclers do
        table.insert(activeRecyclers, Recycler(rightToGunRecyclers[i].x, rightToGunRecyclers[i].y, recyclerConnectorY))
        recyclerConnectorY += 5
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

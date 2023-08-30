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
    local recyclerCenterPos = recyclerSize / 2
    local pairs = generateRecyclerPositions(maxRecyclerCount, recyclerCenterPos,
        maxScreenWidth - recyclerCenterPos, maxScreenHeight - recyclerCenterPos)

    for _, pair in ipairs(pairs) do
        table.insert(activeRecyclers, Recycler(pair.x, pair.y))
    end
end

function generateRecyclerPositions(maxCount, minX, maxX, maxY)
    -- Playdate Lua doesn't have an 'os' method. Use something else.
    -- math.randomseed(os.time())
    local gunStartX = gunBaseX - gunBaseSize / 2
    local gunEndX = gunBaseX + gunBaseSize / 2
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

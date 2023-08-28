import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/recycler"

local numOfRecyclers = 5
local minSeparationDistance = 10

local function hasClashWithDistance(pairs, x, minDistance)
    for _, pair in ipairs(pairs) do
        local distanceBetweenX = math.abs(pair.x - x)
        if distanceBetweenX < minDistance then
            return true
        end
    end
    return false
end

local function generatePairsWithDistance(numPairs, minX, maxX, maxY, minDistance)
    -- math.randomseed(os.time())
    local pairs = {}

    while #pairs < numPairs do
        local x = math.random(minX, maxX)
        local y = maxY

        if not hasClashWithDistance(pairs, x, minDistance) then
            table.insert(pairs, { x = x, y = y })
        end
    end

    return pairs
end

function spawnRecyclers()
    local recyclerCenterPos = 32 / 2
    local pairs = generatePairsWithDistance(numOfRecyclers, recyclerCenterPos,
        maxScreenWidth - recyclerCenterPos, maxScreenHeight - recyclerCenterPos,
        recyclerCenterPos * 2)

    for i, pair in ipairs(pairs) do
        local recycler = Recycler(pair.x, pair.y)
    end
end

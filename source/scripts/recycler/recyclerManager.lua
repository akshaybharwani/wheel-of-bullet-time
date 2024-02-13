import "scripts/recycler/recycler"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('RecyclerManager').extends(gfx.sprite)

local recyclerConstants = RECYCLER_CONSTANTS

local maxRecyclerCount = recyclerConstants.maxRecyclerCount
local debrisHoldDuration = recyclerConstants.debrisHoldDuration

ACTIVE_RECYCLERS = {}

function RecyclerManager:init()
    RecyclerManager.super.init(self)
    ACTIVE_RECYCLERS = {}
    self.collectedDebris = 0

    self.debrisCollectedSound = SfxPlayer(SFX_FILES.debris_collected)
    
    self:setupDebrisHoldTimer()

    self:spawnRecyclers()
    self:add()
end

function RecyclerManager:spawnRecyclers()
    local recyclerCenterPos = RECYCLER_SIZE / 2
    local pairs = self:generateRecyclerPositions(maxRecyclerCount, recyclerCenterPos,
        SCREEN_WIDTH - recyclerCenterPos, SCREEN_HEIGHT - recyclerCenterPos)

    local leftToGunRecyclers = {}
    local rightToGunRecyclers = {}
    for i = 1, #pairs do
        if (pairs[i].x < SCREEN_WIDTH / 2) then
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
        self:addRecycler(leftToGunRecyclers[i].x, leftToGunRecyclers[i].y, recyclerConnectorY, true)
        recyclerConnectorY += 5
    end

    recyclerConnectorY = 0
    for i = 1, #rightToGunRecyclers do
        self:addRecycler(rightToGunRecyclers[i].x, rightToGunRecyclers[i].y, recyclerConnectorY, false)
        recyclerConnectorY += 5
    end
end

function RecyclerManager:addRecycler(posX, posY, recyclerConnectorY, isLeftToGun)
    local recycler = Recycler(posX,posY, recyclerConnectorY, isLeftToGun)
    table.insert(ACTIVE_RECYCLERS, recycler)
    table.insert(ACTIVE_TARGETS, recycler)
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

function RecyclerManager:setupDebrisHoldTimer()
    self.holdDebrisTimer = pd.timer.new(debrisHoldDuration)
    self.holdDebrisTimer:pause()
    self.holdDebrisTimer.discardOnCompletion = false
    self.holdDebrisTimer.repeats = true
    self.holdDebrisTimer.timerEndedCallback = function(timer)
        if self.collectedDebris > 0 then
            local activeRecyclers = ACTIVE_RECYCLERS
            for i = 1, #activeRecyclers do
                local recycler = activeRecyclers[i]
                if recycler.available then
                    recycler:sendDebrisToRecycler()
                    self.collectedDebris -= 1
                    break
                end
            end
        else
            self.holdDebrisTimer:pause()
        end
    end
end

function RecyclerManager:assignDebris()
    self.collectedDebris += 1
    self.debrisCollectedSound:play()
    if self.holdDebrisTimer.paused then
        self.holdDebrisTimer:start()
    end
end

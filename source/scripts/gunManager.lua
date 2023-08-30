import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/gun"
import "scripts/recyclerManager"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('GunManager').extends(gfx.sprite)

local gunMaxRotationAngle = 85
local gunRotationSpeed = 3 -- Screen updates 30 times per second by default

-- TODO: should be a better way to maintain these variables
gunBaseSize = 64
gunBaseX, gunBaseY = 0, 0
gunCurrentRotationAngle = 0
recyclerSize = 32

function GunManager:init()
    GunManager.super.init(self)

    Gun()
    RecyclerManager()
    self:add()
end

function isOverlappingGunElements(pairs, x, gunStartX, gunEndX)
    -- logic to check if it doesn't overlap gun base
    if (x - recyclerSize / 2 <= gunEndX
            and x + recyclerSize / 2 >= gunStartX) then
        return true
    end

    for _, pair in ipairs(pairs) do
        local distanceBetweenX = math.abs(pair.x - x)
        if distanceBetweenX < recyclerSize then
            return true
        end
    end
    return false
end

function GunManager:update()
    self:readRotationInput()
end

function GunManager:readRotationInput()
    if pd.buttonIsPressed("RIGHT") then
        if (gunCurrentRotationAngle < gunMaxRotationAngle) then
            gunCurrentRotationAngle += gunRotationSpeed
        end
    elseif pd.buttonIsPressed("LEFT") then
        if (gunCurrentRotationAngle > -gunMaxRotationAngle) then
            gunCurrentRotationAngle -= gunRotationSpeed
        end
    end
end

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/enemy"
import "scripts/crankTimer"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('EnemyManager').extends(gfx.sprite)

local enemySpawnWaitDuration = 5 -- here this is number of seconds instead of miliseconds elsewhere
local currentEnemyRate = 1
local oneWaveDuration = 30000
local currentWaveDuration = 0
local maxEnemyRate = 6

local explosionImagePath = "images/enemies/enemy_explosion-table-64-64"

local enemyA = {
    hp = 1,
    attackColliderSize = 22,
    shieldColliderSize = 26,
    baseImagePath = "images/enemies/enemy_a",
    explosionImageTable = gfx.imagetable.new(explosionImagePath)
}

local enemyB = {
    hp = 3,
    attackColliderSize = 26,
    shieldColliderSize = 30,
    baseImagePath = "images/enemies/enemy_b",
    explosionImageTable = gfx.imagetable.new(explosionImagePath)
}

local enemyC = {
    hp = 5,
    attackColliderSize = 40,
    shieldColliderSize = 46,
    baseImagePath = "images/enemies/enemy_c",
    explosionImageTable = gfx.imagetable.new(explosionImagePath)
}

local enemies = { enemyA, enemyB, enemyC }

function EnemyManager:init(debrisManager)
    EnemyManager.super.init(self)

    self.debrisManager = debrisManager
    self.enemySpawnTimer = CrankTimer(enemySpawnWaitDuration, true, function()
        self:handleEnemyWave()
        self:spawnEnemies()
    end)
    self:setupEnemySpawn()
    self:add()
end

function EnemyManager:spawnEnemies()
    for i = 1, currentEnemyRate do
        local enemyToSpawn = enemies[math.random(1, #enemies)]
        Enemy(enemyToSpawn, self.debrisManager)
    end
end

function EnemyManager:handleEnemyWave()
    if (maxEnemyRate > currentEnemyRate) then
        currentWaveDuration += enemySpawnWaitDuration
        if (currentWaveDuration >= oneWaveDuration) then
            currentEnemyRate += 1
            currentWaveDuration = 0
        end
    end
end

function EnemyManager:setupEnemySpawn()
    self:spawnEnemies()
end

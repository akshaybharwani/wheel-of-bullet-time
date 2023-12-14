import "scripts/enemies/enemy"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('EnemyManager').extends(gfx.sprite)

local enemyConstants = ENEMY_CONSTANTS

local enemySpawnWaitDuration = enemyConstants.enemySpawnWaitDuration / 1000 -- here this is number of seconds instead of miliseconds elsewhere
local oneWaveDuration = enemyConstants.oneWaveDuration
local maxEnemySpawnRate = enemyConstants.oneWaveDuration

local currentEnemySpawnRate = 1
local currentWaveDuration = 0

local explosionImagePath = "images/enemies/enemy_explosion-table-64-64"

local enemyA = {
    hp = 1,
    attackColliderSize = 22,
    shieldColliderSize = 26,
    baseImagePath = "images/enemies/enemy_a",
    explosionImageTable = gfx.imagetable.new(explosionImagePath),
    deathSound = SfxPlayer(SFX_FILES.enemy_dead_type1)
}

local enemyB = {
    hp = 3,
    attackColliderSize = 26,
    shieldColliderSize = 30,
    baseImagePath = "images/enemies/enemy_b",
    explosionImageTable = gfx.imagetable.new(explosionImagePath),
    deathSound = SfxPlayer(SFX_FILES.enemy_dead_type3)
}

local enemyC = {
    hp = 5,
    attackColliderSize = 40,
    shieldColliderSize = 46,
    baseImagePath = "images/enemies/enemy_c",
    explosionImageTable = gfx.imagetable.new(explosionImagePath),
    deathSound = SfxPlayer(SFX_FILES.enemy_dead_type5)
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
    for i = 1, currentEnemySpawnRate do
        local enemyToSpawn = enemies[math.random(1, #enemies)]
        Enemy(enemyToSpawn, self.debrisManager)
    end
end

function EnemyManager:handleEnemyWave()
    if (maxEnemySpawnRate > currentEnemySpawnRate) then
        currentWaveDuration += enemySpawnWaitDuration
        if (currentWaveDuration >= oneWaveDuration) then
            currentEnemySpawnRate += 1
            currentWaveDuration = 0
        end
    end
end

function EnemyManager:setupEnemySpawn()
    self:spawnEnemies()
end

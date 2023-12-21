import "scripts/enemies/enemy"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('EnemyManager').extends(gfx.sprite)

local enemyConstants = ENEMY_CONSTANTS

local enemySpawnWaitDuration = enemyConstants.enemySpawnWaitDuration
local oneWaveDuration = enemyConstants.oneWaveDuration
local maxEnemySpawnRate = enemyConstants.maxEnemySpawnRate

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
    self.currentEnemySpawnRate = 1
    self.currentWaveDuration = 0
    self.isGunDisabled = false

    self.debrisManager = debrisManager
    self.gameActiveSpawnTimer = CrankTimer(enemySpawnWaitDuration / 1000, true, function()
        self:handleEnemySpawning()
    end)
    self.gunDisabledSpawnTimer = pd.timer.new(enemySpawnWaitDuration)
    self.gunDisabledSpawnTimer:pause()
    self.gunDisabledSpawnTimer.repeats = true
    self.gunDisabledSpawnTimer.timerEndedCallback = function(timer)
        self:handleEnemySpawning()
    end
    NOTIFICATION_CENTER:subscribe(NOTIFY_GUN_IS_DISABLED, self, function()
        self.gameActiveSpawnTimer:remove()
        self.isGunDisabled = true
        self.gunDisabledSpawnTimer:start()
    end)
    NOTIFICATION_CENTER:subscribe(NOTIFY_GAME_OVER, self, function()
        self.gunDisabledSpawnTimer:remove()
    end)
    self:spawnEnemies()
    self:add()
end

function EnemyManager:handleEnemySpawning()
    self:handleEnemyWave()
    self:spawnEnemies()
end

function EnemyManager:spawnEnemies()
    for i = 1, self.currentEnemySpawnRate do
        local enemyToSpawn = enemies[math.random(1, #enemies)]
        Enemy(enemyToSpawn, self.debrisManager, self.isGunDisabled)
    end
end

function EnemyManager:handleEnemyWave()
    if (maxEnemySpawnRate > self.currentEnemySpawnRate) then
        self.currentWaveDuration += enemySpawnWaitDuration
        if (self.currentWaveDuration >= oneWaveDuration) then
            self.currentEnemySpawnRate += 1
            self.currentWaveDuration = 0
        end
    end
end

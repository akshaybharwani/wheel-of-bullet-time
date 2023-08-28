import "scripts/enemy"

local pd <const> = playdate

local enemySpawnWaitDuration = 5000
local currentEnemyRate = 1
local oneWaveDuration = 30000
local currentWaveDuration = 0
local maxEnemyRate = 6

local enemyA = {
    hp = 1,
    attackColliderSize = 22,
    shieldColliderSize = 26,
    baseImagePath = "images/enemy_a",
    explosionImagePath = "images/enemy_explosionattack_a"
}

local enemyB = {
    hp = 3,
    attackColliderSize = 26,
    shieldColliderSize = 30,
    baseImagePath = "images/enemy_b",
    explosionImagePath = "images/enemy_explosionattack_bc"
}

local enemyC = {
    hp = 5,
    attackColliderSize = 40,
    shieldColliderSize = 46,
    baseImagePath = "images/enemy_c",
    explosionImagePath = "images/enemy_explosionattack_bc"
}

local enemies = { enemyA, enemyB, enemyC }

local function spawnEnemies()
    --[[ if pd.getCrankChange() == 0 then
        return
    end ]]
    for i = 1, currentEnemyRate do
        local enemyToSpawn = enemies[math.random(1, #enemies)]
        local enemy = Enemy(enemyToSpawn)
    end
end

local function handleEnemyWave()
    if (maxEnemyRate > currentEnemyRate) then
        currentWaveDuration += enemySpawnWaitDuration
        if (currentWaveDuration >= oneWaveDuration) then
            currentEnemyRate += 1
            currentWaveDuration = 0
        end
    end
end

local function setupEnemySpawnTimer()
    local enemySpawnTimer = pd.timer.new(enemySpawnWaitDuration)
    enemySpawnTimer.repeats = true
    enemySpawnTimer.timerEndedCallback = function(timer)
        handleEnemyWave()
        spawnEnemies()
    end
end

function setupEnemySpawn()
    spawnEnemies()
    setupEnemySpawnTimer()
end

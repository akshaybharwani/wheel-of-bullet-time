-- some notes for current state and libraries

-- * FPS
-- current default FPS for every animation is 30 and the value that is used goes by variable called tickStep = 1
-- so, tickStep = 2 is every second frame, making animation 15fps. As the update still happens frame based, 
-- not sure how float values will work here. TODO: revisit this

-- * Time/Duration
-- It's in milliseconds, ex put 500 for 0.5 seconds.

-- core game
CORE_GAME_CONSTANTS = {}
CORE_GAME_CONSTANTS.crankCheckWaitDuration = 100

-- title
TITLE_CONSTANTS = {}
TITLE_CONSTANTS.titleDuration = 1000

-- opening animation
OPENING_ANIMATION_CONSTANTS = {}
OPENING_ANIMATION_CONSTANTS.waitDurationToSpawnRecyclers = 1000
OPENING_ANIMATION_CONSTANTS.waitDurationToSpawnDebris = 600
OPENING_ANIMATION_CONSTANTS.debrisGroupAtStartCount = 4

-- debris
DEBRIS_CONSTANTS = {}
DEBRIS_CONSTANTS.spawnAnimationFPS = 1.2
DEBRIS_CONSTANTS.startSpeed = 1
DEBRIS_CONSTANTS.maxSpeed = 8
DEBRIS_CONSTANTS.acceleration = 0.5
DEBRIS_CONSTANTS.minDebris, DEBRIS_CONSTANTS.maxDebris = 4, 6
DEBRIS_CONSTANTS.expirationDuration = 4000
DEBRIS_CONSTANTS.framesBeforeSpeedReset = 5

-- recycler
RECYCLER_CONSTANTS = {}
RECYCLER_CONSTANTS.ammoGenerationDuration = 250
RECYCLER_CONSTANTS.debrisTravelDuration = 350
RECYCLER_CONSTANTS.maxHP = 4
-- connector are the pipes going from recyclers to the gun
RECYCLER_CONSTANTS.connectorAnimationDuration = 300
RECYCLER_CONSTANTS.maxRecyclerCount = 5
RECYCLER_CONSTANTS.debrisHoldDuration = 350

-- gun
GUN_CONSTANTS = {}
GUN_CONSTANTS.maxHP = 4
GUN_CONSTANTS.animationFPS = 2
GUN_CONSTANTS.maxRotationAngle = 85
GUN_CONSTANTS.rotationSpeed = 3
GUN_CONSTANTS.colliderSizeX = 40
GUN_CONSTANTS.colliderSizeY = 44
GUN_CONSTANTS.colliderPosition = 12

-- gun shooter
GUN_SHOOTER_CONSTANTS = {}
GUN_SHOOTER_CONSTANTS.maxFiringCooldown = 500

-- gun vacuum
GUN_VACUUM_CONSTANTS = {}
GUN_VACUUM_CONSTANTS.vacuumAreaWidth = 32
GUN_VACUUM_CONSTANTS.vacuumLength = 1000
GUN_VACUUM_CONSTANTS.vacuumVaporDistance = 32
GUN_VACUUM_CONSTANTS.vacuumVaporCount = 10
GUN_VACUUM_CONSTANTS.vacuumVaporSpeed = 32
GUN_VACUUM_CONSTANTS.vacuumVaporAnimationFPS = 20

-- bullet
BULLET_CONSTANTS = {}
BULLET_CONSTANTS.bulletSpeed = 16
BULLET_CONSTANTS.bulletTrailDistance = 8

-- ui
UI_CONSTANTS = {}
-- space between each number 
UI_CONSTANTS.numberPadding = 1

-- bulletDisplay
BULLET_DISPLAY_CONSTANTS = {}
BULLET_DISPLAY_CONSTANTS.bounceTotalDuration = 100
BULLET_DISPLAY_CONSTANTS.bounceHeight = 3

-- game over
GAME_OVER_CONSTANTS = {}
GAME_OVER_CONSTANTS.waitToShowResultsDuration = 2000
GAME_OVER_CONSTANTS.showResultsDuration = 3000
GAME_OVER_CONSTANTS.timeMultiplier = 8

-- enemy general settings
ENEMY_CONSTANTS = {}
ENEMY_CONSTANTS.minSpeed, ENEMY_CONSTANTS.maxSpeed = 1, 6
ENEMY_CONSTANTS.hitAnimationDuration = 100
ENEMY_CONSTANTS.explosionAnimationLoopCount = 3
ENEMY_CONSTANTS.explosionAnimationFPS = 6
ENEMY_CONSTANTS.minTotalPatrolDuration, ENEMY_CONSTANTS.maxTotalPatrolDuration = 4, 6
ENEMY_CONSTANTS.minPatrolSegmentDuration, ENEMY_CONSTANTS.maxPatrolSegmentDuration = 1, 2

ENEMY_CONSTANTS.enemySpawnWaitDuration = 18000
ENEMY_CONSTANTS.oneWaveDuration = 19000
-- number of enemies spawn after every enemySpawnWaitDuration
ENEMY_CONSTANTS.maxEnemySpawnRate = 6

-- enemy data
-- * Go to scripts/enemyManager for setting individual enemy data
-- TODO: Move these settings to a json file

-- high score
HIGH_SCORE_CONSTANTS = {}
HIGH_SCORE_CONSTANTS.maxScores = 5

-- background
BACKGROUND_CONSTANTS = {}
BACKGROUND_CONSTANTS.cloudSeperationDistance = 3
BACKGROUND_CONSTANTS.cloudSpeed = 40
-- includes the cloud outside the max screen width
BACKGROUND_CONSTANTS.cloudsAtStartCount = 7
BACKGROUND_CONSTANTS.satelliteSpeed = 6
BACKGROUND_CONSTANTS.satelliteFPS = 3
BACKGROUND_CONSTANTS.satelliteMinRespawnDuration, BACKGROUND_CONSTANTS.satelliteMaxRespawnDuration = 3, 6

-- time Display on Top
TIME_DISPLAY_CONSTANTS = {}
TIME_DISPLAY_CONSTANTS.playAnimationFPS = 10

-- audio
AUDIO_CONSTANTS = {}
AUDIO_CONSTANTS.fadeSeconds = 0.5
AUDIO_CONSTANTS.maxVolume = 1
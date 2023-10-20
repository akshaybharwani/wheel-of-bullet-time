-- some notes for current state and libraries
-- current default FPS for every animation is 30 and the value that is used goes by variable called tickStep = 1
-- so, tickStep = 2 is every second frame, making animation 15fps. As the update still happens frame based, 
-- not sure how float values will work here. TODO: revisit this

-- opening animation
OPENING_ANIMATION = {}
OPENING_ANIMATION.recyclerSpawnDuration = 2000
OPENING_ANIMATION.debrisSpawnDuration = 1000
OPENING_ANIMATION.debrisGroupAtStartCount = 4
-- includes the cloud outside the max screen width
OPENING_ANIMATION.cloudAtStartCount = 7

-- debris
DEBRIS_CONSTANTS = {}
DEBRIS_CONSTANTS.spawnAnimationFPS = 1.2
DEBRIS_CONSTANTS.toRecycleDuration = 1000

-- bulletDisplay
BULLET_DISPLAY_CONSTANTS = {}
BULLET_DISPLAY_CONSTANTS.numberPadding = 1
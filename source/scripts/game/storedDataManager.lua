local pd <const> = playdate
local gfx <const> = pd.graphics

class('StoredDataManager').extends(gfx.sprite)

local maxScores = HIGH_SCORE_CONSTANTS.maxScores

local highScores = {}

function StoredDataManager:init()
    StoredDataManager.super.init(self)
    self:loadGameData()
    self:add()
end

function StoredDataManager:loadGameData()
    local gameData = pd.datastore.read()
    if gameData then
        if gameData.highScores then
            highScores = gameData.highScores
        end
    end
end

-- ? do we want to save the entire game state, with enemies, bullets, etc?
function StoredDataManager:saveGameData()
    local currentScore = GAME_ACTIVE_ELAPSED_SECONDS
    if #highScores > 0 then
        for i = 1, #highScores do
            if (currentScore > highScores[i]) then
                table.insert(highScores, i, currentScore)
                break
            end
        end
        if #highScores > maxScores then
            table.remove(highScores, #highScores)
        end
    else
        table.insert(highScores, currentScore)
    end
    local gameData = {
        highScores = highScores
    }
    pd.datastore.write(gameData)
    return highScores
end

--[[ function pd.gameWillTerminate()
    saveGameData()
end

function pd.gameWillSleep()
    saveGameData()
end ]]
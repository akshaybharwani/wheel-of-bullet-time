local pd <const> = playdate
local gfx <const> = pd.graphics

class('StoredDataManager').extends(gfx.sprite)

local maxScores = HIGH_SCORE_CONSTANTS.maxScores

function StoredDataManager:init()
    StoredDataManager.super.init(self)
    self.highScores = {}
    self:loadGameData()
    self:add()
end

function StoredDataManager:loadGameData()
    local gameData = pd.datastore.read()
    if gameData then
        if gameData.highScores then
            self.highScores = gameData.highScores
        end
    end
end

-- ? do we want to save the entire game state, with enemies, bullets, etc?
function StoredDataManager:saveGameData()
    local currentScore = GAME_ACTIVE_ELAPSED_SECONDS
    if currentScore == 0 then
        return self.highScores
    end
    if #self.highScores > 0 then
        for i = 1, #self.highScores do
            if (currentScore > self.highScores[i]) then
                table.insert(self.highScores, i, currentScore)
                break
            end
        end
        if #self.highScores > maxScores then
            table.remove(self.highScores, #self.highScores)
        end
    else
        table.insert(self.highScores, currentScore)
    end
    local gameData = {
        highScores = self.highScores
    }
    pd.datastore.write(gameData)
    return gameData.highScores
end

--[[ function pd.gameWillTerminate()
    saveGameData()
end

function pd.gameWillSleep()
    saveGameData()
end ]]
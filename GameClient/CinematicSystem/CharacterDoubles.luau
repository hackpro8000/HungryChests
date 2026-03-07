local Players = game:GetService("Players")
local CharacterDoubles = {}

local CharacterDoublesCache = {}

local function createDefaultDouble()
    return Players:CreateHumanoidModelFromDescriptionAsync(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R15)
end

function CharacterDoubles.preloadForUserID(userID: number)
    local successful, errorMessage = pcall(function(...)
        local characterDouble = Players:CreateHumanoidModelFromUserIdAsync(userID)
        CharacterDoublesCache[userID] = characterDouble
    end)
    
    if not successful then
        warn(`Failed to preload character double for user {userID}: {errorMessage}`)
        CharacterDoublesCache[userID] = createDefaultDouble()
    end
end

function CharacterDoubles.releaseDouble(userID : number)
    CharacterDoublesCache[userID] = nil
end

return CharacterDoubles

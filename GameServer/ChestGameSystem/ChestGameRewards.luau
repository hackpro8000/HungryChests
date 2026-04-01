local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestGameDataTypes = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameDataTypes)
local ChestGameState = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameState)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)
local GamepassIDMap = require(ReplicatedStorage.GameDefinitions.MarketplaceSystem.GamepassIDMap)

ChestGameState.changeState.listenInOrder(1, function(chestGameID: string, state: "ChoosingChests" | "Conclusion" | "Dormant" | "InAction")
    if state ~= "Conclusion" then
        return
    end
    
    local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]

    for participantID : string, participant : ChestGameDataTypes.ChestGameParticipant in chestGame.Participants do
        if participant.UserIDString == "0" then
            continue
        end

        local primaryCurrencyGamepassMult = 1
        local trophyGamepassMult = 1
        local winStreakMult = 1
        
        local primaryCurrencyReward, trophyReward, winStreakReward = 0, 0, 1

        if MarketplaceService:UserOwnsGamePassAsync(tonumber(participant.UserIDString), GamepassIDMap.DoubleCoins) then
            primaryCurrencyGamepassMult = 2
        end

        if MarketplaceService:UserOwnsGamePassAsync(tonumber(participant.UserIDString), GamepassIDMap.DoubleTrophies) then
            trophyGamepassMult = 2
        end

        if MarketplaceService:UserOwnsGamePassAsync(tonumber(participant.UserIDString), GamepassIDMap.DoubleWinStreak) then
            trophyGamepassMult = 2
        end

        if MarketplaceService:UserOwnsGamePassAsync(tonumber(participant.UserIDString), GamepassIDMap.VIPBundle) then
            primaryCurrencyGamepassMult = 2
            trophyGamepassMult = 2
            winStreakMult = 2
        end

        if participant.HealthPoints > 0 then
            -- If participant won:

            primaryCurrencyReward = math.random(
                chestGame.WinnerPrimaryRewardRange.Min,
                chestGame.WinnerPrimaryRewardRange.Max
            )
            
            trophyReward = math.random(
                chestGame.WinnerTrophyRewardRange.Min,
                chestGame.WinnerTrophyRewardRange.Max
            )

            ProfileState:GetServer().winChestGame(
                participant.UserIDString, 
                primaryCurrencyReward * primaryCurrencyGamepassMult, 
                trophyReward * trophyGamepassMult,
                1,
                winStreakReward * winStreakMult
            )
        else
            -- If participant lost:

            primaryCurrencyReward = math.random(
                chestGame.LoserPrimaryRewardRange.Min,
                chestGame.LoserPrimaryRewardRange.Max
            )
            
            trophyReward = math.random(
                chestGame.LoserTrophyRewardRange.Min,
                chestGame.LoserTrophyRewardRange.Max
            )

            ProfileState:GetServer().loseChestGame(
                participant.UserIDString, 
                primaryCurrencyReward * primaryCurrencyGamepassMult, 
                trophyReward * trophyGamepassMult
            )
        end
    end
end)

return nil

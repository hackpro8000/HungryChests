local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestGameServer = require(script.Parent.ChestGameServer)
local ChestGameDataTypes = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameState)
local NetLibServer = require(ReplicatedStorage.TLib.NetLib.NetLibServer)
local TimeLib = require(ReplicatedStorage.TLib.TimeLib)

local RE_ChooseChest = NetLibServer.RemoteEvent("ChestGameSystem/ChooseChest")

RE_ChooseChest.OnServerEvent:Connect(function(player : Player, chestNum : number)
    assert(chestNum, "Chest number not provided!")

    local activeChestGameID : string, activeChestGame : ChestGameDataTypes.ChestGame, activeParticipantID : string = ChestGameHelper.getPlayerChestGame(player)
    
    assert(activeChestGameID, `Couldn't find active chest game for player {player.Name}!`)
    assert(activeParticipantID, `Player {player.Name} is not actively participating in chest game {activeChestGameID}!`)
    
    ChestGameServer.chooseChestRegulated(activeChestGameID, activeParticipantID, chestNum)
end)

ChestGameState.chooseChest.listen(function(chestGameID: string, participantID: string, chestNum: number)
    local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]

    local participantCount : number = ChestGameHelper.countParticipants(chestGame)
    local chosenChestsCount : number = 0

    for participantID : string, participant : ChestGameDataTypes.ChestGameParticipant in chestGame.Participants do
        chosenChestsCount += #participant.ChosenChests
    end

    if chosenChestsCount >= participantCount * chestGame.MaxChestChoice then
        task.defer(function()
            ChestGameState:GetServer().cancelTimer(chestGameID)
            ChestGameState:GetServer().changeState(chestGameID, "InAction")
        end)
    end
end)

ChestGameState.changeState.listen(function(chestGameID: string, state: "ChoosingChests" | "Dormant" | "InAction")
    if state == "ChoosingChests" then
        task.defer(function()
            ChestGameState:GetServer().startTimer(chestGameID, TimeLib.getTime(), 10)
        end)
    end
end)

ChestGameState.timeoutTimer.listen(function(chestGameID: string)
    local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]

    if chestGame.State == "ChoosingChests" then
        -- Auto-choose random chests for participants who haven't reached max choice count
        for participantID : string, participant : ChestGameDataTypes.ChestGameParticipant in chestGame.Participants do
            local currentChoiceCount = #participant.ChosenChests
            
            if currentChoiceCount < chestGame.MaxChestChoice then
                local choicesNeeded = chestGame.MaxChestChoice - currentChoiceCount
                
                for i = 1, choicesNeeded do
                    local availableChests = ChestGameHelper.getAvailableChests(chestGameID)
                    
                    if #availableChests >= 1 then
                        local randomChest = availableChests[math.random(#availableChests)]
                        ChestGameState:GetServer().chooseChest(chestGameID, participantID, randomChest)
                    end
                end
            end
        end
    end
end)

return nil

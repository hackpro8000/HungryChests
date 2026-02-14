local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IChestGameRenderer = require(script.Parent.IChestGameRenderer)
local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local ChestGameDataTypes = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameState)
local NetLibClient = require(ReplicatedStorage.TLib.NetLib.NetLibClient)
local StreamingLibClient = require(ReplicatedStorage.TLib.StreamingLib.StreamingLibClient)

local RE_ChooseChest = NetLibClient.RemoteEvent("ChestGameSystem/ChooseChest")
local RE_OpenChest = NetLibClient.RemoteEvent("ChestGameSystem/OpenChest")

local LocalPlayer = Players.LocalPlayer
local ChestPrefabs = ReplicatedStorage.Resources.Prefabs.Chests

BootEvents.NetworkStarted:Connect(function()
    for chestGameID: string, chestGame: ChestGameDataTypes.ChestGame in ChestGameState.Data.ChestGameCollection do
        IChestGameRenderer.renderChairs(chestGameID)
    end
end)

ChestGameState.chooseChest.listen(function(chestGameID: string, participantID: string, chestNumber: number)
    local activeChestGameID, _, activeParticipantID = ChestGameHelper.getPlayerChestGame(LocalPlayer)

    if chestGameID ~= activeChestGameID then
        return
    end

    IChestGameRenderer.updateCurrentChestRendering(chestGameID, activeParticipantID)
end)

ChestGameState.changeState.listen(function(chestGameID: string, state: "Active" | "ChoosingChests" | "Dormant")
    local activeChestGameID: string, activeChestGame: ChestGameDataTypes.ChestGame?, activeParticipantID: string = ChestGameHelper.getPlayerChestGame(LocalPlayer)
    
    if chestGameID == activeChestGameID and activeChestGame then
        local chestGameInstance: Model? = StreamingLibClient.getInstance(activeChestGame.InstanceStreamableID)
        if chestGameInstance == nil then
            return
        end
        
        if state == "ChoosingChests" then
            IChestGameRenderer.renderInteractableChests(chestGameID, activeParticipantID, function(chestNum: number)
                RE_ChooseChest:FireServer(chestNum)
            end)
        elseif state == "Active" then
            IChestGameRenderer.renderInteractableChests(chestGameID, activeParticipantID, function(chestNum: number)
                RE_ChooseChest:FireServer(chestNum)
            end)
        end
    else
        if state == "ChoosingChests" or state == "Active" then
            IChestGameRenderer.renderGridChests(chestGameID, activeParticipantID)
        end
    end
end)

ChestGameState.createChestGame.listen(function(chestGameID: string, chestGame: ChestGameDataTypes.ChestGame)
    IChestGameRenderer.renderChairs(chestGameID)
end)

ChestGameState.addParticipant.listen(function(chestGameID: string, participantID: string, participant: ChestGameDataTypes.ChestGameParticipant)
    IChestGameRenderer.renderChairs(chestGameID)
end)

ChestGameState.removeParticipant.listen(function(chestGameID: string, participantID: string)
    IChestGameRenderer.renderChairs(chestGameID)
end)

-- Listen for state changes to handle InAction rendering
ChestGameState.changeState.listen(function(chestGameID: string, state: "ChoosingChests" | "Dormant" | "InAction")
    local activeChestGameID: string, activeChestGame: ChestGameDataTypes.ChestGame, activeParticipantID: string = ChestGameHelper.getPlayerChestGame(LocalPlayer)
    
    if state == "InAction" then
        if chestGameID == activeChestGameID and activeChestGame then
            local isMyTurn = activeChestGame.CurrentTurnParticipantID == activeParticipantID
            IChestGameRenderer.renderInteractableChests(chestGameID, activeParticipantID, function(chestNum: number)
                if isMyTurn then
                    RE_OpenChest:FireServer(chestNum)
                end
            end)
            IChestGameRenderer.updateCurrentChestRendering(chestGameID, activeParticipantID)
        else
            IChestGameRenderer.renderGridChests(chestGameID, activeParticipantID)
        end
    end
end)

-- Listen for current turn participant changes
ChestGameState.setCurrentTurnParticipant.listen(function(chestGameID: string, participantID: string?)
    local activeChestGameID: string, activeChestGame: ChestGameDataTypes.ChestGame, activeParticipantID: string = ChestGameHelper.getPlayerChestGame(LocalPlayer)

    if chestGameID == activeChestGameID and activeChestGame then
        if activeChestGame.State == "InAction" then
            local isMyTurn = participantID == activeParticipantID
            IChestGameRenderer.renderInteractableChests(chestGameID, activeParticipantID, function(chestNum: number)
                if isMyTurn then
                    RE_OpenChest:FireServer(chestNum)
                end
            end)
            IChestGameRenderer.updateCurrentChestRendering(chestGameID, activeParticipantID)
        end
    else
        IChestGameRenderer.renderGridChests(chestGameID, activeParticipantID)
    end
end)

-- Listen for chest openings to update rendering
ChestGameState.openChest.listen(function(chestGameID: string, participantID: string, chestNumber: number)
    local activeChestGameID: string, activeChestGame: ChestGameDataTypes.ChestGame, activeParticipantID: string = ChestGameHelper.getPlayerChestGame(LocalPlayer)

    if chestGameID == activeChestGameID and activeChestGame then
        if activeChestGame.State == "InAction" then
            local isMyTurn = activeChestGame.CurrentTurnParticipantID == activeParticipantID
            IChestGameRenderer.renderInteractableChests(chestGameID, activeParticipantID, function(chestNum: number)
                if isMyTurn then
                    RE_OpenChest:FireServer(chestNum)
                end
            end)
            IChestGameRenderer.updateCurrentChestRendering(chestGameID, activeParticipantID)
        end
    else
        IChestGameRenderer.renderGridChests(chestGameID, activeParticipantID)
    end
end)

-- Listen for health point changes to update rendering
ChestGameState.reduceHealthPoints.listen(function(chestGameID: string, participantID: string, damage: number)
    local activeChestGameID: string, activeChestGame: ChestGameDataTypes.ChestGame, activeParticipantID: string = ChestGameHelper.getPlayerChestGame(LocalPlayer)

    if chestGameID == activeChestGameID and activeChestGame then
        if activeChestGame.State == "InAction" then
            local isMyTurn = activeChestGame.CurrentTurnParticipantID == activeParticipantID
            IChestGameRenderer.renderInteractableChests(chestGameID, activeParticipantID, function(chestNum: number)
                if isMyTurn then
                    RE_OpenChest:FireServer(chestNum)
                end
            end)
            IChestGameRenderer.updateCurrentChestRendering(chestGameID, activeParticipantID)
        end
    else
        IChestGameRenderer.renderGridChests(chestGameID, activeParticipantID)
    end
end)

ChestGameState.changeState.listen(function(chestGameID: string, state: "Active" | "ChoosingChests" | "Dormant" | "Conclusion")
    if state == "Conclusion" then
        IChestGameRenderer.cleanOldChestRendering(chestGameID)
        IChestGameRenderer.cleanOldChairRendering(chestGameID)
    end
end)

ChestGameState.changeState.listenBefore(function(chestGameID: string, state: "ChoosingChests" | "Dormant" | "InAction" | "Conclusion")
    if state == "Dormant" then
        IChestGameRenderer.cleanOldChestRendering(chestGameID)
        IChestGameRenderer.cleanOldChairRendering(chestGameID)
    end
end)

return nil

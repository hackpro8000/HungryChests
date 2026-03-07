local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestGameDataTypes = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameState)
local StreamingLibClient = require(ReplicatedStorage.TLib.StreamingLib.StreamingLibClient)
local UILib = require(ReplicatedStorage.TLib.UILib)

local LocalPlayer = Players.LocalPlayer

local ChestChosenIndicators = {} :: {[string] : {typeof(UILib.Viewer())}}

local function getChestChosenIndicators(chestGameID : string)
    if ChestChosenIndicators[chestGameID] == nil then
        ChestChosenIndicators[chestGameID] = {}
    end
    
    return ChestChosenIndicators[chestGameID]
end

local function cleanChestChosenIndicators(chestGameID : string)
    local chosenChestIndicators = ChestChosenIndicators[chestGameID]

    if chosenChestIndicators == nil then
        return
    end

    for chestNum : number, chosenChestIndicatorViewer : typeof(UILib.Viewer()) in chosenChestIndicators do
        if chosenChestIndicatorViewer.Tree.Adornee then
            chosenChestIndicatorViewer.Tree.Adornee:Destroy()
        end
        
        chosenChestIndicatorViewer:Destroy()
    end

    chosenChestIndicators[ChestChosenIndicators] = nil
end

local function renderChosenIndicators(chestGameID : string, participantID : string)
    cleanChestChosenIndicators(chestGameID)

    local chosenChestIndicators = getChestChosenIndicators(chestGameID)
    local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    local chestGameInstance : Model = StreamingLibClient.getInstance(chestGame.InstanceStreamableID)
    local participant : ChestGameDataTypes.ChestGameParticipant = chestGame.Participants[participantID]

    for _, chestNum : number in participant.ChosenChests do
        local gridX : number, gridY : number = ChestGameHelper.getChestGridPosition(chestGame, chestNum)
        local adornee = Instance.new("Part")
        adornee.Transparency = 1
        adornee.CanCollide = false
        adornee.Anchored = true
        adornee.Size = Vector3.one * 0.1
        adornee.CFrame = chestGameInstance.Mat.CFrame:ToWorldSpace(CFrame.new(gridX, 2, gridY))
        adornee.Parent = workspace
        
        local chestChosenViewer = UILib.Viewer()
        chestChosenViewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Billboards.ChestChosenIndicator:Clone())
        chestChosenViewer:AutoParent()
        chestChosenViewer.Tree.Adornee = adornee

        chosenChestIndicators[chestNum] = chestChosenViewer
    end
end

ChestGameState.chooseChest.listen(function(chestGameID: string, participantID: string)
    local activeChestGameID : string, _, activeParticipantID : string = ChestGameHelper.getPlayerChestGame(LocalPlayer)
    
    if activeChestGameID ~= chestGameID then
        return
    end

    if participantID ~= activeParticipantID then
        return
    end

    renderChosenIndicators(chestGameID, participantID)
end)

return nil

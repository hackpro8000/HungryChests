local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local ChestGameDataTypes = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameState)
local StreamingLibClient = require(ReplicatedStorage.TLib.StreamingLib.StreamingLibClient)
local UILib = require(ReplicatedStorage.TLib.UILib)

local ChestGameBillboardPlotUIPrefab = ReplicatedStorage.Resources.UIPrefabs.Billboards.ChestGamePlot

local ChestGameBillboardViewers = {} :: {[string] : typeof(UILib.Viewer())}

local function updateBillboardUI(chestGameID : string)
    local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    local billboardViewer = ChestGameBillboardViewers[chestGameID]

    if billboardViewer then
        billboardViewer:SetLabel("ParticipantCount", `{ChestGameHelper.countParticipantsByID(chestGameID)}/{chestGame.MaxPlayers} Players`)
        billboardViewer:SetLabelVisible("ParticipantCount", chestGame.State == "Dormant")
    end
end

local function handleChestGame(chestGameID : string, chestGame : ChestGameDataTypes.ChestGame)
    local function onStreamIn(instance : Instance)
        if not instance then
            return
        end
        
        local matPart = instance:WaitForChild("Mat")
        
        local billboardViewer = UILib.Viewer()
        billboardViewer:Hydrate(ChestGameBillboardPlotUIPrefab:Clone())
        billboardViewer:AutoParent()
        billboardViewer.Tree.Adornee = matPart

        ChestGameBillboardViewers[chestGameID] = billboardViewer
        
        updateBillboardUI(chestGameID)
    end

    local function onStreamOut(instance : Instance)
        local billboardViewer = ChestGameBillboardViewers[chestGameID]

        if billboardViewer then
            billboardViewer:Destroy()
        end

        ChestGameBillboardViewers[chestGameID] = nil
    end
    
    local existingInstance = StreamingLibClient.getInstance(chestGame.InstanceStreamableID)
    if existingInstance then
        onStreamIn(existingInstance)
    end
    
    StreamingLibClient.listenToInstanceStreamedIn(chestGame.InstanceStreamableID, onStreamIn)
    StreamingLibClient.listenToInstanceStreamedOut(chestGame.InstanceStreamableID, onStreamOut)
end

BootEvents.NetworkStarted:Connect(function()
    for chestGameID : string, chestGame : ChestGameDataTypes.ChestGame in ChestGameState.Data.ChestGameCollection do
        task.spawn(handleChestGame, chestGameID, chestGame)
    end

    ChestGameState.createChestGame.listen(handleChestGame)
    ChestGameState.addParticipant.listen(updateBillboardUI)
    ChestGameState.removeParticipant.listen(updateBillboardUI)
    ChestGameState.changeState.listen(updateBillboardUI)
end)

return nil

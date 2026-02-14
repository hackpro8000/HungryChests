local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestGameDataTypes = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameState)
local StreamingLibClient = require(ReplicatedStorage.TLib.StreamingLib.StreamingLibClient)

local LocalPlayer = Players.LocalPlayer
local ChestPrefabs = ReplicatedStorage.Resources.Prefabs.Chests
local ChairPrefabs = ReplicatedStorage.Resources.Prefabs.Chairs
local ChestChosenIndicator = ReplicatedStorage.Resources.Prefabs.VFX.ChestChosenIndicator
local ChestAllowIndicator = ReplicatedStorage.Resources.Prefabs.VFX.ChestAllowIndicator
local ChestForbidIndicator = ReplicatedStorage.Resources.Prefabs.VFX.ChestForbidIndicator

local IChestGameRenderer = {}
local ChestRenderMemory = {}
local ChairRenderMemory = {}

function IChestGameRenderer.cleanOldChestRendering(chestGameID : string)
    local oldRendering = ChestRenderMemory[chestGameID]

    if oldRendering then
        for _, chestRenderModel : Model in oldRendering do
            chestRenderModel:Destroy()
        end

        ChestRenderMemory[chestGameID] = nil
    end
end

function IChestGameRenderer.cleanOldChairRendering(chestGameID : string)
    local oldRendering = ChairRenderMemory[chestGameID]

    if oldRendering then
        for _, chairModel : Model in oldRendering do
            chairModel:Destroy()
        end

        ChairRenderMemory[chestGameID] = nil
    end
end

function IChestGameRenderer.updateCurrentChestRendering(chestGameID : string, activeParticipantID : string)
    local currentRendering = ChestRenderMemory[chestGameID]

    if currentRendering == nil then
        return
    end

    local chestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    local chestGameInstance : Model? = StreamingLibClient.getInstance(chestGame.InstanceStreamableID)

    if chestGameInstance == nil then
        return
    end

    local activeParticipant : ChestGameDataTypes.ChestGameParticipant? = chestGame.Participants[activeParticipantID]
    local participantCount : number = ChestGameHelper.countParticipantsByID(chestGameID)

    if participantCount == 0 then
        return
    end

    for chestNum : number, chestRenderModel : Model in currentRendering do
        local participantIndex : number = ((chestNum-1) % participantCount) + 1
        local chestChosenIndicator = chestRenderModel:FindFirstChild("ChestChosenIndicator") :: typeof(ChestChosenIndicator)
        local chestAllowIndicator = chestRenderModel:FindFirstChild("ChestAllowIndicator") :: typeof(ChestAllowIndicator)
        local chestForbidIndicator = chestRenderModel:FindFirstChild("ChestForbidIndicator") :: typeof(ChestForbidIndicator)
        local clickDetector = chestRenderModel:FindFirstChild("ClickDetector")

        local isChestOpened = table.find(chestGame.OpenedChests or {}, chestNum) ~= nil
        local isMyTurn = activeParticipant and chestGame.CurrentTurnParticipantID == activeParticipantID

        -- Handle ChoosingChests state
        if chestGame.State == "ChoosingChests" then
            if activeParticipant and table.find(activeParticipant.ChosenChests, chestNum) then
                chestChosenIndicator.SurfaceGui.Enabled = true
                chestForbidIndicator.SurfaceGui.Enabled = false
                chestAllowIndicator.SurfaceGui.Enabled = false
            else
                chestChosenIndicator.SurfaceGui.Enabled = false
                chestForbidIndicator.SurfaceGui.Enabled = false
                chestAllowIndicator.SurfaceGui.Enabled = true
            end
        -- Handle InAction state
        elseif chestGame.State == "InAction" then
            local isMyOwnDangerousChest = activeParticipant and table.find(activeParticipant.ChosenChests, chestNum)
            
            if isChestOpened then
                -- Chest already opened - hide all indicators
                chestChosenIndicator.SurfaceGui.Enabled = false
                chestForbidIndicator.SurfaceGui.Enabled = false
                chestAllowIndicator.SurfaceGui.Enabled = false
                -- Disable click detector
                if clickDetector then
                    clickDetector.MaxActivationDistance = 0
                end
            else
                -- Chest not opened yet - chosen indicator has highest priority
                if isMyOwnDangerousChest then
                    chestChosenIndicator.SurfaceGui.Enabled = true
                    chestForbidIndicator.SurfaceGui.Enabled = false
                    chestAllowIndicator.SurfaceGui.Enabled = false
                    if clickDetector then
                        clickDetector.MaxActivationDistance = 0
                    end
                else
                    chestChosenIndicator.SurfaceGui.Enabled = false
                    
                    if isMyTurn then
                        -- My turn and not my dangerous chest - allow interaction
                        chestForbidIndicator.SurfaceGui.Enabled = false
                        chestAllowIndicator.SurfaceGui.Enabled = true
                        if clickDetector then
                            clickDetector.MaxActivationDistance = math.huge
                        end
                    else
                        -- Not my turn - forbid interaction
                        chestForbidIndicator.SurfaceGui.Enabled = true
                        chestAllowIndicator.SurfaceGui.Enabled = false
                        if clickDetector then
                            clickDetector.MaxActivationDistance = 0
                        end
                    end
                end
            end
        elseif chestGame.State == "Conclusion" then
            -- Conclusion state - hide all indicators and disable interaction
            chestChosenIndicator.SurfaceGui.Enabled = false
            chestForbidIndicator.SurfaceGui.Enabled = false
            chestAllowIndicator.SurfaceGui.Enabled = false
            if clickDetector then
                clickDetector.MaxActivationDistance = 0
            end
        else
            -- Default state - hide all indicators
            chestChosenIndicator.SurfaceGui.Enabled = false
            chestForbidIndicator.SurfaceGui.Enabled = false
            chestAllowIndicator.SurfaceGui.Enabled = false
            if clickDetector then
                clickDetector.MaxActivationDistance = 0
            end
        end
    end
end

function IChestGameRenderer.renderGridChests(chestGameID : string, activeParticipantID : string)
    local rendered = {}

    IChestGameRenderer.cleanOldChestRendering(chestGameID)

    local chestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    local chestGameInstance : Model? = StreamingLibClient.getInstance(chestGame.InstanceStreamableID)

    if chestGameInstance == nil then
        return
    end

    local origin : CFrame = chestGameInstance.Mat:GetPivot()
    local participantCount : number = ChestGameHelper.countParticipantsByID(chestGameID)    
    local activeParticipant : ChestGameDataTypes.ChestGameParticipant? = chestGame.Participants[activeParticipantID]

    if participantCount == 0 then
        return
    end

    local totalChests = ChestGameHelper.getTotalChests(chestGame)
    for chestNum : number = 1, totalChests do
        local gridX : number, gridY : number = ChestGameHelper.getChestGridPosition(chestGame, chestNum)
        local participantIndex : number = ((chestNum-1) % participantCount) + 1
        local _, participant : ChestGameDataTypes.ChestGameParticipant? = ChestGameHelper.getParticipantByIndex(chestGameID, participantIndex)
        
        if not participant then
            continue
        end
        
        local chestType : string = participant.ChestType
        local chestPrefab : Model? = ChestPrefabs:FindFirstChild(chestType)

        if chestPrefab == nil then
            continue
        end

        local chestRenderModel = chestPrefab:Clone()
        chestRenderModel:PivotTo(origin * CFrame.new(gridX,0,gridY))
        chestRenderModel.Parent = chestGameInstance

        local chestChosenIndicator = ChestChosenIndicator:Clone()
        chestChosenIndicator:PivotTo(chestRenderModel:GetPivot())
        chestChosenIndicator.SurfaceGui.Enabled = if activeParticipant and table.find(activeParticipant.ChosenChests, chestNum) then true else false
        chestChosenIndicator.Parent = chestRenderModel

        local chestAllowIndicator = ChestAllowIndicator:Clone()
        chestAllowIndicator:PivotTo(chestRenderModel:GetPivot())
        chestAllowIndicator.SurfaceGui.Enabled = false
        chestAllowIndicator.Parent = chestRenderModel

        local chestForbidIndicator = ChestForbidIndicator:Clone()
        chestForbidIndicator:PivotTo(chestRenderModel:GetPivot())
        chestForbidIndicator.SurfaceGui.Enabled = false
        chestForbidIndicator.Parent = chestRenderModel
        
        rendered[chestNum] = chestRenderModel
    end

    ChestRenderMemory[chestGameID] = rendered

    return rendered
end

function IChestGameRenderer.renderInteractableChests(chestGameID : string, activeParticipantID : string, callback : (chestNum : number) -> ())
    local rendered = IChestGameRenderer.renderGridChests(chestGameID, activeParticipantID)

    for chestNum : number, chestRenderModel : Model in rendered do
        local clickDetector = Instance.new("ClickDetector")
        clickDetector.MaxActivationDistance = math.huge
        clickDetector.Parent = chestRenderModel
        clickDetector.MouseClick:Connect(function()
            callback(chestNum)
        end)
    end

    return rendered
end

function IChestGameRenderer.renderChairs(chestGameID : string)
    IChestGameRenderer.cleanOldChairRendering(chestGameID)

    local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    local chestGameInstance : Instance? = StreamingLibClient.getInstance(chestGame.InstanceStreamableID)

    if not chestGameInstance then
        return
    end

    local rendered : {[string] : Model} = {}

    for _, seat : Seat in chestGameInstance.Seats:GetChildren() :: {Seat} do
        local participantID : string = seat.Name
        local participant : ChestGameDataTypes.ChestGameParticipant? = chestGame.Participants[participantID]
        local chairType : string = if participant then (participant.ChairType or chestGame.DefaultChairType) else chestGame.DefaultChairType
        local chairPrefab : Model? = ChairPrefabs:FindFirstChild(chairType)

        if not chairPrefab then
            continue
        end

        local chairInstance : Model = chairPrefab:Clone()
        chairInstance:PivotTo(seat.CFrame)
        chairInstance.Parent = chestGameInstance
        rendered[participantID] = chairInstance
    end

    ChairRenderMemory[chestGameID] = rendered
    return rendered
end

return IChestGameRenderer

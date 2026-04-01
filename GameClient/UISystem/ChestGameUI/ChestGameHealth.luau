local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local ChestGameDataTypes = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameState)
local StreamingLibClient = require(ReplicatedStorage.TLib.StreamingLib.StreamingLibClient)
local UILib = require(ReplicatedStorage.TLib.UILib)

local ChestGameHealthUIPrefab = ReplicatedStorage.Resources.UIPrefabs.Billboards.ChestGameHealth

local ChestGameHealthViewers = {} :: {[string] : {[number] : typeof(UILib.Viewer())}}

local function handleChestGame(chestGameID: string, chestGame: ChestGameDataTypes.ChestGame)
    -- Clean up existing health UI for this chest game
    if ChestGameHealthViewers[chestGameID] then
        for _, viewer in ChestGameHealthViewers[chestGameID] do
            viewer:Destroy()
        end
        ChestGameHealthViewers[chestGameID] = nil
    end

    -- Get chest game instance
    local chestGameInstance: Model? = StreamingLibClient.getInstance(chestGame.InstanceStreamableID)
    if not chestGameInstance then
        return
    end

    -- Create health UI for each participant seat position
    local healthViewers = {}
    for participantID, participant in chestGame.Participants do
        -- Find the seat for this participant's index
        local seat = chestGameInstance.SeatPositions:FindFirstChild(participantID)
        
        if seat then
            -- Create health UI viewer
            local healthViewer = UILib.Viewer()
            healthViewer:Hydrate(ChestGameHealthUIPrefab:Clone())
            healthViewer:AutoParent()
            healthViewer.Tree.Adornee = seat
            
            -- Update initial health
            local healthString = ("❤ "):rep(participant.HealthPoints)
            healthViewer:SetLabel("Health", healthString)
            
            -- Store viewer by participant index
            healthViewers[participant.Index] = healthViewer
        end
    end
    
    ChestGameHealthViewers[chestGameID] = healthViewers
end

local function updateHealthUI(chestGameID: string)
    local chestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    if not chestGame then
        return
    end

    local healthViewers = ChestGameHealthViewers[chestGameID]
    if not healthViewers then
        return
    end

    -- Update health for each participant
    for participantID, participant in chestGame.Participants do
        local viewer = healthViewers[participant.Index]
        if viewer then
            -- Update health text
            local healthString = ("❤ "):rep(participant.HealthPoints)

            if participant.HealthPoints <= 0 then
                healthString = "💀"
            end

            viewer:SetLabel("Health", healthString)
        end
    end
end

local function cleanupChestGame(chestGameID: string)
    if ChestGameHealthViewers[chestGameID] then
        for _, viewer in ChestGameHealthViewers[chestGameID] do
            viewer:Destroy()
        end
        ChestGameHealthViewers[chestGameID] = nil
    end
end

BootEvents.NetworkStarted:Connect(function()
    -- Handle existing chest games
    for chestGameID: string, chestGame: ChestGameDataTypes.ChestGame in ChestGameState.Data.ChestGameCollection do
        task.spawn(handleChestGame, chestGameID, chestGame)
    end

    -- Listen for new chest games
    ChestGameState.createChestGame.listen(handleChestGame)
    
    -- Listen for health changes
    ChestGameState.reduceHealthPoints.listen(updateHealthUI)
    ChestGameState.eliminateParticipant.listen(updateHealthUI)
    
    -- Listen for participant changes
    ChestGameState.addParticipant.listen(function(chestGameID: string)
        local chestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
        if chestGame then
            handleChestGame(chestGameID, chestGame)
        end
    end)
    
    ChestGameState.removeParticipant.listen(function(chestGameID: string)
        local chestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
        if chestGame then
            handleChestGame(chestGameID, chestGame)
        end
    end)
    
    -- Listen for state changes to cleanup
    ChestGameState.changeState.listen(function(chestGameID: string, state: ChestGameDataTypes.ChestGameState)
        if state == "Dormant" then
            cleanupChestGame(chestGameID)
        end
    end)
end)

return nil

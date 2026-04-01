local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local ChestGameDataTypes = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameDataTypes)
local ChestGameConfigurations = require(ReplicatedStorage.GameDefinitions.ChestGameSystem.ChestGameConfigurations)
local ChestGameState = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameState)
local StreamingLib = require(ReplicatedStorage.TLib.StreamingLib)

local CHEST_GAME_TAG = "ChestGame"

local function handleChestGameInstance(chestGameInstance : Instance)
    local chestGameType = chestGameInstance:GetAttribute("ChestGameType")
    assert(chestGameType, "ChestGameType attribute is required!")
    
    local config = ChestGameConfigurations[chestGameType]
    assert(config, `Invalid ChestGameType: {chestGameType}`)
    
    local chestGameID : string = HttpService:GenerateGUID(false)
    local chestGame : ChestGameDataTypes.ChestGame = {
        InstanceStreamableID = StreamingLib.getID(chestGameInstance),
        State = "Dormant",
        GridSizeX = config.GRID_SIZE_X,
        GridSizeY = config.GRID_SIZE_Y,
        MaxChestChoice = config.MAX_CHEST_CHOICE,
        TurnTimer = config.TURN_TIMER,
        MaxPlayers = config.MAX_PLAYERS,
        TimerMin = nil,
        TimerMax = nil,
        CurrentTurnParticipantID = nil,
        AnimationEnds = nil,
        OpenedChests = {},
        DefaultChairType = chestGameInstance:GetAttribute("DefaultChairType") or "OakChair",
        Participants = {},
        WinnerPrimaryRewardRange = NumberRange.new(80, 100),
        LoserPrimaryRewardRange = NumberRange.new(10, 15),
        WinnerTrophyRewardRange = NumberRange.new(5, 10),
        LoserTrophyRewardRange = NumberRange.new(0, 1)
    }

    ChestGameState:GetServer().createChestGame(chestGameID, chestGame)
end

BootEvents.NetworkStarted:Connect(function()
    for _, chestGameInstance : Instance in CollectionService:GetTagged(CHEST_GAME_TAG) do
        task.spawn(handleChestGameInstance, chestGameInstance)
    end

    CollectionService:GetInstanceAddedSignal(CHEST_GAME_TAG):Connect(handleChestGameInstance)
end)

return nil

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ChestGameDataTypes = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameDataTypes)
local ChestGameState = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameState)
local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileSystemTypes)
local StreamingLibServer = require(ReplicatedStorage.TLib.StreamingLib.StreamingLibServer)

local function getPlayerChairType(player : Player)
    local userIDString : string = `{player.UserId}`
    local profile : ProfileSystemTypes.Profile = ProfileState.Data.Profiles[userIDString]

    if profile and profile.ChairEquippedType then
        return profile.ChairEquippedType
    end

    return nil
end

local function getPlayerChestType(player : Player)
    local userIDString : string = `{player.UserId}`
    local profile : ProfileSystemTypes.Profile = ProfileState.Data.Profiles[userIDString]

    if profile and profile.ChestEquippedType then
        return profile.ChestEquippedType
    end

    return nil
end

local function onPlayerSeated(chestGameID : string, chestGame : ChestGameDataTypes.ChestGame, player : Player, participantID : string, index : number)
    local participant : ChestGameDataTypes.ChestGameParticipant = {
        UserIDString = `{player.UserId}`,
        ChosenChests = {},
        HealthPoints = 3,
        HealthPointsMax = 3,
        ChestType = getPlayerChestType(player) or "OakChest",
        ChairType = getPlayerChairType(player) or chestGame.DefaultChairType,
        Index = index
    }

    ChestGameState:GetServer().addParticipant(chestGameID, participantID, participant)
end

local function onPlayerUnseated(chestGameID : string, player : Player, participantID : string)
    local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]

    if chestGame.Participants[participantID] == nil then
        return
    end

    ChestGameState:GetServer().removeParticipant(chestGameID, participantID)
end

local function addAIParticipants(chestGameID: string, chestGame: ChestGameDataTypes.ChestGame)
    local chestGameInstance : Instance = StreamingLibServer.getInstance(chestGame.InstanceStreamableID)
    local seatsFolder : Folder = chestGameInstance.Seats
    local seats = seatsFolder:GetChildren()

    for i, seat : Seat in seats do
        if i >= #seats then
            continue
        end
        
        local participantID = seat.Name

        ChestGameState:GetServer().addParticipant(chestGameID, participantID, {
            UserIDString = `0`,
            ChosenChests = {},
            HealthPoints = 3,
            HealthPointsMax = 3,
            ChestType = "ObsidianChest",
            ChairType = chestGame.DefaultChairType,
            Index = seat:GetAttribute("ParticipantIndex"),
        })
    end
end

local function onChestGameCreated(chestGameID: string, chestGame : ChestGameDataTypes.ChestGame)
    local chestGameInstance : Instance = StreamingLibServer.getInstance(chestGame.InstanceStreamableID)
    local seatsFolder : Folder = chestGameInstance.Seats

    for _, seat : Seat in seatsFolder:GetChildren() :: {Seat} do
        local oldPlayer : Player? = nil
        
        seat:GetPropertyChangedSignal("Occupant"):Connect(function()
            local character : Model? = seat.Occupant and seat.Occupant.Parent
            local player : Player? = character and Players:GetPlayerFromCharacter(character)

            if player ~= nil then
                onPlayerSeated(chestGameID, chestGame, player, seat.Name, seat:GetAttribute("ParticipantIndex"))

                oldPlayer = player
            elseif player == nil and oldPlayer ~= nil then
                onPlayerUnseated(chestGameID, oldPlayer, seat.Name)
            end
        end)
    end

    if RunService:IsStudio() then
        addAIParticipants(chestGameID, chestGame)
    end
end

ChestGameState.createChestGame.listenInOrder(2, onChestGameCreated)

return nil

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestGameDataTypes = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameDataTypes)
local ChestGameState = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameState)
local StreamingLibServer = require(ReplicatedStorage.TLib.StreamingLib.StreamingLibServer)

ChestGameState.createChestGame.listen(function(chestGameID: string, chestGame : ChestGameDataTypes.ChestGame)
    local chestGameInstance : Instance = StreamingLibServer.getInstance(chestGame.InstanceStreamableID)
    
    local seatPositions = chestGameInstance:FindFirstChild("SeatPositions")
    if seatPositions then
        local seatsFolder = Instance.new("Folder")
        seatsFolder.Name = "Seats"
        seatsFolder.Parent = chestGameInstance
        
        for _, positionPart : Instance in seatPositions:GetChildren() do
            if positionPart:IsA("BasePart") then
                local seat = Instance.new("Seat")
                seat:SetAttribute("ParticipantIndex", positionPart:GetAttribute("ParticipantIndex"))
                seat.Anchored = true
                seat.CanCollide = false
                seat.Transparency = 1
                seat.CFrame = positionPart.CFrame
                seat.Size = Vector3.new(3,0.5,3)
                seat.Name = positionPart.Name
                seat.Parent = seatsFolder
            end
        end
    end
end)

return nil

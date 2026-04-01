local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local ChestGameHelper = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameState)

local function onChestOpened(chestGameID: string, participantID: string, chestNum: number)
    if ChestGameHelper.isBadChest(chestGameID, chestNum) ~= true then
        return
    end

    ChestGameState:GetServer().reduceHealthPoints(chestGameID, participantID, 1)
end

BootEvents.NetworkStarted:Connect(function()
    ChestGameState.openChest.listen(onChestOpened)
end)

return nil

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)
local NetLibServer = require(ReplicatedStorage.TLib.NetLib.NetLibServer)

local RE_EquipChest = NetLibServer.RemoteEvent("InventorySystem/EquipChest")

RE_EquipChest.OnServerEvent:Connect(function(player : Player, chestType : string)
    ProfileState:GetServer().equipChest(`{player.UserId}`, chestType)
end)

return nil

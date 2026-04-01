local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)
local NetLibServer = require(ReplicatedStorage.TLib.NetLib.NetLibServer)

local RE_EquipChair = NetLibServer.RemoteEvent("InventorySystem/EquipChair")

RE_EquipChair.OnServerEvent:Connect(function(player : Player, chairType : string)
    ProfileState:GetServer().equipChair(`{player.UserId}`, chairType)
end)

return nil
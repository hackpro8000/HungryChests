local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryViewer = require(ReplicatedStorage.GameClient.UISystem.InventoryUI.InventoryViewer)
local PlayerStatsViewer = require(ReplicatedStorage.GameClient.UISystem.PlayerStatsUI.PlayerStatsViewer)

PlayerStatsViewer.InteractionContext:GetButton("OpenInventory"):ListenLMB(function(isDown : boolean)
    if isDown then
        return
    end

    InventoryViewer:SetVisible(true)
end)

return nil

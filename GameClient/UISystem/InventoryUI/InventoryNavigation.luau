local InventoryNavigator = require(script.Parent.InventoryNavigator)
local InventoryViewer = require(script.Parent.InventoryViewer)

for _, tabName : string in {"Chests", "Chairs", "PowerUps"} do
    InventoryViewer.InteractionContext:GetButton(`TabSelector/{tabName}`):ListenLMB(function(isDown : boolean)
        if isDown == true then
            return
        end

        InventoryNavigator.toTab(tabName)
    end)
end

return nil

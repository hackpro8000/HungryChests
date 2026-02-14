local InventoryViewer = require(script.Parent.InventoryViewer)

InventoryViewer.InteractionContext:GetButton("Close"):ListenLMB(function(isDown : boolean)
    if isDown == true then
        return
    end

    InventoryViewer:SetVisible(false)
end)

return nil

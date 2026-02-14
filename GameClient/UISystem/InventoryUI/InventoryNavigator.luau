local InventoryViewer = require(script.Parent.InventoryViewer)
local InventoryNavigator = {}

function InventoryNavigator.toTab(tabName : string)
    local tabLayout : UIPageLayout = InventoryViewer:FromRef("TabLayout")
    local tab : GuiObject? = InventoryViewer:FromRef(`Tabs/{tabName}`)

    tabLayout:JumpTo(tab)
end

return InventoryNavigator

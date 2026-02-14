local MarketplaceViewer = require(script.Parent.MarketplaceViewer)
local MarketplaceNavigator = {}

function MarketplaceNavigator.toTab(tabName : string)
    local tabLayout : UIPageLayout = MarketplaceViewer:FromRef("TabLayout")
    local tab : GuiObject? = MarketplaceViewer:FromRef(`Tabs/{tabName}`)

    tabLayout:JumpTo(tab)
end

return MarketplaceNavigator

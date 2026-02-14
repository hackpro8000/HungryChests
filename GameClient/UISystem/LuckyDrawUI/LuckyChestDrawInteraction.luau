local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LuckyDrawNetworker = require(ReplicatedStorage.GameClient.LuckyDrawSystem.LuckyDrawNetworker)
local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local LuckyChestDrawViewer = require(script.Parent.LuckyChestDrawViewer)
local ProductIDMap = require(ReplicatedStorage.GameDefinitions.MarketplaceSystem.ProductIDMap)

local LocalPlayer = Players.LocalPlayer

LuckyChestDrawViewer.InteractionContext:GetButton("CommonDraw1"):ListenLMB(function(isDown : boolean)
    if isDown == true then
        return
    end

    LuckyDrawNetworker.requestLuckyDraw("LuckyChestDraw", "Common", 1)
end)

LuckyChestDrawViewer.InteractionContext:GetButton("CommonDraw5"):ListenLMB(function(isDown : boolean)
    if isDown == true then
        return
    end

    LuckyDrawNetworker.requestLuckyDraw("LuckyChestDraw", "Common", 5)
end)

LuckyChestDrawViewer.InteractionContext:GetButton("PremiumDraw1"):ListenLMB(function(isDown : boolean)
    if isDown == true then
        return
    end

    MarketplaceService:PromptProductPurchase(LocalPlayer, ProductIDMap.LuckyChestDrawPremium)
end)

LuckyChestDrawViewer.InteractionContext:GetButton("PremiumDraw5"):ListenLMB(function(isDown : boolean)
    if isDown == true then
        return
    end

    MarketplaceService:PromptProductPurchase(LocalPlayer, ProductIDMap.LuckyChestDrawPremium5)
end)

local function onLuckyChestDrawInstanceAdded(luckyChestDrawInstance : Instance)
    local proximityPrompt : ProximityPrompt = luckyChestDrawInstance.Interaction.ProximityPrompt

    proximityPrompt.PromptShown:Connect(function()
        LuckyChestDrawViewer.Tree.Adornee = luckyChestDrawInstance.Interaction
        LuckyChestDrawViewer:SetVisible(true)
    end)

    proximityPrompt.PromptHidden:Connect(function()
        LuckyChestDrawViewer:SetVisible(false)
    end)
end

local function startInteraction()
    for _, luckyChestDrawInstance : Instance in CollectionService:GetTagged("LuckyChestDraw") do
        onLuckyChestDrawInstanceAdded(luckyChestDrawInstance)
    end

    CollectionService:GetInstanceAddedSignal("LuckyChestDraw"):Connect(onLuckyChestDrawInstanceAdded)
end

BootEvents.NetworkStarted:Connect(function()
    startInteraction()
end)

return nil

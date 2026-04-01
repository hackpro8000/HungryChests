local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LuckyChairDrawViewer = require(script.Parent.LuckyChairDrawViewer)
local LuckyDrawNetworker = require(ReplicatedStorage.GameClient.LuckyDrawSystem.LuckyDrawNetworker)
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local ProductIDMap = require(ReplicatedStorage.GameDefinitions.MarketplaceSystem.ProductIDMap)

local LocalPlayer = Players.LocalPlayer

LuckyChairDrawViewer.InteractionContext:GetButton("CommonDraw1"):ListenLMB(function(isDown : boolean)
    if isDown == true then
        return
    end

    LuckyDrawNetworker.requestLuckyDraw("LuckyChairDraw", "Common", 1)

    task.wait(2)
end)

LuckyChairDrawViewer.InteractionContext:GetButton("CommonDraw5"):ListenLMB(function(isDown : boolean)
    if isDown == true then
        return
    end

    LuckyDrawNetworker.requestLuckyDraw("LuckyChairDraw", "Common", 5)

    task.wait(2)
end)

LuckyChairDrawViewer.InteractionContext:GetButton("PremiumDraw1"):ListenLMB(function(isDown : boolean)
    if isDown == true then
        return
    end

    MarketplaceService:PromptProductPurchase(LocalPlayer, ProductIDMap.LuckyChairDrawPremium)
end)

LuckyChairDrawViewer.InteractionContext:GetButton("PremiumDraw5"):ListenLMB(function(isDown : boolean)
    if isDown == true then
        return
    end

    MarketplaceService:PromptProductPurchase(LocalPlayer, ProductIDMap.LuckyChairDrawPremium5)
end)

local function onLuckyChairDrawInstanceAdded(luckyChairDrawInstance : Instance)
    local proximityPrompt : ProximityPrompt = luckyChairDrawInstance.Interaction.ProximityPrompt

    proximityPrompt.PromptShown:Connect(function()
        LuckyChairDrawViewer.Tree.Adornee = luckyChairDrawInstance.Interaction
        LuckyChairDrawViewer:SetVisible(true)
    end)

    proximityPrompt.PromptHidden:Connect(function()
        LuckyChairDrawViewer:SetVisible(false)
    end)
end

local function startInteraction()
    for _, luckyChairDrawInstance : Instance in CollectionService:GetTagged("LuckyChairDraw") do
        onLuckyChairDrawInstanceAdded(luckyChairDrawInstance)
    end

    CollectionService:GetInstanceAddedSignal("LuckyChairDraw"):Connect(onLuckyChairDrawInstanceAdded)
end

BootEvents.NetworkStarted:Connect(function()
    startInteraction()
end)

return nil

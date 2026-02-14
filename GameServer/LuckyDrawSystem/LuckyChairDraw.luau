local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ToastNotificationSender = require(ServerScriptService.GameServer.ToastNotificationSystem.ToastNotificationSender)
local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local LuckyDrawEvents = require(ReplicatedStorage.GameCommons.LuckyDrawSystem.LuckyDrawEvents)
local LuckyDrawHelper = require(ReplicatedStorage.GameCommons.LuckyDrawSystem.LuckyDrawHelper)
local LuckyDrawState = require(ReplicatedStorage.GameCommons.LuckyDrawSystem.LuckyDrawState)
local LuckyDrawTypes = require(ReplicatedStorage.GameCommons.LuckyDrawSystem.LuckyDrawTypes)
local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileSystemTypes)
local LuckyChairDrawPool = require(ReplicatedStorage.GameDefinitions.LuckyDrawSystem.LuckyChairDraw.LuckyChairDrawPool)
local LuckyChairCommonTier = require(ReplicatedStorage.GameDefinitions.LuckyDrawSystem.LuckyChairDraw.LuckyChairCommonTier)
local LuckyChairPremiumTier = require(ReplicatedStorage.GameDefinitions.LuckyDrawSystem.LuckyChairDraw.LuckyChairPremiumTier)

local LUCKY_DRAW_ID = "LuckyChairDraw"
local BASE_DRAW_COST = 500
local DRAW_5_COST = 2200

LuckyDrawEvents.LuckyDrawRequested:Connect(function(luckyDrawRequest: LuckyDrawTypes.LuckyDrawRequest)
    if luckyDrawRequest:GetLuckyDrawID() ~= LUCKY_DRAW_ID then
        return
    end
    
    local userIDString = `{luckyDrawRequest:GetPlayer().UserId}`
    local prizeIDs : {string} = LuckyDrawHelper.evaluateLuckyDrawRequest(luckyDrawRequest)
    local profile : ProfileSystemTypes.Profile? = ProfileState.Data.Profiles[userIDString]
    local drawCost : number = BASE_DRAW_COST * luckyDrawRequest:GetQuantity()

    --[[
        Prevent illegal requests via
        client-sided script injection
    ]]
    if luckyDrawRequest:GetTierID() == "Premium" then
        if luckyDrawRequest:IsIAP() == false then
            luckyDrawRequest:GetPlayer():Kick("Illegal request!")

            return
        end
    end

    --[[
        Ensure profile exists
    ]]
    if profile == nil then
        luckyDrawRequest:Deny("NilProfile")
        
        return
    end

    --[[
        Give a 13.6% discount for bulk draws
    ]]
    if luckyDrawRequest:GetQuantity() == 5 then
        drawCost = DRAW_5_COST
    end

    --[[
        Ensure player has enough coins
    ]]
    if profile.Currencies.Primary < drawCost then
        luckyDrawRequest:Deny("InsufficientCurrency.Primary")

        return
    end

    --[[
        Ensure player received what they paid for, otherwise deny the draw request.
    ]]
    if #prizeIDs == luckyDrawRequest:GetQuantity() then
        --[[
            Award the prizes.
        ]]        
        for _, prizeID in prizeIDs do
            print(`Received prize ID: {prizeID}!`)
            ProfileState:GetServer().ownChair(userIDString, prizeID)
        end

        ToastNotificationSender.sendNotification(Players:GetPlayerByUserId(tonumber(userIDString)), `Received: {table.concat(prizeIDs, ", ")}`, 5)

        --[[
            If not an IAP, take currency from the profile.
        ]]
        if luckyDrawRequest:IsIAP() == false then
            ProfileState:GetServer().takeCurrency(userIDString, "Primary", drawCost)
        end

        luckyDrawRequest:Confirm(prizeIDs)
    else
        luckyDrawRequest:Deny("NoPrizes")
    end
end)

--[[
    HANDLE REGISTRATION UPON STARTUP
]]
BootEvents.NetworkStarted:Connect(function()
    -- REGISTER LUCKY DRAW BELOW HERE
    LuckyDrawState:GetServer().registerLuckyDraw(LUCKY_DRAW_ID)

    -- ADD POOLS BELOW HERE
    LuckyDrawState:GetServer().addPool(LUCKY_DRAW_ID, "Default", LuckyChairDrawPool)

    -- ADD TIERS BELOW HERE
    LuckyDrawState:GetServer().addTier(LUCKY_DRAW_ID, "Common", LuckyChairCommonTier)
    LuckyDrawState:GetServer().addTier(LUCKY_DRAW_ID, "Premium", LuckyChairPremiumTier)
end)

return nil

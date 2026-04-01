local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ToastNotificationSender = require(ServerScriptService.GameServer.ToastNotificationSystem.ToastNotificationSender)
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local LuckyDrawEvents = require(ReplicatedStorage.GameCommon.LuckyDrawSystem.LuckyDrawEvents)
local LuckyDrawHelper = require(ReplicatedStorage.GameCommon.LuckyDrawSystem.LuckyDrawHelper)
local LuckyDrawState = require(ReplicatedStorage.GameCommon.LuckyDrawSystem.LuckyDrawState)
local LuckyDrawTypes = require(ReplicatedStorage.GameCommon.LuckyDrawSystem.LuckyDrawTypes)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileSystemTypes)
local LuckyChestDrawPool = require(ReplicatedStorage.GameDefinitions.LuckyDrawSystem.LuckyChestDraw.LuckyChestDrawPool)
local LuckyChestCommonTier = require(ReplicatedStorage.GameDefinitions.LuckyDrawSystem.LuckyChestDraw.LuckyChestCommonTier)
local LuckyChestDrawPrefabs = require(ReplicatedStorage.GameDefinitions.LuckyDrawSystem.LuckyChestDraw.LuckyChestDrawPrefabs)
local LuckyChestPremiumTier = require(ReplicatedStorage.GameDefinitions.LuckyDrawSystem.LuckyChestDraw.LuckyChestPremiumTier)

local LUCKY_DRAW_ID = "LuckyChestDraw"
local BASE_DRAW_COST = 500
local DRAW_5_COST = 2200
local DUPLICATE_COMPENSATION = 200

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
    if profile.Currencies.Primary < drawCost and not luckyDrawRequest:IsIAP() then
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
            --[[
                Handle duplicates
            ]]
            if profile.ChestInventory[prizeID] then
                ProfileState:GetServer().giveCurrency(userIDString, "Primary", DUPLICATE_COMPENSATION)
                
                continue
            end
            
            print(`Received prize ID: {prizeID}!`)
            
            ProfileState:GetServer().ownChest(userIDString, prizeID)
        end

        -- ToastNotificationSender.sendNotification(Players:GetPlayerByUserId(tonumber(userIDString)), `Received: {table.concat(prizeIDs, ", ")}`, 5)

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
    LuckyDrawState:GetServer().addPool(LUCKY_DRAW_ID, "Default", LuckyChestDrawPool)

    -- SET PREFABS BELOW HERE
    LuckyDrawState:GetServer().setPrefabs(LUCKY_DRAW_ID, LuckyChestDrawPrefabs)

    -- ADD TIERS BELOW HERE
    LuckyDrawState:GetServer().addTier(LUCKY_DRAW_ID, "Common", LuckyChestCommonTier)
    LuckyDrawState:GetServer().addTier(LUCKY_DRAW_ID, "Premium", LuckyChestPremiumTier)
end)

return nil

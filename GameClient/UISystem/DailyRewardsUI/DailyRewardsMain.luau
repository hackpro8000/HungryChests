


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DailyRewardsViewer = require(script.Parent.DailyRewardsViewer)
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local NetLibClient = require(ReplicatedStorage.TLib.NetLib.NetLibClient)
local DailyRewardState = require(ReplicatedStorage.GameCommon.DailyRewardSystem.DailyRewardState)
local DailyRewardTypes = require(ReplicatedStorage.GameCommon.DailyRewardSystem.DailyRewardTypes)
local UILib = require(ReplicatedStorage.TLib.UILib)

local RF_ClaimReward = NetLibClient.RemoteFunction("DailyRewardSystem/ClaimReward")

local LocalPlayer = Players.LocalPlayer
local UserIDString = tostring(LocalPlayer.UserId)

local CellViewers = {}

local function initCellViewers()
    for i, cell : Frame in DailyRewardsViewer:FromRef("CellContainer"):GetChildren() do
        if not cell:IsA("Frame") then
            continue
        end
        
        local rewardIndex = cell:GetAttribute("RewardIndex")

        if not rewardIndex then
            continue
        end
    
        local cellViewer = UILib.Viewer()
        cellViewer:Hydrate(cell)
        local claimButton : typeof(UILib.ButtonBasic()) = cellViewer.InteractionContext:GetButton("Claim")
        
        claimButton:ListenLMB(function(isDown : boolean)
            if isDown then
                return
            end
            
            local success, result = RF_ClaimReward:InvokeServer(rewardIndex)

            if not success then
                warn("Failed to claim reward:", result)
            end
        end)

        CellViewers[rewardIndex] = cellViewer
    end
end

local function updateCellViewers(dailyTracker : DailyRewardTypes.DailyTracker)
    print(dailyTracker)
    for rewardIndex : number, cellViewer : typeof(UILib.Viewer()) in CellViewers do
        local dailyReward : DailyRewardTypes.DailyReward? = dailyTracker.DailyRewardMap[rewardIndex]
        
        if dailyReward == nil then
            continue
        end

        local isClaimable = table.find(dailyTracker.ClaimableRewards, rewardIndex)
        local isClaimed = table.find(dailyTracker.ClaimedRewards, rewardIndex)
        local claimButton : typeof(UILib.ButtonBasic()) = cellViewer.InteractionContext:GetButton("Claim")

        if isClaimable then
            if isClaimed then
                cellViewer:SetLabelVisible("Locked", false)
                cellViewer:SetLabelVisible("Claimed", true)
                claimButton.buttonInstance.Visible = false
            else
                cellViewer:SetLabelVisible("Locked", false)
                cellViewer:SetLabelVisible("Claimed", false)
                claimButton.buttonInstance.Visible = true
            end
        else
            cellViewer:SetLabelVisible("Locked", true)
            cellViewer:SetLabelVisible("Claimed", false)
        end
    end
end

local function onDailyTrackerUpdated(dailyTrackerID : string)
    if dailyTrackerID ~= UserIDString then
        return
    end

    local dailyTracker = DailyRewardState.Data.DailyTrackers[dailyTrackerID]
    if dailyTracker then
        updateCellViewers(dailyTracker)
    end
end

local function onDailyTrackerAdded(dailyTrackerID : string, dailyTracker : DailyRewardTypes.DailyTracker)
    for _, rewardIndex : number in dailyTracker.ClaimableRewards do
        if table.find(dailyTracker.ClaimedRewards, rewardIndex) then
            continue
        end

        DailyRewardsViewer:SetVisible(true)

        break
    end
    
    onDailyTrackerUpdated(dailyTrackerID)
end

BootEvents.NetworkStarted:Connect(function()
    initCellViewers()

    for dailyTrackerID : string, dailyTracker in DailyRewardState.Data.DailyTrackers do
        onDailyTrackerAdded(dailyTrackerID, dailyTracker)
    end

    -- Listen to all daily tracker state changes
    DailyRewardState.addDailyTracker.listen(onDailyTrackerAdded)
    DailyRewardState.incrementStreak.listen(onDailyTrackerUpdated)
    DailyRewardState.claimReward.listen(onDailyTrackerUpdated)
    DailyRewardState.resetDailyTracker.listen(onDailyTrackerUpdated)
    DailyRewardState.addClaimableReward.listen(onDailyTrackerUpdated)
end)

return nil

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngagementRewardsViewer = require(script.Parent.EngagementRewardsViewer)
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local EngagementRewardState = require(ReplicatedStorage.GameCommon.EngagementRewardSystem.EngagementRewardState)
local EngagementRewardTypes = require(ReplicatedStorage.GameCommon.EngagementRewardSystem.EngagementRewardTypes)
local UILib = require(ReplicatedStorage.TLib.UILib)
local NetLibClient = require(ReplicatedStorage.TLib.NetLib.NetLibClient)

local LocalPlayer = Players.LocalPlayer
local RF_ClaimReward = NetLibClient.RemoteFunction("EngagementRewardSystem/ClaimReward")

local CellViewers = {} :: {typeof(UILib.Viewer())}

local function onEngagementTrackerUpdated(engagementTracker : EngagementRewardTypes.EngagementTracker)
    for i, engagementReward : EngagementRewardTypes.EngagementReward in engagementTracker.EngagementRewardMap do
        local cellViewer = CellViewers[i]
        local barContainer = cellViewer:FromRef("BarContainer")
        local barFill = cellViewer:FromRef("BarFill")
        local padlockGrey = cellViewer:FromRef("PadlockGrey")
        local padlockGreen = cellViewer:FromRef("PadlockGreen")
        local claimButton = cellViewer.InteractionContext:GetButton("Claim")

        if i == engagementTracker.EngagementRewardIndex then
            -- CURRENT REWARD
            cellViewer.Tree.GroupTransparency = 0
            local completionFactor = engagementTracker.TimeSpent / engagementReward.Interval
            barFill.Position = UDim2.fromScale(completionFactor, 0)
            barContainer.Visible = true
            padlockGrey.Visible = false
            padlockGreen.Visible = false

            if completionFactor >= 1 then
                claimButton.buttonInstance.Visible = true
            else
                claimButton.buttonInstance.Visible = false
            end
        elseif i == engagementTracker.EngagementRewardIndex + 1 then
            -- NEXT REWARD
            cellViewer.Tree.GroupTransparency = 0.2
            barContainer.Visible = false
            claimButton.buttonInstance.Visible = false
            padlockGrey.Visible = false
            padlockGreen.Visible = true
        elseif i < engagementTracker.EngagementRewardIndex then
            -- ALREADY CLAIMED
            barFill.Position = UDim2.fromScale(1, 0)
            cellViewer.Tree.GroupTransparency = 0.2
            barContainer.Visible = true
            claimButton.buttonInstance.Visible = false
            padlockGrey.Visible = false
            padlockGreen.Visible = false
        else
            -- NOT YET REACHABLE
            cellViewer.Tree.GroupTransparency = 0.5
            barContainer.Visible = false
            claimButton.buttonInstance.Visible = false
            padlockGrey.Visible = true
            padlockGreen.Visible = false
        end
    end
end

local function onEngagementTrackerAdded(engagementTracker : EngagementRewardTypes.EngagementTracker)
    for i, engagementReward : EngagementRewardTypes.EngagementReward in engagementTracker.EngagementRewardMap do
        local cellViewer = UILib.Viewer()
        cellViewer:Hydrate(EngagementRewardsViewer:FromRef("CellTemplate"):Clone())
        cellViewer:SetParent(EngagementRewardsViewer:FromRef("CellContainer"))
        
        cellViewer:SetLabel("SubstituteIcon", engagementReward.Reward)

        cellViewer.InteractionContext:GetButton("Claim"):ListenLMB(function(isDown : boolean)
            if isDown then
                return
            end

            local success, errorMessage = RF_ClaimReward:InvokeServer()
            
            if not success then
                warn(`Failed to claim reward: {errorMessage}`)
            end
        end)

        CellViewers[i] = cellViewer
    end

    onEngagementTrackerUpdated(engagementTracker)
end

BootEvents.NetworkStarted:Connect(function()
    if EngagementRewardState.Data.EngagementTrackers[`{LocalPlayer.UserId}`] then
        onEngagementTrackerAdded(EngagementRewardState.Data.EngagementTrackers[`{LocalPlayer.UserId}`])
    end
    
    EngagementRewardState.addEngagementTracker.listen(function(engagementTrackerID: string, engagementTracker: EngagementRewardTypes.EngagementTracker)
        if engagementTrackerID ~= `{LocalPlayer.UserId}` then
            return
        end
        
        onEngagementTrackerAdded(engagementTracker)
    end)

    EngagementRewardState.addTimeSpent.listen(function(engagementTrackerID: string, timeSpent: number)
        if engagementTrackerID ~= `{LocalPlayer.UserId}` then
            return
        end
        
        local engagementTracker = EngagementRewardState.Data.EngagementTrackers[`{LocalPlayer.UserId}`]

        if engagementTracker then
            onEngagementTrackerUpdated(engagementTracker)
        end
    end)

    EngagementRewardState.claimReward.listen(function(engagementTrackerID: string)
        if engagementTrackerID ~= `{LocalPlayer.UserId}` then
            return
        end
        
        local engagementTracker = EngagementRewardState.Data.EngagementTrackers[`{LocalPlayer.UserId}`]

        if engagementTracker then
            onEngagementTrackerUpdated(engagementTracker)
        end
    end)
end)

return nil

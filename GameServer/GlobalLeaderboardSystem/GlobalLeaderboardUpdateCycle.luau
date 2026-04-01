local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local GlobalLeaderboardEvents = require(ReplicatedStorage.GameCommon.GlobalLeaderboardSystem.GlobalLeaderboardEvents)

local function downloadData()
    task.wait(1)

    while true do
        GlobalLeaderboardEvents.OnDownload:Fire()

        task.wait(70)
    end
end

local function uploadData()
    task.wait(1)

    while true do
        GlobalLeaderboardEvents.OnUpload:Fire()

        task.wait(70)
    end
end

BootEvents.NetworkStarted:Connect(function()
    GlobalLeaderboardEvents.PreBoot:Fire()
    task.spawn(downloadData)
    task.spawn(uploadData)
end)

return nil
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetLibClient = require(ReplicatedStorage.TLib.NetLib.NetLibClient)
local ToastNotificationEvents = require(script.Parent.ToastNotificationEvents)

local RE_SendToastNotification = NetLibClient.RemoteEvent("ToastNotificationSystem/SendToastNotification")

RE_SendToastNotification.OnClientEvent:Connect(function(messageText : string)
    ToastNotificationEvents.NotificationReceived:Fire(messageText)
end)

return nil

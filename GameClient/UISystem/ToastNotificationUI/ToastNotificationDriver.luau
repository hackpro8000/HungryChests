local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ToastNotificationViewer = require(script.Parent.ToastNotificationViewer)
local ToastNotificationEvents = require(ReplicatedStorage.GameClient.ToastNotificationSystem.ToastNotificationEvents)

local ToastNotificationTemplate = ToastNotificationViewer.Tree.TopCenterAnchor.NotificationTemplate

ToastNotificationEvents.NotificationReceived:Connect(function(messageText: string, duration : number)
    local toastNotification = ToastNotificationTemplate:Clone()
    toastNotification.Text = messageText
    toastNotification.Visible = true
    toastNotification.Parent = ToastNotificationViewer.Tree.TopCenterAnchor
    
    Debris:AddItem(toastNotification, duration)
end)

return nil

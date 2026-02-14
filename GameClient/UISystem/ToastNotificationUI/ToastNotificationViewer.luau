local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UILib = require(ReplicatedStorage.TLib.UILib)

local ToastNotificationViewer = UILib.Viewer()
ToastNotificationViewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Screens.ToastNotifications:Clone())
ToastNotificationViewer:AutoParent()

return ToastNotificationViewer

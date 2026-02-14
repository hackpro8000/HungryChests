local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetLibServer = require(ReplicatedStorage.TLib.NetLib.NetLibServer)

local RE_SendToastNotification = NetLibServer.RemoteEvent("ToastNotificationSystem/SendToastNotification")

local ToastNotificationSender = {}

function ToastNotificationSender.sendNotification(recipient : Player | "All", messageText : string, duration : number)
    if recipient == "All" then
        RE_SendToastNotification:FireAllClients(messageText, duration)
    else
        RE_SendToastNotification:FireClient(recipient, messageText, duration)
    end
end

return ToastNotificationSender

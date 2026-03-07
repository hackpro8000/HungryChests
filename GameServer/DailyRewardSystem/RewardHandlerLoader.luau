local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModuleLib = require(ReplicatedStorage.TLib.ModuleLib)

ModuleLib.LoadChildren(script.Parent.RewardHandlers)

return nil

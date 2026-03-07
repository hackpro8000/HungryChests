local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModuleLib = require(ReplicatedStorage.TLib.ModuleLib)

return ModuleLib.LoadChildren(script, "Serial")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local Load = require(ReplicatedStorage.GameCommons.BootSystem.Load)
local LoadChildren = require(ReplicatedStorage.GameCommons.BootSystem.LoadChildren)
local DataLib = require(ReplicatedStorage.TLib.DataLib)

BootEvents.SystemStarting:Fire(); do
    for _, systemFolder : Folder in script.Parent.Parent:GetChildren() do
        local systemStartupModule : ModuleScript? = systemFolder:FindFirstChild("#SYSTEMSTARTUP")
        
        if systemStartupModule then
            Load(systemStartupModule)
        else
            LoadChildren(systemFolder)
        end
    end
end; BootEvents.SystemStarted:FireDeferred()

BootEvents.NetworkStarting:Fire(); do
    DataLib.Networking:Start()    
end; BootEvents.NetworkStarted:FireDeferred()
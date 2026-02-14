local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModuleLib = require(ReplicatedStorage.TLib.ModuleLib)

for _, systemFolder : Folder in script.Parent:GetChildren() do
    if not systemFolder:IsA("Folder") then
        continue
    end
    
    ModuleLib.LoadChildren(systemFolder, "Parallel")
end

return nil

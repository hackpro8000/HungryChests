local ContentProvider = game:GetService("ContentProvider")

local AssetLoader = {}
AssetLoader.__index = AssetLoader

function AssetLoader.new()
    local self = setmetatable({}, AssetLoader)

    self.assetsToLoad = {}
    self.loadedAssets = {}

    return self
end

function AssetLoader.CollectDescendants(self : typeof(AssetLoader.new()), parent : Instance)
    for _, descendant in parent:GetDescendants() do
        if descendant:IsA("Folder") then
            return
        end
        
        table.insert(self.assetsToLoad, descendant)
    end
end

return AssetLoader

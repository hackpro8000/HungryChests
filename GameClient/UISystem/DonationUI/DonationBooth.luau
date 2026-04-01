local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProductIDMap = require(ReplicatedStorage.GameDefinitions.MarketplaceSystem.ProductIDMap)
local CleanerLib = require(ReplicatedStorage.TLib.CleanerLib)
local UILib = require(ReplicatedStorage.TLib.UILib)

local DonationBooth = {}
DonationBooth.__index = DonationBooth

function DonationBooth.new(instance : Model)
    local self = setmetatable({}, DonationBooth)

    self.__cleaner = CleanerLib.Cleaner()

    self.Instance = instance
    self.Viewer = UILib.Viewer()
    self.Viewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Billboards.Donations)
    self.Viewer:AutoParent()
    self.Viewer.Tree.Adornee = instance.BillboardAdornee

    self:__dealWithInput()

    return self
end

function DonationBooth.__buttonPressed(self : typeof(DonationBooth.new()), productRef : string)
    local productID : number = ProductIDMap[productRef]

    MarketplaceService:PromptProductPurchase(Players.LocalPlayer, productID)
end

function DonationBooth.__dealWithInput(self : typeof(DonationBooth.new()))
    for _, listCell : Frame in self.Viewer:ChildrenFromRef("List") do
        if not listCell:IsA("Frame") then
            continue
        end

        local button : typeof(UILib.ButtonBasic()) = UILib.ButtonBasic(listCell.Button)

        self.__cleaner:Add(button)
        button:ListenLMB(function(isDown : boolean)
            if isDown == true then
                return
            end
            
            self:__buttonPressed(listCell.Name)
        end)
    end
end

function DonationBooth.Destroy(self : typeof(DonationBooth.new()))
    
end

return DonationBooth

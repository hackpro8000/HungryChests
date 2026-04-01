local CollectionService = game:GetService("CollectionService")

local DonationBooth = require(script.Parent.DonationBooth)

local DonationBooths = {} :: {[Model] : typeof(DonationBooth.new())}

local function onDonationBoothInstanceAdded(donationBoothInstance : Model)
    local donationBooth = DonationBooth.new(donationBoothInstance)

    DonationBooths[donationBoothInstance] = donationBooth
end

local function onDonationBoothInstanceRemoved(donationBoothInstance : Model)
    
end

for _, donationBoothInstance : Model in CollectionService:GetTagged("DonationBooth") do
    onDonationBoothInstanceAdded(donationBoothInstance)
end

CollectionService:GetInstanceAddedSignal("DonationBooth"):Connect(onDonationBoothInstanceAdded)
CollectionService:GetInstanceRemovedSignal("DonationBooth"):Connect(onDonationBoothInstanceRemoved)

return nil

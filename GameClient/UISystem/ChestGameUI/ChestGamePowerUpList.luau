local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrderedSignal = require(ReplicatedStorage.TLib.OrderedSignal)
local OrderedSignalTypes = require(ReplicatedStorage.TLib.OrderedSignal.OrderedSignalTypes)
local UILib = require(ReplicatedStorage.TLib.UILib)
local ChestGameViewer = require(script.Parent.ChestGameViewer)

local PowerUpButtonPrefab : TextButton = ChestGameViewer:FromRef("PowerUpButtonTemplate")
local ListInstance : Frame = ChestGameViewer:FromRef("PowerUpButtonList")

local PowerUpButtonCollection = {} :: {[string] : typeof(UILib.ButtonBasic())}

local ChestGamePowerUpList = {}
ChestGamePowerUpList.OnPowerUpTriggered = OrderedSignal.new() :: OrderedSignalTypes.OrderedSignal<(powerUpID : string) -> ()>

function ChestGamePowerUpList.showPowerUp(powerUpID : string)
    local buttonInstance = PowerUpButtonPrefab:Clone()
    buttonInstance.Parent = ListInstance
    
    local button = UILib.ButtonBasic(buttonInstance)

    PowerUpButtonCollection[powerUpID] = button
end

function ChestGamePowerUpList.hidePowerUp(powerUpID : string)
    local button = PowerUpButtonCollection[powerUpID]

    button:Destroy()

    PowerUpButtonCollection[powerUpID] = nil
end

return ChestGamePowerUpList

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local ChestGameDataTypes = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameState)
local NetLibClient = require(ReplicatedStorage.TLib.NetLib.NetLibClient)
local StreamingLibClient = require(ReplicatedStorage.TLib.StreamingLib.StreamingLibClient)
local ChestInteractible = require(script.Parent.ChestInteractible)

local RE_ChooseChest = NetLibClient.RemoteEvent("ChestGameSystem/ChooseChest")
local RE_OpenChest = NetLibClient.RemoteEvent("ChestGameSystem/OpenChest")

local LocalPlayer = Players.LocalPlayer

local Interactibles = {} :: { [string]: { ChestInteractible.ChestInteractible } }

local function onChestClicked(chestGameID: string, chestNum: number)
	local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]

    if chestGame.State == "ChoosingChests" then
        RE_ChooseChest:FireServer(chestNum)
    elseif chestGame.State == "InAction" then
        RE_OpenChest:FireServer(chestNum)
    end
end

local function onChestGameUpdated(chestGameID: string)
	local enableInteractions: boolean = false
	local chestGameInteractibles = Interactibles[chestGameID]
	local chestGame: ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    local state : ChestGameDataTypes.ChestGameState = chestGame.State
	local activeChestGameID: string, _: ChestGameDataTypes.ChestGame, activeParticipantID: string =
		ChestGameHelper.getPlayerChestGame(LocalPlayer)

	if chestGameInteractibles == nil then
		return
	end

	if state == "ChoosingChests" then
        enableInteractions = true
	elseif state == "InAction" then
        if chestGame.CurrentTurn and chestGame.CurrentTurn.ParticipantID == activeParticipantID then
            enableInteractions = true
        end
	end

	if activeChestGameID ~= chestGameID then
		enableInteractions = false
	end

	if enableInteractions == true then
		for chestNum: number, chestInteractible: ChestInteractible.ChestInteractible in chestGameInteractibles do
			chestInteractible:Enable()
		end
	else
		for chestNum: number, chestInteractible: ChestInteractible.ChestInteractible in chestGameInteractibles do
			chestInteractible:Disable()
		end
	end
end

--[[
    Bulky initialization code (MAY BE DISTRACTING PAST THIS POINT)
]]
local function onChestGameCreated(chestGameID: string, chestGame: ChestGameDataTypes.ChestGame)
	local function streamedIn(chestGameInstance: Instance)
		Interactibles[chestGameID] = {}

		local totalChests = ChestGameHelper.getTotalChests(chestGame)

		for chestNum: number = 1, totalChests, 1 do
			local gridX: number, gridY: number = ChestGameHelper.getChestGridXY(chestGame, chestNum)
			local cframe: CFrame = chestGameInstance.Mat.CFrame * CFrame.new(gridX, 2, gridY)
			local chestInteractible: ChestInteractible.ChestInteractible = ChestInteractible.new(cframe)

			chestInteractible.ClickDetector.MouseClick:Connect(function()
				onChestClicked(chestGameID, chestNum)
			end)

			Interactibles[chestGameID][chestNum] = chestInteractible
		end
	end

	local function streamedOut()
		local chestGameInteractibles = Interactibles[chestGameID]

		if chestGameInteractibles ~= nil then
			for chestNum: number, chestInteractible: ChestInteractible.ChestInteractible in chestGameInteractibles do
				chestInteractible:Destroy()
			end
		end

		Interactibles[chestGameID] = nil
	end

    if StreamingLibClient.getInstance(chestGame.InstanceStreamableID) then
        streamedIn(StreamingLibClient.getInstance(chestGame.InstanceStreamableID))
    end
	StreamingLibClient.listenToInstanceStreamedIn(chestGame.InstanceStreamableID, streamedIn)
	StreamingLibClient.listenToInstanceStreamedOut(chestGame.InstanceStreamableID, streamedOut)
end

BootEvents.NetworkStarted:Connect(function()
	for chestGameID: string, chestGame: ChestGameDataTypes.ChestGame in ChestGameState.Data.ChestGameCollection do
		task.spawn(onChestGameCreated, chestGameID, chestGame)
	end

	ChestGameState.createChestGame.listen(onChestGameCreated)
	ChestGameState.changeState.listen(onChestGameUpdated)
    ChestGameState.nextTurn.listen(onChestGameUpdated)
end)

return nil

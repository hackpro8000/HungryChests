local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileSystemTypes = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileSystemTypes)
local PromiseLib = require(ReplicatedStorage.TLib.PromiseLib)

local MainDataStore = DataStoreService:GetDataStore("MainDataStore")

local MainDataStoreManager = {}

function MainDataStoreManager.getMainDataStore()
    return MainDataStore
end

function MainDataStoreManager.setSave(key : string, profile : ProfileSystemTypes.Profile, maxAttempts : number?) : PromiseLibTypes.Promise<() -> ()>
    maxAttempts = maxAttempts or 3

    return PromiseLib.new(function(resolve: () -> (), reject: (err : string?, attempts : number?) -> (), onCancel: (() -> ()) -> boolean, onCleanup: () -> ())
        local currentAttempts = 0
        local latestErr : string? = nil

        local function saveData()
            MainDataStore:SetAsync(key, profile)
        end

        while currentAttempts < maxAttempts do
            if DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync) > 0 then
                local success, err = pcall(saveData)

                if success then
                    resolve()
                    return
                else
                    warn(err)
                    latestErr = err
                end

                currentAttempts += 1
            end; task.wait()
        end

        reject(latestErr, currentAttempts)
    end)
end

return MainDataStoreManager

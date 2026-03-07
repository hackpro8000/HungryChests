
local RewardProcessRequest = {}
RewardProcessRequest.__index = RewardProcessRequest

function RewardProcessRequest.new(engagementTrackerID : string, reward : string)
    local self = setmetatable({}, RewardProcessRequest)

    self.__engagementTrackerID = engagementTrackerID
    self.__reward = reward
    self.__parsed = reward:split(":")
    self.__status = "Pending" :: "Pending" | "Confirmed" | "Denied"
    self.__statusError = nil :: string?

    return self
end

function RewardProcessRequest.ParseReward(self, parseInfo : string)
    local desiredType, argIndex = parseInfo:match("^(%w+):(%d+)$")
    argIndex = tonumber(argIndex)

    local rawString : string = assert(self.__parsed[argIndex], `ArgIndex {argIndex} is out of range!`)

    if desiredType == "number" then
        return tonumber(rawString)
    end

    return rawString
end

function RewardProcessRequest.GetStatus(self)
    return self.__status
end

function RewardProcessRequest.GetStatusError(self)
    return self.__statusError
end

function RewardProcessRequest.IsPending(self)
    return self.__status == "Pending"
end

function RewardProcessRequest.IsConfirmed(self)
    return self.__status == "Confirmed"
end

function RewardProcessRequest.IsDenied(self)
    return self.__status == "Denied"
end

function RewardProcessRequest.Confirm(self)
    self.__status = "Confirmed"
end

function RewardProcessRequest.Deny(self, reason : string)
    self.__status = "Denied"
    self.__statusError = reason
end

return RewardProcessRequest

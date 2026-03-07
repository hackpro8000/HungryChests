local DailyRewardProcessRequest = {}
DailyRewardProcessRequest.__index = DailyRewardProcessRequest

function DailyRewardProcessRequest.new(dailyTrackerID : string, reward : string)
    local self = setmetatable({}, DailyRewardProcessRequest)

    self.__dailyTrackerID = dailyTrackerID
    self.__reward = reward
    self.__parsed = {}
    self.__status = "Pending" :: "Pending" | "Confirmed" | "Denied"
    self.__statusError = nil :: string?
    self:__parse()

    return self
end

function DailyRewardProcessRequest.__parse(self)
    local brokenDownRewards = self.__reward:split("&")
    
    for i, reward : string in brokenDownRewards do
        local rewardSplit : {string} = reward:split(":")
        local rewardType : string = rewardSplit[1]

        self.__parsed[rewardType] = {}

        for j = 2, #rewardSplit do
            table.insert(self.__parsed[rewardType], rewardSplit[j])
        end
    end
end

function DailyRewardProcessRequest.ParseReward(self, parseInfo : string)
    local desiredType, argIndex = parseInfo:match("^(%w+):(%d+)$")
    argIndex = tonumber(argIndex)

    local rawString : string = assert(self.__parsed[argIndex], `ArgIndex {argIndex} is out of range!`)

    if desiredType == "number" then
        return tonumber(rawString)
    end

    return rawString
end

function DailyRewardProcessRequest.GetRewardArgs(self, rewardType : string) : ...any
    local args = self.__parsed[rewardType]
    if not args or #args == 0 then
        return nil
    end
    
    return unpack(args)
end

function DailyRewardProcessRequest.ContainsReward(self, rewardType : string) : boolean
    return self.__parsed[rewardType] ~= nil
end

function DailyRewardProcessRequest.GetStatus(self)
    return self.__status
end

function DailyRewardProcessRequest.GetStatusError(self)
    return self.__statusError
end

function DailyRewardProcessRequest.IsPending(self)
    return self.__status == "Pending"
end

function DailyRewardProcessRequest.IsConfirmed(self)
    return self.__status == "Confirmed"
end

function DailyRewardProcessRequest.IsDenied(self)
    return self.__status == "Denied"
end

function DailyRewardProcessRequest.Confirm(self)
    self.__status = "Confirmed"
end

function DailyRewardProcessRequest.Deny(self, reason : string)
    self.__status = "Denied"
    self.__statusError = reason
end

return DailyRewardProcessRequest

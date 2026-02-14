local LuckyDrawRequest = {}
LuckyDrawRequest.__index = LuckyDrawRequest

function LuckyDrawRequest.new(player : Player, luckyDrawID : string, tierID : string, quantity : number)
    local self = setmetatable({}, LuckyDrawRequest)

    self.__IAP = false
    self.__confirmed = false
    self.__denied = false
    self.__player = player
    self.__luckyDrawID = luckyDrawID
    self.__tierID = tierID
    self.__quantity = quantity

    return self
end

function LuckyDrawRequest.GetPlayer(self)
    return self.__player
end

function LuckyDrawRequest.GetLuckyDrawID(self)
    return self.__luckyDrawID
end

function LuckyDrawRequest.GetTierID(self)
    return self.__tierID
end

function LuckyDrawRequest.GetQuantity(self)
    return self.__quantity
end

function LuckyDrawRequest.GetResult(self)
    return self.__result
end

function LuckyDrawRequest.GetDenialResult(self)
    return self.__denialResult
end

function LuckyDrawRequest.IsIAP(self)
    return self.__IAP
end

function LuckyDrawRequest.IsConfirmed(self)
    return self.__confirmed
end

function LuckyDrawRequest.IsDenied(self)
    return self.__denied
end

function LuckyDrawRequest.DeclareIAP(self)
    self.__IAP = true
end

function LuckyDrawRequest.Deny(self, result : string)
    self.__denialResult = result
    self.__denied = true
end

function LuckyDrawRequest.Confirm(self, result : string)
    assert(result, "Cannot confirm lucky draw request without a result!")

    self.__result = result
    self.__confirmed = true
end

return LuckyDrawRequest

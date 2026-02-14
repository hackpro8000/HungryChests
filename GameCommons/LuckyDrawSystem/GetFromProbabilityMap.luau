--!nocheck

function sum(weightMap)
    local total = 0

    for _, weight in weightMap do
        total += weight
    end

    return total
end

function GetFromProbabilityMap<U>(weightMap, extraLuck) : U
    local w = sum(weightMap)
    local r = math.clamp(math.random()*w + (extraLuck or 0), 0, w)
    local c = 0

    for id, weight in weightMap do
        c+=weight

        if c >= r then
            return id
        end
    end
    
    print(weightMap)
    warn("No candidate, fix your weight map!\n")

    return
end

return GetFromProbabilityMap

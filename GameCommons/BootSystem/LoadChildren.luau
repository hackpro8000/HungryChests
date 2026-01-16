--!nocheck
local function TrackTime(childModule, warnFn)
    local startTime = os.clock()

    while true do
        task.wait(5)
        local timeElapsed = os.clock() - startTime

        if timeElapsed > 5 then
            warnFn(`{childModule:GetFullName()} is currently taking a while to load. ({timeElapsed//1}s)`)
        end
    end
end

local function Load(parent, failureFn, warnFn)
    for _, childModule : ModuleScript in parent:GetChildren() do
        if childModule:IsA("ModuleScript") then
            local trackTimeThread = task.spawn(TrackTime, childModule, warnFn or function() end)
            local success, result = pcall(require, childModule)

            if not success then
                failureFn(childModule, result)
            end

            task.cancel(trackTimeThread)
        end
    end
end

return Load


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

local function Load(moduleScript, failureFn, warnFn)
    assert(moduleScript:IsA("ModuleScript"), `ModuleScript expected, got: {moduleScript.ClassName}`)

    local trackTimeThread = task.spawn(TrackTime, moduleScript, warnFn or function() end)
    local success, result = pcall(require, moduleScript)

    if not success then
        failureFn(moduleScript, result)
    end

    task.cancel(trackTimeThread)
end

return Load


local function LoadErrorHandler(childModule, errorMessage)
    warn("Failed to load module:", childModule:GetFullName(), "\nError:", errorMessage)
end

return LoadErrorHandler

local Vehicle = require(script.Parent.Vehicle)

local vehicleID : string = Vehicle.fromInstance(workspace.TukTuk)

print(`Spawned vehicle with ID: {vehicleID}!`)

return nil

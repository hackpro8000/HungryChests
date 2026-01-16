local VehicleArithmetic = {}

function VehicleArithmetic.getTorqueCoefficient(currentRPM, peakRPM, redline, dropoffSharpness, dropoffDelay) : number
    assert(peakRPM > 0, "INVALID ENGINE MODEL! PeakRPM must always be greater than zero!")
    assert(redline > peakRPM, "INVALID ENGINE MODEL! Redline must always be greater than Peak RPM!")

    local dropoffCoeff = 1 - math.clamp(currentRPM ^ (((currentRPM-(redline-peakRPM)-peakRPM)/(redline-peakRPM)) * dropoffSharpness - dropoffDelay), 0, 1)
    local baseTorqueCoeff = math.sin((currentRPM/peakRPM) * (math.pi/2))

    return baseTorqueCoeff * dropoffCoeff
end

return VehicleArithmetic

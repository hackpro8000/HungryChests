export type Engine = {
    RPM : number,
    IdleRPM : number,
    Redline : number,
    PeakRPM : number,
    MaxTorqueNm : number,
    FrictionTorqueNm : number,
    TorqueDropoffSharpness : number,
    TorqueDropoffDelay : number,
    FlywheelWeightKG : number,
}

export type Clutch = {
    MaxTorqueTransferFromEngineNm : number,
    MaxTorqueTransferToEngineNm : number,
    TorqueTransferFromEngineCoeff : number,
    TorqueTransferToEngineCoeff : number,
    Engagement : number,
}

export type Transmission = {
    CurrentGear : number,
    FinalDrive : number,
    GearRatios : {
        [number] : number
    }
}

export type Wheel = {
    RPM : number,
    LocationOnVehicle : CFrame,
    LateralGripCoeff : number,
    LateralGripLimitKG : number,
    ForwardGripCoeff : number,
    ForwardGripLimitKG : number,
    Radius : number,
    SteerAngleInner : number,
    SteerAngleOuter : number,
    SpringLength : number,
    SpringMaxLength : number,
    SpringRestLength : number,
    SpringStiffnessCoeff : number,
    SpringStiffnessLimitNm : number,
    SpringDampingCoeff : number,
    SpringDampingLimitNm : number,
}

export type VehicleAssembly = {
    NetworkOwnerUserIDString : string,
    InstanceStreamableID : string,
    VehicleWeightKG : number,
    Engine : Engine,
    Clutch : Clutch,
    Transmission : Transmission,
    Wheels : {[string] : Wheel},
}

return nil

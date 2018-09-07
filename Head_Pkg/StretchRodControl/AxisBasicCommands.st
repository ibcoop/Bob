
(* Handle basic axis commands *)
FUNCTION AxisBasicCommands
    
    IF ((ADR(pStretchRod) = 0) OR (ADR(pCurrentStretchRod) = 0) OR (ADR(pLogArguments) = 0)) THEN
        AxisBasicCommands := FALSE;
        RETURN;
    END_IF
    
    AxisBasicCommands := FALSE;
    IF (pCurrentStretchRod.commands.powerOn = FALSE) THEN
        logDebug('StretchRod', 'Module %h, Head %h, Node %h Powering Off', ADR(pLogArguments));
        pStretchRod.MpAxisBasic_0.Power             := FALSE;
        pStretchRod.state                           := WAIT_FOR_POWER;
        AxisBasicCommands                           := TRUE;
    ELSIF (pCurrentStretchRod.commands.abort = TRUE) THEN
        logDebug('StretchRod', 'Module %h, Head %h, Node %h Abort', ADR(pLogArguments));
        pCurrentStretchRod.commands.abort           := FALSE;
        AxisBasicCommands                           := TRUE;
    ELSIF (pCurrentStretchRod.commands.home = TRUE) THEN
        pCurrentStretchRod.commands.home            := FALSE;
        logDebug('StretchRod', 'Module %h, Head %h, Node %h Homing Axis', ADR(pLogArguments));
         
        IF (pStretchRod.MpAxisBasic_0.IsHomed = TRUE) THEN
            logDebug('StretchRod', 'Module %h, Head %h, Node %h Axis already homed, just moving to the home position', ADR(pLogArguments));
            // if the axis has already been homed then just move to the home position
            pStretchRod.mpParams.Acceleration       := pCurrentStretchRod.parameters.machineData.manualAcceleration;
            pStretchRod.mpParams.Deceleration       := pCurrentStretchRod.parameters.machineData.manualDeceleration;
            pStretchRod.mpParams.Velocity           := pCurrentStretchRod.parameters.machineData.velocity;
            pStretchRod.mpParams.Position           := pCurrentStretchRod.parameters.machineData.home.position;
            pStretchRod.MpAxisBasic_0.MoveAbsolute  := TRUE;
            pStretchRod.state                       := IN_MOTION;
        ELSE
            IF ((pStretchRod.MpAxisBasic_0.Info.HardwareInfo.DeviceType = mpAXIS_ACOPOS_SIM) OR (DiagCpuIsSimulated() = TRUE)) THEN
                pStretchRod.mpParams.Home.Mode                              := mpAXIS_HOME_MODE_DIRECT;
                pStretchRod.mpParams.Home.ReferencePulse                    := mpAXIS_HOME_OPTION_OFF;
            ELSE
                pStretchRod.mpParams.Home.Mode                              := mpAXIS_HOME_MODE_LIMIT_SWITCH;
                pStretchRod.mpParams.Home.ReferencePulse                    := mpAXIS_HOME_OPTION_OFF;
            END_IF
            
            pStretchRod.mpParams.Home.SwitchEdge        := mpAXIS_HOME_DIR_NEGATIVE;
            pStretchRod.mpParams.Home.HomingDirection   := mpAXIS_HOME_DIR_POSITIVE;
            pStretchRod.mpParams.Home.Acceleration      := pCurrentStretchRod.parameters.machineData.home.acceleration;
            pStretchRod.mpParams.Home.StartVelocity     := pCurrentStretchRod.parameters.machineData.home.velocity;
            pStretchRod.mpParams.Home.HomingVelocity    := pCurrentStretchRod.parameters.machineData.home.velocity / 2.0;
            pStretchRod.mpParams.Home.Position          := pCurrentStretchRod.parameters.machineData.home.position;
            pStretchRod.mpParams.Home.TorqueLimit       := pCurrentStretchRod.parameters.machineData.home.torque;
            pStretchRod.MpAxisBasic_0.Home              := TRUE;
            pStretchRod.state                           := HOMING;
        END_IF
        
        AxisBasicCommands                           := TRUE;
    ELSIF (pCurrentStretchRod.commands.moveAbsolute = TRUE) THEN
        pCurrentStretchRod.commands.moveAbsolute    := FALSE;
        pLogArguments[3] := ADR(pCurrentStretchRod.parameters.machineData.position);
        logDebug('StretchRod', 'Module %h, Head %h, Node %h Move absolute to = %f', ADR(pLogArguments));
                    
        pStretchRod.mpParams.Position               := pCurrentStretchRod.parameters.machineData.position;
        pStretchRod.mpParams.Acceleration           := pCurrentStretchRod.parameters.machineData.manualAcceleration;
        pStretchRod.mpParams.Deceleration           := pCurrentStretchRod.parameters.machineData.manualDeceleration;
        pStretchRod.mpParams.Velocity               := pCurrentStretchRod.parameters.machineData.velocity;
        pStretchRod.MpAxisBasic_0.MoveAbsolute      := TRUE;
        pStretchRod.state                           := IN_MOTION;
        AxisBasicCommands                           := TRUE;
    ELSIF (pCurrentStretchRod.commands.jogNegative = TRUE) THEN
        logDebug('StretchRod', 'Module %h, Head %h, Node %h Jogging Negative', ADR(pLogArguments));
                    
        pStretchRod.mpParams.Jog.Acceleration       := pCurrentStretchRod.parameters.machineData.manualAcceleration;
        pStretchRod.mpParams.Jog.Deceleration       := pCurrentStretchRod.parameters.machineData.manualDeceleration;
        pStretchRod.mpParams.Jog.Velocity           := pCurrentStretchRod.parameters.machineData.velocity;
        pStretchRod.MpAxisBasic_0.JogNegative       := TRUE;
        pStretchRod.state                           := IN_MOTION;
        AxisBasicCommands                           := TRUE;
    ELSIF (pCurrentStretchRod.commands.jogPositive = TRUE) THEN
        logDebug('StretchRod', 'Module %h, Head %h, Node %h Jogging Positive', ADR(pLogArguments));
                    
        pStretchRod.mpParams.Jog.Acceleration       := pCurrentStretchRod.parameters.machineData.manualAcceleration;
        pStretchRod.mpParams.Jog.Deceleration       := pCurrentStretchRod.parameters.machineData.manualDeceleration;
        pStretchRod.mpParams.Jog.Velocity           := pCurrentStretchRod.parameters.machineData.velocity;
        pStretchRod.MpAxisBasic_0.JogPositive       := TRUE;
        pStretchRod.state                           := IN_MOTION;
        AxisBasicCommands                           := TRUE;
    END_IF
    
END_FUNCTION

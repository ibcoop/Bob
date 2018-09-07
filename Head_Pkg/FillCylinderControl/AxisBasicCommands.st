
(* Handle basic axis commands *)
FUNCTION AxisBasicCommands
    
    IF ((ADR(pFillPiston) = 0) OR (ADR(pCurrentPiston) = 0) OR (ADR(pLogArguments) = 0)) THEN
        AxisBasicCommands := FALSE;
        RETURN;
    END_IF
    
    AxisBasicCommands := FALSE;
    IF (pCurrentPiston.commands.powerOn = FALSE) THEN
        logDebug('FillPiston', 'Module %h, Head %h, Node %h Powering Off', ADR(pLogArguments));
        pFillPiston.MpAxisBasic_0.Power := FALSE;
        pFillPiston.state               := WAIT_FOR_POWER;
        AxisBasicCommands               := TRUE;
    ELSIF (pCurrentPiston.commands.abort = TRUE) THEN
        logDebug('FillPiston', 'Module %h, Head %h, Node %h Abort', ADR(pLogArguments));
        pCurrentPiston.commands.abort   := FALSE;
        AxisBasicCommands               := TRUE;
    ELSIF (pCurrentPiston.commands.home = TRUE) THEN
        pCurrentPiston.commands.home := FALSE;
        logDebug('FillPiston', 'Module %h, Head %h, Node %h Homing Axis', ADR(pLogArguments));
                   
        IF (pFillPiston.MpAxisBasic_0.IsHomed = TRUE) THEN
            logDebug('FillPiston', 'Module %h, Head %h, Node %h Axis already homed, just moving to the home position', ADR(pLogArguments));

            // if the axis has already been homed then just move to the home position
            pFillPiston.mpParams.Acceleration       := pCurrentPiston.parameters.machineData.manualAcceleration;
            pFillPiston.mpParams.Deceleration       := pCurrentPiston.parameters.machineData.manualDeceleration;
            pFillPiston.mpParams.Velocity           := pCurrentPiston.parameters.machineData.velocity;
            pFillPiston.mpParams.Position           := pCurrentPiston.parameters.machineData.home.position;
            pFillPiston.MpAxisBasic_0.MoveAbsolute  := TRUE;
            pFillPiston.state                       := IN_MOTION;
        ELSE

            IF (pFillPiston.MpAxisBasic_0.Info.HardwareInfo.DeviceType = mpAXIS_ACOPOS_SIM) THEN
                pFillPiston.mpParams.Home.Mode            := mpAXIS_HOME_MODE_DIRECT;
            ELSE
                pFillPiston.mpParams.Home.Mode            := mpAXIS_HOME_MODE_LIMIT_SWITCH;
            END_IF
            
            pFillPiston.mpParams.Home.SwitchEdge        := mpAXIS_HOME_DIR_NEGATIVE;
            pFillPiston.mpParams.Home.HomingDirection   := mpAXIS_HOME_DIR_POSITIVE;
            pFillPiston.mpParams.Home.Acceleration      := pCurrentPiston.parameters.machineData.home.acceleration;
            pFillPiston.mpParams.Home.StartVelocity     := pCurrentPiston.parameters.machineData.home.velocity;
            pFillPiston.mpParams.Home.HomingVelocity    := pCurrentPiston.parameters.machineData.home.velocity / 2.0;
            pFillPiston.mpParams.Home.Position          := pCurrentPiston.parameters.machineData.home.position;
            pFillPiston.mpParams.Home.TorqueLimit       := pCurrentPiston.parameters.machineData.home.torque;
            pFillPiston.MpAxisBasic_0.Home              := TRUE;
            pFillPiston.state                           := HOMING;
        END_IF
        
        AxisBasicCommands                                           := TRUE;
    ELSIF (pCurrentPiston.commands.moveAbsolute = TRUE) THEN
        pCurrentPiston.commands.moveAbsolute := FALSE;
        pLogArguments[3] := ADR(pCurrentPiston.parameters.machineData.position);
        logDebug('FillPiston', 'Module %h, Head %h, Node %h Move absolute to = %f', ADR(pLogArguments));
                    
        pFillPiston.mpParams.Acceleration       := pCurrentPiston.parameters.machineData.manualAcceleration;
        pFillPiston.mpParams.Deceleration       := pCurrentPiston.parameters.machineData.manualDeceleration;
        pFillPiston.mpParams.Velocity           := pCurrentPiston.parameters.machineData.velocity;
        pFillPiston.mpParams.Position           := pCurrentPiston.parameters.machineData.position;
        pFillPiston.MpAxisBasic_0.MoveAbsolute  := TRUE;
        pFillPiston.state                       := IN_MOTION;
        AxisBasicCommands                       := TRUE;
    ELSIF (pCurrentPiston.commands.jogNegative = TRUE) THEN
        logDebug('FillPiston', 'Module %h, Head %h, Node %h Jogging Negative', ADR(pLogArguments));
                    
        pFillPiston.mpParams.Jog.Acceleration   := pCurrentPiston.parameters.machineData.manualAcceleration;
        pFillPiston.mpParams.Jog.Deceleration   := pCurrentPiston.parameters.machineData.manualDeceleration;
        pFillPiston.mpParams.Jog.Velocity       := pCurrentPiston.parameters.machineData.velocity;
        pFillPiston.MpAxisBasic_0.JogNegative   := TRUE;
        pFillPiston.state                       := IN_MOTION;
        AxisBasicCommands                       := TRUE;
    ELSIF (pCurrentPiston.commands.jogPositive = TRUE) THEN
        logDebug('FillPiston', 'Module %h, Head %h, Node %h Jogging Positive', ADR(pLogArguments));
                    
        pFillPiston.mpParams.Jog.Acceleration   := pCurrentPiston.parameters.machineData.manualAcceleration;
        pFillPiston.mpParams.Jog.Deceleration   := pCurrentPiston.parameters.machineData.manualDeceleration;
        pFillPiston.mpParams.Jog.Velocity       := pCurrentPiston.parameters.machineData.velocity;
        pFillPiston.MpAxisBasic_0.JogPositive   := TRUE;
        pFillPiston.state                       := IN_MOTION;
        AxisBasicCommands                       := TRUE;
    END_IF
    
END_FUNCTION

ACTION productSupplyValveAction: 

    pCurrentValve ACCESS ADR(gModules[currentModule].productSupply.valve);
    pLocalValve ACCESS ADR(modules[currentModule].valve);
    
    IF (pCurrentValve.parameters.machineData.enabled = TRUE) THEN
        
        IF (((pCurrentValve.commands.open = TRUE) AND (pCurrentValve.commands.close = FALSE)) AND
            (pLocalValve.doOpen = FALSE)) THEN
            logDebug('Fill Valve', 'Module %h, Head %h, Open Command', ADR(logArguments));
            pLocalValve.doOpen := TRUE;
        END_IF
        
        IF (((pCurrentValve.commands.close = TRUE) AND (pCurrentValve.commands.open = FALSE)) AND
            (pLocalValve.doOpen = TRUE)) THEN
            logDebug('Fill Valve', 'Module %h, Head %h, Close Command', ADR(logArguments));
            pLocalValve.doOpen := FALSE;
        END_IF

        // 20ms debounce timer
        pLocalValve.openDebounceTimer.IN    := pLocalValve.diOpened;
        pLocalValve.openDebounceTimer.PT    := pCurrentValve.parameters.machineData.debounceTime;
        pLocalValve.openDebounceTimer();
                
        // 20ms debounce timer
        pLocalValve.closeDebounceTimer.IN := pLocalValve.diClosed;
        pLocalValve.closeDebounceTimer.PT := pCurrentValve.parameters.machineData.debounceTime;
        pLocalValve.closeDebounceTimer();
    
        // ensure that the valve opens
        pLocalValve.openErrorTimer.IN    := ((pCurrentValve.commands.open = TRUE) AND (pLocalValve.diOpened = FALSE));
        pLocalValve.openErrorTimer.PT    := pCurrentValve.parameters.machineData.timeout;
        pLocalValve.openErrorTimer();
    
        // ensure that the valve closes
        pLocalValve.closeErrorTimer.IN := ((pCurrentValve.commands.close = TRUE) AND (pLocalValve.diClosed = FALSE));
        pLocalValve.closeErrorTimer.PT := pCurrentValve.parameters.machineData.timeout;
        pLocalValve.closeErrorTimer();
    
        pCurrentValve.status.opened             := pLocalValve.openDebounceTimer.Q;
        pCurrentValve.status.closed             := pLocalValve.closeDebounceTimer.Q;
        pCurrentValve.status.centered           := ((pCurrentValve.status.opened <> TRUE) AND (pCurrentValve.status.closed <> TRUE));
        pCurrentValve.status.position           := 0;
        pCurrentValve.status.fullFlowAchieved   := FALSE;
        
        pLocalValve.openError_r_trig.CLK := pLocalValve.openErrorTimer.Q;
        pLocalValve.openError_r_trig();
        IF (pLocalValve.openError_r_trig.Q = TRUE) THEN
            valveErrorName := pLocalValve.valveName;
            MpAlarmXSet(gAlarmXCore, 'VALVE_NOT_OPENED');
        END_IF
        pLocalValve.openError_f_trig.CLK := pLocalValve.openErrorTimer.Q;
        pLocalValve.openError_f_trig();
        IF (pLocalValve.openError_f_trig.Q = TRUE) THEN
            MpAlarmXReset(gAlarmXCore, 'VALVE_NOT_OPENED');
        END_IF

        pLocalValve.closeError_r_trig.CLK := pLocalValve.closeErrorTimer.Q;
        pLocalValve.closeError_r_trig();
        IF (pLocalValve.closeError_r_trig.Q = TRUE) THEN
            valveErrorName := pLocalValve.valveName;
            MpAlarmXSet(gAlarmXCore, 'VALVE_NOT_CLOSED');
        END_IF
        pLocalValve.closeError_f_trig.CLK := pLocalValve.closeErrorTimer.Q;
        pLocalValve.closeError_f_trig();
        IF (pLocalValve.closeError_f_trig.Q = TRUE) THEN
            MpAlarmXReset(gAlarmXCore, 'VALVE_NOT_CLOSED');
        END_IF
        
        pLocalValve.open_and_close_error_r_trig.CLK := ((pCurrentValve.commands.open = TRUE) AND (pCurrentValve.commands.close = TRUE));
        pLocalValve.open_and_close_error_r_trig();
        IF (pLocalValve.open_and_close_error_r_trig.Q = TRUE) THEN
            valveErrorName := pLocalValve.valveName;
            MpAlarmXSet(gAlarmXCore, 'VALVE_COMMANDED_OPEN_AND_CLOSE');
        END_IF
        pLocalValve.open_and_close_error_f_trig.CLK := ((pCurrentValve.commands.open = TRUE) AND (pCurrentValve.commands.close = TRUE));
        pLocalValve.open_and_close_error_f_trig();
        IF (pLocalValve.open_and_close_error_f_trig.Q = TRUE) THEN
            MpAlarmXReset(gAlarmXCore, 'VALVE_COMMANDED_OPEN_AND_CLOSE');
        END_IF
        
        pLocalValve.io_error_r_trig.CLK := ((pLocalValve.inputModuleOk = FALSE) OR (pLocalValve.outputModuleOk = FALSE));
        pLocalValve.io_error_r_trig();
        IF (pLocalValve.io_error_r_trig.Q = TRUE) THEN
            valveErrorName := pLocalValve.valveName;
            MpAlarmXSet(gAlarmXCore, 'VALVE_IO_MISSING');
        END_IF
        pLocalValve.io_error_f_trig.CLK := ((pLocalValve.inputModuleOk = FALSE) OR (pLocalValve.outputModuleOk = FALSE));
        pLocalValve.openError_f_trig();
        IF (pLocalValve.openError_f_trig.Q = TRUE) THEN
            MpAlarmXReset(gAlarmXCore, 'VALVE_IO_MISSING');
        END_IF
        
        pCurrentValve.status.errorActive        := NOT((pLocalValve.inputModuleOk AND pLocalValve.outputModuleOk)) OR 
                                                      ((pLocalValve.closeErrorTimer.Q = TRUE) OR (pLocalValve.openErrorTimer.Q = TRUE)) OR 
                                                      ((pCurrentValve.commands.open = TRUE) AND (pCurrentValve.commands.close = TRUE));
        
        IF (pCurrentValve.commands.errorAcknowledge = TRUE) THEN
            pCurrentValve.commands.errorAcknowledge := FALSE;
        END_IF
    END_IF
    
END_ACTION

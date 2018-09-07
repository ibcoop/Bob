
// common code for handling valve alarms
// pLocalValve, pCurrentValve must be set to an valid point before the action is called
ACTION checkValveAlarms: 

    IF ((ADR(pLocalValve) <> 0) AND (ADR(pCurrentValve) <> 0)) THEN

        // ensure that the valve opens
        pLocalValve.openErrorTimer.IN    := ((pCurrentValve.commands.open = TRUE) AND (pLocalValve.diOpened = FALSE));
        pLocalValve.openErrorTimer.PT    := pCurrentValve.parameters.machineData.timeout;
        pLocalValve.openErrorTimer();

        IF pLocalValve.openErrorTimer.IN = TRUE THEN
            pCurrentValve.status.openTime :=	TIME_TO_REAL(pLocalValve.openErrorTimer.ET) / 1000.0;
        END_IF

        // ensure that the valve closes
        pLocalValve.closeErrorTimer.IN := ((pCurrentValve.commands.close = TRUE) AND (pLocalValve.diClosed = FALSE));
        pLocalValve.closeErrorTimer.PT := pCurrentValve.parameters.machineData.timeout;
        pLocalValve.closeErrorTimer();
        
        IF pLocalValve.closeErrorTimer.IN = TRUE THEN
            pCurrentValve.status.closeTime :=	TIME_TO_REAL(pLocalValve.closeErrorTimer.ET) / 1000.0;
        END_IF
        
        pLocalValve.openError_r_trig.CLK := pLocalValve.openErrorTimer.Q;
        pLocalValve.openError_r_trig();
        IF (pLocalValve.openError_r_trig.Q = TRUE) THEN
            valveErrorName := pLocalValve.valveName;
            logError(pLocalValve.valveName, 'Module %h, Head %h, valve did not open', ADR(logArguments));
            IF (pLocalValve.openAlarmID = 0) THEN
                pLocalValve.openAlarmID                := MpAlarmXSet(gAlarmXCore, 'VALVE_NOT_OPENED');
            ELSE
                logError(pLocalValve.valveName, 'Module %h, Head %h, valve did not open occurred when alarm already active', ADR(logArguments));
            END_IF
            
        END_IF

        pLocalValve.closeError_r_trig.CLK := pLocalValve.closeErrorTimer.Q;
        pLocalValve.closeError_r_trig();
        IF (pLocalValve.closeError_r_trig.Q = TRUE) THEN
            valveErrorName := pLocalValve.valveName;
            logError(pLocalValve.valveName, 'Module %h, Head %h, valve did not close', ADR(logArguments));
            IF (pLocalValve.closeAlarmID = 0) THEN
                pLocalValve.closeAlarmID                 := MpAlarmXSet(gAlarmXCore, 'VALVE_NOT_CLOSED');
            ELSE
                logError(pLocalValve.valveName, 'Module %h, Head %h, valve did not close occurred when alarm already active', ADR(logArguments));
            END_IF
        END_IF

        pLocalValve.open_and_close_error_r_trig.CLK := ((pCurrentValve.commands.open = TRUE) AND (pCurrentValve.commands.close = TRUE));
        pLocalValve.open_and_close_error_r_trig();
        IF (pLocalValve.open_and_close_error_r_trig.Q = TRUE) THEN
            valveErrorName      := pLocalValve.valveName;
            logError(pLocalValve.valveName, 'Module %h, Head %h, valve commanded open and close', ADR(logArguments));
            IF (pLocalValve.openAndCloseAlarmID = 0) THEN
                pLocalValve.openAndCloseAlarmID                 := MpAlarmXSet(gAlarmXCore, 'VALVE_COMMANDED_OPEN_AND_CLOSE');
            ELSE
                logError(pLocalValve.valveName, 'Module %h, Head %h, valve commanded open and close occurred when alarm already active', ADR(logArguments));
            END_IF
        END_IF

        pLocalValve.powerOnTimer.IN := gMachineControl.commands.powerOn;
        pLocalValve.powerOnTimer.PT := T#5s;
        pLocalValve.powerOnTimer();
        
        pLocalValve.io_error_r_trig.CLK := ((pLocalValve.inputModuleOk = FALSE) OR (pLocalValve.outputModuleOk = FALSE)) AND (pLocalValve.powerOnTimer.Q = TRUE);
        pLocalValve.io_error_r_trig();
        IF (pLocalValve.io_error_r_trig.Q = TRUE) THEN
            valveErrorName      := pLocalValve.valveName;
            logError(pLocalValve.valveName, 'Module %h, Head %h, valve io missing', ADR(logArguments));
            IF (pLocalValve.moduleOKAlarmID = 0) THEN
                pLocalValve.moduleOKAlarmID         := MpAlarmXSet(gAlarmXCore, 'VALVE_IO_MISSING');
            ELSE
                logError(pLocalValve.valveName, 'Module %h, Head %h, valve io missing occurred when alarm already active', ADR(logArguments));
            END_IF
        END_IF

        pLocalValve.io_error_f_trig.CLK := ((pLocalValve.inputModuleOk = FALSE) OR (pLocalValve.outputModuleOk = FALSE));
        pLocalValve.io_error_f_trig();
        IF (pLocalValve.io_error_f_trig.Q = TRUE) THEN
            MpAlarmXResetID(gAlarmXCore, pLocalValve.moduleOKAlarmID);
            pLocalValve.moduleOKAlarmID         := 0;
        END_IF
    END_IF
    
END_ACTION

ACTION handleValveErrors:

    IF ((ADR(pLocalValve) <> 0) AND (ADR(pCurrentValve) <> 0)) THEN

        pCurrentValve.status.errorActive        := ((pLocalValve.openAlarmID <> 0) OR (pLocalValve.closeAlarmID <> 0) OR (pLocalValve.openAndCloseAlarmID <> 0) OR (pLocalValve.moduleOKAlarmID <> 0));
        
        IF (pCurrentValve.status.errorActive = TRUE) THEN
            pCurrentValve.commands.close            := FALSE;
            pCurrentValve.commands.open             := FALSE;
        END_IF
        IF (pCurrentValve.commands.errorAcknowledge = TRUE) THEN
            pCurrentValve.commands.errorAcknowledge := FALSE;
            pCurrentValve.status.errorActive        := FALSE;
    
            IF (pLocalValve.openAlarmID <> 0) THEN
                logError(pLocalValve.valveName, 'Module %h, Head %h, Acknowledging Error', ADR(logArguments));
                IF (MpAlarmXResetID(gAlarmXCore, pLocalValve.openAlarmID) <> 0) THEN
                    logError(pLocalValve.valveName, 'Module %h, Head %h, Could not acknowledge alarm with ID, resetting all OPENED alarms', ADR(logArguments));
                    MpAlarmXReset(gAlarmXCore, 'VALVE_NOT_OPENED');
                END_IF
                pLocalValve.openAlarmID := 0;
            END_IF
    			
            IF (pLocalValve.closeAlarmID <> 0) THEN
                logError(pLocalValve.valveName, 'Module %h, Head %h, Acknowledging Error', ADR(logArguments));
                IF (MpAlarmXResetID(gAlarmXCore, pLocalValve.closeAlarmID) <> 0) THEN
                    logError(pLocalValve.valveName, 'Module %h, Head %h, Could not acknowledge alarm with ID, resetting all CLOSED alarms', ADR(logArguments));
                    MpAlarmXReset(gAlarmXCore, 'VALVE_NOT_CLOSED');
                END_IF
                pLocalValve.closeAlarmID := 0;
            END_IF
    
            IF (pLocalValve.openAndCloseAlarmID <> 0) THEN
                logError(pLocalValve.valveName, 'Module %h, Head %h, Acknowledging Error', ADR(logArguments));
                IF (MpAlarmXResetID(gAlarmXCore, pLocalValve.openAndCloseAlarmID) <> 0) THEN
                    logError(pLocalValve.valveName, 'Module %h, Head %h, Could not acknowledge alarm with ID, resetting all OPEN_AND_CLOSE alarms', ADR(logArguments));
                    MpAlarmXReset(gAlarmXCore, 'VALVE_COMMANDED_OPEN_AND_CLOSE');
                END_IF
                pLocalValve.openAndCloseAlarmID := 0;
            END_IF
        END_IF
    END_IF
    
END_ACTION
    
ACTION updateValveState: 

    IF ((ADR(pLocalValve) <> 0) AND (ADR(pCurrentValve) <> 0)) THEN

		//Set ValveState integer value for grphics
		pCurrentValve.status.valveState := 0;
		IF pLocalValve.doOpen = FALSE AND pLocalValve.diOpened = FALSE THEN
			pCurrentValve.status.valveState := 1;
		ELSIF pLocalValve.doOpen = TRUE AND pLocalValve.diOpened = FALSE THEN
			pCurrentValve.status.valveState := 2;
		ELSIF pLocalValve.doOpen = TRUE AND pLocalValve.diOpened = TRUE THEN
			pCurrentValve.status.valveState := 3;
		ELSIF pLocalValve.doOpen = FALSE AND pLocalValve.diOpened = TRUE THEN
			pCurrentValve.status.valveState := 4;
		ELSIF pLocalValve.doClose = FALSE AND pLocalValve.diClosed = FALSE THEN
			pCurrentValve.status.valveState := 5;
		ELSIF pLocalValve.doClose = TRUE AND pLocalValve.diClosed = FALSE THEN
			pCurrentValve.status.valveState := 6;
		ELSIF pLocalValve.doClose = TRUE AND pLocalValve.diClosed = TRUE THEN
			pCurrentValve.status.valveState := 7;
		ELSIF pLocalValve.doClose = FALSE AND pLocalValve.diClosed = TRUE THEN
			pCurrentValve.status.valveState := 8;
		END_IF
		
    END_IF
 
	
END_ACTION

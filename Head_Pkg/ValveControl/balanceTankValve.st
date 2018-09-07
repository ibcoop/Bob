
ACTION balanceTankAction: 
    
    pCurrentValve ACCESS ADR(gModules[currentModule].heads[currentHead].balanceTank);
    pLocalValve ACCESS ADR(balanceTankValve[indexOf(currentModule, currentHead, NUM_OF_HEADS_PER_MODULE)]);
            
	IF (pCurrentValve.parameters.machineData.enabled = TRUE) THEN
		IF (pCurrentValve.status.errorActive <> TRUE) THEN

			IF (((pCurrentValve.commands.open = TRUE) AND (pCurrentValve.commands.close = FALSE)) AND
				(pLocalValve.doOpen = FALSE)) THEN
				logDebug(pLocalValve.valveName, 'Module %h, Head %h, Open Command', ADR(logArguments));
				pLocalValve.doOpen := TRUE;
				pLocalValve.doClose := FALSE;
			END_IF
            
			IF (((pCurrentValve.commands.close = TRUE) AND (pCurrentValve.commands.open = FALSE)) AND
				(pLocalValve.doClose = FALSE)) THEN
				logDebug(pLocalValve.valveName, 'Module %h, Head %h, Close Command', ADR(logArguments));
				pLocalValve.doClose := TRUE;
				pLocalValve.doOpen := FALSE;
			END_IF
    
			IF (((pCurrentValve.commands.close = FALSE) AND (pCurrentValve.commands.open = FALSE)) AND 
				((pLocalValve.doClose <> FALSE) OR (pLocalValve.doOpen <> FALSE))) THEN
				logDebug(pLocalValve.valveName, 'Module %h, Head %h, Center Command', ADR(logArguments));
				pLocalValve.doClose := FALSE;
				pLocalValve.doOpen := FALSE;
			END_IF

		END_IF
        
		checkValveAlarms;
        updateValveState;
        
		// 20ms debounce timer
		pLocalValve.openDebounceTimer.IN    := pLocalValve.diOpened;
		pLocalValve.openDebounceTimer.PT    := pCurrentValve.parameters.machineData.debounceTime;
		pLocalValve.openDebounceTimer();
            
		// 20ms debounce timer
		pLocalValve.closeDebounceTimer.IN := pLocalValve.diClosed;
		pLocalValve.closeDebounceTimer.PT := pCurrentValve.parameters.machineData.debounceTime;
		pLocalValve.closeDebounceTimer();
        
		pCurrentValve.status.opened             := pLocalValve.openDebounceTimer.Q;
		pCurrentValve.status.closed             := pLocalValve.closeDebounceTimer.Q;
		pCurrentValve.status.centered           := ((pCurrentValve.status.opened <> TRUE) AND (pCurrentValve.status.closed <> TRUE));
		pCurrentValve.status.position           := 0;
		pCurrentValve.status.fullFlowAchieved   := FALSE;
        
        handleValveErrors;
        
    END_IF
    
END_ACTION

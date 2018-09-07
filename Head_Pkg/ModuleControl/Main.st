
PROGRAM _INIT
    modules[0].valve.valveName := 'Module 1 Supply Valve';
    modules[1].valve.valveName := 'Module 2 Supply Valve';
    
    MpRecipeRegPar_0[0].PVName := ADR('gModules[0].heads[0].enable');
    MpRecipeRegPar_0[1].PVName := ADR('gModules[0].heads[1].enable');
    MpRecipeRegPar_0[2].PVName := ADR('gModules[1].heads[0].enable');
    MpRecipeRegPar_0[3].PVName := ADR('gModules[1].heads[1].enable');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        MpRecipeRegPar_0[currentHead].MpLink := ADR(gMachineRecipe);
        MpRecipeRegPar_0[currentHead].Enable := TRUE;
        MpRecipeRegPar_0[currentHead].Category := ADR(MACHINE_CATEGORY);
        MpRecipeRegPar_0[currentHead]();
    END_FOR
    
	gModules[0].productSupply.parameters;
    MpRecipeRegPar_1[0].PVName := ADR('gModules[0].productSupply.parameters');
    MpRecipeRegPar_1[1].PVName := ADR('gModules[1].productSupply.parameters');
    
    FOR currentHead:=0 TO NUMBER_OF_MODULES_M1 DO
        MpRecipeRegPar_1[currentHead].MpLink := ADR(gMachineRecipe);
        MpRecipeRegPar_1[currentHead].Enable := TRUE;
        MpRecipeRegPar_1[currentHead].Category := ADR(MACHINE_CATEGORY);
        MpRecipeRegPar_1[currentHead]();
    END_FOR
    
    MpRecipeRegPar_2[0].PVName := ADR('gModules[0].heads[0].pressureTransducer.parameters');
    MpRecipeRegPar_2[1].PVName := ADR('gModules[0].heads[1].pressureTransducer.parameters');
    MpRecipeRegPar_2[2].PVName := ADR('gModules[1].heads[0].pressureTransducer.parameters');
    MpRecipeRegPar_2[3].PVName := ADR('gModules[1].heads[1].pressureTransducer.parameters');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        MpRecipeRegPar_2[currentHead].MpLink := ADR(gMachineRecipe);
        MpRecipeRegPar_2[currentHead].Enable := TRUE;
        MpRecipeRegPar_2[currentHead].Category := ADR(MACHINE_CATEGORY);
        MpRecipeRegPar_2[currentHead]();
    END_FOR
    
END_PROGRAM


PROGRAM _CYCLIC

    memset(ADR(logArguments), 0, SIZEOF(logArguments));

	modules[0].ps.mpAxis := ADR(gMpAxisPS1);
	modules[1].ps.mpAxis := ADR(gMpAxisPS2);
	
	FOR currentModule:=0 TO NUMBER_OF_MODULES_M1 DO
        
        gModules[currentModule].productSupply.temperature   := ((modules[currentModule].supplyTemperatureRaw * gModules[currentModule].productSupply.parameters.scalingFactor) + gModules[currentModule].productSupply.parameters.scalingOffset) / 100.0;
        productSupplyValveAction;
        
        FOR currentHead:=0 TO NUM_OF_HEADS_PER_MODULE_M1 DO
			pCurrentHead ACCESS ADR(gModules[currentModule].heads[currentHead]);
			
			//set .ready bit for each head
            pCurrentHead.ready                          := ((pCurrentHead.stretchRod.status.atHome = TRUE OR pCurrentHead.stretchRod.status.atRetractPos= TRUE) AND (pCurrentHead.nozzle.status.opened = TRUE) AND ((pCurrentHead.fillPiston.status.atReturnPos = TRUE) OR (pCurrentHead.enable = FALSE)));
            pCurrentHead.pressureTransducer.pressure    := (modules[currentModule].head[currentHead].pressureTransducerRaw - pCurrentHead.pressureTransducer.parameters.scalingOffset) * pCurrentHead.pressureTransducer.parameters.scalingFactor;
        END_FOR
        
        logArguments[0] := ADR(currentModule);
        logArguments[1] := ADR(modules[currentModule].ps.MpAxisBasic_0.Info.HardwareInfo.NodeID);
            
        // if an error occurs in any state then go to the error state
        CASE modules[currentModule].ps.state OF
            ERROR:
            
            ELSE
                IF (modules[currentModule].ps.MpAxisBasic_0.Error = TRUE) THEN
                    logArguments[3] := ADR(modules[currentModule].ps.MpAxisBasic_0.StatusID);            
                    logError('Power Supply', 'Module %h, Node %h Error %d', ADR(logArguments));
                    modules[currentModule].ps.state := ERROR;
                ELSIF (gModules[currentModule].powerSupply.commands.errorAcknowledge = TRUE) THEN
                    gModules[currentModule].powerSupply.commands.errorAcknowledge := FALSE;
                END_IF
        END_CASE
        
        CASE (modules[currentModule].ps.state) OF
            WAIT_FOR_READY_TO_POWER:
                IF (modules[currentModule].ps.MpAxisBasic_0.Info.AxisInitialized <> TRUE) AND (modules[currentModule].ps.MpAxisBasic_0.Update = FALSE) THEN
                    modules[currentModule].ps.MpAxisBasic_0.Update := TRUE;
                ELSIF (modules[currentModule].ps.MpAxisBasic_0.UpdateDone = TRUE) THEN
                    modules[currentModule].ps.MpAxisBasic_0.Update := FALSE;
                END_IF
                
                IF (modules[currentModule].ps.MpAxisBasic_0.Info.ReadyToPowerOn = TRUE) AND (gMachineControl.commands.powerOn = TRUE) THEN
					logArguments[0] := ADR(modules[currentModule].ps.MpAxisBasic_0.Info.HardwareInfo.NodeID);
					logDebug('PSControl', 'Power Supply Axis Ready to power on, index = %d', ADR(logArguments));
                    modules[currentModule].ps.MpAxisBasic_0.Power   := TRUE;
                    modules[currentModule].ps.state                 := WAIT_FOR_POWER_ON;
                END_IF
				
			WAIT_FOR_POWER_ON:
                IF (modules[currentModule].ps.MpAxisBasic_0.PowerOn = TRUE) THEN
                    logArguments[0] := ADR(modules[currentModule].ps.MpAxisBasic_0.Info.HardwareInfo.NodeID);
                    logDebug('PSControl', 'Node %d Power Supply Axis powered on', ADR(logArguments));
                    modules[currentModule].ps.state := READY;
                END_IF
            
            READY:
                IF (gMachineControl.commands.powerOn = FALSE) THEN
                    modules[currentModule].ps.MpAxisBasic_0.Power   := FALSE;
                    logArguments[0] := ADR(modules[currentModule].ps.MpAxisBasic_0.Info.HardwareInfo.NodeID);
                    logDebug('PSControl', 'Node %d Power Supply Axis powered off', ADR(logArguments));
                    modules[currentModule].ps.state := WAIT_FOR_READY_TO_POWER;
                END_IF
            
            ERROR:
                IF (gModules[currentModule].powerSupply.commands.errorAcknowledge = TRUE) THEN
                    logDebug('FillPiston', 'Module %h, Head %h, Node %h Acknowledging Error', ADR(logArguments));
                    gModules[currentModule].powerSupply.commands.errorAcknowledge   := FALSE;
                    modules[currentModule].ps.MpAxisBasic_0.ErrorReset                 := TRUE;
                END_IF
            
                IF (modules[currentModule].ps.MpAxisBasic_0.Error <> TRUE) THEN
                    logDebug('PSControl', 'Module %h, Node %h All Errors Acknowledged', ADR(logArguments));
                    modules[currentModule].ps.MpAxisBasic_0.ErrorReset  := FALSE;
                    IF (modules[currentModule].ps.MpAxisBasic_0.PowerOn = TRUE) THEN
                        modules[currentModule].ps.state := READY;
                    ELSE
                        modules[currentModule].ps.state := WAIT_FOR_READY_TO_POWER;
                    END_IF
                END_IF
        END_CASE
        
        IF (modules[currentModule].ps.state <> old_state[currentModule]) THEN
            old_state[currentModule] := modules[currentModule].ps.state;
            logArguments[0] := ADR(modules[currentModule].ps.MpAxisBasic_0.Info.HardwareInfo.NodeID);
            logArguments[1] := ADR(modules[currentModule].ps.state);
            logDebug('PSControl', 'Node %d Changing State to %d', ADR(logArguments));
        END_IF
        
        modules[currentModule].ps.MpAxisBasic_0.Enable      := TRUE;
        modules[currentModule].ps.MpAxisBasic_0.Axis        := ADR(modules[currentModule].ps.axis);
        modules[currentModule].ps.MpAxisBasic_0.MpLink      := modules[currentModule].ps.mpAxis;
        modules[currentModule].ps.MpAxisBasic_0.Parameters  := ADR(modules[currentModule].ps.mpParams);
        modules[currentModule].ps.MpAxisBasic_0();
        
        gModules[currentModule].powerSupply.status.errorActive  := modules[currentModule].ps.MpAxisBasic_0.Error;
        gModules[currentModule].powerSupply.status.errorNumber  := modules[currentModule].ps.MpAxisBasic_0.StatusID;
        gModules[currentModule].powerSupply.status.poweredOn    := modules[currentModule].ps.MpAxisBasic_0.PowerOn;
        
	END_FOR
	
END_PROGRAM

PROGRAM _EXIT
    FOR currentModule:=0 TO NUMBER_OF_MODULES_M1 DO
        modules[currentModule].ps.MpAxisBasic_0.Enable  := FALSE;
        modules[currentModule].ps.MpAxisBasic_0();
    END_FOR    
END_PROGRAM


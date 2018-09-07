
PROGRAM _INIT
    
    lastWatchDog := TRUE;

	
END_PROGRAM

PROGRAM _CYCLIC
    

	
/////////////////////////////////////////////	
	size := SIZEOF(externalComm.inputs);
  
	
    IF (lastWatchDog <> externalComm.inputs.watchDog) THEN
        lastWatchDog := externalComm.inputs.watchDog;
        MpAlarmXResetID(gAlarmXCore, watchDogAlarmID);
        lastTimeWatchDogChanged := clock_ms();
    END_IF
    
    watchDog_r_trig.CLK := ((clock_ms() - lastTimeWatchDogChanged) >= WATCHDOG_TIMEOUT);
    watchDog_r_trig();
    
    IF ((watchDog_r_trig.Q = TRUE) AND (DiagCpuIsSimulated() = FALSE)) THEN
		watchDogAlarmID := MpAlarmXSet(gAlarmXCore, 'EXTERNAL_COMM_WATCHDOG');
		gMachineControl.status.extCommunicationStatus := 'COMM FAULT';
	ELSE
		gMachineControl.status.extCommunicationStatus := 'COMM GOOD';
    END_IF

	// Removed - changing to user defined setpoint trigged at forming cycle start. 
//  zeroDegree_r_trig.CLK := externalComm.inputs.rotaryDegreeAtZeroDegree;
//  zeroDegree_r_trig();
//  IF (zeroDegree_r_trig.Q = TRUE) THEN
//        previousTimeZeroDegree := currentTimeZeroDegree;
//        currentTimeZeroDegree := TIME_TO_UDINT(clock_ms());
//        gMachineControl.parameters.speed := (360.0 / ((UDINT_TO_REAL(currentTimeZeroDegree - previousTimeZeroDegree)) / 1000.0));
//    END_IF
    
   // gMachineControl.parameters.speed := externalComm.inputs.machineSpeedDegSec;
   //F (gMachineControl.parameters.machineProductionRateBPH <> 0) THEN
        // speed is in degrees/sec
        // bph = bottles / hour
        // degrees / sec = (bottles / hour) * (360 degrees / bottle) * (1 hour / 60 min) * (1 min / 60 seconds)
	//MachineControl.parameters.speed := (gMachineControl.parameters.machineProductionRateBPH * (360.0 / 1.0) * (1.0 / 60.0) * (1.0 / 60.0));
		//	gMachineControl.parameters.speed := (gMachineControl.parameters.machineProductionRateBPH;
	gMachineControl.parameters.speed := 100;
		
  //END_IF
    
	IF (externalComm.inputs.machineAutoMode = TRUE) AND (externalComm.inputs.machineInAutoCycle = FALSE) THEN
		gMachineControl.status.machineModeStatus := 'Auto Mode Selected';
	ELSIF externalComm.inputs.machineManualMode THEN
		gMachineControl.status.machineModeStatus := 'Manual Mode Selected';
	ELSIF externalComm.inputs.machineSetupMode THEN
		gMachineControl.status.machineModeStatus := 'Setup Mode Selected';
	ELSIF externalComm.inputs.machineInAutoCycle THEN
		gMachineControl.status.machineModeStatus := 'Machine in Auto Cycle';
		
	ELSE
		gMachineControl.status.machineModeStatus := 'No Mode Selected';
	END_IF
	
	// If a valid recipe is not loaded, shut off autocycle selector
	IF gMachineControl.status.processParameterRecipeNotLoaded THEN
		gMachineControl.commands.formingControlAutomode := FALSE;
	END_IF
	
	
// Start of Forming Cycling from machine command via external communciatons. 
	IF gMachineControl.commands.formingControlAutomode = TRUE  THEN
		r_trig_autoCycleStart.CLK := ((externalComm.inputs.machineInAutoCycle = TRUE) AND (externalComm.inputs.autoCycleMoldsClosedReadyToForm = TRUE));
		r_trig_autoCycleStart();
		IF (r_trig_autoCycleStart.Q = TRUE) THEN
			gMachineControl.commands.start := TRUE;
		END_IF
	END_IF

	gMachineControl.parameters.machineProductionRateBPH := externalComm.inputs.machineSpeedDegSec; // Display cph
	
	gMachineControl.status.machineAutoMode					:= externalComm.inputs.machineAutoMode;
	gMachineControl.status.machineManualMode				:= externalComm.inputs.machineManualMode;	
	gMachineControl.status.machineSetupMode					:= externalComm.inputs.machineSetupMode;
    gMachineControl.status.inAutoCycle                      := externalComm.inputs.machineInAutoCycle;
    gMachineControl.status.moldsClosed                      := externalComm.inputs.moldsClosed;
    gMachineControl.status.moldsOpen                        := externalComm.inputs.moldsOpen;
	gMachineControl.status.autoCycleMoldsClosedReadyToForm  := externalComm.inputs.autoCycleMoldsClosedReadyToForm;
	gMachineControl.status.preformsEnteringMold			  	:= externalComm.inputs.preformsEnteringMold;  // on during the time preforms start loading into mold, 
	
    
	//Check if Enabled FillPiston and Stretch Rods are Homed 
	IF (gModules[0].heads[0].fillPiston.status.homed OR NOT(gModules[0].heads[0].enable) AND
		gModules[0].heads[1].fillPiston.status.homed OR NOT(gModules[0].heads[1].enable) AND
		gModules[1].heads[0].fillPiston.status.homed OR NOT(gModules[1].heads[0].enable) AND 
		gModules[1].heads[1].fillPiston.status.homed OR NOT(gModules[1].heads[1].enable)) THEN
		gMachineControl.status.allFillPistonsHomed := TRUE;
	ELSE
		gMachineControl.status.allFillPistonsHomed := FALSE;
	END_IF
	
		
		IF (gModules[0].heads[0].stretchRod.status.homed OR NOT(gModules[0].heads[0].enable) AND
			gModules[0].heads[1].stretchRod.status.homed OR NOT(gModules[0].heads[1].enable) AND
			gModules[1].heads[0].stretchRod.status.homed OR NOT(gModules[1].heads[0].enable) AND 
			gModules[1].heads[1].stretchRod.status.homed OR NOT(gModules[1].heads[1].enable)) THEN
			gMachineControl.status.allStretchRodsHomed := TRUE;	
		ELSE 
			gMachineControl.status.allStretchRodsHomed := FALSE;
		END_IF
		
		
	
    rf_trig_power.CLK := externalComm.inputs.powerOn;
    rf_trig_power();
    IF (rf_trig_power.Q = TRUE) THEN
        gMachineControl.commands.powerOn    := externalComm.inputs.powerOn;
    END_IF
   
	
	
    rf_trig_home.CLK := externalComm.inputs.homeHeadsCmd;
    rf_trig_home();
	IF (rf_trig_home.Q = TRUE) THEN
		IF (gMachineControl.status.allStretchRodsHomed = FALSE) OR (gMachineControl.status.allStretchRodsHomed = FALSE) THEN
			gMachineControl.commands.home :=  externalComm.inputs.homeHeadsCmd;  // from Machine control - Home Servos
		ELSIF (gMachineControl.status.allStretchRodsHomed = TRUE) AND (gMachineControl.status.allStretchRodsHomed = TRUE) THEN
			gMachineControl.commands.reset := externalComm.inputs.homeHeadsCmd;  // from Machine control - reset ready condition 
		END_IF
	END_IF
	
	
	IF EDGEPOS(externalComm.inputs.machineInAutoCycle) THEN  //at machine cycle start,  send forming system to return all position
		gMachineControl.commands.reset := TRUE;
	END_IF
	
    
    IF (DiagCpuIsSimulated() = TRUE) THEN
        gModules[0].heads[0].preformPresent := TRUE;
        gModules[0].heads[1].preformPresent := TRUE;
        gModules[1].heads[0].preformPresent := TRUE;
        gModules[1].heads[1].preformPresent := TRUE;
        gModules[0].heads[0].bottlePresent  := TRUE;
        gModules[0].heads[1].bottlePresent  := TRUE;
        gModules[1].heads[0].bottlePresent  := TRUE;
        gModules[1].heads[1].bottlePresent  := TRUE;
    ELSE
        gModules[getModuleIndex(0)].heads[getHeadIndex(0)].preformPresent := externalComm.inputs.preformPresentAtMoldHD1;
        gModules[getModuleIndex(1)].heads[getHeadIndex(1)].preformPresent := externalComm.inputs.preformPresentAtMoldHD2;
        gModules[getModuleIndex(2)].heads[getHeadIndex(2)].preformPresent := externalComm.inputs.preformPresentAtMoldHD3;
        gModules[getModuleIndex(3)].heads[getHeadIndex(3)].preformPresent := externalComm.inputs.preformPresentAtMoldHD4;
        gModules[getModuleIndex(0)].heads[getHeadIndex(0)].bottlePresent  := externalComm.inputs.bottlePresentAtExitHD1;
        gModules[getModuleIndex(1)].heads[getHeadIndex(1)].bottlePresent  := externalComm.inputs.bottlePresentAtExitHD2;
        gModules[getModuleIndex(2)].heads[getHeadIndex(2)].bottlePresent  := externalComm.inputs.bottlePresentAtExitHD3;
        gModules[getModuleIndex(3)].heads[getHeadIndex(3)].bottlePresent  := externalComm.inputs.bottlePresentAtExitHD4;
    END_IF
    
    gMachineControl.status.preformInfeedTransferInDuration  := externalComm.inputs.preformInfeedTransferInDuration;
    gMachineControl.status.preformInfeedGripperCloseToOpen  := externalComm.inputs.preformInfeedGripperCloseToOpen;
    gMachineControl.status.bottleExitTransferOutDuration    := externalComm.inputs.bottleExitTransferOutDuration;
    
    gModules[getModuleIndex(0)].heads[getHeadIndex(0)].preformTemperature := externalComm.inputs.preformTemperatureActualHD1;
    gModules[getModuleIndex(1)].heads[getHeadIndex(1)].preformTemperature := externalComm.inputs.preformTemperatureActualHD2;
    gModules[getModuleIndex(2)].heads[getHeadIndex(2)].preformTemperature := externalComm.inputs.preformTemperatureActualHD3;
    gModules[getModuleIndex(3)].heads[getHeadIndex(3)].preformTemperature := externalComm.inputs.preformTemperatureActualHD4;

    FOR i:=0 TO ((SIZEOF(blowers)/SIZEOF(blowers[0])) - 1) DO
        blowers[i] :=  externalComm.inputs.blowers[i];
    END_FOR;
    
    FOR currentOven:=0 TO ((SIZEOF(ovens)/SIZEOF(ovens[0])) - 1) DO
        FOR currentZone:=0 TO ((SIZEOF(ovens[0].zone)/SIZEOF(ovens[0].zone[0])) - 1) DO
            ovens[currentOven].zone[currentZone].enable     := externalComm.inputs.ovens[currentOven].zone[currentZone].enable;
            ovens[currentOven].zone[currentZone].setPoint   := externalComm.inputs.ovens[currentOven].zone[currentZone].setPoint;
        END_FOR
    END_FOR
    
	
	
	
	
	    
	CASE sequencerState OF
        
		WAIT_FOR_START:
			IF (gMachineControl.status.cycleRunning = TRUE) THEN
				externalComm.outputs.formingCompleteHD1 := FALSE;
				externalComm.outputs.formingCompleteHD2 := FALSE;
				externalComm.outputs.formingCompleteHD3 := FALSE;
				externalComm.outputs.formingCompleteHD4 := FALSE;
				externalComm.outputs.formingCycleComplete := FALSE;
				sequencerState := STARTED;
			END_IF
        
	
        
		STARTED:
			IF (NOT externalComm.outputs.formingHeadHomedHD1 OR (NOT externalComm.outputs.formingHeadEnabledHD1)) AND (NOT externalComm.outputs.formingHeadHomedHD2 OR 
				(NOT externalComm.outputs.formingHeadEnabledHD2)) AND (NOT externalComm.outputs.formingHeadHomedHD3 OR 
				(NOT externalComm.outputs.formingHeadEnabledHD3)) AND (NOT externalComm.outputs.formingHeadHomedHD4 OR (NOT externalComm.outputs.formingHeadEnabledHD4)) THEN
				sequencerState := RUNNING;
				
			END_IF
		
		RUNNING: 
			externalComm.outputs.formingCompleteHD1 := externalComm.outputs.formingHeadHomedHD1;
			externalComm.outputs.formingCompleteHD2 := externalComm.outputs.formingHeadHomedHD2;
			externalComm.outputs.formingCompleteHD3 := externalComm.outputs.formingHeadHomedHD3;	
			externalComm.outputs.formingCompleteHD4 := externalComm.outputs.formingHeadHomedHD4;
            
			IF externalComm.outputs.formingCompleteHD1 AND externalComm.outputs.formingCompleteHD2 AND externalComm.outputs.formingCompleteHD3 AND externalComm.outputs.formingCompleteHD4 THEN
				externalComm.outputs.formingCycleComplete := TRUE;
			END_IF
					
					
			IF externalComm.outputs.formingCycleComplete = TRUE AND gMachineControl.status.cycleComplete = TRUE THEN
				sequencerState := WAIT_FOR_START;
			END_IF
					
	END_CASE
				
					

	
    externalComm.outputs.formingHeadNoFaultHD1  := NOT(gModules[getModuleIndex(0)].heads[getHeadIndex(0)].errorActive);
    externalComm.outputs.formingHeadNoFaultHD2  := NOT(gModules[getModuleIndex(1)].heads[getHeadIndex(1)].errorActive);
    externalComm.outputs.formingHeadNoFaultHD3  := NOT(gModules[getModuleIndex(2)].heads[getHeadIndex(2)].errorActive);
    externalComm.outputs.formingHeadNoFaultHD4  := NOT(gModules[getModuleIndex(3)].heads[getHeadIndex(3)].errorActive);
    externalComm.outputs.formingHeadEnabledHD1  := gModules[getModuleIndex(0)].heads[getHeadIndex(0)].enable;
    externalComm.outputs.formingHeadEnabledHD2  := gModules[getModuleIndex(1)].heads[getHeadIndex(1)].enable;
    externalComm.outputs.formingHeadEnabledHD3  := gModules[getModuleIndex(2)].heads[getHeadIndex(2)].enable;
    externalComm.outputs.formingHeadEnabledHD4  := gModules[getModuleIndex(3)].heads[getHeadIndex(3)].enable;
    externalComm.outputs.formingHeadReadyHD1    := gModules[getModuleIndex(0)].heads[getHeadIndex(0)].ready;
    externalComm.outputs.formingHeadReadyHD2    := gModules[getModuleIndex(1)].heads[getHeadIndex(1)].ready;
    externalComm.outputs.formingHeadReadyHD3    := gModules[getModuleIndex(2)].heads[getHeadIndex(2)].ready;
    externalComm.outputs.formingHeadReadyHD4    := gModules[getModuleIndex(3)].heads[getHeadIndex(3)].ready;
    externalComm.outputs.formingHeadHomedHD1    := (gModules[getModuleIndex(0)].heads[getHeadIndex(0)].stretchRod.status.atRetractPos OR gModules[getModuleIndex(0)].heads[getHeadIndex(0)].stretchRod.status.atHome) AND gModules[getModuleIndex(0)].heads[getHeadIndex(0)].nozzle.status.opened;
    externalComm.outputs.formingHeadHomedHD2    := (gModules[getModuleIndex(1)].heads[getHeadIndex(1)].stretchRod.status.atRetractPos OR gModules[getModuleIndex(1)].heads[getHeadIndex(1)].stretchRod.status.atHome) AND gModules[getModuleIndex(1)].heads[getHeadIndex(1)].nozzle.status.opened;
    externalComm.outputs.formingHeadHomedHD3    := (gModules[getModuleIndex(2)].heads[getHeadIndex(2)].stretchRod.status.atRetractPos OR gModules[getModuleIndex(2)].heads[getHeadIndex(2)].stretchRod.status.atHome) AND gModules[getModuleIndex(2)].heads[getHeadIndex(2)].nozzle.status.opened;
    externalComm.outputs.formingHeadHomedHD4    := (gModules[getModuleIndex(3)].heads[getHeadIndex(3)].stretchRod.status.atRetractPos OR gModules[getModuleIndex(3)].heads[getHeadIndex(3)].stretchRod.status.atHome) AND gModules[getModuleIndex(3)].heads[getHeadIndex(3)].nozzle.status.opened;
    
		// this will toggle our watchdog output every 100ms
		IF ((clock_ms() - lastTimeWatchDogSet) >= WATCHDOG_TOGGLE_TIME) THEN
			lastTimeWatchDogSet := clock_ms();
			externalComm.outputs.watchDog := NOT(externalComm.outputs.watchDog);
			
		END_IF

		
 END_PROGRAM

PROGRAM _EXIT
        (* Insert code here *)
	 
 END_PROGRAM



PROGRAM _INIT

    fillPiston[0].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[0].fillPiston.parameters.machineData');
    fillPiston[1].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[1].fillPiston.parameters.machineData');
    fillPiston[2].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[0].fillPiston.parameters.machineData');
    fillPiston[3].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[1].fillPiston.parameters.machineData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        fillPiston[currentHead].MpRecipeRegPar_0.MpLink := ADR(gMachineRecipe);
        fillPiston[currentHead].MpRecipeRegPar_0.Enable := TRUE;
        fillPiston[currentHead].MpRecipeRegPar_0.Category := ADR(MACHINE_CATEGORY);
        fillPiston[currentHead].MpRecipeRegPar_0();
    END_FOR
    
    fillPiston[0].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[0].fillPiston.parameters.processData');
    fillPiston[1].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[1].fillPiston.parameters.processData');
    fillPiston[2].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[0].fillPiston.parameters.processData');
    fillPiston[3].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[1].fillPiston.parameters.processData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        fillPiston[currentHead].MpRecipeRegPar_1.MpLink := ADR(gProcessRecipe);
        fillPiston[currentHead].MpRecipeRegPar_1.Enable := TRUE;
		fillPiston[currentHead].MpRecipeRegPar_1.Category := ADR(PROCESS_CATEGORY);
        fillPiston[currentHead].MpRecipeRegPar_1();
    END_FOR
	    
	gModules[0].heads[0].pressureTransducer.parameters;
	fillPiston[0].MpRecipeRegPar_2.PVName := ADR('gModules[0].heads[0].pressureTransducer.parameters');
	fillPiston[1].MpRecipeRegPar_2.PVName := ADR('gModules[0].heads[1].pressureTransducer.parameters');
	fillPiston[2].MpRecipeRegPar_2.PVName := ADR('gModules[1].heads[0].pressureTransducer.parameters');
	fillPiston[3].MpRecipeRegPar_2.PVName := ADR('gModules[1].heads[1].pressureTransducer.parameters');
    
	FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
		fillPiston[currentHead].MpRecipeRegPar_2.MpLink := ADR(gProcessRecipe);
		fillPiston[currentHead].MpRecipeRegPar_2.Enable := TRUE;
		fillPiston[currentHead].MpRecipeRegPar_2.Category := ADR(MACHINE_CATEGORY);
		fillPiston[currentHead].MpRecipeRegPar_2();
	END_FOR
	
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        itoa(currentHead+1, ADR(tempString));
        pFillPiston ACCESS ADR(fillPiston[currentHead]);
        pFillPiston.name := 'Head ';
        strcat(ADR(pFillPiston.name), ADR(tempString));
        strcat(ADR(pFillPiston.name), ADR(' Fill Piston'));
    END_FOR

END_PROGRAM

PROGRAM _CYCLIC
    
    fillPiston[0].mpAxis := ADR(gMpAxisPiston1);
    fillPiston[1].mpAxis := ADR(gMpAxisPiston2);
    fillPiston[2].mpAxis := ADR(gMpAxisPiston3);
    fillPiston[3].mpAxis := ADR(gMpAxisPiston4);
    
    fillPiston[0].mpConfig := ADR(mpConfig1);
    fillPiston[1].mpConfig := ADR(mpConfig2);
    fillPiston[2].mpConfig := ADR(mpConfig3);
    fillPiston[3].mpConfig := ADR(mpConfig4);
	
	memset(ADR(logArguments), 0, SIZEOF(logArguments));

	FOR currentModule:=0 TO NUMBER_OF_MODULES_M1 DO
        FOR currentHead:=0 TO NUM_OF_HEADS_PER_MODULE_M1 DO
            pFillPiston ACCESS ADR(fillPiston[indexOf(currentModule, currentHead, NUM_OF_HEADS_PER_MODULE)]);
            pCurrentHead ACCESS ADR(gModules[currentModule].heads[currentHead]);
            pCurrentPiston ACCESS ADR(pCurrentHead.fillPiston);
            pEndlessPositionData ACCESS ADR(endlessPositionData[indexOf(currentModule, currentHead, NUM_OF_HEADS_PER_MODULE)]);
            pMpConfig ACCESS fillPiston[indexOf(currentModule, currentHead, NUM_OF_HEADS_PER_MODULE)].mpConfig;
            
            logArguments[0] := ADR(currentModule);
            logArguments[1] := ADR(currentHead);
            logArguments[2] := ADR(pFillPiston.MpAxisBasic_0.Info.HardwareInfo.NodeID);
            
            // if an error occurs in any state then go to the error state
            CASE pFillPiston.state OF
                ERROR:
            
                ELSE
                    IF (pFillPiston.MpAxisBasic_0.Error = TRUE) THEN
                        IF (pFillPiston.MpAxisBasic_0.MoveActive = TRUE) THEN
                            pFillPiston.MpAxisBasic_0.Stop  := TRUE;
                        END_IF
                        logArguments[3] := ADR(pFillPiston.MpAxisBasic_0.StatusID);            
						logError('FillPiston', 'Module %h, Head %h, Node %h Error %d', ADR(logArguments));
						pCurrentHead.fillPiston.status.fillPistonSequenceState := 999;
					    pFillPiston.state := ERROR;
                    ELSIF (pCurrentPiston.commands.errorAcknowledge = TRUE) THEN
                        pCurrentPiston.commands.errorAcknowledge := FALSE;
					END_IF
            
            END_CASE
        
            fillPistonErrorName := pFillPiston.name;
            
            CASE pFillPiston.state OF
            
                LOAD_CONFIG:
                    IF (pFillPiston.MpAxisBasic_0.Active = TRUE) THEN
                        pFillPiston.MpAxisBasicConfig_0.Load    := TRUE;
                        
                        IF (pFillPiston.MpAxisBasicConfig_0.CommandDone = TRUE) THEN
                            pFillPiston.MpAxisBasicConfig_0.Load    := FALSE;
                            
                            IF ((pFillPiston.MpAxisBasic_0.Info.HardwareInfo.DeviceType = mpAXIS_ACOPOS_SIM) OR (DiagCpuIsSimulated() = TRUE)) THEN
                                logDebug('FillPiston', 'Module %h, Head %h, Node %h Simulation Mode is active, setting inputs to active hi', ADR(logArguments));
                                pMpConfig.Drive.DigitalInputs.Level.NegativeLimitSwitch := mpAXIS_IO_ACTIVE_HI;
                                pMpConfig.Drive.DigitalInputs.Level.PositiveLimitSwitch := mpAXIS_IO_ACTIVE_HI;
                                pFillPiston.MpAxisBasicConfig_0.Save                    := TRUE;
                            END_IF
                        
                            pFillPiston.state := WAIT_FOR_POWER;
                        END_IF
                        
                    END_IF
                
                WAIT_FOR_POWER:
                    ClearCommands;
                    IF (pFillPiston.MpAxisBasic_0.Info.ReadyToPowerOn = TRUE) AND (pCurrentPiston.commands.powerOn = TRUE) THEN
                        logDebug('FillPiston', 'Module %h, Head %h, Node %h Powering On', ADR(logArguments));
                        pFillPiston.MpAxisBasic_0.Power         := TRUE;
                        pFillPiston.state                       := INIT;
                    END_IF
                    pFillPiston.MC_BR_CheckEndlessPosition_0.Execute := FALSE;
            
                INIT:
                    pFillPiston.MC_BR_CheckEndlessPosition_0.Execute := TRUE;
                    
                    IF (pFillPiston.MpAxisBasic_0.PowerOn = TRUE) THEN
                        logDebug('FillPiston', 'Module %h, Head %h, Node %h Powered On', ADR(logArguments));
               
                        pFillPiston.state := INIT;
                    END_IF

                    IF ((pFillPiston.MpAxisBasic_0.Info.AxisInitialized = TRUE) AND (pFillPiston.MC_BR_CheckEndlessPosition_0.Done = TRUE)) THEN
                        logDebug('FillPiston', 'Module %h, Head %h, Node %h Axis Initialized', ADR(logArguments));
                        pFillPiston.MpAxisBasic_0.Update := TRUE;
						IF ((pFillPiston.MpAxisBasic_0.Info.HardwareInfo.DeviceType = mpAXIS_ACOPOS_SIM) OR 
                            ((pFillPiston.MC_BR_CheckEndlessPosition_0.EndlessPositionInitialized = TRUE) AND (pFillPiston.MC_BR_CheckEndlessPosition_0.DataValid = TRUE))) THEN
                            pFillPiston.state   := RESTORE_HOME;
                        ELSIF (pFillPiston.MpAxisBasic_0.IsHomed <> TRUE) THEN
                            pFillPiston.state   := WAIT_FOR_HOME;
                        ELSE
                            pFillPiston.state   := READY;
                        END_IF
                    END_IF
            
                WAIT_FOR_HOME:
                    IF (pFillPiston.homeWarningID = 0) THEN
                        logWarn('FillCylinder', 'Module %h, Head %h, Node %h Axis has not been homed', ADR(logArguments));
                        fillPistonErrorName := pFillPiston.name;
                        pFillPiston.homeWarningID := MpAlarmXSet(gAlarmXCore, 'FILL_NOT_HOMED');
                    END_IF
                    
                    IF (pCurrentPiston.commands.powerOn = FALSE) THEN
                        logDebug('FillPiston', 'Head %h, Node %h Powering Off', ADR(logArguments));
                        pFillPiston.MpAxisBasic_0.Power   := FALSE;
                        pFillPiston.state                 := WAIT_FOR_POWER;
                    ELSIF (pCurrentPiston.commands.home = TRUE) THEN
                        pCurrentPiston.commands.home := FALSE;
                        logDebug('FillPiston', 'Module %h, Head %h, Node %h Homing Axis', ADR(logArguments));
                    
                        pFillPiston.mpParams.Home.Mode                              := mpAXIS_HOME_MODE_LIMIT_SWITCH;
                        pFillPiston.mpParams.Home.SwitchEdge                        := mpAXIS_HOME_DIR_NEGATIVE;
                        pFillPiston.mpParams.Home.HomingDirection                   := mpAXIS_HOME_DIR_POSITIVE;
                        pFillPiston.mpParams.Home.Acceleration                      := pCurrentPiston.parameters.machineData.home.acceleration;
                        pFillPiston.mpParams.Home.StartVelocity                     := pCurrentPiston.parameters.machineData.home.velocity;
                        pFillPiston.mpParams.Home.HomingVelocity                    := pCurrentPiston.parameters.machineData.home.velocity / 2.0;
                        pFillPiston.mpParams.Home.Position                          := pCurrentPiston.parameters.machineData.home.position;
                        pFillPiston.MpAxisBasic_0.Home                              := TRUE;
                        pFillPiston.state                                           := HOMING;
                    END_IF
            
                HOMING:
                    IF (pFillPiston.MpAxisBasic_0.IsHomed = TRUE) THEN
                        ClearCommands;
                        logDebug('FillPiston', 'Module %h, Head %h, Node %h Axis Homed', ADR(logArguments));
                        pFillPiston.MpAxisBasic_0.Home    := FALSE;
                        MpAlarmXResetID(gAlarmXCore, pFillPiston.homeWarningID);
                        pFillPiston.state                 := SAVE_HOME_OFFSET;
                    END_IF
            
                SAVE_HOME_OFFSET:
                    pFillPiston.mpParams.Home.EndlessPositionDataRef := pFillPiston.pEndlessPositionData;
                    pFillPiston.state := READY;
            
                RESTORE_HOME:
                    // if this is on the simulator then perform a direct home
                    IF ((pFillPiston.MpAxisBasic_0.Info.HardwareInfo.DeviceType = mpAXIS_ACOPOS_SIM) OR (DiagCpuIsSimulated() = TRUE)) THEN
                        pFillPiston.mpParams.Home.Mode                      := mpAXIS_HOME_MODE_DIRECT;
                        pFillPiston.mpParams.Home.Position                  := pCurrentPiston.parameters.machineData.home.position;
                        pFillPiston.mpParams.Home.ReferencePulse            := mpAXIS_HOME_OPTION_OFF;
                        pFillPiston.MpAxisBasic_0.Home                      := TRUE;
                    ELSE
                        pFillPiston.mpParams.Home.Mode                      := mpAXIS_HOME_MODE_RESTORE_POS;
                        pFillPiston.mpParams.Home.EndlessPositionDataRef    := pFillPiston.pEndlessPositionData;
                        pFillPiston.MpAxisBasic_0.Home                      := TRUE;
                    END_IF
                    IF (pFillPiston.MpAxisBasic_0.IsHomed = TRUE) THEN
                        ClearCommands;
                        logDebug('FillPiston', 'Module %h, Head %h, Node %h Axis Homed', ADR(logArguments));
                        pFillPiston.MpAxisBasic_0.Home    := FALSE;
                        pFillPiston.state                 := READY;
                    END_IF
            
				READY:
					IF (AxisBasicCommands(ADR(pFillPiston), ADR(pCurrentPiston), ADR(logArguments)) = TRUE) THEN
						// commands are handled by the function, so nothing to do here
					ELSIF (pCurrentPiston.commands.moveToPreCharge = TRUE) THEN
                        pCurrentPiston.commands.moveToPreCharge := FALSE;
                        logArguments[3] := ADR(pCurrentPiston.parameters.processData.preChargePosition);
						logDebug('FillPiston', 'Module %h, Head %h, Node %h Moving to Pre-Charge Position %f', ADR(logArguments));
						pCurrentHead.fillPiston.status.fillPistonSequenceState := 10;
                        pFillPiston.mpParams.Distance               := -1.0 * pCurrentPiston.parameters.processData.preChargePosition;
						pFillPiston.mpParams.Velocity               := pCurrentPiston.parameters.processData.preChargeVelocity;
                        pFillPiston.mpParams.Acceleration           := pCurrentPiston.parameters.machineData.acceleration;
						pFillPiston.mpParams.Deceleration           := pFillPiston.mpParams.Acceleration;
                        pFillPiston.MpAxisBasic_0.MoveAdditive      := TRUE;
                        pFillPiston.state                           := IN_MOTION;
                    ELSIF (pCurrentPiston.commands.startPreBlow = TRUE) THEN
                        pCurrentPiston.commands.startPreBlow := FALSE;
                    
                        // calculate the fill area = PI * r^2 * h
						// fillArea //bc 
						pCurrentPiston.parameters.machineData.fillPistonTotalVolume := PI * ((pCurrentPiston.parameters.machineData.pistonDiameter / 2.0) ** 2) * pCurrentPiston.parameters.machineData.pistonStroke / 1000.0; // division by 1000 to convert from mm^3 to ml.
                        
                        // distance to move to displace a set amount of liquid = (1000.0 * volume) / (PI * r^2)
                        pCurrentPiston.status.preBlowDistance       := ((1000.0 * pCurrentPiston.parameters.processData.preBlowVolume) / (PI * ((pCurrentPiston.parameters.machineData.pistonDiameter / 2.0) ** 2)));

                        // the time it will take the to move from Pt10 to Pt0
                        moveTime                                    := LREAL_TO_REAL(pCurrentHead.degreeAtPt10 - pCurrentHead.degreeAtPt0) / gMachineControl.status.masterVelocity;
                        pCurrentPiston.status.preBlowVelocity       := pCurrentPiston.status.preBlowDistance / ((5.0 / 6.0) * moveTime);
                        pCurrentPiston.status.preBlowAcceleration   := (3.0 * pCurrentPiston.status.preBlowVelocity) / moveTime;
                        
                        pFillPiston.mpParams.Velocity               := pCurrentPiston.status.preBlowVelocity;
                        pFillPiston.mpParams.Acceleration           := pCurrentPiston.status.preBlowAcceleration;
                        pFillPiston.mpParams.Deceleration           := pFillPiston.mpParams.Acceleration;
                        pFillPiston.mpParams.Direction              := mpAXIS_DIR_NEGATIVE;
                        logArguments[3]                             := ADR(pCurrentPiston.status.preBlowDistance);
                        logArguments[4]                             := ADR(pCurrentPiston.status.preBlowVelocity);
                        logArguments[5]                             := ADR(pCurrentPiston.status.preBlowAcceleration);
                        logDebug('FillPiston', 'Module %h, Head %h, Node %h Moving to %f at Pre-Blow Velocity %f Accel = %f', ADR(logArguments));
                        pCurrentHead.fillPiston.status.fillPistonSequenceState := 20;
                        pFillPiston.MpAxisBasic_0.MoveVelocity      := TRUE;
                        pFillPiston.state                           := IN_MOTION;
                    ELSIF (pCurrentPiston.commands.startForming = TRUE) THEN
                        pCurrentPiston.commands.startForming        := FALSE;
						pCurrentHead.formingPressureMax             := 0;
						pFillPiston.mpParams.Position               := pCurrentPiston.parameters.processData.ptB;
						pFillPiston.mpParams.Velocity               := pCurrentPiston.parameters.processData.formingVelocity;
						pFillPiston.mpParams.Direction				:= mpAXIS_DIR_NEGATIVE;
                        pFillPiston.mpParams.Acceleration           := pCurrentPiston.parameters.processData.formingAcceleration;

                        // Deceleration rate = v^2 / (2 * distance decelerating over)
                        pFillPiston.mpParams.Deceleration			:= MIN(((pCurrentPiston.parameters.processData.formingVelocity**2) / (2.0 * pCurrentPiston.parameters.processData.decelOffsetPtA)), pMpConfig.Axis.MovementLimits.Deceleration);
                        pFillPiston.MpAxisBasic_0.MoveAbsolute      := TRUE;
                        pFillPiston.state                           := IN_MOTION;
						logArguments[3] := ADR(pCurrentPiston.parameters.processData.formingVelocity);
						logArguments[4] := ADR(pCurrentPiston.parameters.processData.formingVelocity);
						logDebug('FillPiston', 'Module %h, Head %h, Node %h Moving Forming Velocity %f Decel = %f', ADR(logArguments));
						pCurrentHead.fillPiston.status.fillPistonSequenceState := 30;
					ELSIF (pCurrentPiston.commands.moveToFillCylinderReturn = TRUE) THEN
                        pCurrentPiston.commands.moveToFillCylinderReturn := FALSE;
                        logArguments[3] := ADR(pCurrentPiston.parameters.processData.fillCylinderReturnPosition );
                        logDebug('FillPiston', 'Module %h, Head %h, Node %h Moving to Fill Position %f', ADR(logArguments));
                    	pCurrentHead.fillPiston.status.fillPistonSequenceState := 80;
                        pFillPiston.mpParams.Position             := pCurrentPiston.parameters.processData.fillCylinderReturnPosition;
                        pFillPiston.mpParams.Velocity             := pCurrentPiston.parameters.processData.fillReturnVelocity;
                        pFillPiston.mpParams.Acceleration         := pCurrentPiston.parameters.machineData.acceleration;
                        pFillPiston.mpParams.Deceleration         := pFillPiston.mpParams.Acceleration;
                        pFillPiston.MpAxisBasic_0.MoveAbsolute    := TRUE;
                        pFillPiston.state                         := IN_MOTION;
 // pressure relief         
					ELSIF (pCurrentPiston.commands.pressureRelief = TRUE) THEN
                        pCurrentPiston.commands.pressureRelief := FALSE;
                        logArguments[3] := ADR(pCurrentPiston.parameters.processData.pressureReliefRate);
						logDebug('FillPiston', 'Module %h, Head %h, Node %h Relieving Pressure at Rate %f', ADR(logArguments));
						pFillPiston.state                         := PRESSURE_RELIEF;
						
                    ELSIF (pCurrentPiston.commands.holdPressure = TRUE) THEN
                        pCurrentPiston.commands.holdPressure := FALSE;
                        logArguments[3] := ADR(pCurrentPiston.parameters.processData.holdPressure);
						logDebug('FillPiston', 'Module %h, Head %h, Node %h Holding Pressure %f', ADR(logArguments));
						pFillPiston.state                         := HOLD_PRESSURE;
                    ELSIF (pCurrentPiston.commands.depressurize = TRUE) THEN
                        pCurrentPiston.commands.depressurize    := FALSE;
						logDebug('FillPiston', 'Module %h, Head %h, Node %h Depressurize', ADR(logArguments));
						pFillPiston.state                     := DEPRESSURIZE;
                    ELSIF (pCurrentPiston.commands.depressurizeComplete = TRUE) THEN
                        pCurrentPiston.commands.depressurizeComplete := FALSE;
						logDebug('FillPiston', 'Module %h, Head %h, Node %h Depressurize Complete', ADR(logArguments));
					    pFillPiston.state                         := READY;
                    
					
					ELSIF (pCurrentPiston.commands.moveToFillCylinderCIPPos = TRUE) THEN
							pCurrentPiston.commands.moveToFillCylinderCIPPos := FALSE;
							logArguments[3] := ADR(pCurrentPiston.parameters.machineData.fillCylinderCIPPosition);
							logDebug('FillPiston', 'Module %h, Head %h, Node %h Moving to CIP Position %f', ADR(logArguments));
							pCurrentHead.fillPiston.status.fillPistonSequenceState := 10;
							pFillPiston.mpParams.Position               := pCurrentPiston.parameters.machineData.fillCylinderCIPPosition;
							pFillPiston.mpParams.Velocity               := pCurrentPiston.parameters.processData.fillReturnVelocity;
							pFillPiston.mpParams.Acceleration           := pCurrentPiston.parameters.machineData.acceleration;
							pFillPiston.mpParams.Deceleration           := pFillPiston.mpParams.Acceleration;
							pFillPiston.MpAxisBasic_0.MoveAbsolute    	:= TRUE;
							pFillPiston.state                           := IN_MOTION;
					
					
					END_IF
            
                IN_MOTION:
                    pCurrentHead.formingActualPressure := pCurrentHead.pressureTransducer.pressure;
                    IF (pCurrentHead.pressureTransducer.pressure >= pCurrentHead.formingPressureMax) THEN
                        pCurrentHead.formingPressureMax := pCurrentHead.pressureTransducer.pressure;
                    END_IF
                    
                    IF (pCurrentPiston.commands.abort = TRUE) THEN
                        pCurrentPiston.commands.abort := FALSE;
                        logDebug('FillPiston', 'Module %h, Head %h, Node %h Abort', ADR(logArguments));
                        pFillPiston.MpAxisBasic_0.MoveAdditive  := FALSE;
                        pFillPiston.MpAxisBasic_0.MoveAbsolute  := FALSE;
                        pFillPiston.MpAxisBasic_0.MoveVelocity  := FALSE;
                        pFillPiston.MpAxisBasic_0.Stop          := TRUE;
                    ELSIF ((pFillPiston.MpAxisBasic_0.Info.MoveDone = TRUE) OR (pFillPiston.MpAxisBasic_0.Stopped = TRUE)) THEN
                        logArguments[3] := ADR(pCurrentPiston.status.actualPosition );
                        logDebug('FillPiston', 'Module %h, Head %h, Node %h In Position %f', ADR(logArguments));
                        pFillPiston.MpAxisBasic_0.MoveAdditive  := FALSE;
                        pFillPiston.MpAxisBasic_0.MoveAbsolute  := FALSE;
                        pFillPiston.MpAxisBasic_0.MoveVelocity  := FALSE;
                        pFillPiston.MpAxisBasic_0.Stop          := FALSE;
                        pFillPiston.state                       := READY;
                    ELSIF ((pFillPiston.MpAxisBasic_0.MoveVelocity = TRUE) AND (pFillPiston.MpAxisBasic_0.Position <= (pCurrentPiston.parameters.processData.ptB + pCurrentPiston.parameters.processData.decelOffsetPtA))) THEN
                        logArguments[3] := ADR(pCurrentPiston.status.actualPosition);
                        pFillPiston.MpAxisBasic_0.MoveAdditive  := FALSE;
                        pFillPiston.MpAxisBasic_0.MoveAbsolute  := FALSE;
                        pFillPiston.MpAxisBasic_0.MoveVelocity  := FALSE;
                        pFillPiston.MpAxisBasic_0.Stop          := FALSE;
                        pFillPiston.state                       := READY;
                    ELSIF (pCurrentPiston.commands.startForming = TRUE) THEN
                        pCurrentPiston.commands.startForming := FALSE;
                        pFillPiston.MpAxisBasic_0.MoveAdditive  := FALSE;
                        pFillPiston.MpAxisBasic_0.MoveAbsolute  := FALSE;
                        pFillPiston.MpAxisBasic_0.MoveVelocity  := FALSE;
                        pFillPiston.MpAxisBasic_0.Stop          := FALSE;
                        
						pCurrentHead.formingPressureMax         := 0;
						pFillPiston.mpParams.Position           := pCurrentPiston.parameters.processData.ptB;
						pFillPiston.mpParams.Velocity           := pCurrentPiston.parameters.processData.formingVelocity;
                        pFillPiston.mpParams.Direction			:= mpAXIS_DIR_NEGATIVE;
                        pFillPiston.mpParams.Acceleration       := pCurrentPiston.parameters.processData.formingAcceleration;

                        // Deceleration rate = v^2 / (2 * distance decelerating over)
                        pFillPiston.mpParams.Deceleration			:= MIN(((pCurrentPiston.parameters.processData.formingVelocity**2) / (2.0 * pCurrentPiston.parameters.processData.decelOffsetPtA)), pMpConfig.Axis.MovementLimits.Deceleration);
                        pFillPiston.MpAxisBasic_0.MoveAbsolute      := TRUE;
						pFillPiston.state                           := IN_MOTION;
						logArguments[3]                             := ADR(pCurrentPiston.parameters.processData.formingVelocity);
						logArguments[4]                             := ADR(pCurrentPiston.parameters.processData.formingVelocity);
						logDebug('FillPiston', 'Module %h, Head %h, Node %h Moving Forming Velocity %f Decel = %f', ADR(logArguments));

                    ELSIF (pCurrentPiston.commands.holdPressure = TRUE) THEN
                        pCurrentPiston.commands.holdPressure      := FALSE;
                        logArguments[3] := ADR(pCurrentPiston.status.actualPosition );
						logDebug('FillPiston', 'Module %h, Head %h, Node %h In Position %f', ADR(logArguments));
                        pFillPiston.MpAxisBasic_0.MoveAdditive  := FALSE;
                        pFillPiston.MpAxisBasic_0.MoveAbsolute  := FALSE;
                        pFillPiston.MpAxisBasic_0.MoveVelocity  := FALSE;
                        pFillPiston.MpAxisBasic_0.Stop          := FALSE;
                        pFillPiston.state                       := READY;
                    //pressure relief
                    ELSIF (pCurrentPiston.commands.pressureRelief = TRUE) THEN
                        pCurrentPiston.commands.pressureRelief := FALSE;
						logDebug('FillPiston', 'Module %h, Head %h, Node %h Pressure Relief Commanded', ADR(logArguments));
						pFillPiston.state := PRESSURE_RELIEF;
 
					ELSIF (((pCurrentPiston.commands.jogNegative = FALSE) AND (pFillPiston.MpAxisBasic_0.JogNegative = TRUE)) OR
                        ((pCurrentPiston.commands.jogPositive = FALSE) AND (pFillPiston.MpAxisBasic_0.JogPositive = TRUE))) THEN
                        logDebug('FillPiston', 'Module %h, Head %h, Node %h Stopping Jog', ADR(logArguments));
                        pFillPiston.MpAxisBasic_0.JogNegative := FALSE;
                        pFillPiston.MpAxisBasic_0.JogPositive := FALSE;
                        pFillPiston.state                     := READY;
                    ELSIF ((pCurrentPiston.commands.jogPositive = FALSE) AND (pFillPiston.MpAxisBasic_0.JogPositive = TRUE)) THEN
                        logDebug('FillPiston', 'Module %h, Head %h, Node %h Stopping Jog', ADR(logArguments));
                        pFillPiston.MpAxisBasic_0.JogPositive := FALSE;
                        pFillPiston.state                     := READY;
                    END_IF
            
				PRESSURE_RELIEF:
					pCurrentHead.fillPiston.status.fillPistonSequenceState := 40;
				    //  pCurrentPiston.commands.pressureRelief := FALSE; // added 10/20/17 
                    pCurrentHead.formingActualPressure := pCurrentHead.pressureTransducer.pressure;

					pFillPiston.MC_BR_TorqueControl_0.Enable          := TRUE;
					pFillPiston.MC_BR_TorqueControl_0.StartSignal     := TRUE;
					pFillPiston.MC_BR_TorqueControl_0.Torque          := 0;
                    //  pFillPiston.MC_BR_TorqueControl_0.Torque          := pCurrentPiston.parameters.processData.holdPressure; 
                    pFillPiston.MC_BR_TorqueControl_0.TorqueRamp      := pCurrentPiston.parameters.processData.pressureReliefRate;
                    pFillPiston.MC_BR_TorqueControl_0.PosMaxVelocity  := pCurrentPiston.parameters.machineData.velocity;
					pFillPiston.MC_BR_TorqueControl_0.NegMaxVelocity  := 0.0;
                    pFillPiston.MC_BR_TorqueControl_0.Acceleration    := pCurrentPiston.parameters.machineData.acceleration;
                    
                    pFillPiston.MC_BR_TorqueControl_0.TimeLimit       := 0.5;
                    pFillPiston.MC_BR_TorqueControl_0.Mode            := mcV_LIMIT_CALC + mcTIME_LIMIT;
                
					IF ((pFillPiston.MC_BR_TorqueControl_0.InTorque = TRUE) OR
						(pCurrentHead.pressureTransducer.pressure <= pCurrentPiston.parameters.processData.holdPressure)) THEN
						logDebug('FillPiston', 'Module %h, Head %h, Node %h Relief Pressure Reached', ADR(logArguments));
						pFillPiston.state := HOLD_PRESSURE;
					END_IF
                
                    IF (pCurrentPiston.commands.holdPressure = TRUE) THEN
                        pCurrentPiston.commands.holdPressure := FALSE;
						logDebug('FillPiston', 'Module %h, Head %h, Node %h Hold Pressure Command', ADR(logArguments));
						pFillPiston.MC_BR_TorqueControl_0.Enable          := FALSE;
						pFillPiston.MC_BR_TorqueControl_0.StartSignal     := FALSE;
                        pFillPiston.state := HOLD_PRESSURE;
                    END_IF
            
				HOLD_PRESSURE:
					pCurrentHead.fillPiston.status.fillPistonSequenceState := 50;
					pCurrentPiston.commands.holdPressure := FALSE; // added 10/20/17 
					pCurrentPiston.commands.pressureRelief := FALSE; // added 10/20/17 
                    pFillPiston.MpAxisBasic_0.MoveAdditive  := FALSE;
                    pFillPiston.MpAxisBasic_0.MoveAbsolute  := FALSE;
                    pFillPiston.MpAxisBasic_0.MoveVelocity  := FALSE;
                    
                    pCurrentHead.holdPressure          := pCurrentHead.pressureTransducer.pressure;
                    pCurrentHead.formingActualPressure := pCurrentHead.pressureTransducer.pressure;
                    IF (pCurrentHead.pressureTransducer.pressure >= pCurrentHead.formingPressureMax) THEN
                        pCurrentHead.formingPressureMax := pCurrentHead.pressureTransducer.pressure;
                    END_IF
                    
                    pFillPiston.MC_BR_TorqueControl_0.Enable          := FALSE;
                    pFillPiston.MC_BR_TorqueControl_0.StartSignal     := FALSE;
                    
                    IF (pFillPiston.MC_BR_TorqueControl_0.Active = FALSE) THEN
                        logArguments[3] := ADR(pCurrentHead.pressureTransducer.pressure);
                        logDebug('FillPiston', 'Module %h, Head %h, Node %h Hold Pressure Complete, Actual Pressure = %f', ADR(logArguments));
                        pFillPiston.state := READY;
                    END_IF
                    
                DEPRESSURIZE:
                    pFillPiston.MpAxisBasic_0.MoveAdditive  := FALSE;
                    pFillPiston.MpAxisBasic_0.MoveAbsolute  := FALSE;
                    pFillPiston.MpAxisBasic_0.MoveVelocity  := FALSE;
					pCurrentHead.fillPiston.status.fillPistonSequenceState := 60;
                    pCurrentHead.formingActualPressure      := pCurrentHead.pressureTransducer.pressure;

                    pFillPiston.MC_BR_TorqueControl_0.Enable            := TRUE;
                    pFillPiston.MC_BR_TorqueControl_0.StartSignal       := TRUE;
                    pFillPiston.MC_BR_TorqueControl_0.Torque            := 0; // Decompress pressure to Zero 
                    pFillPiston.MC_BR_TorqueControl_0.TorqueRamp        := pCurrentPiston.parameters.processData.pressureReliefRate;
                    pFillPiston.MC_BR_TorqueControl_0.PosMaxVelocity    := pCurrentPiston.parameters.machineData.velocity;
                    pFillPiston.MC_BR_TorqueControl_0.NegMaxVelocity    := 0;
                    pFillPiston.MC_BR_TorqueControl_0.Acceleration      := pCurrentPiston.parameters.machineData.acceleration;
                    pFillPiston.MC_BR_TorqueControl_0.TimeLimit         := 0.25;
                    pFillPiston.MC_BR_TorqueControl_0.Mode              := mcV_LIMIT_CALC + mcTIME_LIMIT;
                
                    IF (pFillPiston.MC_BR_TorqueControl_0.InTorque = TRUE) THEN
                        logArguments[3] := ADR(pCurrentHead.pressureTransducer.pressure);
						logDebug('FillPiston', 'Module %h, Head %h, Node %h Depressurize Complete, Actual Pressure = %f', ADR(logArguments));
						pFillPiston.MC_BR_TorqueControl_0.Enable          := FALSE;
						pFillPiston.MC_BR_TorqueControl_0.StartSignal     := FALSE;
                        pFillPiston.state := READY;
                    END_IF
                
					IF (pCurrentPiston.commands.depressurizeComplete = TRUE) THEN
						pFillPiston.MC_BR_TorqueControl_0.Enable          := FALSE;  
						pFillPiston.MC_BR_TorqueControl_0.StartSignal     := FALSE;
                        pCurrentHead.fillPiston.status.fillPistonSequenceState := 70;
                        pCurrentPiston.commands.depressurizeComplete    := FALSE;
                        logArguments[3]                                 := ADR(pCurrentHead.pressureTransducer.pressure);
                        logDebug('FillPiston', 'Module %h, Head %h, Node %h Depressurize Completed Commanded, Actual Pressure = %f', ADR(logArguments));
                        pFillPiston.state := READY;
                    END_IF
                
                ERROR:
                    pFillPiston.MpAxisBasic_0.MoveAbsolute          := FALSE;
                    pFillPiston.MpAxisBasic_0.MoveAdditive          := FALSE;
                    pFillPiston.MpAxisBasic_0.MoveVelocity          := FALSE;
                    pFillPiston.MC_BR_TorqueControl_0.Enable        := FALSE;
                    pFillPiston.MC_BR_TorqueControl_0.StartSignal   := FALSE;
                    
                    IF (pFillPiston.MpAxisBasic_0.PowerOn = FALSE) THEN
                        pFillPiston.MpAxisBasic_0.Power := FALSE;
                    END_IF
                    
                    IF (pCurrentPiston.commands.errorAcknowledge = TRUE) THEN
                        logDebug('FillPiston', 'Module %h, Head %h, Node %h Acknowledging Error', ADR(logArguments));
                        pCurrentPiston.commands.errorAcknowledge    := FALSE;
                        pFillPiston.MpAxisBasic_0.ErrorReset        := TRUE;
                    END_IF
            
                    IF (pFillPiston.MpAxisBasic_0.Error <> TRUE) THEN
                        ClearCommands;
                        logDebug('FillPiston', 'Module %h, Head %h, Node %h All Errors Acknowledged', ADR(logArguments));
                        pFillPiston.MpAxisBasic_0.ErrorReset    := FALSE;
                        pFillPiston.MpAxisBasic_0.Stop          := FALSE;
                        IF (pFillPiston.MpAxisBasic_0.PowerOn = TRUE) THEN
                            IF (pFillPiston.MpAxisBasic_0.IsHomed <> TRUE) THEN
                                pFillPiston.state := WAIT_FOR_HOME;
                            ELSE
                                pFillPiston.state := READY;
                            END_IF
                        ELSE
                            pFillPiston.state   := WAIT_FOR_POWER;
                        END_IF
                    
                    END_IF
            
			END_CASE
			
			IF (pFillPiston.MpAxisBasic_0.UpdateDone = TRUE) THEN
				pFillPiston.MpAxisBasic_0.Update := FALSE;
			END_IF
        
            IF (gModules[currentModule].heads[currentHead].enable = TRUE) THEN
                pFillPiston.MpAxisBasic_0.Enable                := TRUE;
                pFillPiston.mpParams.CyclicRead.TorqueMode      := mpAXIS_READ_CYCLIC;
                pFillPiston.mpParams.CyclicRead.UserChannelMode := mpAXIS_READ_CYCLIC;
            ELSE
                pFillPiston.MpAxisBasic_0.Enable                := FALSE;
                pFillPiston.mpParams.CyclicRead.TorqueMode      := mpAXIS_READ_OFF;
                pFillPiston.mpParams.CyclicRead.UserChannelMode := mpAXIS_READ_OFF;
            END_IF
        
            pFillPiston.MpAxisBasic_0.Enable      := TRUE;
            pFillPiston.MpAxisBasic_0.Axis        := ADR(pFillPiston.axis);
            pFillPiston.MpAxisBasic_0.MpLink      := pFillPiston.mpAxis;
            pFillPiston.MpAxisBasic_0.Parameters  := ADR(pFillPiston.mpParams);
            pFillPiston.MpAxisBasic_0();
            
            pFillPiston.MpAxisBasicConfig_0.Enable        := TRUE;
            pFillPiston.MpAxisBasicConfig_0.MpLink        := pFillPiston.mpAxis;
            pFillPiston.MpAxisBasicConfig_0.Configuration := pFillPiston.mpConfig;
            pFillPiston.MpAxisBasicConfig_0();
            IF (pFillPiston.MpAxisBasicConfig_0.CommandDone = TRUE) THEN
                pFillPiston.MpAxisBasicConfig_0.Load    := FALSE;
                pFillPiston.MpAxisBasicConfig_0.Save    := FALSE;
            END_IF

            // if the MC_BR_TorqueControl function block is used on the simulator then an error is generated
            IF NOT((pFillPiston.MpAxisBasic_0.Info.HardwareInfo.DeviceType = mpAXIS_ACOPOS_SIM) OR (pFillPiston.axis.simulation.acp_sim = ncTRUE)) THEN 
                pFillPiston.MC_BR_TorqueControl_0.Axis := ADR(pFillPiston.axis);
                pFillPiston.MC_BR_TorqueControl_0();
            END_IF
            
            pFillPiston.MC_BR_CheckEndlessPosition_0.Axis         := ADR(pFillPiston.axis);
            pFillPiston.MC_BR_CheckEndlessPosition_0.DataAddress  := pFillPiston.pEndlessPositionData;
            pFillPiston.MC_BR_CheckEndlessPosition_0();
            
            pFillPiston.MC_BR_CyclicRead_0.Enable       := TRUE;
            pFillPiston.MC_BR_CyclicRead_0.Axis         := ADR(pFillPiston.axis);
            pFillPiston.MC_BR_CyclicRead_0.ParID        := ACP10PAR_PCTRL_S_ACT;
            pFillPiston.MC_BR_CyclicRead_0.DataAddress  := ADR(pFillPiston.actualPosition);
            pFillPiston.MC_BR_CyclicRead_0.DataType     := ncPAR_TYP_DINT;
            pFillPiston.MC_BR_CyclicRead_0();
            IF (pFillPiston.MC_BR_CyclicRead_0.Valid = TRUE) THEN
                pCurrentPiston.status.actualPosition       := DINT_TO_REAL(pFillPiston.actualPosition) * LREAL_TO_REAL(pMpConfig.Axis.MeasurementResolution);
            END_IF
            
            pCurrentPiston.status.setPosition       := LREAL_TO_REAL(pFillPiston.MpAxisBasic_0.Position);
            pCurrentPiston.status.actualVelocity    := pFillPiston.MpAxisBasic_0.Velocity;
            pCurrentPiston.status.actualCurrent     := LREAL_TO_REAL(pFillPiston.MpAxisBasic_0.Info.CyclicRead.UserChannelParameterID.Value);
            pCurrentPiston.status.actualTorque      := LREAL_TO_REAL(pFillPiston.MpAxisBasic_0.Info.CyclicRead.Torque.Value);
           	pCurrentPiston.status.actualPressure    := (pFillPiston.pressureTransducer - pCurrentPiston.parameters.machineData.scalingOffset) * pCurrentPiston.parameters.machineData.scalingFactor;
			pCurrentPiston.status.inPosition        := pFillPiston.MpAxisBasic_0.InPosition;
            pCurrentPiston.status.moveComplete      := pFillPiston.MpAxisBasic_0.Info.MoveDone;
            
            pFillPiston.r_trig_pt0.CLK := (pCurrentHead.stretchRod.status.distanceToPt0 <= 0.0);
            pFillPiston.r_trig_pt0();
            IF (pFillPiston.r_trig_pt0.Q = TRUE) THEN
                pCurrentPiston.status.formingPositionAtPt0  := pCurrentPiston.status.actualPosition;
                 pCurrentPiston.status.formingVelocityAtPt0 := pCurrentPiston.status.actualVelocity;
            END_IF
            
            pFillPiston.r_trig_pt10.CLK := (pCurrentHead.stretchRod.status.distanceToPt10 <= 0.0);
            pFillPiston.r_trig_pt10();
            IF (pFillPiston.r_trig_pt10.Q = TRUE) THEN
                pCurrentPiston.status.formingPositionAtPt10 := pCurrentPiston.status.actualPosition;
                pCurrentPiston.status.formingVelocityAtPt10 := pCurrentPiston.status.actualVelocity;
			END_IF
			
            pCurrentPiston.status.moveActive		:= pFillPiston.MpAxisBasic_0.MoveActive;
            pCurrentPiston.status.errorActive       := pFillPiston.MpAxisBasic_0.Error;
            pCurrentPiston.status.errorNumber       := pFillPiston.MpAxisBasic_0.StatusID;
            pCurrentPiston.status.homed             := pFillPiston.MpAxisBasic_0.IsHomed;
            pCurrentPiston.status.atHome            := (pFillPiston.MpAxisBasic_0.IsHomed = TRUE) AND (pFillPiston.MpAxisBasic_0.Position <= (pFillPiston.mpParams.Home.Position + 1));  // if we are within 1 mm of the home position
            pCurrentPiston.status.homingOk          := ((pFillPiston.MC_BR_CheckEndlessPosition_0.EndlessPositionInitialized = TRUE) AND (pFillPiston.MC_BR_CheckEndlessPosition_0.DataValid = TRUE));
            pCurrentPiston.status.poweredOn         := pFillPiston.MpAxisBasic_0.PowerOn;
			pCurrentPiston.status.atReturnPos       := (pFillPiston.MpAxisBasic_0.IsHomed = TRUE) AND (pFillPiston.MpAxisBasic_0.Position <=  (pCurrentPiston.parameters.processData.fillCylinderReturnPosition + 1)AND (pFillPiston.MpAxisBasic_0.Position >= pCurrentPiston.parameters.processData.fillCylinderReturnPosition - 1));  // if we are within +-1 mm of the return position
			
            pCurrentPiston.status.negSwEndLimit     := LREAL_TO_REAL(pMpConfig.Axis.SoftwareLimitPositions.LowerLimit);
            pCurrentPiston.status.posSwEndLimit     := LREAL_TO_REAL(pMpConfig.Axis.SoftwareLimitPositions.UpperLimit);
            
            pCurrentPiston.status.onNegSwEndLimit   := (pFillPiston.MpAxisBasic_0.Position <= pMpConfig.Axis.SoftwareLimitPositions.LowerLimit);
            pCurrentPiston.status.onPosSwEndLimit   := (pFillPiston.MpAxisBasic_0.Position >= pMpConfig.Axis.SoftwareLimitPositions.UpperLimit);
            
            pCurrentPiston.status.onNegHwEndLimit   := pFillPiston.MpAxisBasic_0.Info.DigitalInputsStatus.NegativeLimitSwitch;
            pCurrentPiston.status.onPosHwEndLimit   := pFillPiston.MpAxisBasic_0.Info.DigitalInputsStatus.PositiveLimitSwitch;
 
            LogState;
            pFillPiston.r_trig_moveAbs.CLK := pFillPiston.MpAxisBasic_0.MoveAbsolute;
            pFillPiston.r_trig_moveAbs();
            IF (pFillPiston.r_trig_moveAbs.Q = TRUE) THEN
                logArguments[3] := ADR(pFillPiston.mpParams.Position);
                logArguments[4] := ADR(pFillPiston.mpParams.Velocity);
                logDebug('FillPiston', 'Module %h, Head %h, Node %h Moving Absolute to %L(mm) at %f(mm/s)', ADR(logArguments));
            END_IF
            
            pFillPiston.r_trig_moveRel.CLK := pFillPiston.MpAxisBasic_0.MoveAdditive;
            pFillPiston.r_trig_moveRel();
            IF (pFillPiston.r_trig_moveRel.Q = TRUE) THEN
                logArguments[3] := ADR(pFillPiston.mpParams.Distance);
                logArguments[4] := ADR(pFillPiston.mpParams.Velocity);
                logDebug('FillPiston', 'Module %h, Head %h, Node %h Moving Relative %L(mm) at %f(mm/s)', ADR(logArguments));
            END_IF
        END_FOR
            
    END_FOR

END_PROGRAM

PROGRAM _EXIT
    FOR currentModule:=0 TO NUMBER_OF_MODULES_M1 DO
        FOR currentHead:=0 TO NUM_OF_HEADS_PER_MODULE_M1 DO
            pFillPiston ACCESS ADR(fillPiston[indexOf(currentModule, currentHead, NUM_OF_HEADS_PER_MODULE)]);
            
            pFillPiston.MpAxisBasic_0.Enable := FALSE;
            pFillPiston.MpAxisBasic_0();
            
            pFillPiston.MpAxisBasicConfig_0.Enable := FALSE;
            pFillPiston.MpAxisBasicConfig_0();
            
            pFillPiston.MC_BR_TorqueControl_0.Enable := FALSE;
            pFillPiston.MC_BR_TorqueControl_0();

        END_FOR
    END_FOR
    
END_PROGRAM


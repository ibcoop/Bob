
PROGRAM _INIT

    stretchRod[0].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[0].stretchRod.parameters.machineData');
    stretchRod[1].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[1].stretchRod.parameters.machineData');
    stretchRod[2].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[0].stretchRod.parameters.machineData');
    stretchRod[3].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[1].stretchRod.parameters.machineData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        stretchRod[currentHead].MpRecipeRegPar_0.MpLink     := ADR(gMachineRecipe);
        stretchRod[currentHead].MpRecipeRegPar_0.Enable     := TRUE;
        stretchRod[currentHead].MpRecipeRegPar_0.Category   := ADR(MACHINE_CATEGORY);
        stretchRod[currentHead].MpRecipeRegPar_0();
    END_FOR
    
    stretchRod[0].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[0].stretchRod.parameters.processData');
    stretchRod[1].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[1].stretchRod.parameters.processData');
    stretchRod[2].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[0].stretchRod.parameters.processData');
    stretchRod[3].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[1].stretchRod.parameters.processData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        stretchRod[currentHead].MpRecipeRegPar_1.MpLink     := ADR(gProcessRecipe);
        stretchRod[currentHead].MpRecipeRegPar_1.Enable     := TRUE;
        stretchRod[currentHead].MpRecipeRegPar_1.Category   := ADR(PROCESS_CATEGORY);
        stretchRod[currentHead].MpRecipeRegPar_1();
    END_FOR

    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        itoa(currentHead+1, ADR(tempString));

        pStretchRod ACCESS ADR(stretchRod[currentHead]);
        pStretchRod.name := 'Head ';
        strcat(ADR(pStretchRod.name), ADR(tempString));
        strcat(ADR(pStretchRod.name), ADR(' Stretch Rod'));
    END_FOR
    
    IF (DiagCpuIsSimulated() = TRUE) THEN
        FOR currentModule:=0 TO NUMBER_OF_MODULES_M1 DO
            FOR currentHead:=0 TO NUM_OF_HEADS_PER_MODULE_M1 DO
                gModules[currentModule].heads[currentHead].stretchRod.status.calibratedPt0     := 10;
                gModules[currentModule].heads[currentHead].stretchRod.status.calibratedPt10    := 100;
            END_FOR
        END_FOR
    END_IF
    
END_PROGRAM

PROGRAM _CYCLIC
    
    stretchRod[0].mpAxis := ADR(gMpAxisStretchRod1);
	stretchRod[1].mpAxis := ADR(gMpAxisStretchRod2);
	stretchRod[2].mpAxis := ADR(gMpAxisStretchRod3);
	stretchRod[3].mpAxis := ADR(gMpAxisStretchRod4);
	
    stretchRod[0].mpConfig := ADR(mpConfig1);
    stretchRod[1].mpConfig := ADR(mpConfig2);
    stretchRod[2].mpConfig := ADR(mpConfig3);
    stretchRod[3].mpConfig := ADR(mpConfig4);
    
	//memset(ADR(logArguments), 0, SIZEOF(logArguments));

    FOR currentModule:=0 TO NUMBER_OF_MODULES_M1 DO
        FOR currentHead:=0 TO NUM_OF_HEADS_PER_MODULE_M1 DO
            pStretchRod ACCESS ADR(stretchRod[indexOf(currentModule, currentHead, NUM_OF_HEADS_PER_MODULE)]);
            pCurrentStretchRod ACCESS ADR(gModules[currentModule].heads[currentHead].stretchRod);
            pMpConfig ACCESS stretchRod[indexOf(currentModule, currentHead, NUM_OF_HEADS_PER_MODULE)].mpConfig;

            logArguments[0] := ADR(currentModule);
            logArguments[1] := ADR(currentHead);
            logArguments[2] := ADR(pStretchRod.MpAxisBasic_0.Info.HardwareInfo.NodeID);
		
		 // pressure transducer scaling for stretchrod fill level control pressure transducer
			pCurrentStretchRod.status.actualPressure    := (pCurrentStretchRod.status.pressureTransducerRaw - pCurrentStretchRod.parameters.machineData.pressureTransducer.scalingOffset) * pCurrentStretchRod.parameters.machineData.pressureTransducer.scalingFactor;


			
			
			
            // if an error occurs in any state then go to the error state
            CASE pStretchRod.state OF
                ERROR:
            
                ELSE
                    IF (pStretchRod.MpAxisBasic_0.Error = TRUE) THEN
                        IF (pStretchRod.MpAxisBasic_0.MoveActive = TRUE) THEN
                            pStretchRod.MpAxisBasic_0.Stop  := TRUE;
                        END_IF
                        logArguments[3] := ADR(pStretchRod.MpAxisBasic_0.StatusID);            
						logError('StretchRod', 'Module %h, Head %h, Node %h Error %d', ADR(logArguments));
						pCurrentStretchRod.status.stretchRodSequenceState := 999;
                        pStretchRod.state := ERROR;
                    ELSIF (pCurrentStretchRod.commands.errorAcknowledge = TRUE) THEN
                        pCurrentStretchRod.commands.errorAcknowledge := FALSE;
                    END_IF
            
            END_CASE
        
            CASE pStretchRod.state OF
            
                WAIT_FOR_POWER:
                    ClearCommands;                        
                    IF (pStretchRod.MpAxisBasic_0.Info.ReadyToPowerOn = TRUE) AND (pCurrentStretchRod.commands.powerOn = TRUE) THEN
                        logDebug('StretchRod', 'Module %h, Head %h, Node %h Powering On', ADR(logArguments));

						pCurrentStretchRod.status.calibratedPt0     := pCurrentStretchRod.parameters.processData.pt0;
						pCurrentStretchRod.status.calibratedPt10    := pCurrentStretchRod.parameters.processData.pt10;
                        
						pStretchRod.MpAxisBasic_0.Power         := TRUE;
                        pStretchRod.MpAxisBasicConfig_0.Load    := TRUE;
                        pStretchRod.state := INIT;
                    END_IF
            
                INIT:
                    IF (pStretchRod.MpAxisBasic_0.PowerOn = TRUE) THEN
                        ClearCommands;
                        logDebug('StretchRod', 'Module %h, Head %h, Node %h Powered On', ADR(logArguments));
                        pStretchRod.state := INIT;
                    END_IF

                    IF (pStretchRod.MpAxisBasic_0.Info.AxisInitialized = TRUE) THEN
                        pStretchRod.MpAxisBasic_0.Update := TRUE;
						logDebug('StretchRod', 'Module %h, Head %h, Node %h Axis Initialized', ADR(logArguments));
                        IF (pStretchRod.MpAxisBasic_0.IsHomed = TRUE) THEN
                            pStretchRod.state := READY;
                        ELSE
                            pStretchRod.state := WAIT_FOR_HOME;
                        END_IF
                    END_IF
            
                WAIT_FOR_HOME:
                    IF (pStretchRod.homeWarningID = 0) THEN
                        logWarn('StretchRod', 'Module %h, Head %h, Node %h Axis has not been homed', ADR(logArguments));
                        stretchRodErrorName := pStretchRod.name;
                        pStretchRod.homeWarningID := MpAlarmXSet(gAlarmXCore, 'STRETCHROD_NOT_HOMED');
                    END_IF
                    
                    IF (pCurrentStretchRod.commands.powerOn = FALSE) THEN
                        logDebug('StretchRod', 'Module %h, Head %h, Node %h Powering Off', ADR(logArguments));
                        pStretchRod.MpAxisBasic_0.Power   := FALSE;
                        pStretchRod.state                 := WAIT_FOR_POWER;
                    ELSIF (pCurrentStretchRod.commands.home = TRUE) THEN
                        pCurrentStretchRod.commands.home := FALSE;
                        logDebug('StretchRod', 'Module %h, Head %h, Node %h Homing Axis', ADR(logArguments));
                    
                        IF ((pStretchRod.MpAxisBasic_0.Info.HardwareInfo.DeviceType = mpAXIS_ACOPOS_SIM) OR (DiagCpuIsSimulated() = TRUE)) THEN
                            pStretchRod.mpParams.Home.Mode                              := mpAXIS_HOME_MODE_DIRECT;  // used for reference switch homing
							pStretchRod.mpParams.Home.ReferencePulse                    := mpAXIS_HOME_OPTION_OFF;
				//			pStretchRod.mpParams.Home.Mode                              := mpAXIS_HOME_MODE_BLOCK_TORQUE; // use for Torque control homing
							
                        ELSE
                            pStretchRod.mpParams.Home.Mode                              := mpAXIS_HOME_MODE_LIMIT_SWITCH;
							pStretchRod.mpParams.Home.ReferencePulse                    := mpAXIS_HOME_OPTION_OFF;
					//		pCurrentStretchRod.parameters.machineData.home.position		:= (-1 * pCurrentStretchRod.parameters.machineData.home.offset);  //used for home offset, check if *-1 is needed 
                        END_IF
                        
                        pStretchRod.mpParams.Home.SwitchEdge                        := mpAXIS_HOME_DIR_NEGATIVE;
                        pStretchRod.mpParams.Home.HomingDirection                   := mpAXIS_HOME_DIR_POSITIVE;
                        pStretchRod.mpParams.Home.Acceleration                      := pCurrentStretchRod.parameters.machineData.home.acceleration;
                        pStretchRod.mpParams.Home.StartVelocity                     := pCurrentStretchRod.parameters.machineData.home.velocity;
                        pStretchRod.mpParams.Home.HomingVelocity                    := pCurrentStretchRod.parameters.machineData.home.velocity / 2.0;
                        pStretchRod.mpParams.Home.Position                          := pCurrentStretchRod.parameters.machineData.home.position;
                      //  pStretchRod.mpParams.Home.SensorOffset					:= pCurrentStretchRod.parameters.machineData.home.offset; // offeset from ref sw.
						pStretchRod.MpAxisBasic_0.Home                              := TRUE;
                        pStretchRod.state                                           := HOMING;
                    END_IF
            
                HOMING:
                    IF (pStretchRod.MpAxisBasic_0.IsHomed = TRUE) THEN
                        ClearCommands;
                        logDebug('StretchRod', 'Module %h, Head %h, Node %h Axis Homed', ADR(logArguments));
                        pStretchRod.MpAxisBasic_0.Home    := FALSE;
                        MpAlarmXResetID(gAlarmXCore, pStretchRod.homeWarningID);
                        IF ((pCurrentStretchRod.status.calibratedPt0 <> 0) AND (pCurrentStretchRod.status.calibratedPt10 <> 0)) THEN
                            pStretchRod.state   := READY;
                        ELSE
                            pStretchRod.state   := WAIT_FOR_CALIBRATION;
                        END_IF
                    END_IF
                        
                WAIT_FOR_CALIBRATION:
                    IF (pStretchRod.calibrationWarningID = 0) THEN
                        stretchRodErrorName                 := pStretchRod.name;
                        pStretchRod.calibrationWarningID    := MpAlarmXSet(gAlarmXCore, 'STRETCHROD_NOT_CALIBRATED');
                    END_IF
                    
                    IF (AxisBasicCommands(ADR(pStretchRod), ADR(pCurrentStretchRod), ADR(logArguments)) = TRUE) THEN
                        // commands are handled by the function, so nothing to do here
                    ELSIF (pCurrentStretchRod.commands.calibratePt0 = TRUE) THEN
						pCurrentStretchRod.commands.calibratePt0    := FALSE;
						pStretchRod.calibratingPt0 					:= TRUE;
                        logArguments[3] := ADR(pCurrentStretchRod.parameters.machineData.calibration.torque);
                        logDebug('StretchRod', 'Module %h, Head %h, Node %h calibratePt0 with torque = %f', ADR(logArguments));
                        pStretchRod.state                           := CALIBRATION;
                    ELSIF (pCurrentStretchRod.commands.calibratePt10 = TRUE) THEN
						pCurrentStretchRod.commands.calibratePt10   := FALSE;
						pStretchRod.calibratingPt10 				:= TRUE;
                        logArguments[3] := ADR(pCurrentStretchRod.parameters.machineData.calibration.torque);
                        logDebug('StretchRod', 'Module %h, Head %h, Node %h calibratePt10 with torque = %f', ADR(logArguments));
                        pStretchRod.state                           := CALIBRATION;
                    END_IF
                
				CALIBRATION:
                    //IF ((pStretchRod.MpAxisBasic_0.Info.HardwareInfo.DeviceType <> mpAXIS_ACOPOS_SIM) AND (DiagCpuIsSimulated() = FALSE)) THEN
                        pStretchRod.MC_BR_TorqueControl_0.Enable            := TRUE;
                        pStretchRod.MC_BR_TorqueControl_0.StartSignal       := TRUE;
                        pStretchRod.MC_BR_TorqueControl_0.Mode              := mcV_LIMIT_CALC;

                        pStretchRod.MC_BR_TorqueControl_0.PosMaxVelocity    := pCurrentStretchRod.parameters.machineData.calibration.velocity;
                        pStretchRod.MC_BR_TorqueControl_0.NegMaxVelocity    := -1.0 * pStretchRod.MC_BR_TorqueControl_0.PosMaxVelocity;
                        pStretchRod.MC_BR_TorqueControl_0.Acceleration      := pCurrentStretchRod.parameters.machineData.calibration.acceleration;
                        pStretchRod.MC_BR_TorqueControl_0.Torque            := pCurrentStretchRod.parameters.machineData.calibration.torque;
	                    pStretchRod.MC_BR_TorqueControl_0.TorqueRamp        := 0.3;  // 0.3 Nm from original program
	                    pStretchRod.MC_BR_TorqueControl_0.TimeLimit         := 0;
					IF (pStretchRod.MC_BR_TorqueControl_0.InTorque = TRUE) THEN						
                        ClearCommands;
                        pStretchRod.MC_BR_TorqueControl_0.Enable        := FALSE;
                        pStretchRod.MC_BR_TorqueControl_0.StartSignal   := FALSE;	                        
						IF (pStretchRod.calibratingPt0 = TRUE) THEN						
							pStretchRod.calibratingPt0 						:= FALSE;
							pCurrentStretchRod.status.calibratedPt0 		:= pCurrentStretchRod.status.actualPosition - 1;
							pCurrentStretchRod.parameters.processData.pt0	:= pCurrentStretchRod.status.calibratedPt0;
                        ELSIF (pStretchRod.calibratingPt10 = TRUE) THEN
							pStretchRod.calibratingPt10 					:= FALSE;
							pCurrentStretchRod.status.calibratedPt10 		:= pCurrentStretchRod.status.actualPosition - 1;
							pCurrentStretchRod.parameters.processData.pt10	:= pCurrentStretchRod.status.calibratedPt10;
                        END_IF
                        IF ((pCurrentStretchRod.status.calibratedPt0 <> 0) AND (pCurrentStretchRod.status.calibratedPt10 <> 0)) THEN
							MpAlarmXResetID(gAlarmXCore, pStretchRod.calibrationWarningID);
							pCurrentStretchRod.commands.moveToRetraction	:= TRUE;// got to retract position after calibratin is done
                            pStretchRod.state                 				:= READY;
                        ELSE
                            pStretchRod.state                 				:= WAIT_FOR_CALIBRATION;
						END_IF
					END_IF

                
                READY:
                    IF (pStretchRod.MpAxisBasic_0.Position >= pCurrentStretchRod.parameters.processData.pt10) THEN
                        pCurrentStretchRod.status.startOfStretching := FALSE;
                        pCurrentStretchRod.status.endOfStretching   := TRUE;
                    END_IF
                    
                    IF (AxisBasicCommands(ADR(pStretchRod), ADR(pCurrentStretchRod), ADR(logArguments)) = TRUE) THEN
                        // commands are handled by the function, so nothing to do here    
                    ELSIF (pCurrentStretchRod.commands.moveToHome = TRUE) THEN
                        pCurrentStretchRod.commands.moveToHome := FALSE;
                        logDebug('StretchRod', 'Module %h, Head %h, Node %h moveToHome', ADR(logArguments));
                        pStretchRod.mpParams.Position               := pCurrentStretchRod.parameters.processData.homePosition;
                        pStretchRod.mpParams.Velocity               := pCurrentStretchRod.parameters.processData.homeVelocity;
                        pStretchRod.mpParams.Acceleration           := pCurrentStretchRod.parameters.machineData.acceleration;
                        pStretchRod.mpParams.Deceleration           := pStretchRod.mpParams.Acceleration;
                        pStretchRod.MpAxisBasic_0.MoveAbsolute      := TRUE;
                        pStretchRod.state                           := IN_MOTION;
                    ELSIF (pCurrentStretchRod.commands.moveToPremove = TRUE) THEN
                        pCurrentStretchRod.commands.moveToPremove   := FALSE;
						logDebug('StretchRod', 'Module %h, Head %h, Node %h moveToPremove', ADR(logArguments));
						pCurrentStretchRod.status.stretchRodSequenceState := 10;
                        pStretchRod.mpParams.Position               := pCurrentStretchRod.parameters.processData.premovePosition;
                        pStretchRod.mpParams.Velocity               := pCurrentStretchRod.parameters.processData.premoveVelocity;
                        pStretchRod.mpParams.Acceleration           := pCurrentStretchRod.parameters.machineData.acceleration;
                        pStretchRod.mpParams.Deceleration           := pStretchRod.mpParams.Acceleration;
                        pStretchRod.MpAxisBasic_0.MoveAbsolute      := TRUE;
                        pStretchRod.state                           := IN_MOTION;
                    ELSIF (pCurrentStretchRod.commands.moveToStretch = TRUE) THEN
                        pCurrentStretchRod.commands.moveToStretch   := FALSE;
						logDebug('StretchRod', 'Module %h, Head %h, Node %h moveToStretch', ADR(logArguments));
						pCurrentStretchRod.status.stretchRodSequenceState := 20;
                        pStretchRod.mpParams.Position               := pCurrentStretchRod.parameters.processData.pt10;
                        pStretchRod.mpParams.Velocity               := pCurrentStretchRod.parameters.processData.stretchVelocity;
                        pStretchRod.mpParams.Acceleration           := pCurrentStretchRod.parameters.machineData.acceleration;
                        pStretchRod.mpParams.Deceleration           := pStretchRod.mpParams.Acceleration;
                        pStretchRod.MpAxisBasic_0.MoveAbsolute      := TRUE;
                        pStretchRod.state                           := IN_MOTION;
                        pCurrentStretchRod.status.startOfStretching := TRUE;
                        pCurrentStretchRod.status.endOfStretching   := FALSE;
                    ELSIF (pCurrentStretchRod.commands.moveToVolumetricPosition = TRUE) THEN
                        pCurrentStretchRod.commands.moveToVolumetricPosition:= FALSE;
						logDebug('StretchRod', 'Module %h, Head %h, Node %h moveToVolumetricPosition', ADR(logArguments));
						pCurrentStretchRod.status.stretchRodSequenceState := 30;
                        pStretchRod.mpParams.Position               := pCurrentStretchRod.parameters.processData.volumetricPosition;
                        pStretchRod.mpParams.Velocity               := pCurrentStretchRod.parameters.processData.volumetricVelocity;
                        pStretchRod.mpParams.Acceleration           := pCurrentStretchRod.parameters.machineData.acceleration;
                        pStretchRod.mpParams.Deceleration           := pStretchRod.mpParams.Acceleration;
                        pStretchRod.MpAxisBasic_0.MoveAbsolute      := TRUE;
                        pStretchRod.state                           := IN_MOTION;
                    ELSIF (pCurrentStretchRod.commands.moveToFillLevel = TRUE) THEN
                        pCurrentStretchRod.commands.moveToFillLevel := FALSE;
						logDebug('StretchRod', 'Module %h, Head %h, Node %h moveToFillLevel', ADR(logArguments));
						pCurrentStretchRod.status.stretchRodSequenceState := 40;
                        pStretchRod.mpParams.Position               := pCurrentStretchRod.parameters.processData.fillLevelPosition;
                        pStretchRod.mpParams.Velocity               := pCurrentStretchRod.parameters.processData.fillLevelVelocity;
                        pStretchRod.mpParams.Acceleration           := pCurrentStretchRod.parameters.machineData.acceleration;
                        pStretchRod.mpParams.Deceleration           := pStretchRod.mpParams.Acceleration;
                        pStretchRod.MpAxisBasic_0.MoveAbsolute      := TRUE;
                        pStretchRod.state                           := IN_MOTION;
                    ELSIF (pCurrentStretchRod.commands.moveToRetraction = TRUE) THEN
                        pCurrentStretchRod.commands.moveToRetraction := FALSE;
						logDebug('StretchRod', 'Module %h, Head %h, Node %h moveToRetraction', ADR(logArguments));
						pCurrentStretchRod.status.stretchRodSequenceState := 50;
                        pStretchRod.mpParams.Position               := pCurrentStretchRod.parameters.processData.retractPosition;
                        pStretchRod.mpParams.Velocity               := pCurrentStretchRod.parameters.processData.retractVelocity;
                        pStretchRod.mpParams.Acceleration           := pCurrentStretchRod.parameters.machineData.acceleration;
                        pStretchRod.mpParams.Deceleration           := pStretchRod.mpParams.Acceleration;
                        pStretchRod.MpAxisBasic_0.MoveAbsolute      := TRUE;
                        pStretchRod.state                           := IN_MOTION;
                    ELSIF (pCurrentStretchRod.commands.calibratePt0 = TRUE) THEN
						pCurrentStretchRod.commands.calibratePt0    := FALSE;
						pStretchRod.calibratingPt0 					:= TRUE;
						logDebug('StretchRod', 'Module %h, Head %h, Node %h calibratePt0', ADR(logArguments));
						pStretchRod.state                           := CALIBRATION;
                    ELSIF (pCurrentStretchRod.commands.calibratePt10 = TRUE) THEN
						pCurrentStretchRod.commands.calibratePt10   := FALSE;
						pStretchRod.calibratingPt10 				:= TRUE;
						logDebug('StretchRod', 'Module %h, Head %h, Node %h calibratePt10', ADR(logArguments));
						pStretchRod.state                           := CALIBRATION;
                    END_IF
            
                IN_MOTION:
                    IF (pCurrentStretchRod.commands.abort = TRUE) THEN
                        pCurrentStretchRod.commands.abort := FALSE;
                        logDebug('StretchRod', 'Module %h, Head %h, Node %h Abort', ADR(logArguments));
                        pStretchRod.MpAxisBasic_0.MoveAdditive  := FALSE;
                        pStretchRod.MpAxisBasic_0.MoveAbsolute  := FALSE;
                        pStretchRod.MpAxisBasic_0.MoveVelocity  := FALSE;
                        pStretchRod.MpAxisBasic_0.Stop          := TRUE;
                    ELSIF ((pStretchRod.MpAxisBasic_0.Info.MoveDone = TRUE) OR (pStretchRod.MpAxisBasic_0.Stopped = TRUE)) THEN
                        logArguments[3] := ADR(pCurrentStretchRod.status.actualPosition);
                        logDebug('StretchRod', 'Module %h, Head %h, Node %h In Position %f', ADR(logArguments));
                        pStretchRod.MpAxisBasic_0.MoveAdditive  := FALSE;
                        pStretchRod.MpAxisBasic_0.MoveAbsolute  := FALSE;
                        pStretchRod.MpAxisBasic_0.MoveVelocity  := FALSE;
                        pStretchRod.MpAxisBasic_0.Stop          := FALSE;
                        pStretchRod.state                       := READY;
                    ELSIF (((pCurrentStretchRod.commands.jogNegative = FALSE) AND (pStretchRod.MpAxisBasic_0.JogNegative = TRUE)) OR 
                           ((pCurrentStretchRod.commands.jogPositive = FALSE) AND (pStretchRod.MpAxisBasic_0.JogPositive = TRUE))) THEN
                        logDebug('StretchRod', 'Module %h, Head %h, Node %h Stopping Jog', ADR(logArguments));
                        pStretchRod.MpAxisBasic_0.JogNegative := FALSE;    
                        pStretchRod.MpAxisBasic_0.JogPositive := FALSE;
						pStretchRod.state                     := READY;
					END_IF
                
                ERROR:
                    pStretchRod.MpAxisBasic_0.MoveAbsolute          := FALSE;
                    pStretchRod.MpAxisBasic_0.MoveAdditive          := FALSE;
                    pStretchRod.MpAxisBasic_0.MoveVelocity          := FALSE;
                    pStretchRod.MC_BR_TorqueControl_0.Enable        := FALSE;
                    pStretchRod.MC_BR_TorqueControl_0.StartSignal   := FALSE;
                    
                    IF (pStretchRod.MpAxisBasic_0.PowerOn = FALSE) THEN
                        pStretchRod.MpAxisBasic_0.Power := FALSE;
                    END_IF
                    
					IF (pCurrentStretchRod.commands.errorAcknowledge = TRUE) THEN
                        logDebug('StretchRod', 'Module %h, Head %h, Node %h Acknowledging Error', ADR(logArguments));
                        pCurrentStretchRod.commands.errorAcknowledge    := FALSE;
                        pStretchRod.MpAxisBasic_0.ErrorReset            := TRUE;
                    END_IF
            
                    IF (pStretchRod.MpAxisBasic_0.Error <> TRUE) THEN                        
                        ClearCommands;
                        logDebug('StretchRod', 'Module %h, Head %h, Node %h All Errors Acknowledged', ADR(logArguments));
                        pStretchRod.MpAxisBasic_0.ErrorReset  := FALSE;
                        pStretchRod.MpAxisBasic_0.Stop        := FALSE;
                        IF (pStretchRod.MpAxisBasic_0.PowerOn = TRUE) THEN
                            IF (pStretchRod.MpAxisBasic_0.IsHomed <> TRUE) THEN
                                pStretchRod.state := WAIT_FOR_HOME;
                            ELSE
                                pStretchRod.state := READY;
                            END_IF
                        ELSE
                            pStretchRod.state    := WAIT_FOR_POWER;
                        END_IF
                    
                    END_IF
            
            END_CASE
        
			IF (pStretchRod.MpAxisBasic_0.UpdateDone = TRUE) THEN
				pStretchRod.MpAxisBasic_0.Update := FALSE;
			END_IF
					
            IF (gModules[currentModule].heads[currentHead].enable = TRUE) THEN
                pStretchRod.MpAxisBasic_0.Enable := TRUE;
                pStretchRod.mpParams.CyclicRead.TorqueMode := mpAXIS_READ_CYCLIC;
                pStretchRod.mpParams.CyclicRead.UserChannelMode := mpAXIS_READ_CYCLIC;
            ELSE
                pStretchRod.MpAxisBasic_0.Enable := FALSE;
                pStretchRod.mpParams.CyclicRead.TorqueMode := mpAXIS_READ_OFF;
                pStretchRod.mpParams.CyclicRead.UserChannelMode := mpAXIS_READ_OFF;
        
            END_IF
            
            // if the MC_BR_TorqueControl function block is used on the simulator then an error is generated
            IF (pStretchRod.MpAxisBasic_0.Info.HardwareInfo.DeviceType = mpAXIS_ACOPOS_SIM) THEN
                pStretchRod.MC_BR_TorqueControl_0.Axis := ADR(pStretchRod.axis);
                pStretchRod.MC_BR_TorqueControl_0();
            END_IF
        
            pStretchRod.MpAxisBasic_0.Enable        := TRUE;
            pStretchRod.MpAxisBasic_0.Axis          := ADR(pStretchRod.axis);
            pStretchRod.MpAxisBasic_0.MpLink        := pStretchRod.mpAxis;
            pStretchRod.MpAxisBasic_0.Parameters    := ADR(pStretchRod.mpParams);
            pStretchRod.MpAxisBasic_0();

            pStretchRod.MpAxisBasicConfig_0.Enable        := TRUE;
            pStretchRod.MpAxisBasicConfig_0.MpLink        := pStretchRod.mpAxis;
            pStretchRod.MpAxisBasicConfig_0.Configuration := pStretchRod.mpConfig;
            pStretchRod.MpAxisBasicConfig_0();
            IF (pStretchRod.MpAxisBasicConfig_0.CommandDone = TRUE) THEN
                pStretchRod.MpAxisBasicConfig_0.Load    := FALSE;
                pStretchRod.MpAxisBasicConfig_0.Save    := FALSE;
            END_IF
        
            pStretchRod.MC_BR_TorqueControl_0.Axis  := ADR(pStretchRod.axis);
            pStretchRod.MC_BR_TorqueControl_0();

            pStretchRod.MC_BR_CyclicRead_0.Enable       := TRUE;
            pStretchRod.MC_BR_CyclicRead_0.Axis         := ADR(pStretchRod.axis);
            pStretchRod.MC_BR_CyclicRead_0.ParID        := ACP10PAR_PCTRL_S_ACT;
            pStretchRod.MC_BR_CyclicRead_0.DataAddress  := ADR(pStretchRod.actualPosition);
            pStretchRod.MC_BR_CyclicRead_0.DataType     := ncPAR_TYP_DINT;
            pStretchRod.MC_BR_CyclicRead_0();
            IF (pStretchRod.MC_BR_CyclicRead_0.Valid = TRUE) THEN
                pCurrentStretchRod.status.actualPosition       := DINT_TO_REAL(pStretchRod.actualPosition) * LREAL_TO_REAL(pMpConfig.Axis.MeasurementResolution);
            END_IF
            
            pCurrentStretchRod.status.setPosition       := LREAL_TO_REAL(pStretchRod.MpAxisBasic_0.Position);
            pCurrentStretchRod.status.actualVelocity    := pStretchRod.MpAxisBasic_0.Velocity;
            pCurrentStretchRod.status.actualCurrent     := LREAL_TO_REAL(pStretchRod.MpAxisBasic_0.Info.CyclicRead.UserChannelParameterID.Value);
            pCurrentStretchRod.status.actualTorque      := LREAL_TO_REAL(pStretchRod.MpAxisBasic_0.Info.CyclicRead.Torque.Value);
            pCurrentStretchRod.status.inPosition        := pStretchRod.MpAxisBasic_0.InPosition;
            pCurrentStretchRod.status.moveComplete      := pStretchRod.MpAxisBasic_0.Info.MoveDone;

            pCurrentStretchRod.status.errorActive       := pStretchRod.MpAxisBasic_0.Error;
            pCurrentStretchRod.status.errorNumber       := pStretchRod.MpAxisBasic_0.StatusID;
            pCurrentStretchRod.status.homed             := pStretchRod.MpAxisBasic_0.IsHomed;
            pCurrentStretchRod.status.atHome            := (pStretchRod.MpAxisBasic_0.IsHomed = TRUE) AND (pStretchRod.MpAxisBasic_0.Position <= (pStretchRod.mpParams.Home.Position + 1));  // if we are within 1 mm of the home position
			pCurrentStretchRod.status.atRetractPos      := (pStretchRod.MpAxisBasic_0.IsHomed = TRUE) AND (pStretchRod.MpAxisBasic_0.Position <= (pCurrentStretchRod.parameters.processData.retractPosition + 1) AND (pStretchRod.MpAxisBasic_0.Position >= pCurrentStretchRod.parameters.processData.retractPosition - 1));  // if we are within 1 mm of the home position
     
			pCurrentStretchRod.status.poweredOn         := pStretchRod.MpAxisBasic_0.PowerOn;
            pCurrentStretchRod.status.moveActive        := pStretchRod.MpAxisBasic_0.MoveActive;
			
            pCurrentStretchRod.status.negSwEndLimit     := LREAL_TO_REAL(pMpConfig.Axis.SoftwareLimitPositions.LowerLimit);
            pCurrentStretchRod.status.posSwEndLimit     := LREAL_TO_REAL(pMpConfig.Axis.SoftwareLimitPositions.UpperLimit);
            
            pCurrentStretchRod.status.onNegSwEndLimit   := (pStretchRod.MpAxisBasic_0.Position <= pMpConfig.Axis.SoftwareLimitPositions.LowerLimit);
            pCurrentStretchRod.status.onPosSwEndLimit   := (pStretchRod.MpAxisBasic_0.Position >= pMpConfig.Axis.SoftwareLimitPositions.UpperLimit);
            
            pCurrentStretchRod.status.onNegHwEndLimit   := pStretchRod.MpAxisBasic_0.Info.DigitalInputsStatus.NegativeLimitSwitch;
            pCurrentStretchRod.status.onPosHwEndLimit   := pStretchRod.MpAxisBasic_0.Info.DigitalInputsStatus.PositiveLimitSwitch;

            pCurrentStretchRod.status.distanceToPt10    := pCurrentStretchRod.parameters.processData.pt10 - pCurrentStretchRod.parameters.processData.premovePosition;
            pCurrentStretchRod.status.distanceToPt0     := pCurrentStretchRod.parameters.processData.pt0 - pCurrentStretchRod.parameters.processData.premovePosition;
            
            pCurrentStretchRod.parameters.processData.pt1 := pCurrentStretchRod.parameters.processData.pt0 + pCurrentStretchRod.parameters.processData.pt1Offset;
            
            pStretchRod.startStretchTrigger.CLK := (pCurrentStretchRod.status.actualPosition >= pCurrentStretchRod.parameters.processData.premovePosition);
            pStretchRod.startStretchTrigger();
            IF (pStretchRod.startStretchTrigger.Q = TRUE) THEN
                pCurrentStretchRod.status.degreeAtStretchingStart := gMachineControl.status.masterPosition;
            END_IF
    
            pStretchRod.atPt0.CLK := (pCurrentStretchRod.status.actualPosition >= pCurrentStretchRod.parameters.processData.pt0);
            pStretchRod.atPt0();
			IF (pStretchRod.atPt0.Q = TRUE) THEN
				pCurrentStretchRod.status.stretchRodSequenceState := 21;
                pCurrentStretchRod.status.degreeAtPt0 := gMachineControl.status.masterPosition;
            END_IF
            pStretchRod.atPt10.CLK := (pCurrentStretchRod.status.actualPosition >= (pCurrentStretchRod.parameters.processData.pt10 - 0.3)); //  minus 0.3mm for in position tolorance
            pStretchRod.atPt10();
			IF (pStretchRod.atPt10.Q = TRUE) THEN
			pCurrentStretchRod.status.stretchRodSequenceState := 22;	
                pCurrentStretchRod.status.degreeAtPt10 := gMachineControl.status.masterPosition;
			END_IF
			    
			pStretchRod.atPreMove.CLK := (pCurrentStretchRod.status.actualPosition >= (pCurrentStretchRod.parameters.processData.premovePosition - 0.3));// minue 0.3mm for in position tolorance
			pStretchRod.atPreMove();
			IF (pStretchRod.atPt0.Q = TRUE) THEN
				pCurrentStretchRod.status.degreeAtPremove := gMachineControl.status.masterPosition;
			END_IF
            
            LogState;
            
            pStretchRod.r_trig_moveAbs.CLK := pStretchRod.MpAxisBasic_0.MoveAbsolute;
            pStretchRod.r_trig_moveAbs();
            IF (pStretchRod.r_trig_moveAbs.Q = TRUE) THEN
                logArguments[3] := ADR(pStretchRod.mpParams.Position);
                logArguments[4] := ADR(pStretchRod.mpParams.Velocity);
                logDebug('StretchRod', 'Module %h, Head %h, Node %h Moving Absolute to %L(mm) at %f(mm/s)', ADR(logArguments));
            END_IF

        END_FOR
        
    END_FOR

END_PROGRAM

PROGRAM _EXIT
    FOR currentModule:=0 TO NUMBER_OF_MODULES_M1 DO
        FOR currentHead:=0 TO NUM_OF_HEADS_PER_MODULE_M1 DO
            pStretchRod ACCESS ADR(stretchRod[indexOf(currentModule, currentHead, NUM_OF_HEADS_PER_MODULE)]);
            
            pStretchRod.MpAxisBasic_0.Enable := FALSE;
            pStretchRod.MpAxisBasic_0();
            
            pStretchRod.MpAxisBasicConfig_0.Enable := FALSE;
            pStretchRod.MpAxisBasicConfig_0();
            
            pStretchRod.MC_BR_TorqueControl_0.Enable := FALSE;
            pStretchRod.MC_BR_TorqueControl_0();

        END_FOR
    END_FOR
END_PROGRAM



PROGRAM _INIT
	(* Insert code here *)
    AsLoggerServer_0.port   := 15622;
    AsLoggerServer_0.level  := LOG_LEVEL_DEBUG;

    AsLoggerFile_0.enable   := TRUE;
    strcpy(ADR(AsLoggerFile_0.delimiter), ADR(','));
    strcpy(ADR(AsLoggerFile_0.device), ADR('control'));
    strcpy(ADR(AsLoggerFile_0.fileExtension), ADR('csv'));
    strcpy(ADR(AsLoggerFile_0.fileName), ADR('diagnostics\logTest'));
    AsLoggerFile_0.maxFiles     := 10;
    AsLoggerFile_0.maxFileSize  := 100000;
    AsLoggerFile_0.level        := LOG_LEVEL_DEBUG;
    
    StatusIOList:= IOList(ADR(pIOInformation));

    IOReadIndex:= 0;

    Step:= INIT;
    
    memset(ADR(OldBatteryState), 1, SIZEOF(OldBatteryState));
    
    // set all old module state to 3
    // which is that it is connected TO prevent the LOG error from showing up on power up
    FOR i:=0 TO ((SIZEOF(OldModuleState)/SIZEOF(OldModuleState[0])) - 1) DO
        OldModuleState[i] := 3;
    END_FOR
    
    logErrorOnce := FALSE;
	 
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
    AsLoggerServer_0();
    AsLoggerFile_0();
    
    ModuleDiagnose_1.AdrModuleInformationBuffer:= ADR(ModuleInformation);
    ModuleDiagnose_1.Option:= DiagnoseOption;
    ModuleDiagnose_1.AdrAlarmInformation:= ADR(AlarmInformation);
    ModuleDiagnose_1();
    pIOData ACCESS pIOInformation.StartAdrBuffer + (IOReadIndex * SIZEOF(pIOData));
    Elements:= pIOInformation.TotalIONumber;

    CASE ModuleDiagnose_1.status OF
        0:
            NumberOfTotalModules:= ModuleDiagnose_1.NumberOfTotalModules - ModuleDiagnose_1.NumberNotCheckedModules;
        
        ERR_FUB_BUSY:
        ERR_FUB_ENABLE_FALSE:
            
        ELSE
            IF (logErrorOnce = FALSE) THEN
                logErrorOnce := TRUE;
                logError('IO Diagnostics', 'Error in IO Module Diagnosis Function', 0);
            END_IF
        
    END_CASE
    
    MemCheck.enable := 1;
    MemCheck.mem_typ := brUSRRAM;
    MemCheck();
		
    IF ((strcmp(ADR(ModuleInformation[0].ModuleName),ADR('1A4000.00')) = 0) OR (DiagCpuIsSimulated() = TRUE)) THEN
        mSimulationMode:= 1;
        RETURN;
    ELSE
        mSimulationMode:= 0;
    END_IF
        
    IF (ADR(pIOInformation) <> 0) THEN

        CASE shortCircuitState OF
            0:
                // IF (short_circuit_check_index >= pIOInformation.TotalIONumber) THEN
                IF ((short_circuit_check_index >= MAX_IO_SLICE) OR (short_circuit_check_index >= pIOInformation.TotalIONumber)) THEN //letting this go to TotalIONumber could result in an array-out-of-bounds
                    short_circuit_check_index := 0;
                END_IF

                IF (pIOInformation.StartAdrBuffer <> 0) THEN
                    pIODataShortCircuit ACCESS pIOInformation.StartAdrBuffer + (short_circuit_check_index * SIZEOF(pIOData));

                    // check if this is a digital output
                    FindResult := FIND(pIODataShortCircuit.ID,'%QX.');
                    IF ((FindResult >= 1) AND (FIND(pIODataShortCircuit.ID,'.DigitalOutput') >= 1)) THEN
                        strcpy(ADR(shortCircuitName), ADR(pIODataShortCircuit.ID));

                        // the following code will change the convert the output name into the input status name
                        // %QX is replaced by %IX
                        // DigitalOutput is replaced by StatusDigitalOutput
                        shortCircuitName := REPLACE(shortCircuitName, '%IX.', strlen(ADR('%IX.')), FindResult);
                        FindResult:= FIND(shortCircuitName,'.DigitalOutput');
                        shortCircuitName := DELETE(shortCircuitName, strlen(ADR('.DigitalOutput')), FindResult);
                        shortCircuitName := INSERT(shortCircuitName, '.StatusDigitalOutput', FindResult - 1);

                        AsIODPStatus_0.enable := TRUE;
                        AsIODPStatus_0.pDatapoint := ADR(shortCircuitName);
                        shortCircuitState := 10;
                    ELSE
                        short_circuit_check_index := short_circuit_check_index + 1;
                    END_IF
                END_IF

            10:
                IF (AsIODPStatus_0.status = 0) THEN
                    AsIODPStatus_0.enable := FALSE;
                    
                    IF (AsIODPStatus_0.value = 1) AND (shortCircuitCheckOldData[short_circuit_check_index] <> TRUE) THEN
                        shortCircuitCheckOldData[short_circuit_check_index] := TRUE;
                        strcpy(ADR(logString), ADR('short circuit on digital output: '));
                        pIODataShortCircuit.ID := RIGHT(pIODataShortCircuit.ID, strlen(ADR(pIODataShortCircuit.ID)) - FIND(pIODataShortCircuit.ID,'.SL'));
                        strcpy(ADR(moduleError), ADR(pIODataShortCircuit.ID));
                        strcat(ADR(logString), ADR(moduleError));
                        logError('IO Diagnostics', logString, 0);
                        shortCircuitAlarmID := MpAlarmXSet(gAlarmXCore,  'IO_SHORT');
                    END_IF
                    
                    IF (AsIODPStatus_0.value = 0) AND (shortCircuitCheckOldData[short_circuit_check_index] = TRUE) THEN
                        shortCircuitCheckOldData[short_circuit_check_index] := FALSE;
                        strcpy(ADR(logString), ADR('digital output is no longer shorted: '));
                        pIODataShortCircuit.ID := RIGHT(pIODataShortCircuit.ID, strlen(ADR(pIODataShortCircuit.ID)) - FIND(pIODataShortCircuit.ID,'.SL'));
                        strcat(ADR(logString), ADR(pIODataShortCircuit.ID));
                        logError('IO Diagnostics', logString, 0);
                        MpAlarmXResetID(gAlarmXCore,  shortCircuitAlarmID);
                    END_IF
                    short_circuit_check_index := short_circuit_check_index + 1;
                    shortCircuitState := 0;
                
                ELSIF ((AsIODPStatus_0.status > 0) AND (AsIODPStatus_0.status < 65534)) THEN
                    AsIODPStatus_0.enable := FALSE;
                    short_circuit_check_index := short_circuit_check_index + 1;
                    shortCircuitState := 0;
                END_IF
                
                IF (AsIODPStatus_0.status = 65534) THEN
                    AsIODPStatus_0.enable := TRUE;
                END_IF
                  
        END_CASE
        AsIODPStatus_0();
        
    END_IF
    
    CASE batteryStatusState OF
        0:
            IF (batteryStatusIndex >= ((SIZEOF(ModuleInformation)/SIZEOF(ModuleInformation[0])) - 1)) THEN
                batteryStatusIndex := 0;
            END_IF

            IF (ModuleInformation[batteryStatusIndex].ModulePath = '$$root') OR
                (FIND(ModuleInformation[batteryStatusIndex].ModuleName, '5LS') >= 1) THEN

                IF (ModuleInformation[batteryStatusIndex].ModulePath = '$$root') THEN
                    batteryInputName := '%IB.BatteryStatusCPU';
                ELSE
                    batteryInputName := '%IB.';
                    strcat(ADR(batteryInputName), ADR(ModuleInformation[batteryStatusIndex].ModulePath));
                    strcat(ADR(batteryInputName), ADR('.BatteryStatus'));
                END_IF

                AsIODPStatus_2.enable := TRUE;
                AsIODPStatus_2.pDatapoint := ADR(batteryInputName);

                batteryStatusState := 10;
            ELSE
                batteryStatusIndex := batteryStatusIndex + 1;
            END_IF

        10:
            CASE AsIODPStatus_2.status OF
                0:
                    // value read successfully
                    // check if the battery status is 0, which means that the battery is low
                    AsIODPStatus_2.enable := FALSE;
                    IF (AsIODPStatus_2.value = 0) AND (OldBatteryState[batteryStatusIndex] = TRUE) THEN
                        strcpy(ADR(logString), ADR('Battery is low in module ' ));
                        strcat(ADR(logString), ADR(ModuleInformation[batteryStatusIndex].ModuleName));
                        logError('IO Diagnostics', logString, 0);
                    ELSIF (AsIODPStatus_2.value = 1) AND (OldBatteryState[batteryStatusIndex] = FALSE) THEN
                        
                    END_IF
                    OldBatteryState[batteryStatusIndex] := UDINT_TO_BOOL(AsIODPStatus_2.value);
                    batteryStatusIndex := batteryStatusIndex + 1;
                    batteryStatusState := 0;

                65534:
                    AsIODPStatus_2.enable := TRUE;

                65535:
                    // do nothing

                ELSE
                    AsIODPStatus_2.enable := FALSE;
                    batteryStatusIndex := batteryStatusIndex + 1;
                    batteryStatusState := 0;
            END_CASE

    END_CASE
    
    AsIODPStatus_2();

    FOR checkModuleStatusIndex:=0 TO ((SIZEOF(ModuleInformation)/SIZEOF(ModuleInformation[0])) - 1) DO
        IF ((ModuleInformation[checkModuleStatusIndex].ModuleState <> 0) AND
            NOT((FIND(ModuleInformation[checkModuleStatusIndex].ModuleName, '8LS')  <> 0) OR
            (FIND(ModuleInformation[checkModuleStatusIndex].ModuleName, '8JS')  <> 0) OR 
            (FIND(ModuleInformation[checkModuleStatusIndex].ModuleName, '8LV')  <> 0) OR
            (FIND(ModuleInformation[checkModuleStatusIndex].ModuleName, '8MS')  <> 0) OR
            (FIND(ModuleInformation[checkModuleStatusIndex].ModuleName, '8V')   <> 0) OR
            (FIND(ModuleInformation[checkModuleStatusIndex].ModuleName, '8BV')  <> 0) OR
            (FIND(ModuleInformation[checkModuleStatusIndex].ModuleName, '8CV')  <> 0) OR
            (FIND(ModuleInformation[checkModuleStatusIndex].ModuleName, '80SD') <> 0) OR
            (FIND(ModuleInformation[checkModuleStatusIndex].ModuleName, '80VD') <> 0) OR
            (FIND(ModuleInformation[checkModuleStatusIndex].ModuleName, '8BAC') <> 0) OR
            (FIND(ModuleInformation[checkModuleStatusIndex].ModuleName, '8AC') <> 0) OR
            (FIND(ModuleInformation[checkModuleStatusIndex].ModulePath, 'M1') <> 0))) THEN
            IF (ModuleInformation[checkModuleStatusIndex].ModuleState <> OldModuleState[checkModuleStatusIndex]) THEN
                CASE (ModuleInformation[checkModuleStatusIndex].ModuleState) OF
                    1:
                        strcpy(ADR(logString), ADR('I/O Module is not plugged in: '));
                        strcpy(ADR(moduleError), ADR(ModuleInformation[checkModuleStatusIndex].ModuleName));
                        strcat(ADR(moduleError), ADR(' '));
                        strcat(ADR(moduleError), ADR(ModuleInformation[checkModuleStatusIndex].ModulePath));
                        strcat(ADR(logString), ADR(moduleError));
                        logError('IO Diagnostics', logString, 0);
                        ModuleInformation[checkModuleStatusIndex].notPluggedAlarmID := MpAlarmXSet(gAlarmXCore,  'IO_NOT_PLUGGED');
                    
                    2:
                        strcpy(ADR(logString), ADR('I/O Module is plugged in but not configured: '));
                        strcpy(ADR(moduleError), ADR(ModuleInformation[checkModuleStatusIndex].ModuleName));
                        strcat(ADR(moduleError), ADR(' '));
                        strcat(ADR(moduleError), ADR(ModuleInformation[checkModuleStatusIndex].ModulePath));
                        strcat(ADR(logString), ADR(moduleError));
                        logError('IO Diagnostics', logString, 0);
                        ModuleInformation[checkModuleStatusIndex].notConfiguredAlarmID := MpAlarmXSet(gAlarmXCore, 'IO_NOT_CONFIGURED');
                    
                    3:
                        strcpy(ADR(logString), ADR('I/O Module is now OK: '));
                        strcpy(ADR(moduleError), ADR(ModuleInformation[checkModuleStatusIndex].ModuleName));
                        strcat(ADR(moduleError), ADR(' '));
                        strcat(ADR(moduleError), ADR(ModuleInformation[checkModuleStatusIndex].ModulePath));
                        strcat(ADR(logString), ADR(moduleError));
                        logError('IO Diagnostics', logString, 0);
                        
                        IF (ModuleInformation[checkModuleStatusIndex].notPluggedAlarmID <> 0) THEN
                            ModuleInformation[checkModuleStatusIndex].notPluggedAlarmID := 0;
                            MpAlarmXResetID(gAlarmXCore, ModuleInformation[checkModuleStatusIndex].notPluggedAlarmID);
                        END_IF
                        IF (ModuleInformation[checkModuleStatusIndex].notConfiguredAlarmID <> 0) THEN
                            ModuleInformation[checkModuleStatusIndex].notConfiguredAlarmID := 0;
                            MpAlarmXResetID(gAlarmXCore, ModuleInformation[checkModuleStatusIndex].notConfiguredAlarmID);
                        END_IF
                        IF (ModuleInformation[checkModuleStatusIndex].wrongModuleAlarmID <> 0) THEN
                            ModuleInformation[checkModuleStatusIndex].wrongModuleAlarmID := 0;
                            MpAlarmXResetID(gAlarmXCore, ModuleInformation[checkModuleStatusIndex].wrongModuleAlarmID);
                        END_IF
                    
                    4:
                        strcpy(ADR(logString), ADR('Wrong I/O Module is plugged in: '));
                        strcpy(ADR(moduleError), ADR('Module is :'));
                        strcat(ADR(moduleError), ADR(ModuleInformation[checkModuleStatusIndex].ModuleName));
                        strcat(ADR(moduleError), ADR(' but should be:'));
                        strcat(ADR(moduleError), ADR(ModuleInformation[checkModuleStatusIndex].ErrorModuleName));
                        strcat(ADR(moduleError), ADR(' '));
                        strcat(ADR(moduleError), ADR(ModuleInformation[checkModuleStatusIndex].ModulePath));
                        strcat(ADR(logString), ADR(moduleError));
                        logError('IO Diagnostics', logString, 0);
                        ModuleInformation[checkModuleStatusIndex].wrongModuleAlarmID := MpAlarmXSet(gAlarmXCore, 'IO_WRONG_MODULE');
                END_CASE
            END_IF
            OldModuleState[checkModuleStatusIndex] := ModuleInformation[checkModuleStatusIndex].ModuleState;
        END_IF
    END_FOR
  
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM


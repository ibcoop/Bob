(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: traceConfig
 * File: traceConfigCyclic.st
 * Author: buchananw
 * Created: January 16, 2014
 ********************************************************************
 * Implementation of program traceConfig
 ********************************************************************)

PROGRAM _CYCLIC


(* TODO : Add your code here *)
    CASE nwct_state OF
        
        0: (* wait until an error is received *)
            IF ((MpAlarmXCheckReaction(gAlarmXCore, 'StopMachine') = TRUE) OR (gMachineControl.status.errorActive = TRUE)) OR (test = TRUE) THEN
                memset(ADR(dirData), 0, SIZEOF(dirData));
                MC_BR_NetTrace_0.Execute                        := TRUE;
                MC_BR_NetTrace_0.Command                        := ncSAVE;
                MC_BR_NetTrace_0.Configuration.DatObj.Name      := 'diagnostics\nwct';
                MC_BR_NetTrace_0.Configuration.DatObj.Type      := mcFILE + mcADD_DATE_TIME;
                MC_BR_NetTrace_0.Configuration.DatObj.Format    := 0;
                MC_BR_NetTrace_0.Configuration.DatObj.Device    := 'control';
                MC_BR_NetTrace_0.Configuration.NetTrace.Type    := mcNET_TRACE_GLOBAL;
                nwct_state                                      := 10;
            END_IF
        
        10:
            IF (MC_BR_NetTrace_0.Done = TRUE) THEN
                MC_BR_NetTrace_0.Execute    := FALSE;
                DirInfo_0.enable            := TRUE;
                DirInfo_0.pDevice           := ADR(MC_BR_NetTrace_0.Configuration.DatObj.Device);
                DirInfo_0.pPath             := ADR('diagnostics\');;
                nwct_state                  := 20;
            ELSIF (MC_BR_NetTrace_0.Error = TRUE) THEN
                //Write a message to the logger but don't generate an error to the front end. Nothing the operator could do anyway, and we want to leave the machine useable
                logError('NWCT', 'Error in MC_BR_NetTrace within network command trace execution', 0);
                MC_BR_NetTrace_0.Execute    := FALSE;
                nwct_state                  := 100;
            END_IF

        20:
            IF (DirInfo_0.status = 0) THEN
                DirInfo_0.enable        := FALSE;
                NumFiles                := DirInfo_0.filenum;
                IF (DirInfo_0.filenum <= MAX_NUMBER_OF_NWCT) THEN
                    (* number of total files is lower than the number of traces we want to save so skip checking the file names *)
                    nwct_state  := 100;
                ELSE
                    dirIndex            := 0;
                    DirRead_0.enable    := TRUE;
                    DirRead_0.pDevice   := ADR(MC_BR_NetTrace_0.Configuration.DatObj.Device);
                    DirRead_0.pPath     := ADR('diagnostics\');
                    DirRead_0.pData     := ADR(dirData[dirIndex]);
                    DirRead_0.data_len  := SIZEOF(dirData[dirIndex]);
                    DirRead_0.entry     := dirIndex;
                    DirRead_0.option    := fiFILE;
                    memset(ADR(dirData), 0, SIZEOF(dirData));
                    nwct_state          := 30;
                END_IF
            ELSIF(DirInfo_0.status = ERR_FUB_BUSY) OR (DirInfo_0.status = ERR_FUB_ENABLE_FALSE) THEN
                //do nothing
            ELSE
                //Write a message to the logger but don't generate an error to the front end. Nothing the operator could do anyway, and we want to leave the machine useable
                logError('NWCT', 'Error in DirInfo within command trace execution', 0);
                DirInfo_0.enable        := FALSE;
                nwct_state              := 100;
            END_IF
        
        30:
            IF (dirIndex < NumFiles) THEN
                IF (DirRead_0.status = 0) THEN
                    dirIndex            := dirIndex + 1;
                    IF(dirIndex < (SIZEOF(dirData)/SIZEOF(dirData[0]))) THEN //if the number is greater than the size of dirData, stop adding entries to dirData
                        DirRead_0.pData     := ADR(dirData[dirIndex]);
                        DirRead_0.data_len  := SIZEOF(dirData[dirIndex]);
                        DirRead_0.entry     := dirIndex;
                    END_IF
                END_IF
            ELSE
                DirInfo_0.enable    := FALSE;
                DirRead_0.enable    := FALSE;
                nwct_state          := 40;
            END_IF
        
        40:
            nwctFound := 0;
            oldestFound := 255;
            FOR dirIndex := 0 TO ((SIZEOF(dirData)/SIZEOF(dirData[0])) - 1) DO
                (* because the FIND function is dumb we need to convert the array of USINT to a string before calling it *)
                strcpy(ADR(tempFileName), ADR(dirData[dirIndex].Filename));
                IF (FIND(tempFileName, 'nwct') <> 0) THEN
                    nwctFound := nwctFound + 1;
                    IF (oldestFound = 255) THEN
                        oldestFound := dirIndex;
                    END_IF
                    IF (DiffDT(dirData[dirIndex].Date, dirData[oldestFound].Date) = 16#FFFFFFFF) THEN
                        oldestFound := dirIndex;
                    END_IF
                END_IF
            END_FOR
            
            IF (nwctFound <= MAX_NUMBER_OF_NWCT) THEN
                nwct_state := 100;
            ELSE
                FileDelete_0.enable     := TRUE;
                FileDelete_0.pDevice    := ADR(MC_BR_NetTrace_0.Configuration.DatObj.Device);
                tempFileName            := 'diagnostics\';
                strcat(ADR(tempFileName), ADR(dirData[oldestFound].Filename));
                FileDelete_0.pName      := ADR(tempFileName);
                nwct_state              := 50;
            END_IF
        
        50:
            IF (FileDelete_0.status = 0) THEN
                FileDelete_0.enable := FALSE;
                DirInfo_0.enable    := TRUE;
                nwct_state          := 20;
            ELSIF(DirInfo_0.status = ERR_FUB_BUSY) OR (DirInfo_0.status = ERR_FUB_ENABLE_FALSE) THEN
                //do nothing
            ELSE
                //Write a message to the logger but don't generate an error to the front end. Nothing the operator could do anyway, and we want to leave the machine useable
                logError('NWCT', 'Error in file delete within network command trace execution', 0);
                FileDelete_0.enable        := FALSE;
                nwct_state                 := 100;
            END_IF

        100:
            IF ((MpAlarmXCheckReaction(gAlarmXCore, 'StopMachine') = FALSE) AND (gMachineControl.status.errorActive = FALSE)) AND (test = FALSE) THEN
                nwct_state := 0;
            END_IF

    END_CASE

    MC_BR_NetTrace_0();
    DirInfo_0();
    DirRead_0();
    FileDelete_0();

END_PROGRAM
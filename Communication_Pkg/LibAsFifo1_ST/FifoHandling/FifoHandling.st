(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program:FifoHandling
 * File: FifoHandling.st
 * Author: B&R
 ********************************************************************
 * Implementation of program FifoHandling
 ********************************************************************)

PROGRAM _INIT

    (* Defines the name of the fifo. Maximal 32 Characters are allowed *)
    FifoHandling.Data.Input.FifoName  := 'MyFirstFifo';
    (* Configure fifo as ringbuffer *)
    FifoHandling.Data.Input.Mode      := fifoMODE_WRITE_ALWAYS;
    (* Size of fifo buffer in bytes *)
    FifoHandling.Data.Input.Size      := SIZEOF(FifoData_derived) * FIFO_MAX_DATA_ENTRIES;
    (* Preset of write data *)
    FifoHandling.Data.Input.WriteData := 'MyFirstFifoData';
    
END_PROGRAM


PROGRAM _CYCLIC

    CASE FifoHandling.State OF
    
        (* Wait for user command *)
        enSTATE_W4_CMD: 

            IF TRUE = FifoHandling.Command.CmdFifoCreate THEN

                FifoHandling.State  := enSTATE_FIFO_CREATE;

            ELSIF TRUE = FifoHandling.Command.CmdFifoDelete THEN
                
                FifoHandling.State  := enSTATE_FIFO_DELETE;

            ELSIF TRUE = FifoHandling.Command.CmdFifoWrite THEN
                
                FifoHandling.State  := enSTATE_FIFO_WRITE;

            ELSIF TRUE = FifoHandling.Command.CmdFifoRead THEN
                               
                FifoHandling.State  := enSTATE_FIFO_READ;

            ELSIF TRUE = FifoHandling.Command.CmdFifoClear THEN
                
                FifoHandling.State  := enSTATE_FIFO_CLEAR;
            
            ELSIF TRUE = FifoHandling.Command.CmdFifoGetInfo THEN
                
                FifoHandling.State  := enSTATE_FIFO_GET_INFO;

            END_IF

        (* Create new fifo *)
        enSTATE_FIFO_CREATE: 

            FifoHandling.FunctionBlocks.InstFifoCreate.enable := TRUE;
            FifoHandling.FunctionBlocks.InstFifoCreate.pFifo  := ADR(FifoHandling.Data.Input.FifoName);
            FifoHandling.FunctionBlocks.InstFifoCreate.mode   := FifoHandling.Data.Input.Mode;
            FifoHandling.FunctionBlocks.InstFifoCreate.size   := FifoHandling.Data.Input.Size;

            IF ERR_OK = FifoHandling.FunctionBlocks.InstFifoCreate.status THEN  (* fifoCreate successfull*)
                
                FifoHandling.FunctionBlocks.InstFifoCreate.enable := FALSE;
                FifoHandling.Command.CmdFifoCreate                := FALSE;
                FifoHandling.Data.Output.FifoIdent                := FifoHandling.FunctionBlocks.InstFifoCreate.ident;
                FifoHandling.State                                := enSTATE_W4_CMD; 

			ELSIF ERR_FUB_BUSY = FifoHandling.FunctionBlocks.InstFifoCreate.status THEN  (* fifoCreate not finished -> redo *)
		
			  (* Busy *)	

			ELSIF ERR_FUB_ENABLE_FALSE <> FifoHandling.FunctionBlocks.InstFifoCreate.status THEN (* Goto Error Step *)

                FifoHandling.Data.Output.ErrorNumber := FifoHandling.FunctionBlocks.InstFifoCreate.status;
                FifoHandling.State                   := enSTATE_ERROR;

			END_IF

        (* Delete fifo *)
        enSTATE_FIFO_DELETE:

            FifoHandling.FunctionBlocks.InstFifoDelete.enable := TRUE;
            FifoHandling.FunctionBlocks.InstFifoDelete.ident  := FifoHandling.Data.Output.FifoIdent;

            IF ERR_OK = FifoHandling.FunctionBlocks.InstFifoDelete.status THEN  (* fifoDelete successfull*)

                FifoHandling.Command.CmdFifoDelete                := FALSE;
                FifoHandling.FunctionBlocks.InstFifoDelete.enable := FALSE;
                FifoHandling.Data.Output.FifoIdent                := 0;
                FifoHandling.State                                := enSTATE_W4_CMD; 

			ELSIF ERR_FUB_BUSY = FifoHandling.FunctionBlocks.InstFifoDelete.status THEN  (* fifoDelete not finished -> redo *)	
	
			  (* Busy *)	

			ELSIF ERR_FUB_ENABLE_FALSE <> FifoHandling.FunctionBlocks.InstFifoDelete.status THEN  (* Goto Error Step *)

               FifoHandling.Data.Output.ErrorNumber := FifoHandling.FunctionBlocks.InstFifoDelete.status;
               FifoHandling.State                   := enSTATE_ERROR;

			END_IF

        (* Write data into fifo *)
        enSTATE_FIFO_WRITE:

            FifoHandling.FunctionBlocks.InstFifoWrite.enable := TRUE;
            FifoHandling.FunctionBlocks.InstFifoWrite.ident  := FifoHandling.Data.Output.FifoIdent;
            FifoHandling.FunctionBlocks.InstFifoWrite.pData  := ADR(FifoHandling.Data.Input.WriteData);
            FifoHandling.FunctionBlocks.InstFifoWrite.size   := SIZEOF(FifoHandling.Data.Input.WriteData);

            (* FUB fifoWrite() is synchronously *)
            FifoHandling.FunctionBlocks.InstFifoWrite();

            IF ERR_OK = FifoHandling.FunctionBlocks.InstFifoWrite.status THEN  (* fifoWrite successfull*)

                FifoHandling.FunctionBlocks.InstFifoWrite.enable := TRUE;
                FifoHandling.Command.CmdFifoWrite                := FALSE;
                FifoHandling.State                               := enSTATE_W4_CMD; 
	
			ELSE  (* Goto Error Step *)

                FifoHandling.Data.Output.ErrorNumber := FifoHandling.FunctionBlocks.InstFifoWrite.status;
                FifoHandling.State                   := enSTATE_ERROR;

			END_IF

        (* Read data from fifo *)
        enSTATE_FIFO_READ:

            FifoHandling.FunctionBlocks.InstFifoRead.enable := TRUE;
            FifoHandling.FunctionBlocks.InstFifoRead.ident  := FifoHandling.Data.Output.FifoIdent;
            FifoHandling.FunctionBlocks.InstFifoRead.pData  := ADR(FifoHandling.Data.Output.ReadData);
            FifoHandling.FunctionBlocks.InstFifoRead.size   := SIZEOF(FifoHandling.Data.Output.ReadData);

            (* FUB fifoRead() is synchronously *)
            FifoHandling.FunctionBlocks.InstFifoRead();

            IF ERR_OK = FifoHandling.FunctionBlocks.InstFifoRead.status THEN  (* fifoRead successfull*)

                FifoHandling.FunctionBlocks.InstFifoRead.enable := TRUE;
                FifoHandling.Command.CmdFifoRead                := FALSE;
                FifoHandling.State                              := enSTATE_W4_CMD;

			ELSE  (* Goto Error Step *)

                FifoHandling.Data.Output.ErrorNumber := FifoHandling.FunctionBlocks.InstFifoRead.status;
                FifoHandling.State                   := enSTATE_ERROR;

			END_IF

        (* Clear fifo data *)
        enSTATE_FIFO_CLEAR:

            FifoHandling.FunctionBlocks.InstFifoClear.enable := TRUE;
            FifoHandling.FunctionBlocks.InstFifoClear.ident  := FifoHandling.Data.Output.FifoIdent;

            IF ERR_OK = FifoHandling.FunctionBlocks.InstFifoClear.status THEN  (* fifoClear successfull*)

                FifoHandling.Command.CmdFifoClear                := FALSE;
                FifoHandling.FunctionBlocks.InstFifoClear.enable := FALSE;
                FifoHandling.State                               := enSTATE_W4_CMD; 

			ELSIF ERR_FUB_BUSY = FifoHandling.FunctionBlocks.InstFifoClear.status THEN  (* fifoClear not finished -> redo *)
		
			  (* Busy *)	

			ELSIF ERR_FUB_ENABLE_FALSE <> FifoHandling.FunctionBlocks.InstFifoClear.status THEN  (* Goto Error Step *)
                            
                FifoHandling.Data.Output.ErrorNumber             := FifoHandling.FunctionBlocks.InstFifoClear.status;
                FifoHandling.State                               := enSTATE_ERROR;

			END_IF

         (* Read data from fifo *)
         enSTATE_FIFO_GET_INFO:

            FifoHandling.FunctionBlocks.InstFifoGetInfo.enable := TRUE;
            FifoHandling.FunctionBlocks.InstFifoGetInfo.ident  := FifoHandling.Data.Output.FifoIdent;
            (* FUB fifoGetInfo() is synchronously *)
            FifoHandling.FunctionBlocks.InstFifoGetInfo();

            IF ERR_OK = FifoHandling.FunctionBlocks.InstFifoGetInfo.status THEN  (* fifoGetInfo successfull*)
           
                FifoHandling.Command.CmdFifoGetInfo                := FALSE;
                FifoHandling.FunctionBlocks.InstFifoGetInfo.enable := FALSE;
                FifoHandling.Data.Output.FifoFreeBytes             := FifoHandling.FunctionBlocks.InstFifoGetInfo.fifoFree;
                FifoHandling.Data.Output.FifoUsedBytes             := FifoHandling.FunctionBlocks.InstFifoGetInfo.fifoUsed;
                FifoHandling.State                                 := enSTATE_W4_CMD; 

			ELSE  (* Goto Error Step *)

                FifoHandling.Data.Output.ErrorNumber := FifoHandling.FunctionBlocks.InstFifoGetInfo.status;
                FifoHandling.State                   := enSTATE_ERROR;

			END_IF

          (* Error *)
          enSTATE_ERROR:

            (* Reset all function blocks*)
            FifoHandling.FunctionBlocks.InstFifoCreate.enable  := FALSE;
            FifoHandling.FunctionBlocks.InstFifoDelete.enable  := FALSE;
            FifoHandling.FunctionBlocks.InstFifoWrite.enable   := FALSE;
            FifoHandling.FunctionBlocks.InstFifoRead.enable    := FALSE;
            FifoHandling.FunctionBlocks.InstFifoClear.enable   := FALSE;
            FifoHandling.FunctionBlocks.InstFifoGetInfo.enable := FALSE;
                       
            IF TRUE = FifoHandling.Command.CmdErrAckn THEN

                (* Reset all command flags *)
                memset(ADR(FifoHandling.Command), 
                       0, 
                       SIZEOF(FifoHandling_Command_typ));

                FifoHandling.Data.Output.ErrorNumber := 0;
                FifoHandling.Command.CmdErrAckn      := FALSE;
                FifoHandling.State                   := enSTATE_W4_CMD;

            END_IF

    END_CASE
    
     (* cycally call of the asynchronous functionblocks *)
     FifoHandling.FunctionBlocks.InstFifoCreate();
     FifoHandling.FunctionBlocks.InstFifoDelete();
     FifoHandling.FunctionBlocks.InstFifoClear();

END_PROGRAM

PROGRAM _EXIT

    (* Delete fifo if exists *)
    IF 0 <> FifoHandling.Data.Output.FifoIdent THEN

        FifoHandling.FunctionBlocks.InstFifoDelete.enable   := TRUE;
        FifoHandling.FunctionBlocks.InstFifoDelete.ident    := FifoHandling.Data.Output.FifoIdent;

        FifoHandling.FunctionBlocks.InstFifoDelete();
        
        FifoHandling.Data.Output.FifoIdent := 0;

    END_IF

END_PROGRAM

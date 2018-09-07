(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: FifoHandling
 * File: FifoHandling.typ
 * Author: B&R
 ********************************************************************
 * Local data types of program FifoHandling
 ********************************************************************)

TYPE
	FifoHandling_typ : 	STRUCT  (*Main FifoHandling Structure*)
		State : FifoHandling_State_enum; (*State *)
		Command : FifoHandling_Command_typ; (*User commandos*)
		Data : FifoHandling_Data_typ; (*Data*)
		FunctionBlocks : FifoHandling_Functionblock_typ; (*FUB instances*)
	END_STRUCT;
	FifoHandling_State_enum : 
		( (*Statemachine steps*)
		enSTATE_W4_CMD, (*State: Wait for user command*)
		enSTATE_FIFO_CREATE, (*State: Create new fifo*)
		enSTATE_FIFO_DELETE, (*State: Delete fifo*)
		enSTATE_FIFO_WRITE, (*State: Write data in fifo*)
		enSTATE_FIFO_READ, (*State: Read data from fifo*)
		enSTATE_FIFO_CLEAR, (*State: Clear all fifo data*)
		enSTATE_FIFO_GET_INFO, (*State: Get fifo information*)
		enSTATE_ERROR (*State: Error occured*)
		);
	FifoHandling_Command_typ : 	STRUCT  (*Command structure*)
		CmdFifoCreate : BOOL; (*Command: Create new fifo*)
		CmdFifoDelete : BOOL; (*Command: Delete a fifo*)
		CmdFifoWrite : BOOL; (*Command: Write data to fifo*)
		CmdFifoRead : BOOL; (*Command: Read data from fifo*)
		CmdFifoClear : BOOL; (*Command: Clear fifo data*)
		CmdFifoGetInfo : BOOL; (*Command: Get fifo information*)
		CmdErrAckn : BOOL; (*Coomand: Acknowledge Error*)
	END_STRUCT;
	FifoHandling_Data_typ : 	STRUCT  (*Data structure*)
		Input : FifoHandling_Input_Data_typ; (*Input data*)
		Output : FifoHandling_Output_Data_typ; (*Output data*)
	END_STRUCT;
	FifoHandling_Functionblock_typ : 	STRUCT  (*FUB instance strucure*)
		InstFifoCreate : fifoCreate; (*Functionblock fifoCreate()*)
		InstFifoDelete : fifoDelete; (*Functionblock fifoDelete()*)
		InstFifoWrite : fifoWrite; (*Functionblock fifoWrite()*)
		InstFifoRead : fifoRead; (*Functionblock fifoRead()*)
		InstFifoClear : fifoClear; (*Functionblock fifoClear()*)
		InstFifoGetInfo : fifoGetInfo; (*Functionblock fifoGetInfo()*)
	END_STRUCT;
	FifoHandling_Input_Data_typ : 	STRUCT  (*Input Data structure*)
		FifoName : STRING[31]; (*Name of the fifo (max. 32 characters)*)
		Size : USINT; (*Size of the fifo in bytes*)
		Mode : UINT; (*write mode (fifoMODE_WRITE_UNTIL_FULL,  fifoMODE_WRITE_UNTIL_FULL)*)
		WriteData : FifoData_derived; (*Write data to fifo*)
	END_STRUCT;
	FifoHandling_Output_Data_typ : 	STRUCT  (*Output Data structure*)
		FifoIdent : UDINT; (*Ident of the fifo*)
		ReadData : FifoData_derived; (*Read data from fifo*)
		ErrorNumber : UINT; (*ErrorNumber*)
		FifoFreeBytes : UDINT; (*Free bytes of the fifo*)
		FifoUsedBytes : UDINT; (*Used bytes of the fifo*)
	END_STRUCT;
	FifoData_derived :STRING[20];
 (*Fifo data derived data type*)END_TYPE

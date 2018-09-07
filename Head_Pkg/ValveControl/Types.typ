
TYPE
	localValve_typ : 	STRUCT 
		valveName : STRING[80];
		outputModuleOk : BOOL; (*variable to be linked to the module ok on the IO module used for the outputs*)
		inputModuleOk : BOOL; (*variable to be linked to the module ok on the IO module used for the inputs*)
		doOpen : BOOL; (*variable to be linked to the digital output which opens the valve*)
		doClose : BOOL; (*variable to be linked to the digital output which closes the valve*)
		diOpened : BOOL; (*variable to be linked to the digital input which indicates that the valve is opened*)
		diClosed : BOOL; (*variable to be linked to the digital input which indicates that the valve is closed*)
		position : INT;
		openDebounceTimer : TON;
		closeDebounceTimer : TON;
		openErrorTimer : TON;
		closeErrorTimer : TON;
		MpRecipeRegPar_0 : MpRecipeRegPar;
		MpRecipeRegPar_1 : MpRecipeRegPar;
		openError_r_trig : r_trig;
		closeError_r_trig : r_trig;
		open_and_close_error_r_trig : r_trig;
		io_error_r_trig : r_trig;
		io_error_f_trig : f_trig;
		openAndCloseAlarmID : UDINT;
		closeAlarmID : UDINT;
		openAlarmID : UDINT;
		alarmID : UDINT;
		moduleOKAlarmID : UDINT;
		powerOnTimer : TON;
	END_STRUCT;
END_TYPE

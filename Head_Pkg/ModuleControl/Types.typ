
TYPE
	PowerSupplyState_enum : 
		(
		WAIT_FOR_READY_TO_POWER,
		WAIT_FOR_POWER_ON,
		READY,
		ERROR
		);
	localHead_typ : 	STRUCT 
		pressureTransducerRaw : INT;
	END_STRUCT;
	localModule_typ : 	STRUCT 
		ps : localPS_typ;
		valve : localValve_typ;
		supplyTemperatureRaw : INT;
		head : ARRAY[0..NUM_OF_HEADS_PER_MODULE_M1]OF localHead_typ;
	END_STRUCT;
	localPS_typ : 	STRUCT 
		state : PowerSupplyState_enum;
		axis : ACP10AXIS_typ;
		mpAxis : UDINT;
		mpParams : MpAxisBasicParType;
		MpAxisBasic_0 : MpAxisBasic;
	END_STRUCT;
	localValve_typ : 	STRUCT 
		valveName : STRING[80];
		outputModuleOk : BOOL; (*variable to be linked to the module ok on the IO module used for the outputs*)
		inputModuleOk : BOOL; (*variable to be linked to the module ok on the IO module used for the inputs*)
		doOpen : BOOL; (*variable to be linked to the digital output which opens the valve*)
		diOpened : BOOL; (*variable to be linked to the digital input which indicates that the valve is opened*)
		diClosed : BOOL; (*variable to be linked to the digital input which indicates that the valve is closed*)
		openDebounceTimer : TON;
		closeDebounceTimer : TON;
		openTime : REAL;
		openErrorTimer : TON;
		closeTime : REAL;
		closeErrorTimer : TON;
		MpRecipeRegPar_0 : MpRecipeRegPar;
		MpRecipeRegPar_1 : MpRecipeRegPar;
		openError_r_trig : r_trig;
		openError_f_trig : f_trig;
		closeError_r_trig : r_trig;
		closeError_f_trig : f_trig;
		open_and_close_error_r_trig : r_trig;
		open_and_close_error_f_trig : f_trig;
		io_error_r_trig : r_trig;
		io_error_f_trig : f_trig;
	END_STRUCT;
END_TYPE

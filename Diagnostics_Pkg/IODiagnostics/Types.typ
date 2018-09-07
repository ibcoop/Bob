
TYPE
	DiagnosticsIO_typ : 	STRUCT 
		moduleNotOK : ARRAY[0..100]OF BOOL;
	END_STRUCT;
	Diagnostics_typ : 	STRUCT 
		ioStatus : DiagnosticsIO_typ;
	END_STRUCT;
	ModuleInformation_typ : 	STRUCT 
		ModulePath : STRING[30]; (*module path*)
		ModuleName : STRING[20]; (*module name*)
		ModuleState : USINT; (*module state*)
		ModuleColor : USINT; (*module color*)
		ErrorModuleName : STRING[20]; (*name of module with error*)
		notPluggedAlarmID : UDINT;
		notConfiguredAlarmID : UDINT;
		wrongModuleAlarmID : UDINT;
	END_STRUCT;
	IO_enum : 
		(
		IO_BATTERY_LOW := 100,
		IO_NOT_PLUGGED := 200,
		IO_NOT_CONFIGURED := 300,
		IO_WRONG_MODULE := 400,
		IO_SHORT := 500
		);
END_TYPE

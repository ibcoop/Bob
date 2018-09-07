
TYPE
	FillPiston_state : 
		(
		LOAD_CONFIG,
		WAIT_FOR_POWER,
		INIT,
		RESTORE_HOME,
		WAIT_FOR_HOME,
		HOMING,
		SAVE_HOME_OFFSET,
		READY,
		IN_MOTION,
		PRESSURE_RELIEF,
		HOLD_PRESSURE,
		DEPRESSURIZE,
		ERROR
		);
	localFillPiston_typ : 	STRUCT 
		name : STRING[80];
		state : FillPiston_state;
		axis : {REDUND_UNREPLICABLE} ACP10AXIS_typ;
		mpAxis : {REDUND_UNREPLICABLE} UDINT;
		mpConfig : UDINT;
		mpParams : MpAxisBasicParType;
		MpAxisBasic_0 : {REDUND_UNREPLICABLE} MpAxisBasic;
		MpAxisBasicConfig_0 : MpAxisBasicConfig;
		MC_BR_TorqueControl_0 : {REDUND_UNREPLICABLE} MC_BR_TorqueControl;
		MC_BR_CheckEndlessPosition_0 : {REDUND_UNREPLICABLE} MC_BR_CheckEndlessPosition;
		pEndlessPositionData : UDINT;
		MC_BR_CyclicRead_0 : MC_BR_CyclicRead;
		actualPosition : DINT;
		r_trig_moveAbs : r_trig;
		r_trig_moveRel : r_trig;
		r_trig_pt0 : r_trig;
		r_trig_pt10 : r_trig;
		MpRecipeRegPar_0 : MpRecipeRegPar;
		MpRecipeRegPar_1 : MpRecipeRegPar;
		MpRecipeRegPar_2 : MpRecipeRegPar;
		pressureTransducer : INT;
		homeWarningID : UDINT;
	END_STRUCT;
END_TYPE

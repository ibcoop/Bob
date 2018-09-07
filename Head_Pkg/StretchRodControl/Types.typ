
TYPE
	StretchRod_state : 
		(
		WAIT_FOR_POWER,
		INIT,
		WAIT_FOR_HOME,
		HOMING,
		WAIT_FOR_CALIBRATION,
		CALIBRATION,
		READY,
		IN_MOTION,
		ERROR
		);
	localStretchRod_typ : 	STRUCT 
		name : STRING[80];
		state : StretchRod_state;
		axis : ACP10AXIS_typ;
		mpAxis : UDINT;
		mpParams : MpAxisBasicParType;
		mpConfig : UDINT;
		MpAxisBasic_0 : MpAxisBasic;
		MpAxisBasicConfig_0 : MpAxisBasicConfig;
		MC_BR_TorqueControl_0 : MC_BR_TorqueControl;
		MC_BR_CyclicRead_0 : MC_BR_CyclicRead;
		actualPosition : DINT;
		r_trig_moveAbs : r_trig;
		calibratingPt0 : BOOL;
		calibratingPt10 : BOOL;
		MpRecipeRegPar_0 : MpRecipeRegPar;
		MpRecipeRegPar_1 : MpRecipeRegPar;
		startStretchTrigger : r_trig;
		endStretchTrigger : r_trig;
		atPt0 : r_trig;
		atPt10 : r_trig;
		atPreMove : r_trig;
		homeWarningID : UDINT;
		calibrationWarningID : UDINT;
	END_STRUCT;
END_TYPE


PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	
//CheckWeigher Data
	gMachineControl.checkWeigher.status.acceptedCount.VAL			:= (UINT_TO_DINT(gMachineControl.checkWeigher.status.acceptedCount.HW) *65536) + gMachineControl.checkWeigher.status.acceptedCount.LW ;
	gMachineControl.checkWeigher.status.overRejects.VAL				:= (UINT_TO_DINT(gMachineControl.checkWeigher.status.overRejects.HW) *65536) + gMachineControl.checkWeigher.status.overRejects.LW ;
	gMachineControl.checkWeigher.status.underRejects.VAL			:= (UINT_TO_DINT(gMachineControl.checkWeigher.status.underRejects.HW) *65536) + gMachineControl.checkWeigher.status.underRejects.LW ;
	gMachineControl.checkWeigher.status.totalCount.VAL 				:= (UINT_TO_UDINT(gMachineControl.checkWeigher.status.totalCount.HW) *65536) + gMachineControl.checkWeigher.status.totalCount.LW;
	gMachineControl.checkWeigher.status.currentRecipeNumber.VAL 	:= (UINT_TO_UDINT(gMachineControl.checkWeigher.status.currentRecipeNumber.HW) *65536) + gMachineControl.checkWeigher.status.currentRecipeNumber.LW;
		
	gMachineControl.checkWeigher.status.targetWeight.VAL		:= ((UINT_TO_REAL(gMachineControl.checkWeigher.status.targetWeight.HW) *65536) + gMachineControl.checkWeigher.status.targetWeight.LW) /100 ;
	gMachineControl.checkWeigher.status.highLimitWeight.VAL 	:= ((UINT_TO_REAL(gMachineControl.checkWeigher.status.highLimitWeight.HW) *65536) + gMachineControl.checkWeigher.status.highLimitWeight.LW) /100;
	gMachineControl.checkWeigher.status.lowLimitWeight.VAL 		:= ((UINT_TO_REAL(gMachineControl.checkWeigher.status.lowLimitWeight.HW) *65536) + gMachineControl.checkWeigher.status.lowLimitWeight.LW) /100;
	gMachineControl.checkWeigher.status.statsHighWeight.VAL 	:= ((UINT_TO_REAL(gMachineControl.checkWeigher.status.statsHighWeight.HW) *65536) + gMachineControl.checkWeigher.status.statsHighWeight.LW) /100;
	gMachineControl.checkWeigher.status.statsLowWeight.VAL 		:= ((UINT_TO_REAL(gMachineControl.checkWeigher.status.statsLowWeight.HW) *65536) + gMachineControl.checkWeigher.status.statsLowWeight.LW) /100;
	
	gMachineControl.checkWeigher.status.weightAve.VAL		:= ((UINT_TO_REAL(gMachineControl.checkWeigher.status.weightAve.HW) *65536) + gMachineControl.checkWeigher.status.weightAve.LW) /100 ;
	gMachineControl.checkWeigher.status.stdDeviation.VAL	:= ((UINT_TO_REAL(gMachineControl.checkWeigher.status.stdDeviation.HW) *65536) + gMachineControl.checkWeigher.status.stdDeviation.LW) /100 ;
	gMachineControl.checkWeigher.status.weightMin.VAL		:= ((UINT_TO_REAL(gMachineControl.checkWeigher.status.weightMin.HW) *65536) + gMachineControl.checkWeigher.status.weightMin.LW) /100 ;
	gMachineControl.checkWeigher.status.weightMax.VAL		:= ((UINT_TO_REAL(gMachineControl.checkWeigher.status.weightMax.HW) *65536) + gMachineControl.checkWeigher.status.weightMax.LW) /100 ;
	gMachineControl.checkWeigher.status.weightRange.VAL		:= ((UINT_TO_REAL(gMachineControl.checkWeigher.status.weightRange.HW) *65536) + gMachineControl.checkWeigher.status.weightRange.LW) /100 ;
	gMachineControl.checkWeigher.status.lastWeight.VAL 		:= ((UINT_TO_REAL(gMachineControl.checkWeigher.status.lastWeight.HW) *65536) + gMachineControl.checkWeigher.status.lastWeight.LW) /100 ;
	gMachineControl.checkWeigher.status.trend_UCL           := gMachineControl.checkWeigher.status.highLimitWeight.VAL + gMachineControl.checkWeigher.parameter.trendYScale;
	gMachineControl.checkWeigher.status.trend_LCL			:= gMachineControl.checkWeigher.status.lowLimitWeight.VAL - gMachineControl.checkWeigher.parameter.trendYScale; 
		
	gMachineControl.checkWeigher.control.controlBits.0 			:= 	gMachineControl.checkWeigher.control.startCheckWeigher;
	gMachineControl.checkWeigher.control.controlBits.1 			:=  gMachineControl.checkWeigher.control.stopCheckWeigher;
	gMachineControl.checkWeigher.control.controlBits.2 			:=  gMachineControl.checkWeigher.control.changeCheckWeigherRecipe;
	gMachineControl.checkWeigher.control.controlBits.3 			:=  gMachineControl.checkWeigher.control.resetStatus;
	gMachineControl.checkWeigher.control.newRecipeNumber.VAL 	:= (UINT_TO_UDINT(gMachineControl.checkWeigher.control.newRecipeNumber.HW) *65536) + gMachineControl.checkWeigher.control.newRecipeNumber.LW;
	
	IF ((gMachineControl.checkWeigher.control.startCheckWeigher = TRUE) AND (gMachineControl.checkWeigher.status.running = TRUE)) THEN
		gMachineControl.checkWeigher.control.startCheckWeigher := FALSE;
	END_IF 
	
	IF ((gMachineControl.checkWeigher.control.stopCheckWeigher = TRUE) AND (gMachineControl.checkWeigher.status.running = FALSE)) THEN
		gMachineControl.checkWeigher.control.stopCheckWeigher := FALSE;
	END_IF 
		
	gMachineControl.checkWeigher.status.emergencyStop := gMachineControl.checkWeigher.status.bitStatus1.0;			
	gMachineControl.checkWeigher.status.running := gMachineControl.checkWeigher.status.bitStatus1.1;
	gMachineControl.checkWeigher.status.readyToWeigh := gMachineControl.checkWeigher.status.bitStatus1.2;
	gMachineControl.checkWeigher.status.heartBeat := gMachineControl.checkWeigher.status.bitStatus2.15;

	
	
	
//	IF gMachineControl.checkWeigher.status.totalCount.VAL <> gMachineControl.checkWeigher.status.totalCountPrevious THEN
		
	
	 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM


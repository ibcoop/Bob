
TYPE
	externalCommunicationInput_typ : 	STRUCT 
		watchDog : BOOL;
		powerOn : BOOL;
		homeHeadsCmd : BOOL;
		machineAutoMode : BOOL;
		machineSetupMode : BOOL;
		machineManualMode : BOOL;
		machineInAutoCycle : BOOL;
		machineSafetyOK : BOOL;
		machineSpeedDegSec : REAL;
		rotaryDegreeAtZeroDegree : BOOL;
		moldsClosed : BOOL;
		moldsOpen : BOOL;
		autoCycleMoldsClosedReadyToForm : BOOL;
		preformPresentAtMoldHD1 : BOOL;
		preformPresentAtMoldHD2 : BOOL;
		preformPresentAtMoldHD3 : BOOL;
		preformPresentAtMoldHD4 : BOOL;
		bottlePresentAtExitHD1 : BOOL;
		bottlePresentAtExitHD2 : BOOL;
		bottlePresentAtExitHD3 : BOOL;
		bottlePresentAtExitHD4 : BOOL;
		preformInfeedTransferInDuration : REAL;
		preformInfeedGripperCloseToOpen : REAL;
		bottleExitTransferOutDuration : REAL;
		preformTemperatureActualHD1 : REAL;
		preformTemperatureActualHD2 : REAL;
		preformTemperatureActualHD3 : REAL;
		preformTemperatureActualHD4 : REAL;
		blowers : ARRAY[0..NUMBER_OF_BLOWERS_M1]OF REAL;
		ovens : ARRAY[0..NUMBER_OF_OVENS_M1]OF Oven_typ;
		preformsEnteringMold : BOOL;
	END_STRUCT;
	Sequencer_enum : 
		(
		WAIT_FOR_START := 10,
		STARTED := 20,
		RUNNING := 30
		);
	externalCommunicationOutput_typ : 	STRUCT 
		watchDog : BOOL;
		formingCycleComplete : BOOL;
		formingCompleteHD2 : BOOL;
		formingCompleteHD1 : BOOL;
		formingCompleteHD3 : BOOL;
		formingCompleteHD4 : BOOL;
		formingHeadNoFaultHD1 : BOOL;
		formingHeadNoFaultHD2 : BOOL;
		formingHeadNoFaultHD3 : BOOL;
		formingHeadNoFaultHD4 : BOOL;
		formingHeadEnabledHD1 : BOOL;
		formingHeadEnabledHD2 : BOOL;
		formingHeadEnabledHD3 : BOOL;
		formingHeadEnabledHD4 : BOOL;
		formingHeadReadyHD1 : BOOL;
		formingHeadReadyHD2 : BOOL;
		formingHeadReadyHD3 : BOOL;
		formingHeadReadyHD4 : BOOL;
		formingHeadHomedHD1 : BOOL;
		formingHeadHomedHD2 : BOOL;
		formingHeadHomedHD3 : BOOL;
		formingHeadHomedHD4 : BOOL;
	END_STRUCT;
	externalCommunication_typ : 	STRUCT 
		inputs : externalCommunicationInput_typ;
		outputs : externalCommunicationOutput_typ;
	END_STRUCT;
END_TYPE

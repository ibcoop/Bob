
TYPE
	BeckhoffChannel : 	STRUCT 
		Status : INT;
		Control : INT;
		Enum : BeckhoffPowerEnum;
		Value : INT;
	END_STRUCT;
	BeckhoffPowerEnum : 
		(
		Current := 0,
		Voltage := 1,
		EffectivePower := 2,
		PowerFactor := 3,
		EnergyConsumption := 4,
		Frequency := 8,
		EnergyConsumptionOverflow := 128
		);
	BeckhoffPowerMeter : 	STRUCT 
		Channel : ARRAY[0..3]OF BeckhoffChannel;
	END_STRUCT;
END_TYPE

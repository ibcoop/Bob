
ACTION ClearCommands: 
    pCurrentPiston.commands.abort                       := FALSE;
    pCurrentPiston.commands.errorAcknowledge            := FALSE;
    pCurrentPiston.commands.home                        := FALSE;
    pCurrentPiston.commands.jogNegative                 := FALSE;
    pCurrentPiston.commands.jogPositive                 := FALSE;
    pCurrentPiston.commands.moveAbsolute                := FALSE;
    pCurrentPiston.commands.depressurize                := FALSE;
    pCurrentPiston.commands.depressurizeComplete        := FALSE;
    pCurrentPiston.commands.holdPressure                := FALSE;
    pCurrentPiston.commands.moveToFillCylinderReturn    := FALSE;
    pCurrentPiston.commands.moveToPreCharge             := FALSE;
    pCurrentPiston.commands.pressureRelief              := FALSE;
    pCurrentPiston.commands.startForming                := FALSE;
	pCurrentPiston.commands.startPreBlow                := FALSE;
    
    pFillPiston.MpAxisBasic_0.Home                      := FALSE;
    pFillPiston.MpAxisBasic_0.JogNegative               := FALSE;
    pFillPiston.MpAxisBasic_0.JogPositive               := FALSE;
    pFillPiston.MpAxisBasic_0.MoveAbsolute              := FALSE;
    pFillPiston.MpAxisBasic_0.MoveAdditive              := FALSE;
    pFillPiston.MpAxisBasic_0.MoveVelocity              := FALSE;
    pFillPiston.MpAxisBasic_0.Stop                      := FALSE;
END_ACTION


ACTION ClearCommands: 
    pCurrentStretchRod.commands.abort                       := FALSE;
    pCurrentStretchRod.commands.brakeOff                    := FALSE;
    pCurrentStretchRod.commands.brakeOn                     := FALSE;
    pCurrentStretchRod.commands.calibratePt0                := FALSE;
    pCurrentStretchRod.commands.calibratePt10               := FALSE;
    pCurrentStretchRod.commands.errorAcknowledge            := FALSE;
    pCurrentStretchRod.commands.home                        := FALSE;
    pCurrentStretchRod.commands.jogNegative                 := FALSE;
    pCurrentStretchRod.commands.jogPositive                 := FALSE;
    pCurrentStretchRod.commands.moveAbsolute                := FALSE;
    pCurrentStretchRod.commands.moveToFillLevel             := FALSE;
    pCurrentStretchRod.commands.moveToHome                  := FALSE;
    pCurrentStretchRod.commands.moveToPremove               := FALSE;
    pCurrentStretchRod.commands.moveToRetraction            := FALSE;
    pCurrentStretchRod.commands.moveToStretch               := FALSE;
    pCurrentStretchRod.commands.moveToVolumetricPosition    := FALSE;
    
        
    pStretchRod.MpAxisBasic_0.Home                      := FALSE;
    pStretchRod.MpAxisBasic_0.JogNegative               := FALSE;
    pStretchRod.MpAxisBasic_0.JogPositive               := FALSE;
    pStretchRod.MpAxisBasic_0.MoveAbsolute              := FALSE;
    pStretchRod.MpAxisBasic_0.MoveAdditive              := FALSE;
    pStretchRod.MpAxisBasic_0.MoveVelocity              := FALSE;
    pStretchRod.MpAxisBasic_0.Stop                      := FALSE;

END_ACTION

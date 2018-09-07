
PROGRAM _INIT
    IF (DiagCpuIsSimulated() = TRUE) THEN
        DevLink_0.enable := TRUE;
        DevLink_0.pDevice := ADR('energy');
        DevLink_0.pParam := ADR('/DEVICE=C:\temp\control\energy');
        DevLink_0();
    END_IF

    ConnectToShare_Energy.enable        := TRUE;
    ConnectToShare_Energy.ipAddress     := WINDOWS_IP_ADDRESS;
    ConnectToShare_Energy.deviceName    := 'energy';
    ConnectToShare_Energy.shareName     := 'energy';
    ConnectToShare_Energy.userName      := AMCOR_USERNAME;
    ConnectToShare_Energy.userPassword  := AMCOR_PASSWORD;

END_PROGRAM

PROGRAM _CYCLIC
	
    MpEnergyCore_0.MpLink           := ADR(gEnergyCore);
    MpEnergyCore_0.Enable           := TRUE;
    MpEnergyCore_0.DeviceName       := ADR('energy');
    MpEnergyCore_0();
    
    ConnectToShare_Energy();
    IF (ConnectToShare_Energy.status = 0) THEN
        ConnectToShare_Energy.enable    := FALSE;
        KeepAlive_Energy.enable         := TRUE;
        KeepAlive_Energy.deviceName     := ConnectToShare_Energy.deviceName;
    END_IF
    KeepAlive_Energy();
    
    MpEnergyCoreUI_0.Enable     := TRUE;
    MpEnergyCoreUI_0.MpLink     := ADR(gEnergyCore);
    MpEnergyCoreUI_0.UIConnect  := ADR(energyUIConnect);
    MpEnergyCoreUI_0();

    // save the current index so that it can be restored at the end.
    currentIndex := energyUIConnect.ModuleList.SelectedIndex;
    modules[0].index := 255;
    modules[1].index := 255;
    FOR energyUIConnect.ModuleList.SelectedIndex:=0 TO UDINT_TO_UINT(MpEnergyCore_0.Info.RegisteredModules) DO
        IF ((modules[0].index <> 255) AND (energyUIConnect.ModuleList.Names[energyUIConnect.ModuleList.SelectedIndex] = 'gMpAxisPS1')) THEN
            modules[0].index := energyUIConnect.ModuleList.SelectedIndex;
        END_IF
        IF ((modules[1].index <> 255) AND (energyUIConnect.ModuleList.Names[energyUIConnect.ModuleList.SelectedIndex] = 'gMpAxisPS2')) THEN
            modules[1].index := energyUIConnect.ModuleList.SelectedIndex;
        END_IF
    END_FOR
    
    FOR i:=0 TO NUMBER_OF_MODULES_M1 DO

        modules[i].r_trig_0.CLK := gMachineControl.status.cycleRunning;
        modules[i].r_trig_0();
        
        energyUIConnect.ModuleList.SelectedIndex := modules[i].index;
        MpEnergyCoreUI_0();
        
        IF (modules[i].r_trig_0.Q = TRUE) THEN
            modules[i].startOfCycleActivePower      := energyUIConnect.SelectedModule.Details.ActivePower;
            modules[i].startOfCycleApparentEnergy   := energyUIConnect.SelectedModule.Details.Energy.Apparent;
        END_IF
        
        gModules[i].activePower     := energyUIConnect.SelectedModule.Details.ActivePower;
        gModules[i].apparentEnergy  := energyUIConnect.SelectedModule.Details.Energy.Apparent;
        
        IF (gMachineControl.status.cycleRunning = TRUE) THEN
            gModules[i].currentCycleActivePower     := gModules[i].activePower - modules[i].startOfCycleActivePower;
            gModules[i].currentCycleApparentEnergy  := gModules[i].apparentEnergy - modules[i].startOfCycleApparentEnergy;
        END_IF
        
    END_FOR
    
    // restore the index
    energyUIConnect.ModuleList.SelectedIndex := currentIndex;
    MpEnergyCoreUI_0();
    
END_PROGRAM

PROGRAM _EXIT
    
    MpEnergyCore_0.Enable   := FALSE;
    MpEnergyCore_0();
    
END_PROGRAM


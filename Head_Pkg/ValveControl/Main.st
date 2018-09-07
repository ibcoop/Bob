
PROGRAM _INIT
    
    // register the balance tank parameters
    gModules[0].heads[0].balanceTank;
    balanceTankValve[0].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[0].balanceTank.parameters.machineData');
    balanceTankValve[1].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[1].balanceTank.parameters.machineData');
    balanceTankValve[2].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[0].balanceTank.parameters.machineData');
    balanceTankValve[3].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[1].balanceTank.parameters.machineData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        balanceTankValve[currentHead].MpRecipeRegPar_0.MpLink := ADR(gMachineRecipe);
        balanceTankValve[currentHead].MpRecipeRegPar_0.Enable := TRUE;
        balanceTankValve[currentHead].MpRecipeRegPar_0.Category := ADR(MACHINE_CATEGORY);
        balanceTankValve[currentHead].MpRecipeRegPar_0();
    END_FOR
    
    balanceTankValve[0].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[0].balanceTank.parameters.processData');
    balanceTankValve[1].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[1].balanceTank.parameters.processData');
    balanceTankValve[2].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[0].balanceTank.parameters.processData');
    balanceTankValve[3].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[1].balanceTank.parameters.processData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        balanceTankValve[currentHead].MpRecipeRegPar_1.MpLink := ADR(gProcessRecipe);
        balanceTankValve[currentHead].MpRecipeRegPar_1.Enable := TRUE;
        balanceTankValve[currentHead].MpRecipeRegPar_1.Category := ADR(PROCESS_CATEGORY);
        balanceTankValve[currentHead].MpRecipeRegPar_1();
    END_FOR

    // register the fill valve parameters
    gModules[0].heads[0].fillValve;
    fillValve[0].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[0].fillValve.parameters.machineData');
    fillValve[1].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[1].fillValve.parameters.machineData');
    fillValve[2].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[0].fillValve.parameters.machineData');
    fillValve[3].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[1].fillValve.parameters.machineData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        fillValve[currentHead].MpRecipeRegPar_0.MpLink := ADR(gMachineRecipe);
        fillValve[currentHead].MpRecipeRegPar_0.Enable := TRUE;
        fillValve[currentHead].MpRecipeRegPar_0.Category := ADR(MACHINE_CATEGORY);
        fillValve[currentHead].MpRecipeRegPar_0();
    END_FOR
    
    fillValve[0].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[0].fillValve.parameters.processData');
    fillValve[1].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[1].fillValve.parameters.processData');
    fillValve[2].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[0].fillValve.parameters.processData');
    fillValve[3].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[1].fillValve.parameters.processData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        fillValve[currentHead].MpRecipeRegPar_1.MpLink := ADR(gProcessRecipe);
        fillValve[currentHead].MpRecipeRegPar_1.Enable := TRUE;
        fillValve[currentHead].MpRecipeRegPar_1.Category := ADR(PROCESS_CATEGORY);
        fillValve[currentHead].MpRecipeRegPar_1();
    END_FOR

    // register the fill vent parameters
    gModules[0].heads[0].cylinderVent;
    cylinderVentValve[0].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[0].cylinderVent.parameters.machineData');
    cylinderVentValve[1].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[1].cylinderVent.parameters.machineData');
    cylinderVentValve[2].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[0].cylinderVent.parameters.machineData');
    cylinderVentValve[3].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[1].cylinderVent.parameters.machineData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        cylinderVentValve[currentHead].MpRecipeRegPar_0.MpLink := ADR(gMachineRecipe);
        cylinderVentValve[currentHead].MpRecipeRegPar_0.Enable := TRUE;
        cylinderVentValve[currentHead].MpRecipeRegPar_0.Category := ADR(MACHINE_CATEGORY);
        cylinderVentValve[currentHead].MpRecipeRegPar_0();
    END_FOR
    
    cylinderVentValve[0].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[0].cylinderVent.parameters.processData');
    cylinderVentValve[1].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[1].cylinderVent.parameters.processData');
    cylinderVentValve[2].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[0].cylinderVent.parameters.processData');
    cylinderVentValve[3].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[1].cylinderVent.parameters.processData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        cylinderVentValve[currentHead].MpRecipeRegPar_1.MpLink := ADR(gProcessRecipe);
        cylinderVentValve[currentHead].MpRecipeRegPar_1.Enable := TRUE;
        cylinderVentValve[currentHead].MpRecipeRegPar_1.Category := ADR(PROCESS_CATEGORY);
        cylinderVentValve[currentHead].MpRecipeRegPar_1();
    END_FOR
    
    // register the nozzle parameters
    gModules[0].heads[0].nozzle;
    nozzleValve[0].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[0].nozzle.parameters.machineData');
    nozzleValve[1].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[1].nozzle.parameters.machineData');
    nozzleValve[2].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[0].nozzle.parameters.machineData');
    nozzleValve[3].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[1].nozzle.parameters.machineData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        nozzleValve[currentHead].MpRecipeRegPar_0.MpLink := ADR(gMachineRecipe);
        nozzleValve[currentHead].MpRecipeRegPar_0.Enable := TRUE;
        nozzleValve[currentHead].MpRecipeRegPar_0.Category := ADR(MACHINE_CATEGORY);
        nozzleValve[currentHead].MpRecipeRegPar_0();
    END_FOR
    
    nozzleValve[0].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[0].nozzle.parameters.processData');
    nozzleValve[1].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[1].nozzle.parameters.processData');
    nozzleValve[2].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[0].nozzle.parameters.processData');
    nozzleValve[3].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[1].nozzle.parameters.processData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        nozzleValve[currentHead].MpRecipeRegPar_1.MpLink := ADR(gProcessRecipe);
        nozzleValve[currentHead].MpRecipeRegPar_1.Enable := TRUE;
        nozzleValve[currentHead].MpRecipeRegPar_1.Category := ADR(PROCESS_CATEGORY);
        nozzleValve[currentHead].MpRecipeRegPar_1();
    END_FOR

    // register the recirculationValve parameters
    gModules[0].heads[0].recirculationValve;
    recirculationValve[0].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[0].recirculationValve.parameters.machineData');
    recirculationValve[1].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[1].recirculationValve.parameters.machineData');
    recirculationValve[2].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[0].recirculationValve.parameters.machineData');
    recirculationValve[3].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[1].recirculationValve.parameters.machineData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        recirculationValve[currentHead].MpRecipeRegPar_0.MpLink := ADR(gMachineRecipe);
        recirculationValve[currentHead].MpRecipeRegPar_0.Enable := TRUE;
        recirculationValve[currentHead].MpRecipeRegPar_0.Category := ADR(MACHINE_CATEGORY);
        recirculationValve[currentHead].MpRecipeRegPar_0();
    END_FOR
    
    recirculationValve[0].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[0].recirculationValve.parameters.processData');
    recirculationValve[1].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[1].recirculationValve.parameters.processData');
    recirculationValve[2].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[0].recirculationValve.parameters.processData');
    recirculationValve[3].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[1].recirculationValve.parameters.processData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        recirculationValve[currentHead].MpRecipeRegPar_1.MpLink := ADR(gProcessRecipe);
        recirculationValve[currentHead].MpRecipeRegPar_1.Enable := TRUE;
        recirculationValve[currentHead].MpRecipeRegPar_1.Category := ADR(PROCESS_CATEGORY);
        recirculationValve[currentHead].MpRecipeRegPar_1();
    END_FOR
    
    // register the sealPin parameters
    gModules[0].heads[0].sealPin;
    sealPinValve[0].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[0].sealPin.parameters.machineData');
    sealPinValve[1].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[1].sealPin.parameters.machineData');
    sealPinValve[2].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[0].sealPin.parameters.machineData');
    sealPinValve[3].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[1].sealPin.parameters.machineData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        sealPinValve[currentHead].MpRecipeRegPar_0.MpLink := ADR(gMachineRecipe);
        sealPinValve[currentHead].MpRecipeRegPar_0.Enable := TRUE;
        sealPinValve[currentHead].MpRecipeRegPar_0.Category := ADR(MACHINE_CATEGORY);
        sealPinValve[currentHead].MpRecipeRegPar_0();
    END_FOR
    
    sealPinValve[0].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[0].sealPin.parameters.processData');
    sealPinValve[1].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[1].sealPin.parameters.processData');
    sealPinValve[2].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[0].sealPin.parameters.processData');
    sealPinValve[3].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[1].sealPin.parameters.processData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        sealPinValve[currentHead].MpRecipeRegPar_1.MpLink := ADR(gProcessRecipe);
        sealPinValve[currentHead].MpRecipeRegPar_1.Enable := TRUE;
        sealPinValve[currentHead].MpRecipeRegPar_1.Category := ADR(PROCESS_CATEGORY);
        sealPinValve[currentHead].MpRecipeRegPar_1();
    END_FOR

    
    // register the sealPin parameters
    gModules[0].heads[0].sealPin;
    counterStretchRodValve[0].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[0].counterStretchRod.parameters.machineData');
    counterStretchRodValve[1].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[1].counterStretchRod.parameters.machineData');
    counterStretchRodValve[2].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[0].counterStretchRod.parameters.machineData');
    counterStretchRodValve[3].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[1].counterStretchRod.parameters.machineData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        counterStretchRodValve[currentHead].MpRecipeRegPar_0.MpLink := ADR(gMachineRecipe);
        counterStretchRodValve[currentHead].MpRecipeRegPar_0.Enable := TRUE;
        counterStretchRodValve[currentHead].MpRecipeRegPar_0.Category := ADR(MACHINE_CATEGORY);
        counterStretchRodValve[currentHead].MpRecipeRegPar_0();
    END_FOR
    
    counterStretchRodValve[0].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[0].counterStretchRod.parameters.processData');
    counterStretchRodValve[1].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[1].counterStretchRod.parameters.processData');
    counterStretchRodValve[2].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[0].counterStretchRod.parameters.processData');
    counterStretchRodValve[3].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[1].counterStretchRod.parameters.processData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        counterStretchRodValve[currentHead].MpRecipeRegPar_1.MpLink := ADR(gProcessRecipe);
        counterStretchRodValve[currentHead].MpRecipeRegPar_1.Enable := TRUE;
        counterStretchRodValve[currentHead].MpRecipeRegPar_1.Category := ADR(PROCESS_CATEGORY);
        counterStretchRodValve[currentHead].MpRecipeRegPar_1();
    END_FOR
    
    // register the forming valve parameters
    gModules[0].heads[0].formingValve;
    formingValve[0].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[0].formingValve.parameters.machineData');
    formingValve[1].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[1].formingValve.parameters.machineData');
    formingValve[2].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[0].formingValve.parameters.machineData');
    formingValve[3].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[1].formingValve.parameters.machineData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        formingValve[currentHead].MpRecipeRegPar_0.MpLink := ADR(gMachineRecipe);
        formingValve[currentHead].MpRecipeRegPar_0.Enable := TRUE;
        formingValve[currentHead].MpRecipeRegPar_0.Category := ADR(MACHINE_CATEGORY);
        formingValve[currentHead].MpRecipeRegPar_0();
    END_FOR
    
    formingValve[0].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[0].formingValve.parameters.processData');
    formingValve[1].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[1].formingValve.parameters.processData');
    formingValve[2].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[0].formingValve.parameters.processData');
    formingValve[3].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[1].formingValve.parameters.processData');
    
    FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        formingValve[currentHead].MpRecipeRegPar_1.MpLink := ADR(gProcessRecipe);
        formingValve[currentHead].MpRecipeRegPar_1.Enable := TRUE;
        formingValve[currentHead].MpRecipeRegPar_1.Category := ADR(PROCESS_CATEGORY);
        formingValve[currentHead].MpRecipeRegPar_1();
	END_FOR
	
	
	// register the FillLevel Cyclinder valve parameters
	gModules[0].heads[0].fillLevelCylinderValve;
	fillLevelCylinderValve[0].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[0]fillLevelCylinderValve.parameters.machineData');
	fillLevelCylinderValve[1].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[1].fillLevelCylinderValve.parameters.machineData');
	fillLevelCylinderValve[2].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[0].fillLevelCylinderValve.parameters.machineData');
	fillLevelCylinderValve[3].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[1].fillLevelCylinderValve.parameters.machineData');
    
	FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
		fillLevelCylinderValve[currentHead].MpRecipeRegPar_0.MpLink := ADR(gMachineRecipe);
		fillLevelCylinderValve[currentHead].MpRecipeRegPar_0.Enable := TRUE;
		fillLevelCylinderValve[currentHead].MpRecipeRegPar_0.Category := ADR(MACHINE_CATEGORY);
		fillLevelCylinderValve[currentHead].MpRecipeRegPar_0();
	END_FOR
    
	fillLevelCylinderValve[0].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[0].fillLevelCylinderValve.parameters.processData');
	fillLevelCylinderValve[1].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[1].fillLevelCylinderValve.parameters.processData');
	fillLevelCylinderValve[2].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[0].fillLevelCylinderValve.parameters.processData');
	fillLevelCylinderValve[3].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[1].fillLevelCylinderValve.parameters.processData');
    
	FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
		fillLevelCylinderValve[currentHead].MpRecipeRegPar_1.MpLink := ADR(gProcessRecipe);
		fillLevelCylinderValve[currentHead].MpRecipeRegPar_1.Enable := TRUE;
		fillLevelCylinderValve[currentHead].MpRecipeRegPar_1.Category := ADR(PROCESS_CATEGORY);
		fillLevelCylinderValve[currentHead].MpRecipeRegPar_1();
	END_FOR
	
		
	// register the FillLevel Suction valve parameters
	gModules[0].heads[0].fillLevelCylinderValve;
	fillLevelSuctionValve[0].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[0]fillLevelSuctionValve.parameters.machineData');
	fillLevelSuctionValve[1].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[1].fillLevelSuctionValve.parameters.machineData');
	fillLevelSuctionValve[2].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[0].fillLevelSuctionValve.parameters.machineData');
	fillLevelSuctionValve[3].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[1].fillLevelSuctionValve.parameters.machineData');
    
	FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
		fillLevelSuctionValve[currentHead].MpRecipeRegPar_0.MpLink := ADR(gMachineRecipe);
		fillLevelSuctionValve[currentHead].MpRecipeRegPar_0.Enable := TRUE;
		fillLevelSuctionValve[currentHead].MpRecipeRegPar_0.Category := ADR(MACHINE_CATEGORY);
		fillLevelSuctionValve[currentHead].MpRecipeRegPar_0();
	END_FOR
    
	fillLevelSuctionValve[0].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[0].fillLevelSuctionValve.parameters.processData');
	fillLevelSuctionValve[1].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[1].fillLevelSuctionValve.parameters.processData');
	fillLevelSuctionValve[2].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[0].fillLevelSuctionValve.parameters.processData');
	fillLevelSuctionValve[3].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[1].fillLevelSuctionValve.parameters.processData');
    
	FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
		fillLevelSuctionValve[currentHead].MpRecipeRegPar_1.MpLink := ADR(gProcessRecipe);
		fillLevelSuctionValve[currentHead].MpRecipeRegPar_1.Enable := TRUE;
		fillLevelSuctionValve[currentHead].MpRecipeRegPar_1.Category := ADR(PROCESS_CATEGORY);
		fillLevelSuctionValve[currentHead].MpRecipeRegPar_1();
	END_FOR
	
			
	// register the FillLevel Drain valve parameters
	gModules[0].heads[0].fillLevelCylinderValve;
	fillLevelDrainValve[0].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[0]fillLevelDrainValve.parameters.machineData');
	fillLevelDrainValve[1].MpRecipeRegPar_0.PVName := ADR('gModules[0].heads[1].fillLevelDrainValve.parameters.machineData');
	fillLevelDrainValve[2].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[0].fillLevelDrainValve.parameters.machineData');
	fillLevelDrainValve[3].MpRecipeRegPar_0.PVName := ADR('gModules[1].heads[1].fillLevelDrainValve.parameters.machineData');
    
	FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
		fillLevelDrainValve[currentHead].MpRecipeRegPar_0.MpLink := ADR(gMachineRecipe);
		fillLevelDrainValve[currentHead].MpRecipeRegPar_0.Enable := TRUE;
		fillLevelDrainValve[currentHead].MpRecipeRegPar_0.Category := ADR(MACHINE_CATEGORY);
		fillLevelDrainValve[currentHead].MpRecipeRegPar_0();
	END_FOR
    
	fillLevelDrainValve[0].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[0].fillLevelDrainValve.parameters.processData');
	fillLevelDrainValve[1].MpRecipeRegPar_1.PVName := ADR('gModules[0].heads[1].fillLevelDrainValve.parameters.processData');
	fillLevelDrainValve[2].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[0].fillLevelDrainValve.parameters.processData');
	fillLevelDrainValve[3].MpRecipeRegPar_1.PVName := ADR('gModules[1].heads[1].fillLevelDrainValve.parameters.processData');
    
	FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
		fillLevelDrainValve[currentHead].MpRecipeRegPar_1.MpLink := ADR(gProcessRecipe);
		fillLevelDrainValve[currentHead].MpRecipeRegPar_1.Enable := TRUE;
		fillLevelDrainValve[currentHead].MpRecipeRegPar_1.Category := ADR(PROCESS_CATEGORY);
		fillLevelDrainValve[currentHead].MpRecipeRegPar_1();
	END_FOR
	

	
	
	
	
	
	
	
	
    
	FOR currentHead:=0 TO NUMBER_OF_HEADS_M1 DO
        
		pLocalValve ACCESS ADR(balanceTankValve[currentHead]);
		pLocalValve.valveName := gModules[getModuleIndex(currentHead)].heads[getHeadIndex(currentHead)].headName;
		strcat(ADR(pLocalValve.valveName), ADR(' Balance Tank Valve'));

		pLocalValve ACCESS ADR(fillValve[currentHead]);
		pLocalValve.valveName := gModules[getModuleIndex(currentHead)].heads[getHeadIndex(currentHead)].headName;
		strcat(ADR(pLocalValve.valveName), ADR(' Fill Valve'));

		pLocalValve ACCESS ADR(cylinderVentValve[currentHead]);
		pLocalValve.valveName := gModules[getModuleIndex(currentHead)].heads[getHeadIndex(currentHead)].headName;
		strcat(ADR(pLocalValve.valveName), ADR(' Cylinder Vent Valve'));
        
		pLocalValve ACCESS ADR(formingValve[currentHead]);
		pLocalValve.valveName := gModules[getModuleIndex(currentHead)].heads[getHeadIndex(currentHead)].headName;
		strcat(ADR(pLocalValve.valveName), ADR(' Forming Valve'));

        pLocalValve ACCESS ADR(nozzleValve[currentHead]);
        pLocalValve.valveName := gModules[getModuleIndex(currentHead)].heads[getHeadIndex(currentHead)].headName;
        strcat(ADR(pLocalValve.valveName), ADR(' Nozzle Valve'));

        pLocalValve ACCESS ADR(recirculationValve[currentHead]);
        pLocalValve.valveName := gModules[getModuleIndex(currentHead)].heads[getHeadIndex(currentHead)].headName;
        strcat(ADR(pLocalValve.valveName), ADR(' Recirculation Valve'));

        pLocalValve ACCESS ADR(sealPinValve[currentHead]);
        pLocalValve.valveName := gModules[getModuleIndex(currentHead)].heads[getHeadIndex(currentHead)].headName;
        strcat(ADR(pLocalValve.valveName), ADR(' Seal Pin Valve'));

        pLocalValve ACCESS ADR(counterStretchRodValve[currentHead]);
        pLocalValve.valveName := gModules[getModuleIndex(currentHead)].heads[getHeadIndex(currentHead)].headName;
        strcat(ADR(pLocalValve.valveName), ADR(' Counter Stretchrod Valve'));

		pLocalValve ACCESS ADR(fillLevelCylinderValve[currentHead]);
		pLocalValve.valveName := gModules[getModuleIndex(currentHead)].heads[getHeadIndex(currentHead)].headName;
		strcat(ADR(pLocalValve.valveName), ADR(' FillLevel Cylinder Valve'));
		
		pLocalValve ACCESS ADR(fillLevelSuctionValve[currentHead]);
		pLocalValve.valveName := gModules[getModuleIndex(currentHead)].heads[getHeadIndex(currentHead)].headName;
		strcat(ADR(pLocalValve.valveName), ADR(' FillLevel Suction Valve'));
		
		pLocalValve ACCESS ADR(fillLevelDrainValve[currentHead]);
		pLocalValve.valveName := gModules[getModuleIndex(currentHead)].heads[getHeadIndex(currentHead)].headName;
		strcat(ADR(pLocalValve.valveName), ADR(' FillLevel Drain Valve'));
		
		
    END_FOR
    
END_PROGRAM

PROGRAM _CYCLIC

	gMachineControl.commands.preformsEnteringMoldStart.CLK  := (gMachineControl.status.preformsEnteringMold = TRUE);
	gMachineControl.commands.preformsEnteringMoldStart();
	IF gMachineControl.commands.preformsEnteringMoldStart.Q = TRUE THEN
		FOR currentModule:=0 TO NUMBER_OF_MODULES_M1 DO
			FOR currentHead:=0 TO NUM_OF_HEADS_PER_MODULE_M1 DO
				IF ((gModules[currentModule].heads[currentHead].enable = TRUE) AND (gModules[currentModule].heads[currentHead].recirculationValve.status.errorActive <> TRUE)) THEN
					gModules[currentModule].heads[currentHead].recirculationValve.commands.open := FALSE;
					gModules[currentModule].heads[currentHead].recirculationValve.commands.close := TRUE;
				END_IF
			END_FOR
		END_FOR
	END_IF		
				
				
    
    FOR currentModule:=0 TO NUMBER_OF_MODULES_M1 DO
        FOR currentHead:=0 TO NUM_OF_HEADS_PER_MODULE_M1 DO
             
            logArguments[0] := ADR(currentModule);
            logArguments[1] := ADR(currentHead);

            balanceTankAction;
            counterStretchRodAction;            
            fillAction;
            cylinderVentAction;
            formingValveAction;
            nozzleAction;
            recirculationAction;
			sealPinAction;
			fillLevelCylinderValveAction;
			fillLevelSuctionValveAction;
			fillLevelDrainValveAction;

						
						
						
						
            IF (DiagCpuIsSimulated() = TRUE) THEN
                gModules[currentModule].heads[currentHead].fillValve.status.errorActive := FALSE;
                gModules[currentModule].heads[currentHead].formingValve.status.errorActive := FALSE;
                gModules[currentModule].heads[currentHead].recirculationValve.status.errorActive := FALSE;
                gModules[currentModule].heads[currentHead].sealPin.status.errorActive := FALSE;
                gModules[currentModule].heads[currentHead].nozzle.status.errorActive := FALSE;
                gModules[currentModule].heads[currentHead].cylinderVent.status.errorActive := FALSE;
				gModules[currentModule].heads[currentHead].counterStretchRod.status.errorActive := FALSE;
				gModules[currentModule].heads[currentHead].fillLevelCylinderValve.status.errorActive := FALSE;
				gModules[currentModule].heads[currentHead].fillLevelSuctionValve.status.errorActive := FALSE;
				gModules[currentModule].heads[currentHead].fillLevelDrainValve.status.errorActive := FALSE;
                
            END_IF
            
        END_FOR
    END_FOR
    
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM



ACTION LogState: 
    
    IF (pFillPiston.state <> old_state[(currentModule*NUM_OF_HEADS_PER_MODULE)+currentHead]) THEN
        old_state[(currentModule*NUM_OF_HEADS_PER_MODULE)+currentHead] := pFillPiston.state;
    
        CASE pFillPiston.state OF            
            LOAD_CONFIG:
                stateName := 'LOAD_CONFIG';
            WAIT_FOR_POWER:
                stateName := 'WAIT_FOR_POWER';
            INIT:
                stateName := 'INIT';
            RESTORE_HOME:
                stateName := 'RESTORE_HOME';
            WAIT_FOR_HOME:
                stateName := 'WAIT_FOR_HOME';
            HOMING:
                stateName := 'HOMING';
            SAVE_HOME_OFFSET:
                stateName := 'SAVE_HOME_OFFSET';
            READY:
                stateName := 'READY';
            IN_MOTION:
                stateName := 'IN_MOTION';
            PRESSURE_RELIEF:
                stateName := 'PRESSURE_RELIEF';
            HOLD_PRESSURE:
                stateName := 'HOLD_PRESSURE';
            DEPRESSURIZE:
                stateName := 'DEPRESSURIZE';
            ERROR:
                stateName := 'ERROR';
            ELSE
                itoa(pFillPiston.state, ADR(stateName));
        END_CASE
        
        logArguments[3] := ADR(stateName);
        logDebug('FillPiston', 'Module %h, Head %h, Node %h Changing State to %s', ADR(logArguments));
    END_IF

END_ACTION

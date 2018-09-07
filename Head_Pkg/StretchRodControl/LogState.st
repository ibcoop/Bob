
ACTION LogState: 
    
    IF (pStretchRod.state <> old_state[(currentModule*NUM_OF_HEADS_PER_MODULE)+currentHead]) THEN
        old_state[(currentModule*NUM_OF_HEADS_PER_MODULE)+currentHead] := pStretchRod.state;
    
        CASE pStretchRod.state OF
            WAIT_FOR_POWER:
                stateName := 'WAIT_FOR_POWER';
            INIT:
                stateName := 'INIT';
            WAIT_FOR_HOME:
                stateName := 'WAIT_FOR_HOME';
            HOMING:
                stateName := 'HOMING';
            WAIT_FOR_CALIBRATION:
                stateName := 'WAIT_FOR_CALIBRATION';
            CALIBRATION:
                stateName := 'CALIBRATION';
            READY:
                stateName := 'READY';
            IN_MOTION:
                stateName := 'IN_MOTION';
            ERROR:
                stateName := 'ERROR';
            ELSE
                itoa(pStretchRod.state, ADR(stateName));
        END_CASE
        
        logArguments[3] := ADR(stateName);
        logDebug('StretchRod', 'Module %h, Head %h, Node %h Changing State to %s', ADR(logArguments));
    END_IF

END_ACTION

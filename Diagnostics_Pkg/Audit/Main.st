
PROGRAM _INIT
    
    IF (DiagCpuIsSimulated() = TRUE) THEN
        DevLink_0.enable := TRUE;
        DevLink_0.pDevice := ADR('audit');
        DevLink_0.pParam := ADR('/DEVICE=C:\temp\control\audit');
        DevLink_0();
    END_IF
    
    ConnectToShare_Audit.enable         := TRUE;
    ConnectToShare_Audit.ipAddress      := WINDOWS_IP_ADDRESS;
    ConnectToShare_Audit.deviceName     := 'audit';
    ConnectToShare_Audit.shareName      := 'audit';
    ConnectToShare_Audit.userName       := AMCOR_USERNAME;
    ConnectToShare_Audit.userPassword   := AMCOR_PASSWORD;
        
END_PROGRAM

PROGRAM _CYCLIC

    ConnectToShare_Audit();
    IF (ConnectToShare_Audit.status = 0) THEN
        ConnectToShare_Audit.enable    := FALSE;
        KeepAlive_Audit.enable         := TRUE;
        KeepAlive_Audit.deviceName     := ConnectToShare_Audit.deviceName;
    END_IF
    KeepAlive_Audit();

    IF (MpAuditTrail_0.ArchiveAvailable = TRUE) THEN
        MpAuditTrail_0.ExportArchive := TRUE;
    END_IF
    
    IF (MpAuditTrail_0.CommandDone = TRUE) THEN
        MpAuditTrail_0.ExportArchive    := FALSE;
        MpAuditTrail_0.Export           := FALSE;
    END_IF
    
    IF (MpAuditTrail_0.Error = TRUE) THEN
        MpAuditTrail_0.ErrorReset       := TRUE;
        MpAuditTrail_0.ExportArchive    := FALSE;
        MpAuditTrail_0.Export           := FALSE;
    ELSE
        MpAuditTrail_0.ErrorReset := FALSE;
    END_IF
    
    MpAuditTrail_0.Enable       := TRUE;
    MpAuditTrail_0.MpLink       := ADR(gAuditTrail);
    MpAuditTrail_0.DeviceName   := ADR('audit');
    MpAuditTrail_0.Language     := ADR('en-US');
    MpAuditTrail_0();
    
    MpAuditTrailUI_0.Enable     := TRUE;
    MpAuditTrailUI_0.MpLink     := ADR(gAuditTrail);
    MpAuditTrailUI_0.UIConnect  := ADR(mpAuditTrailUIConnect);
    MpAuditTrailUI_0();
    
END_PROGRAM

PROGRAM _EXIT
    MpAuditTrail_0.Enable   := FALSE;
    MpAuditTrail_0();
    
    MpAuditTrailUI_0.Enable := FALSE;
    MpAuditTrailUI_0();
END_PROGRAM


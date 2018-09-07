
FUNCTION AxisBasicCommands : BOOL (*Handle basic axis commands*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pFillPiston : REFERENCE TO localFillPiston_typ;
		pCurrentPiston : REFERENCE TO fillPiston_typ;
		pLogArguments : REFERENCE TO ARRAY[0..LOGGING_MAX_ARGUMENTS] OF UDINT;
	END_VAR
END_FUNCTION

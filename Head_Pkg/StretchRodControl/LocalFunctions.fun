
FUNCTION AxisBasicCommands : BOOL (*Handle basic axis commands*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pStretchRod : REFERENCE TO localStretchRod_typ;
		pCurrentStretchRod : REFERENCE TO stretchRod_typ;
		pLogArguments : REFERENCE TO ARRAY[0..LOGGING_MAX_ARGUMENTS] OF UDINT;
	END_VAR
END_FUNCTION

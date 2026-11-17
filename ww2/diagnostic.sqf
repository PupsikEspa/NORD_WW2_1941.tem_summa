if (!isServer) exitWith {};
if (isNil "WW2_fnc_diagnostic") exitWith {
 diag_log "[WW2 DIAGNOSTIC] Load @WW2_Server to run the diagnostic.";
};
[] call WW2_fnc_diagnostic;

if (!isServer) exitWith {};
if (isNil "WW2_fnc_initMission") exitWith {
 diag_log "[WW2 SERVER] Bootstrap missing. Install the matching @WW2_Server v1.1.38 and restart Arma.";
};
[] call WW2_fnc_initMission;

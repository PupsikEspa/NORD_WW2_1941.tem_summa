if (!hasInterface) exitWith {};
if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {};
if (!isRemoteExecuted && {!isServer}) exitWith {};
if (isNull (findDisplay 312)) exitWith {};
params [["_counts", [], [[]]], ["_rows", [], [[]]]];
if (count _counts != 4) exitWith {};
uiNamespace setVariable ["WW2_zeusHudSnapshot", [diag_tickTime, _counts, _rows]];

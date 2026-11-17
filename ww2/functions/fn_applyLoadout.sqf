if (!isRemoteExecuted || {remoteExecutedOwner!=2}) exitWith {};
params ["_unit","_loadout"];
if (_unit isEqualTo player && {local _unit}) then {_unit setUnitLoadout _loadout};

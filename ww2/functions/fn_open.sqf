params [["_key","",[""]]];
if (!hasInterface || {_key isEqualTo ""}) exitWith {};
[player,"trophyList",_key,[]] remoteExecCall ["WW2_fnc_request",2];

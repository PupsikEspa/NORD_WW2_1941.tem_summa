if (isRemoteExecuted && {remoteExecutedOwner!=2}) exitWith {};
params [["_curator",objNull,[objNull]]];
if (isNull _curator || {_curator getVariable ["WW2_hooked",false]}) exitWith {};
_curator setVariable ["WW2_hooked",true];
{
 _x params ["_event","_kind"];
 private _code = switch _kind do {
  case "placed": {{params ["_curator","_object"]; [_curator,"placed",_object,typeOf _object,getPosATL _object,netId _object] remoteExecCall ["WW2_fnc_zeusEvent",2]}};
  case "deleted": {{params ["_curator","_object"]; [_curator,"deleted",_object,typeOf _object,getPosATL _object,netId _object] remoteExecCall ["WW2_fnc_zeusEvent",2]}};
  default {{params ["_curator","_object"]; [_curator,"edited",_object,typeOf _object,getPosATL _object,netId _object] remoteExecCall ["WW2_fnc_zeusEvent",2]}};
 };
 _curator addEventHandler [_event,_code];
} forEach [["CuratorObjectPlaced","placed"],["CuratorObjectDeleted","deleted"],["CuratorObjectEdited","edited"]];

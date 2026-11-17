if (!hasInterface || {if (isRemoteExecuted) then {remoteExecutedOwner!=2} else {!isServer}}) exitWith {};
params ["_kind","_data"];
switch _kind do {
 case "storeBegin": {private _inventory=findDisplay 602; if (!isNull _inventory) then {_inventory closeDisplay 1}};
 case "message": {hint _data; systemChat _data};
 case "ocap": {
  systemChat _data;
  if (!isNull (findDisplay 312) && {!isNil "zen_common_fnc_showMessage"}) then {
   [_data] call zen_common_fnc_showMessage;
  } else {
   hint _data;
  };
 };
 case "stashApply": {
  _data params ["_unit","_terminal","_revision","_expiry","_before","_after","_moving","_take"];
  private _result = "changed";
  if (player isEqualTo _unit && {local _unit} && {alive _unit} && {!isNull _terminal}
   && {_unit distance _terminal<=7} && {isNull objectParent _unit} && {serverTime<=_expiry}) then {
   _result = [_unit,_before,_moving,_take,_after] call WW2_fnc_stashApply;
  };
  [_unit,"stashApplied",_revision,[_result]] remoteExecCall ["WW2_fnc_request",2];
 };
 case "stashView": {["view",_data] call WW2_fnc_stashUI};
 case "stashNotice": {["notice",_data] call WW2_fnc_stashUI};
 case "spawner": {
  if (isNil "SUS_fnc_openSpawner") exitWith {hint "Установите обновлённый аддон спавнера."};
  _data call SUS_fnc_openSpawner;
 };
 case "arsenal": {
  if ((_data select 0) != player) exitWith {};
  private _display = uiNamespace getVariable ["WW2_display",displayNull];
  if (!isNull _display) then {_display closeDisplay 1};
  _data spawn WW2_fnc_arsenal;
 };
};

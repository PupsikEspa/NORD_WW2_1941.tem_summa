disableSerialization;
params ["_unit", "_token", "_items", "_seconds"];
if (_unit != player || {!alive _unit} || {!local _unit}) exitWith {};
uiNamespace setVariable ["WW2_lastArsenalToken",_token];
private _finish = {
 private _active = uiNamespace getVariable ["WW2_activeArsenal",[]];
 if (_active isNotEqualTo [] && {(_active select 0) isEqualTo _unit} && {(_active select 1) isEqualTo _token}) then {
  uiNamespace setVariable ["WW2_activeArsenal",nil];
 };
 [_unit, "arsenalClose", _token, []] remoteExecCall ["WW2_fnc_request", 2];
};
if (isNil "ace_arsenal_fnc_openBox" || {isNil "ace_arsenal_fnc_initBox"}) exitWith {
 hint "Для этого ящика нужен ACE Arsenal (ACE3).";
 call _finish;
};
private _box = "Box_NATO_Ammo_F" createVehicleLocal [0,0,0];
if (isNull _box) exitWith {
 hint "Не удалось подготовить список для ACE Arsenal.";
 call _finish;
};
_box hideObject true;
_box setVariable ["WW2_arsenalManagedBox", true];
[_box, _items, false] call ace_arsenal_fnc_initBox;
[_box, _unit, false] call ace_arsenal_fnc_openBox;

private _display = displayNull;
private _openDeadline = diag_tickTime + 8;
waitUntil {
 uiSleep 0.05;
 _display = _box getVariable ["WW2_arsenalDisplay", displayNull];
 !isNull _display || {diag_tickTime >= _openDeadline} || {!alive _unit} || {player != _unit}
};
if (isNull _display) exitWith {
 deleteVehicle _box;
 call _finish;
 if (alive _unit && {player isEqualTo _unit}) then {
  hint "ACE Arsenal не открыл окно. Попробуйте снова.";
  diag_log "[WW2 Arsenal] ACE display did not open.";
 };
};
uiNamespace setVariable ["WW2_activeArsenal",[_unit,_token,_display]];
[_unit, "arsenalOpened", _token, []] remoteExecCall ["WW2_fnc_request", 2];
// Keep the server lease alive while this exact ACE display remains open.
// There is no total-duration deadline for choosing equipment.
private _nextHeartbeat = diag_tickTime + 15;
waitUntil {
 uiSleep 0.1;
 private _finished = isNull _display || {!alive _unit} || {player != _unit};
 if (!_finished && {diag_tickTime >= _nextHeartbeat}) then {
  [_unit, "arsenalAlive", _token, []] remoteExecCall ["WW2_fnc_request", 2];
  _nextHeartbeat = diag_tickTime + 15;
 };
 _finished
};
if (!isNull _display) then {_display closeDisplay 2};
deleteVehicle _box;
uiSleep 0.5;
call _finish;

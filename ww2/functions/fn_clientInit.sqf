if (!hasInterface || {missionNamespace getVariable ["WW2_clientStarted",false]}) exitWith {};
WW2_clientStarted = true;
waitUntil {uiSleep 0.1; !isNull player};
if (!isNil "CBA_fnc_addEventHandler") then {
 ["ace_arsenal_displayOpened", {
  params ["_display"];
  private _box = missionNamespace getVariable ["ace_arsenal_currentBox", objNull];
  if (!isNull _box && {_box getVariable ["WW2_arsenalManagedBox", false]}) then {
   _box setVariable ["WW2_arsenalDisplay", _display];
  };
 }] call CBA_fnc_addEventHandler;
};
[] execVM "scripts\zeus\opened_eh.sqf";
if (!isNil "zen_custom_modules_fnc_register" && {!isNil "zen_dialog_fnc_create"}) then {
 ["NORD WW2", "OCAP — остановить и сохранить", {
  private _opened = [
   "OCAP — остановить и сохранить",
   [["TOOLBOX:YESNO", "Остановить текущую запись?", [false, 1, 2], true]],
   {
    params ["_values", "_unit"];
    if !(_values param [0, false]) exitWith {};
    private _curator = getAssignedCuratorLogic _unit;
    if (player != _unit || {isNull _curator}) exitWith {
     ["Для остановки OCAP нужен действующий Zeus на текущем слоте."] call zen_common_fnc_showMessage;
    };
    ["Запрос остановки OCAP отправлен."] call zen_common_fnc_showMessage;
    if (isServer) then {
     [_unit, _curator] call WW2_fnc_ocapRequest;
    } else {
     [_unit, _curator] remoteExecCall ["WW2_fnc_ocapRequest", 2];
    };
   },
   {}, player
  ] call zen_dialog_fnc_create;
  if (!_opened) then {["Не удалось открыть окно OCAP."] call zen_common_fnc_showMessage};
 }] call zen_custom_modules_fnc_register;
};
private _terminalActions = [];
while {true} do {
 private _curator = getAssignedCuratorLogic player;
 if (!isNull _curator && {_curator getVariable ["WW2_managedCurator", false]}) then {
  [_curator] call WW2_fnc_hookZeus;
  if (isServer) then {
   [player, _curator] call WW2_fnc_zeusConfirm;
  } else {
   [player, _curator] remoteExecCall ["WW2_fnc_zeusConfirm", 2];
  };
 };
 private _bindings = missionNamespace getVariable ["WW2_publicTerminals",[]];
 _terminalActions = _terminalActions select {
  _x params ["_binding","_ids"];
  if (_binding in _bindings) exitWith {true};
  private _object = _binding select 0;
  if (!isNull _object) then {{_object removeAction _x} forEach _ids};
  false
 };
 {
  _x params ["_object","_key","_side","_kind"];
  private _binding = _x;
  if (!isNull _object && {(_terminalActions findIf {(_x select 0) isEqualTo _binding}) < 0}) then {
   private _condition = format ["alive _this && {isNull objectParent _this} && {(toUpper str side group _this) isEqualTo '%1'}",_side];
   private _id = if (_kind in ["spawner","garage"]) then {
    private _garage = _kind isEqualTo "garage";
    private _label = if (_garage) then {"Личный гараж трофеев"} else {"Спавнер техники"};
    _object addAction [_label,{
     params ["_target","_caller","_actionId","_binding"];
     _binding params ["_key","_garage"];
     if (isNil "SUS_fnc_initSpawner" || {isNil "SUS_fnc_openSpawner"} ||
      {_garage && {getNumber (configFile >> "CfgPatches" >> "SPAWNER" >> "ww2TrophyGarage")<1}}) exitWith {
      hint "Установите обновлённый аддон спавнера.";
     };
     [_target,_caller,_actionId,_key,_garage] call SUS_fnc_initSpawner;
    },[_key,_garage],1.5,true,true,"",_condition,5]
   } else {
    _object addAction ["Личный склад трофеев",{
     params ["_target","_caller","_actionId","_key"];
     [_key] call WW2_fnc_open;
    },_key,1.5,true,true,"",_condition,5]
   };
   _terminalActions pushBack [_binding,[_id]];
  };
 } forEach _bindings;
 {
  if (!isNull _x && {isNil {_x getVariable "WW2_groupArsenalAction"}}) then {
   private _action = _x addAction ["Арсенал группы", {
    params ["_target", "_caller"];
    [_caller, "groupArsenal", "", [_target]] remoteExecCall ["WW2_fnc_request", 2];
   }, [], 1.5, true, true, "", "alive _this && {isNull objectParent _this}", 5];
   _x setVariable ["WW2_groupArsenalAction", _action];
  };
 } forEach (missionNamespace getVariable ["WW2_publicGroupArsenals", []]);
 uiSleep 2;
};

if (!isRemoteExecuted || {remoteExecutedOwner!=2}) exitWith {};
params ["_unit","_loadout",["_token","",[""]]];
if (_unit isEqualTo player && {local _unit}) then {
 if (_token isNotEqualTo "" && {_token isNotEqualTo (uiNamespace getVariable ["WW2_lastArsenalToken",""])}) exitWith {};
 // A delayed cancellation must never close a newer or unrelated arsenal window.
 private _active = uiNamespace getVariable ["WW2_activeArsenal",[]];
 if (_token isNotEqualTo "" && {_active isNotEqualTo []}
  && {(_active select 0) isEqualTo _unit} && {(_active select 1) isEqualTo _token}) then {
  private _display = _active select 2;
  if (!isNull _display) then {_display closeDisplay 2};
 };
 _unit setUnitLoadout _loadout;
};

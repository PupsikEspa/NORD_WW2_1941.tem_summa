// Recursive vehicle/holder inventory, including attachments, partial magazines and containers.
params ["_mode","_object",["_state",[]],["_depth",0]];
if (_depth>8) exitWith {[]};
if (_mode isEqualTo "read") exitWith {
 private _nested = [];
 { _nested pushBack [_x select 0, ["read",_x select 1,[],_depth+1] call WW2_fnc_cargo]; } forEach everyContainer _object;
 [getItemCargo _object, magazinesAmmoCargo _object, weaponsItemsCargo _object, getBackpackCargo _object, _nested]
};
if (_mode != "clear" && {count _state != 5}) exitWith {false};
clearItemCargoGlobal _object;
clearMagazineCargoGlobal _object;
clearWeaponCargoGlobal _object;
clearBackpackCargoGlobal _object;
if (_mode isEqualTo "clear") exitWith {true};
private _items = _state select 0;
{_object addItemCargoGlobal [_x,(_items select 1) select _forEachIndex]} forEach (_items select 0);
{_object addMagazineAmmoCargo [_x select 0,1,_x select 1]} forEach (_state select 1);
{_object addWeaponWithAttachmentsCargoGlobal [_x,1]} forEach (_state select 2);
private _bags = _state select 3;
{_object addBackpackCargoGlobal [_x,(_bags select 1) select _forEachIndex]} forEach (_bags select 0);
private _available = everyContainer _object;
{
 _x params ["_class","_contents"];
 private _index = _available findIf {(_x select 0) isEqualTo _class};
 if (_index>=0) then {
  private _entry = _available deleteAt _index;
  ["write",_entry select 1,_contents,_depth+1] call WW2_fnc_cargo;
 };
} forEach (_state select 4);
true

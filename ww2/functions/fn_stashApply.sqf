// The unit's owner applies the reserved move in a single unscheduled call.
params ["_unit","_before","_moving","_take","_after"];
if (!local _unit || {!alive _unit}) exitWith {"changed"};
([_unit] call WW2_fnc_stashPlayerItems) params ["_snapshots","_right","_loadout"];
if (!((["signature",_right] call WW2_fnc_stashItems) isEqualTo _before)) exitWith {"changed"};
if (count _loadout!=10) exitWith {"unsupported"};
private _unsupported = _snapshots findIf {
 private _cargo = _x select 2;
 private _rows = ["unpack",_cargo] call WW2_fnc_stashItems;
 private _rebuilt = ["pack",_rows] call WW2_fnc_stashItems;
 isNull (_x select 1) || {!(([_cargo] call WW2_fnc_cargoSignature) isEqualTo ([_rebuilt] call WW2_fnc_cargoSignature))}
};
if (_unsupported>=0) exitWith {"unsupported"};

private _gear = {
 private _value = _this;
 ([0,1,2,6,7,8,9] apply {_value select _x}) + ([3,4,5] apply {(_value select _x) param [0,""]})
};
private _restoreCargo = {
 params ["_wanted"];
 private _boxes = [uniformContainer _unit,vestContainer _unit,backpackContainer _unit];
 private _valid = true;
 {
  _x params ["_slot","","_cargo"];
  private _box = _boxes select (_slot-3);
  if (isNull _box) exitWith {_valid=false};
  private _expected = [_cargo] call WW2_fnc_cargoSignature;
  if (!(([["read",_box] call WW2_fnc_cargo] call WW2_fnc_cargoSignature) isEqualTo _expected)) then {
   ["write",_box,_cargo] call WW2_fnc_cargo;
   _valid = ([["read",_box] call WW2_fnc_cargo] call WW2_fnc_cargoSignature) isEqualTo _expected;
  };
  if (!_valid) exitWith {};
 } forEach _wanted;
 _valid
};
private _boxes = _snapshots apply {_x select 1};
private _weapons = +_loadout;
private _slotChanged = false;
private _ok = true;
if (_take) then {
 {
  _x params ["","_type","_class","_detail","_quantity"];
  private _weaponCfg = configFile >> "CfgWeapons" >> _class;
  private _known = switch _type do {
   case "bag": {isClass (configFile >> "CfgVehicles" >> _class)};
   case "magazine": {isClass (configFile >> "CfgMagazines" >> _class)};
   default {isClass _weaponCfg || {isClass (configFile >> "CfgGlasses" >> _class)}};
  };
  if (!_known) exitWith {_ok=false};
  if (_type isEqualTo "weapon") then {
   private _slot = switch (getNumber (_weaponCfg >> "type")) do {
    case 1: {0};
    case 4: {1};
    case 2: {2};
    case 4096: {8};
    default {-1};
   };
   if (_slot>=0 && {((_weapons select _slot) param [0,""]) isEqualTo ""}) then {
    _weapons set [_slot,_detail];
    _slotChanged = true;
    _quantity = _quantity-1;
   };
  };
  for "_i" from 1 to _quantity do {
   private _index = _boxes findIf {_x canAdd _class};
   if (_index<0) exitWith {_ok=false};
   private _box = _boxes select _index;
   private _nested = if (_type in ["item","bag"] && {count _detail isEqualTo 5}) then {everyContainer _box} else {[]};
   switch _type do {
    case "item": {_box addItemCargoGlobal [_class,1]};
    case "bag": {_box addBackpackCargoGlobal [_class,1]};
    case "magazine": {_box addMagazineAmmoCargo [_class,1,_detail select 0]};
    case "weapon": {_box addWeaponWithAttachmentsCargoGlobal [_detail,1]};
   };
   if (_type in ["item","bag"] && {count _detail isEqualTo 5}) then {
    private _created = (everyContainer _box) select {(_x select 0) isEqualTo _class && {!(_x in _nested)}};
    _ok = count _created isEqualTo 1 && {["write",(_created select 0) select 1,_detail] call WW2_fnc_cargo};
   };
   if (!_ok || {loadAbs _box > (maxLoad _box)+0.001} || {loadAbs _unit > (maxLoad _unit)+0.001}) exitWith {_ok=false};
  };
  if (!_ok) exitWith {};
 } forEach _moving;
} else {
 private _remaining = createHashMap;
 {
  private _slot = _x param [5,-1];
  if (_slot>=0) then {
   _weapons set [_slot,[]];
   _slotChanged = true;
  } else {
   _remaining set [_x select 0,_x select 4];
  };
 } forEach _moving;
 {
  _x params ["","_box","_cargo"];
  private _rows = ["unpack",_cargo] call WW2_fnc_stashItems;
  private _rest = [];
  private _removed = false;
  {
   private _id = _x select 0;
   private _available = _x select 4;
   private _wanted = _remaining getOrDefault [_id,0];
   private _amount = _available min _wanted;
   if (_amount>0) then {
    _remaining set [_id,_wanted-_amount];
    _removed = true;
   };
   if (_available>_amount) then {
    private _row = +_x;
    _row set [4,_available-_amount];
    _rest pushBack _row;
   };
  } forEach _rows;
  if (_removed) then {_ok = ["write",_box,["pack",_rest] call WW2_fnc_stashItems] call WW2_fnc_cargo};
  if (!_ok) exitWith {};
 } forEach _snapshots;
};

if (_ok && {_slotChanged}) then {
 private _cargo = ([_unit] call WW2_fnc_stashPlayerItems) select 0;
 private _target = getUnitLoadout _unit;
 {_target set [_x,_weapons select _x]} forEach [0,1,2,8];
 _unit setUnitLoadout [_target,false];
 _ok = ((getUnitLoadout _unit) call _gear) isEqualTo (_target call _gear);
 if (_ok) then {_ok = [_cargo] call _restoreCargo};
};
if (_ok) then {
 private _actual = ([_unit] call WW2_fnc_stashPlayerItems) select 1;
 private _contents = ["combine",["storage",_actual] call WW2_fnc_stashItems] call WW2_fnc_stashItems;
 _ok = (["signature",_contents] call WW2_fnc_stashItems) isEqualTo _after;
};
if (_ok) exitWith {"ok"};

if (!(((getUnitLoadout _unit) call _gear) isEqualTo (_loadout call _gear))) then {_unit setUnitLoadout [_loadout,false]};
private _restored = [_snapshots] call _restoreCargo;
private _actual = ([_unit] call WW2_fnc_stashPlayerItems) select 1;
if (!_restored || {!(((getUnitLoadout _unit) call _gear) isEqualTo (_loadout call _gear))}
 || {!((["signature",_actual] call WW2_fnc_stashItems) isEqualTo _before)}) exitWith {"unsafe"};
if (_take) then {"full"} else {"retry"}

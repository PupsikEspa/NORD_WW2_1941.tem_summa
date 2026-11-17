params ["_unit"];
private _loadout = getUnitLoadout _unit;
private _containers = [uniformContainer _unit,vestContainer _unit,backpackContainer _unit];
private _snapshots = [];
private _rows = [];
{
 private _slot = 3+_forEachIndex;
 private _worn = _loadout param [_slot,[]];
 if (count _worn>=2) then {
  private _cargo = if (isNull _x) then {[[[],[]],[],[],[[],[]],[]]} else {["read",_x] call WW2_fnc_cargo};
  private _items = ["unpack",_cargo] call WW2_fnc_stashItems;
  // Worn container references can lag the unit loadout on a dedicated server.
  if (!local _unit && {_items isEqualTo []} && {count (_worn select 1)>0}) then {
   _items = ["loadoutCargo",_worn select 1] call WW2_fnc_stashItems;
   _cargo = ["pack",_items] call WW2_fnc_stashItems;
  };
  _snapshots pushBack [_slot,_x,_cargo];
  _rows append _items;
 };
} forEach _containers;
{
 private _weapon = _loadout param [_x,[]];
 if (count _weapon>=7 && {(_weapon select 0) != ""}) then {
  _rows pushBack (["stack",["weapon",_weapon select 0,_weapon,1,_x]] call WW2_fnc_stashItems);
 };
} forEach [0,1,2,8];
[_snapshots,["combine",_rows] call WW2_fnc_stashItems,_loadout]

// Stack rows are [identity, type, classname, details, quantity, equipped slot].
params ["_mode","_data"];
if (_mode isEqualTo "stack") exitWith {
 _data params ["_type","_class","_detail","_count",["_slot",-1]];
 private _signature = if (_type in ["item","bag"]) then {[_detail] call WW2_fnc_cargoSignature} else {_detail};
 private _identity = [_type,toLower _class,_signature];
 if (_slot>=0) then {_identity pushBack _slot};
 [str _identity,_type,_class,_detail,_count,_slot]
};
if (_mode isEqualTo "storage") exitWith {
 _data apply {
  if ((_x param [5,-1])>=0) then {
   ["stack",_x select [1,4]] call WW2_fnc_stashItems
  } else {+_x}
 }
};
if (_mode isEqualTo "signature") exitWith {_data apply {[_x select 0,_x select 4]}};
if (_mode isEqualTo "loadoutCargo") exitWith {
 private _rows = [];
 {
  _x params ["_value","_count",["_rounds",-1]];
  if (_value isEqualType []) then {
   if (count _value>=7) then {_rows pushBack (["stack",["weapon",_value select 0,_value,_count]] call WW2_fnc_stashItems)};
  } else {
   if (_value isEqualType "" && {_value != ""}) then {
    private _bag = getNumber (configFile >> "CfgVehicles" >> _value >> "isBackpack")>0;
    private _container = _bag || {getText (configFile >> "CfgWeapons" >> _value >> "ItemInfo" >> "containerClass") != ""};
    private _type = "item";
    private _detail = [];
    if (_bag) then {_type = "bag"};
    if (_container) then {_detail = [[[],[]],[],[],[[],[]],[]]};
    if (isClass (configFile >> "CfgMagazines" >> _value)) then {
     _type = "magazine";
     _detail = [if (_rounds isEqualType 0 && {_rounds>=0}) then {_rounds} else {getNumber (configFile >> "CfgMagazines" >> _value >> "count")}];
    };
    _rows pushBack (["stack",[_type,_value,_detail,_count]] call WW2_fnc_stashItems);
   };
  };
 } forEach _data;
 ["combine",_rows] call WW2_fnc_stashItems
};
if (_mode isEqualTo "combine") exitWith {
 private _stacks = createHashMap;
 {
  private _key = _x select 0;
  private _count = (_x select 4) + ((_stacks getOrDefault [_key,["","","",[],0]]) select 4);
  private _row = +_x;
  _row set [4,_count];
  _stacks set [_key,_row];
 } forEach _data;
 private _keys = keys _stacks;
 _keys sort true;
 (_keys apply {_stacks get _x}) select {(_x select 4)>0}
};
if (_mode isEqualTo "pack") exitWith {
 private _items = createHashMap;
 private _bags = createHashMap;
 private _magazines = [];
 private _weapons = [];
 private _nested = [];
 {
  _x params ["","_type","_class","_detail","_quantity"];
  switch _type do {
   case "item": {_items set [_class,(_items getOrDefault [_class,0])+_quantity]};
   case "bag": {_bags set [_class,(_bags getOrDefault [_class,0])+_quantity]};
   case "magazine": {for "_i" from 1 to _quantity do {_magazines pushBack [_class,_detail select 0]}};
   case "weapon": {for "_i" from 1 to _quantity do {_weapons pushBack _detail}};
  };
  if (_type in ["item","bag"] && {count _detail isEqualTo 5}) then {
   for "_i" from 1 to _quantity do {_nested pushBack [_class,_detail]};
  };
 } forEach _data;
 private _itemClasses = keys _items;
 private _bagClasses = keys _bags;
 [[_itemClasses,_itemClasses apply {_items get _x}],_magazines,_weapons,
  [_bagClasses,_bagClasses apply {_bags get _x}],_nested]
};
if (count _data != 5) exitWith {[]};
_data params ["_items","_magazines","_weapons","_bags","_nested"];
_nested = +_nested;
private _rows = [];
private _add = {
 params ["_type","_class","_detail","_count"];
 _rows pushBack (["stack",[_type,_class,_detail,_count]] call WW2_fnc_stashItems);
};
{
 _x params ["_type","_classes"];
 _classes params ["_names","_counts"];
 {
  private _class = _x;
  private _remaining = _counts select _forEachIndex;
  for "_i" from 1 to _remaining do {
   private _nestedIndex = _nested findIf {(_x select 0) isEqualTo _class};
   if (_nestedIndex<0) exitWith {};
   private _entry = _nested deleteAt _nestedIndex;
   [_type,_class,_entry select 1,1] call _add;
   _remaining = _remaining-1;
  };
  if (_remaining>0) then {[_type,_class,[],_remaining] call _add};
 } forEach _names;
} forEach [["item",_items],["bag",_bags]];
{["magazine",_x select 0,[_x select 1],1] call _add} forEach _magazines;
{["weapon",_x select 0,_x,1] call _add} forEach _weapons;
["combine",_rows] call WW2_fnc_stashItems

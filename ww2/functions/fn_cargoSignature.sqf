params ["_cargo"];
if (count _cargo != 5) exitWith {[]};
_cargo params ["_items","_magazines","_weapons","_backpacks","_containers"];
private _sorted = [];
{
 _x params ["_classes","_counts"];
 private _entries = [];
 {_entries pushBack str [_x,_counts select _forEachIndex]} forEach _classes;
 _entries sort true;
 _sorted pushBack _entries;
} forEach [_items,_backpacks];
{
 private _entries = _x apply {str _x};
 _entries sort true;
 _sorted pushBack _entries;
} forEach [_magazines,_weapons];
private _entries = _containers apply {str [_x select 0,[_x select 1] call WW2_fnc_cargoSignature]};
_entries sort true;
_sorted pushBack _entries;
_sorted

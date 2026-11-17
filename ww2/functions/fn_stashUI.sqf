disableSerialization;
params ["_mode","_data"];
private _display = uiNamespace getVariable ["WW2_display",displayNull];
private _controlIds = [6203,6204,6205,6213,6214,6215];
if (_mode isEqualTo "notice") exitWith {
 _data params ["_key","_token","_message"];
 if (_token isEqualTo "") exitWith {hint _message};
 if (!isNull _display && {(_display getVariable ["WW2_stashKey",""]) isEqualTo _key}
  && {(_display getVariable ["WW2_stashToken",""]) isEqualTo _token}) then {
  (_display displayCtrl 6220) ctrlSetText _message;
  private _available = _display getVariable ["WW2_stashControls",[]];
  {(_display displayCtrl _x) ctrlEnable (_x in _available)} forEach _controlIds;
 };
};
_data params ["_key","_previous","_token","_left","_right","_message"];
if (_previous != "" && {isNull _display || {(_display getVariable ["WW2_stashKey",""]) != _key}
 || {(_display getVariable ["WW2_stashToken",""]) != _previous}}) exitWith {};
if (_previous isEqualTo "") then {
 if (!isNull _display) then {_display closeDisplay 1};
 _display = (findDisplay 46) createDisplay "RscDisplayEmpty";
};
if (isNull _display) exitWith {};
uiNamespace setVariable ["WW2_display",_display];
_display setVariable ["WW2_stashKey",_key];
_display setVariable ["WW2_stashToken",_token];
if (_previous isEqualTo "") then {
 private _leftEdge = safeZoneX + safeZoneW*0.12;
 private _topEdge = safeZoneY + safeZoneH*0.08;
 private _width = safeZoneW*0.76;
 private _height = safeZoneH*0.84;
 private _create = {
  params ["_type","_id","_x","_y","_w","_h","_font"];
  private _ctrl = _display ctrlCreate [_type,_id];
  _ctrl ctrlSetPosition [_leftEdge+_width*_x,_topEdge+_height*_y,_width*_w,_height*_h];
  _ctrl ctrlSetFontHeight (safeZoneH*_font);
  _ctrl ctrlCommit 0;
  _ctrl
 };
 private _barColor = [0.055,0.061,0.062,0.91];
 private _buttonColor = [0.13,0.14,0.14,0.9];
 private _heading = ["RscText",6198,0,0,1,0.08,0.031] call _create;
 _heading ctrlSetText "Личный склад трофеев";
 _heading ctrlSetBackgroundColor _barColor;
 ["RscStructuredText",6199,0.6,0.018,0.389,0.055,0.024] call _create;

 {
  _x params ["_xPos","_id","_title","_direction","_action"];
  private _header = ["RscText",_id,_xPos,0.098,0.4875,0.063,0.026] call _create;
  _header ctrlSetText _title;
  _header ctrlSetBackgroundColor _barColor;
  private _list = ["RscListbox",_id+1,_xPos,0.178,0.4875,0.559,0.026] call _create;
  _list ctrlSetBackgroundColor [0.044,0.047,0.049,0.82];
  private _quantity = ["RscEdit",_id+2,_xPos,0.754,0.072,0.068,0.026] call _create;
  _quantity ctrlSetText "1";
  _quantity ctrlSetBackgroundColor _barColor;
  _quantity ctrlSetTooltip "Количество выбранного предмета";
  {
   _x params ["_label","_all","_offset"];
   private _button = ["RscButton",_id+3+_forEachIndex,_xPos+_offset,0.754,0.197,0.068,0.023] call _create;
   _button ctrlSetText _label;
   _button ctrlSetBackgroundColor _buttonColor;
   _button setVariable ["WW2_stashAction",[_direction,_all,_id+1,_id+2]];
   _button ctrlAddEventHandler ["ButtonClick",{
    params ["_button"];
    private _display = ctrlParent _button;
    (_button getVariable "WW2_stashAction") params ["_direction","_all","_listId","_quantityId"];
    private _index = -1;
    private _quantity = 0;
    private _valid = true;
    if (!_all) then {
     private _list = _display displayCtrl _listId;
     private _row = lbCurSel _list;
     private _raw = ctrlText (_display displayCtrl _quantityId);
     _quantity = parseNumber _raw;
     _valid = _row>=0 && {_quantity>0} && {finite _quantity} && {count (_raw splitString "0123456789") isEqualTo 0};
     if (_valid) then {_index = _list lbValue _row};
    };
    if (!_valid) exitWith {(_display displayCtrl 6220) ctrlSetText "Выберите предмет и укажите целое количество."};
    {(_display displayCtrl _x) ctrlEnable false} forEach [6203,6204,6205,6213,6214,6215];
    (_display displayCtrl 6220) ctrlSetText "Перенос…";
    [player,"stashMove",_display getVariable "WW2_stashKey",
     [_display getVariable "WW2_stashToken",_direction,_index,_quantity]] remoteExecCall ["WW2_fnc_request",2];
   }];
  } forEach [[_action,false,0.081],[_action+" ВСЁ",true,0.29]];
 } forEach [[0,6201,"Содержимое склада","take","ВЗЯТЬ"],[0.5125,6211,"Инвентарь игрока","put","ПОЛОЖИТЬ"]];
 (_display displayCtrl 6211) ctrlSetTooltip "Предметы в форме, разгрузке и рюкзаке, экипированное оружие";
 private _status = ["RscText",6220,0,0.831,1,0.058,0.025] call _create;
 _status ctrlSetTextColor [1,0.85,0.66,1];
 private _close = ["RscButton",6221,0.39,0.91,0.22,0.078,0.025] call _create;
 _close ctrlSetBackgroundColor _barColor;
 _close ctrlSetText "ЗАКРЫТЬ";
 _close ctrlAddEventHandler ["ButtonClick",{(ctrlParent (_this select 0)) closeDisplay 1}];
};
private _fill = {
 params ["_id","_rows"];
 private _list = _display displayCtrl _id;
 private _selection = _list lbData lbCurSel _list;
 lbClear _list;
 {
  _x params ["_type","_class","_quantity","_rounds",["_slot",-1]];
  private _cfg = [_type,_class] call WW2_fnc_stashItemConfig;
  private _name = getText (_cfg >> "displayName");
  if (_name isEqualTo "") then {_name = _class};
  if (_rounds>=0) then {_name = format ["%1  ·  %2 патр.",_name,_rounds]};
  if (_slot>=0) then {_name = _name + "  ·  экипировано"};
  private _row = _list lbAdd _name;
  private _picture = getText (_cfg >> "picture");
  if (_picture != "") then {_list lbSetPicture [_row,_picture]};
  _list lbSetTextRight [_row,format ["×%1",_quantity]];
  _list lbSetValue [_row,_forEachIndex];
  _list lbSetData [_row,str [_type,_class,_rounds,_slot]];
 } forEach _rows;
 lbSort _list;
 if (lbSize _list>0) then {
  private _selected = 0;
  for "_i" from 0 to (lbSize _list-1) do {
   if ((_list lbData _i) isEqualTo _selection) exitWith {_selected = _i};
  };
  _list lbSetCurSel _selected;
 };
};
[6202,_left] call _fill;
[6212,_right] call _fill;
private _total = 0;
{_total = _total + (_x select 2)} forEach _left;
(_display displayCtrl 6199) ctrlSetStructuredText parseText format ["<t align='right'>Предметов на складе  %1</t>",_total];
if (_message isEqualTo "" && {_right isEqualTo []}) then {_message = "В инвентаре нет вещей для переноса."};
(_display displayCtrl 6220) ctrlSetText _message;
private _available = [];
if (count _left>0) then {_available append [6203,6204,6205]};
if (count _right>0) then {_available append [6213,6214,6215]};
_display setVariable ["WW2_stashControls",_available];
{(_display displayCtrl _x) ctrlEnable (_x in _available)} forEach _controlIds;

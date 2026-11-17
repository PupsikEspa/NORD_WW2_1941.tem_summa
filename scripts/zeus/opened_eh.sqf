if (!hasInterface || {missionNamespace getVariable ["WW2_zeusHudStarted", false]}) exitWith {};
WW2_zeusHudStarted = true;
disableSerialization;

private _teams = ["Красные", "Синие", "Зелёные", "Гражданские"];
private _colors = [[1, 0.43, 0.43, 1], [0.43, 0.72, 1, 1], [0.48, 0.88, 0.56, 1], [0.80, 0.61, 1, 1]];
private _white = [0.93, 0.95, 0.98, 1];
private _muted = [0.68, 0.74, 0.82, 1];
private _clear = [0, 0, 0, 0];

private _report = {
    params ["_unit", "_opened"];
    if (isNull _unit) exitWith {};
    if (isServer) then {
        [_unit, _opened] call WW2_fnc_zeusHudPresence;
    } else {
        [_unit, _opened] remoteExecCall ["WW2_fnc_zeusHudPresence", 2];
    };
};

private _createPanel = {
    params ["_display"];
    private _h = safeZoneH;
    private _width = (safeZoneW * 0.32) min (_h * 0.62);
    private _left = safeZoneX + (safeZoneW - _width) / 2;
    private _top = safeZoneY + _h * 0.068;

    private _clockId = getNumber (configFile >> "RscDisplayCurator" >> "controls" >> "Clock" >> "idc");
    if (_clockId <= 0) then {_clockId = 16808};
    private _clock = _display displayCtrl _clockId;
    if (!isNull _clock) then {
        (ctrlPosition _clock) params ["_clockX", "_clockY", "_clockW", "_clockH"];
        private _clockBottom = _clockY + _clockH;
        if (_clockH > 0 && {_clockY >= safeZoneY} && {_clockBottom < safeZoneY + _h * 0.18}) then {
            _top = _clockBottom + _h * 0.006;
        };
    };

    private _headerHeight = _h * 0.025;
    private _counterHeight = _h * 0.022;
    private _columnHeight = _h * 0.015;
    private _rowHeight = _h * 0.023;
    private _padding = _h * 0.005;
    private _counterY = _top + _headerHeight;
    private _columnY = _counterY + _counterHeight;
    private _rowsY = _columnY + _columnHeight;
    private _textBox = {
        params ["_position", "_fontSize", "_textColor", "_background", ["_text", ""]];
        private _control = _display ctrlCreate ["RscText", -1];
        _control ctrlSetPosition _position;
        _control ctrlSetFontHeight _fontSize;
        _control ctrlSetTextColor _textColor;
        _control ctrlSetBackgroundColor _background;
        _control ctrlSetText _text;
        _control ctrlCommit 0;
        _control
    };

    private _frame = [[_left, _top, _width, _rowsY - _top + _rowHeight + _padding],
        0, _clear, [0.045, 0.055, 0.07, 0.94]] call _textBox;
    private _title = [[_left, _top, _width, _headerHeight], _h * 0.0175,
        _white, [0.11, 0.13, 0.16, 1]] call _textBox;
    _title ctrlSetFont "RobotoCondensedBold";
    [[_left, _top, _width, _h * 0.0018], 0, _clear, [0.86, 0.70, 0.44, 1]] call _textBox;

    private _counterWidth = _width / 4;
    private _counters = [];
    {
        _counters pushBack ([[_left + _forEachIndex * _counterWidth, _counterY, _counterWidth, _counterHeight],
            _h * 0.015, _x, _clear] call _textBox);
    } forEach _colors;
    [[_left + _padding, _columnY, _width * 0.57, _columnHeight],
        _h * 0.013, _muted, _clear, "Ник игрока"] call _textBox;
    [[_left + _padding + (_width - 2 * _padding) * 0.60, _columnY, _width * 0.38, _columnHeight],
        _h * 0.013, _muted, _clear, "SteamID64"] call _textBox;

    private _roster = _display ctrlCreate ["WW2_ZeusHudRoster", 74210];
    _roster ctrlSetPosition [_left + _padding, _rowsY, _width - 2 * _padding, _rowHeight];
    _roster ctrlCommit 0;

    [_frame, _title, _counters, _roster, _rowsY - _top, _rowHeight, _padding]
};

private _updatePanel = {
    params ["_panel", "_counts", "_rows", "_waiting"];
    _panel params ["_frame", "_title", "_counters", "_roster", "_headerHeight", "_rowHeight", "_padding"];
    _title ctrlSetText format ["Активные Zeus  ·  %1", if (_waiting) then {"—"} else {str (count _rows)}];
    {
        private _value = if (_waiting) then {"—"} else {str (_counts select _forEachIndex)};
        _x ctrlSetText format ["%1  %2", _teams select _forEachIndex, _value];
    } forEach _counters;

    lnbClear _roster;
    if (count _rows isEqualTo 0) then {
        _roster lnbAddRow [if (_waiting) then {"Ожидание данных сервера…"} else {"Сейчас никто не открыл Zeus"}, ""];
    } else {
        {
            _x params ["_name", "_uid", "_sideIndex"];
            private _row = _roster lnbAddRow [_name, _uid];
            private _knownSide = _sideIndex >= 0 && {_sideIndex < count _teams};
            private _color = if (_knownSide) then {_colors select _sideIndex} else {_white};
            private _sideLabel = if (_knownSide) then {_teams select _sideIndex} else {"Другая сторона"};
            _roster lnbSetColor [[_row, 0], _color];
            _roster lnbSetColor [[_row, 1], _muted];
            _roster lnbSetTooltip [[_row, 0], format ["%1 · %2 · %3", _name, _uid, _sideLabel]];
        } forEach _rows;
    };

    private _visibleRows = ((count _rows) max 1) min 6;
    private _listHeight = _visibleRows * _rowHeight + _padding * 0.3;
    _roster ctrlSetPositionH _listHeight;
    _roster ctrlCommit 0;
    _frame ctrlSetPositionH (_headerHeight + _listHeight + _padding);
    _frame ctrlCommit 0;
};

private _lastDisplay = displayNull;
private _lastUnit = objNull;
private _panel = [];
private _lastData = [];
private _nextReport = 0;

while {true} do {
    private _display = findDisplay 312;
    private _unit = if (isNull _display) then {objNull} else {player};
    private _newDisplay = !(_display isEqualTo _lastDisplay);
    if (_newDisplay || {!(_unit isEqualTo _lastUnit)}) then {
        [_lastUnit, false] call _report;
        _lastUnit = _unit;
        _nextReport = 0;
        _lastData = [];
        uiNamespace setVariable ["WW2_zeusHudSnapshot", []];
    };
    if (_newDisplay) then {
        _panel = if (isNull _display) then {[]} else {[_display] call _createPanel};
        _lastDisplay = _display;
    };

    if (!isNull _display && {count _panel > 0}) then {
        if (diag_tickTime >= _nextReport) then {
            [_unit, true] call _report;
            _nextReport = diag_tickTime + 2;
        };
        private _snapshot = uiNamespace getVariable ["WW2_zeusHudSnapshot", []];
        private _fresh = (count _snapshot isEqualTo 3) && {diag_tickTime - (_snapshot select 0) <= 6};
        private _data = if (_fresh) then {[_snapshot select 1, _snapshot select 2, false]} else {[[], [], true]};
        if !(_data isEqualTo _lastData) then {
            ([_panel] + _data) call _updatePanel;
            _lastData = _data;
        };
    };
    uiSleep 0.25;
};

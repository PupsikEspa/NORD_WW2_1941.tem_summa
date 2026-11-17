params ["_type","_class"];
switch _type do {
 case "magazine": {configFile >> "CfgMagazines" >> _class};
 case "bag": {configFile >> "CfgVehicles" >> _class};
 default {
  private _weapon = configFile >> "CfgWeapons" >> _class;
  if (isClass _weapon) then {_weapon} else {configFile >> "CfgGlasses" >> _class}
 };
}

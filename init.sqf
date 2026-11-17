[] spawn {
    waitUntil { time > 0 };
    sleep 0.1;
    enableEnvironment [false, true];
};

[] execVM "ROS_hitreaction\scripts\ROS_HitReaction.sqf";

CHVD_terrain = 3.125;
CHVD_allowNoGrass = false;

//Светлая ночь
CHBN_adjustBrightness = 1;
CHBN_adjustColor = [0.5,0.7,1];


0 enableChannel [false, true];
1 enableChannel [false, true];
2 enableChannel [false, true];
4 enableChannel [false, true];
5 enableChannel [false, true];
6 enableChannel [false, true];


// Spawn limits and trophy lifecycle are tracked by the database service.

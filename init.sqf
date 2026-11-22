[] spawn {
    waitUntil { time > 0 };
    sleep 0.1;
    enableEnvironment [false, true];
};

//[] execVM "ROS_hitreaction\scripts\ROS_HitReaction.sqf";

CHVD_terrain = 3.125;
CHVD_allowNoGrass = false;

//Светлая ночь
CHBN_adjustBrightness = 1;
CHBN_adjustColor = [0.5,0.7,1];


0 enableChannel [false, false];
1 enableChannel [false, false];
2 enableChannel [false, false];
3 enableChannel [true, false];
4 enableChannel [false, false];
5 enableChannel [true, false];


// Spawn limits and trophy lifecycle are tracked by the database service.

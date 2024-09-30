Config = {}

-- Starting and ending locations for the job
Config.StartJobCoords = vector3(-1330.33, 41.93, 53.55)
Config.JobEndCoords = vector3(-1331.52, 46.81, 53.57)

-- Predefined spawn locations for the mowers
Config.MowerSpawnLocations = {
    vector4(-1324.77, 33.84, 53.0, 273.66),
    vector4(-1324.91, 36.05, 53.02, 274.32),
    vector4(-1325.13, 38.27, 53.03, 274.22),
    vector4(-1325.33, 40.6, 53.04, 273.76)
}

-- Example marker positions for mowing tasks (using vector3)
Config.Markers = {
    vector3(-1305.771, 37.722171, 52.067142),
    vector3(-1266.336, 24.457567, 47.696327),
    vector3(-1233.861, 3.4207677, 47.178039),
    vector3(-1190.987, -26.21187, 45.527519),
    vector3(-1150.049, -49.27068, 44.22813),
    vector3(-1094.568, -63.2517, 43.37461),
    vector3(-1044.869, -64.04696, 43.688831),
    vector3(-1020.42, -27.96415, 45.39941),
    vector3(-1013.658, 20.957164, 49.706546),
    vector3(-1026, 70.583412, 51.485668),
    vector3(-1063.446, 112.45425, 55.134738),
    vector3(-1102.149, 173.52229, 62.135124),
    vector3(-1146.777, 182.9634, 63.578895),
    vector3(-1203.23, 170.58279, 63.031192),
    vector3(-1284.042, 153.12579, 57.907566),
    vector3(-1312.94, 80.545883, 54.060871),
    vector3(-1284.921, 49.799503, 50.869819),
    vector3(-1216.756, 51.683658, 52.181198),
    vector3(-1153.618, 7.2381629, 48.560211),
    vector3(-1135.987, -64.83516, 43.392555),
    vector3(-1174.603, -81.56285, 44.44894),
    vector3(-1210.005, -58.36651, 44.531208),
    vector3(-1262.445, -22.08497, 47.097194),
    vector3(-1292.918, -1.389213, 49.812995),
    vector3(-1318.893, 25.843694, 53.052135),
    -- Add more markers as needed
}

-- Mower model to be used
Config.MowerModel = "mower" -- Replace this with the actual mower model name if different

-- Rewards for the job
Config.Rewards = {
    rewardPerMarker = 10, -- Amount earned per marker reached
}

Config = {}

---------------------------- Camp Configuration ------------------------------------------

--Blip Setup
Config.CampBlips = {
    enable = true, --if true thier will be a blip on the camp
    BlipName = 'My Camp', --blips name
    BlipHash = 'blip_teamsters' --blips blip hash
}

Config.CampRadius = 30 --radius you will be able to place props inside
Config.CampCommand = true --If true you will set your tent via command (do not have this and camp item enabled at the same time use one or the other)
Config.CampItem = { enabled = false, CampItem = 'water', RemoveItem = true } --if enabled is true then you will need to use the CampItem to set tent make sure the item exists in your database if removeitem is true it will remove 1 of the item from the players inventory when they set camp
Config.CommandName = 'SetTent' --name of the command to set the tent
Config.SetCampInTowns = true --If false players will be able to set camp inside of towns
Config.Cooldown = true --if enabled the cooldown will be active
Config.CooldownTime = 1800000 --time in ms before the player can set a camp again

Config.InventoryLimit = 200 --the camps storage limit

Config.SetupTime = { --time to setup each prop in ms
    TentSetuptime = 30000,
    BenchSetupTime = 15000,
    FireSetupTime = 10000,
    StorageChestTime = 8000,
    HitchingPostTime = 12000,
    FastTravelPostTime = 35000,
}

--Fast Travel Setup
Config.FastTravel = {
    enabled = true, --if true it will allow fast travel
    Locations = {
        {
            name = 'Valentine', --name that will show on the menu
            coords = {x = -206.67, y = 642.26, z = 112.72}, --coords to tp player too
        },
        {
            name = 'Black Water',
            coords = {x = -854.39, y = -1341.26, z = 43.45},
        },
    }
}

-------- Model Setup -------
Config.BedRollModel = 'p_bedrollopen01x' --hash of the bedroll
Config.Furniture = {
    Campfires = { --campfire hash
        {
            hash = 'p_campfire01x', --model of fire
        },
    },
    Benchs = {
        {
            hash = 'p_bench_log03x',
        },
    },
    HitchingPost = {
        {
            hash = 'p_hitchingpost01x',
        },
    },
    Tent = {
        {
            hash = 'p_ambtentscrub01b',
        },
        {
            hash = 'p_ambtentgrass01x',
        },
    },
    StorageChest = {
        {
            hash = 'p_chest01x',
        },
    },
}

--- Any Model Used above MUST be listed here or code will break -----
Config.PropHashes = {
    'p_ambtentscrub01b',
    'p_chest01x',
    'p_campfire01x',
    'p_bench_log03x',
    'p_hitchingpost01x',
    'mp001_s_fasttravelmarker01x',
    'p_ambtentgrass01x',
}

------------------------------- Translate Here ----------------------------------------
Config.Language = {
    --Menu Translations
    MenuName = 'Camp Menu',
    SetTent = 'Setup Camp',
    SetTent_desc = 'Pitch your camp',
    OpenCampMenu = 'Press "G" to Open The Camp Menu',
    OpenCampStorage = 'Press "G" to Open The Camps Storage',
    OpenFastTravel = 'Press G To Open The Fast Travel Menu ',
    SetFire = 'Setup Fire ',
    SetFire_desc = 'Start a Campfire ',
    SetBench = 'Setup a Bench ',
    SetBench_desc = "Setup a Bench ",
    SetStorageChest = "Setup a Storage Chest ",
    SetStorageChest_desc = 'Setup a Storage Chest ',
    SetHitchPost = 'Setup a Hitching Post ',
    SetHitchPost_desc = 'Setup a Hitching Post ',
    SetupFTravelPost = 'Setup a fast travel post ',
    SetupFTravelPost_desc = 'Setup a fast travel post ',
    DestroyCamp = 'Take Down Camp ',
    DestroyCamp_desc = 'Take Down Your Camp ',
    FTravelDisabled = 'Your Server has fast travel disbaled ',
    TpDesc = 'Teleport to ',
    FastTravelMenuName = 'Fast Travel ',
    SettingTentPbar = 'Pitching the tent! ',
    SettingBucnhPbar = 'Setting Up the Bench! ',
    FireSetup = 'Starting a campfire! ',
    StorageChestSetup = 'Placing Storage Chest! ',
    HitchingPostSetup = 'Setting up the hitching post! ',
    FastTravelPostSetup = 'Settin up the fast travel post! ',

    --Camp Setup Translations
    CantBuild = 'You can not build here!',
    InventoryName = 'Camp Storage ',
    Tooclosetotown = 'You are to close to a town',
    Cdown = 'On Cooldown',
    FurnMenu = 'Furniture Menu'
}


--------------------------------- Town Locations ------------------------------------------------------------------------------------
------------Ignore This for the most part. Unless you want to change the range of a town, or add more towns -------------------------
Config.Towns = { --creates a sub table in town table
    {
        coordinates = {x = -297.48, y = 791.1, z = 118.33}, --Valentine (the towns coords)
        range = 150, --The distance away you have to be to be considered outside of town
    },
    {
        coordinates = {x = 2930.95, y = 1348.91, z = 44.1}, --annesburg
        range = 250,
    },
    {
        coordinates = {x = 2632.52, y = -1312.31, z = 51.42}, --Saint denis
        range = 600,
    },
    {
        coordinates = {x = 1346.14, y = -1312.5, z = 76.53}, --Rhodes
        range = 200,
    },
    {
        coordinates = {x = -1801.09, y = -374.86, z = 161.15}, --strawberry
        range = 150,
    },
    {
        coordinates = {x = -801.77, y = -1336.43, z = 43.54}, --blackwater
        range = 350
    },
    {
        coordinates = {x = -3659.38, y = -2608.91, z = -14.08}, --armadillo
        range = 150,
    },
    {
        coordinates = {x = -5498.97, y = -2950.61, z = -1.62}, --Tumbleweed
        range = 100,
    }, --You can add more towns by copy and pasting one of the tables above and changing the coords and range to your liking
}
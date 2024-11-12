Config = {
    -- Set Language
    defaultlang = 'en_lang',
    ---------------------------- ox_target and ox_lib Configuration ------------------------------------------

    oxtarget = false, -- Enable or disable ox target option for camp interaction.
    oxdistance = 2.0, -- Distance for ox target to work.

    notify = 'vorp', -- ox for ox_lib notification vorp for vorp notification
    oxposition = 'center-right', -- Ox notifiation position. use 'top' or 'top-right' or 'top-left' or 'bottom' or 'bottom-right' or 'bottom-left' or 'center-right' or 'center-left'
    oxIconColor = 'white',
    oxstyle = { -- Ox Lib notification css style you can change this as you wish to match for your server theme
        backgroundImage = 'linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url("https://cdn.cs1.frontlineesport.com/yGexrZvPOfRu.jpg")', -- Adds a black overlay with a opacity on top of the image
        backgroundSize = 'cover',           -- Ensures the image covers the entire notification area
        backgroundRepeat = 'no-repeat',     -- Prevents the image from repeating
        backgroundPosition = 'center',      -- Centers the image
        color = '#FFFFFF',                  -- Off-white text color
        textAlign = 'center',               -- Align the text
        lineHeight = '1.4',
        width = 'auto',
        minWidth = '250px',
        maxWidth = '500px',
        ['.description'] = {
            fontSize = '17px',
            fontFamily = 'Georgia, Times, Serif',
        },
    },
    ---------------------------- Camp Configuration ------------------------------------------

    --Blip Setup
    CampBlips = {
        enable = true,          --if true thier will be a blip on the camp
        BlipName = 'Camp',      --blips name
        BlipHash = 'blip_teamsters' --blips blip hash
    },
    DevMode = false,
    CampRadius = 30, --radius you will be able to place props inside
    CampCommand = false, --If true you will set your tent via command (do not have this and camp item enabled at the same time use one or the other)
    CampItem = {
        enabled = true,
        CampItem = 'tent',
        RemoveItem = true,
	GiveBack = true,	-- Give back tent-item after remove camp
    }, --if enabled is true then you will need to use the CampItem to set tent make sure the item exists in your database if removeitem is true it will remove 1 of the item from the players inventory when they set camp

    -- Discord Webhooks
    discordLog = false, -- Enable disable discord logs
    WebhookLink = '', --insert your webhook link here if you want webhooks
    WebhookTitle = '',
    WebhookAvatar = '',
    
    -- Enable or disable ox logging DO NOT TOUCH THIS IF YOU DON'T KNOW WHAT YOU DOING (You can use this for Loki, Datadog, FiveManage, Gray Log. Refer the ox_lib documentation)
    oxLogger = false,

    CommandName = 'SetTent', --name of the command to set the tent
    SetCampInTowns = true, --If false players will be able to set camp inside of towns
    Cooldown = false,     --if enabled the cooldown will be active
    CooldownTime = 1800000, --time in ms before the player can set a camp again

    InventoryLimit = 200, --the camps storage limit

    SetupTime = {        --time to setup each prop in ms
		TentSetuptime = 30000,
		BenchSetupTime = 15000,
		FireSetupTime = 10000,
		StorageChestTime = 8000,
		HitchingPostTime = 12000,
		FastTravelPostTime = 35000,
    },
    MinDistanceFromTent = 150,
    --Fast Travel Setup
    FastTravel = {
        enabled = false, --if true it will allow fast travel
        Locations = {
            {
                name = 'Valentine',                         --name that will show on the menu
                coords = { x = -206.67, y = 642.26, z = 112.72 }, --coords to tp player too
            },
            {
                name = 'Black Water',
                coords = { x = -854.39, y = -1341.26, z = 43.45 },
            },
        }
    },

    -------- Model Setup -------
    BedRollModel = 'p_bedrollopen01x', --hash of the bedroll
    Furniture = {
        Campfires = {                --campfire hash
            {
                hash = 'p_campfire01x', --model of fire
                name = 'Large Campfire', -- Name for Menu
            },
            {
                hash = 'p_campfire05x',
                name = 'Small Campfire',
            },
        },
        Benchs = {
            {
                hash = 'p_bench_log03x',
                name = 'Log Bench',
            },
            {
                hash = 'p_ambchair02x',
                name = 'Small Camp Chair',
            },
        },
        HitchingPost = {
            {
                hash = 'p_hitchingpost01x',
                name = 'Double Hitching Post',
            },
        },
        Tent = {
            {
                hash = 'p_gangtentlemoyne01x',
                name = 'Small Tent',
            },
            {
                hash = 'p_tent0101x',
                name = 'Larg Tent',
            },
        },
        StorageChest = {
            {
                hash = 'p_chest01x',
                name = 'Storage Chest',
            },
        },
        -- FastTravelPost = {
        --     {
        --         hash = 'mp001_s_fasttravelmarker01x',
        --         name = 'Travel Post',
        --     },
        -- },
        -- If you want to create more furniture bellow is an example
        --[[Tables = {
            {
                hash = 'p_table01x',
                name = 'Wooden Table',
            },
            {
                hash = 'p_table02x',
                name = 'Metal Table',
            },
        },]]--
    },
    
    --------------------------------- Town Locations ------------------------------------------------------------------------------------
    ------------Ignore This for the most part. Unless you want to change the range of a town, or add more towns -------------------------
    Towns = {                                               --creates a sub table in town table
        {
            coordinates = { x = -297.48, y = 791.1, z = 118.33 }, --Valentine (the towns coords)
            range = 150,                                    --The distance away you have to be to be considered outside of town
        },
        {
            coordinates = { x = 2930.95, y = 1348.91, z = 44.1 }, --annesburg
            range = 250,
        },
        {
            coordinates = { x = 2632.52, y = -1312.31, z = 51.42 }, --Saint denis
            range = 600,
        },
        {
            coordinates = { x = 1346.14, y = -1312.5, z = 76.53 }, --Rhodes
            range = 200,
        },
        {
            coordinates = { x = -1801.09, y = -374.86, z = 161.15 }, --strawberry
            range = 150,
        },
        {
            coordinates = { x = -801.77, y = -1336.43, z = 43.54 }, --blackwater
            range = 350
        },
        {
            coordinates = { x = -3659.38, y = -2608.91, z = -14.08 }, --armadillo
            range = 150,
        },
        {
            coordinates = { x = -5498.97, y = -2950.61, z = -1.62 }, --Tumbleweed
            range = 100,
        },                                                     --You can add more towns by copy and pasting one of the tables above and changing the coords and range to your liking
    },
}

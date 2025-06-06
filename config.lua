Config = {
    -- Set Language
    defaultlang = 'en_lang',

    ---------------------------- ox_target and ox_lib Configuration ------------------------------------------

    oxtarget = true, -- Enable or disable ox target option for camp interaction.
    oxdistance = 2.0, -- Distance for ox target to work.

    notify = 'ox', -- ox for ox_lib notification vorp for vorp notification
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
        enable = true,              --if true thier will be a blip on the camp
        BlipName = 'Camp',          --blips name
        BlipHash = 'blip_teamsters' --blips blip hash
    },
    DevMode = false,
    CampRadius = 75,     --radius you will be able to place props inside
    CampCommand = false, --If true you will set your tent via command (do not have this and camp item enabled at the same time use one or the other)
    CampItem = {
        enabled = true,
        CampItem = 'tent',
        RemoveItem = true,
        GiveBack = true, -- Give back tent-item after remove camp
    },                   --if enabled is true then you will need to use the CampItem to set tent make sure the item exists in your database if removeitem is true it will remove 1 of the item from the players inventory when they set camp
    UpkeepItemsMax = 25,
    CampUpkeepItems = {
        { dbname = 'BigLeather',   label = 'Big Leather', percent = 1 },
        { dbname = 'SmallLeather', label = 'Small Leather', percent = 1 },
        { dbname = 'Nails',        label = 'Nails', percent = 2 },
        { dbname = 'Rope',         label = 'Rope' , percent = 2},
        { dbname = 'Wood',         label = 'Wood' , percent = 1},
        { dbname = 'Coal',         label = 'Coal', percent = 1 }
    },

    collectTaxes = true,
    -- Tax Day for checking the ledger and collect
    TaxDay = 1,      --This is the number day of each month that taxes will be collected on
    TaxResetDay = 2, --This MUST be the day after TaxDay set above!!! (do not change either of these dates if the current date is one of the 2 for ex if its the 22 or 23rd day do not change these dates it will break the code)
    TaxRepoCondition = 1, -- The Percent the condition must be above on tax day to avoid repo
    ReduceCondition = 25, -- How much percent the condition goes down every ReduceConditionTime
    ReduceConditionTime = 167, -- Every X amount of hours the condition will reduce by ReduceCondition


    -- Discord Webhooks
    discordLog = false, -- Enable disable discord logs
    WebhookLink = '', --insert your webhook link here if you want webhooks
    WebhookTitle = 'BCC-Camp',
    WebhookAvatar = '',

    -- Enable or disable ox logging DO NOT TOUCH THIS IF YOU DON'T KNOW WHAT YOU DOING (You can use this for Loki, Datadog, FiveManage, Gray Log. Refer the ox_lib documentation)
    oxLogger = true,

    CommandName = 'SetTent', --name of the command to set the tent
    SetCampInTowns = true,   --If false players will be able to set camp inside of towns
    Cooldown = false,         --if enabled the cooldown will be active
    CooldownTime = 300000,   --time in ms before the player can set a camp again

    InventoryLimit = 200,    --the camps storage limit

    SetupTime = {            --time to setup each prop in ms
        CampSetupTime = 10000, --time to setup the camp
        TentSetuptime = 10000,
        BenchSetupTime = 10000,
        FireSetupTime = 10000,
        StorageChestTime = 10000,
        HitchingPostTime = 10000,
        FastTravelPostTime = 10000,
    },
    MinDistanceFromTent = 150,
    --Fast Travel Setup
    FastTravel = {
        enabled = false, --if true it will allow fast travel
        Locations = {
            {
                name = 'Valentine',                               --name that will show on the menu
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
        Utilities = {
            Campfires = {                    --campfire hash
                {
                    hash = 'p_campfire01x',  --model of fire
                    name = 'Large Campfire', -- Name for Menu
                    category = 'prop',
                    price = 5
                },
                {
                    hash = 'p_campfire05x',
                    name = 'Small Campfire',
                    category = 'prop',
                    price = 3
                },
                {
                    hash = 'p_campfirecombined03x',
                    name = 'StewPot',
                    category = 'prop',
                    price = 15
                },
            },
            HitchingPost = {
                {
                    hash = 'p_hitchingpost01x',
                    name = 'Double Hitching Post',
                    category = 'prop',
                    price = 7.50
                }
            },
            StorageChest = {
                {
                    hash = 's_lootablemiscchest_wagon',
                    name = 'Medium Storage Chest',
                    category = 'prop',
                    price = 40
                },
                {
                    hash = 's_lootablebigbluechest03x',
                    name = 'Large Storeage Chest',
                    category = 'prop',
                    price = 60
                },
            },
            Washing = {
                {
                    hash = -1315817616,
                    name = 'Water Barrel',
                    category = 'prop',
                    price = 8
                },
                {
                    hash = -40350080,
                    name = 'Water Pump',
                    category = 'prop',
                    price = 20
                },
                {
                    hash = -587276111,
                    name = 'Wash Tub',
                    category = 'prop',
                    price = 4
                }
            },
        },
        Furniture = {
            Benchs = {
                {
                    hash = 'p_bench_log03x',
                    name = 'Log Bench',
                    category = 'prop',
                    price = 2

                },
                {
                    hash = 'p_ambchair02x',
                    name = 'Small Camp Chair',
                    category = 'prop',
                    price = 2

                },
                {
                    hash = 964931263,
                    name = 'Cloth Bench',
                    category = 'prop',
                    price = 4

                },
                {
                    hash = 1057555344,
                    name = 'Wooden Bench',
                    category = 'prop',
                    price = 3.50

                },
            },
            Tables = {
                {
                    hash = 85453683,
                    name = 'Table',
                    category = 'prop',
                    price = 6
                },
            },
            Chairs = {
                {
                    hash = 325252933,
                    name = 'Simple Wooden Chair',
                    category = 'prop',
                    price = 2
                },
            },
            Tent = {
                {
                    hash = 'p_ambtentscrub01b',
                    name = 'Small Basic Tent',
                    category = 'prop',
                    price = 12
                },
                {
                    hash = 'p_ambtentgrass01x',
                    name = 'Medium Basic Tent',
                    category = 'prop',
                    price = 18

                },
                {
                    hash = 'mp005_s_posse_tent_trader07x',
                    name = 'Trader Tent',
                    category = 'prop',
                    price = 25

                },
                {
                    hash = 'mp005_s_posse_tent_bountyhunter04x',
                    name = 'Simple Tent',
                    category = 'prop',
                    price = 25
                },
                {
                    hash = 'p_mptenttanner01x',
                    name = 'Canvas Shade',
                    category = 'prop',
                    price = 8
                },
                {
                    hash = 'mp005_s_posse_tent_bountyhunter07x',
                    name = 'Bounty Hunter Tent',
                    category = 'prop',
                    price = 35
                },

            },
            LightsandLamps = {
                {
                    hash = 'p_torchpostalwayson01x',
                    name = 'Standing Torch',
                    category = 'prop',
                    price = 4
                },
                {
                    hash = 319326044,
                    name = 'Lantern',
                    category = 'prop',
                    price = 3
                },
                {
                    hash = 526843578,
                    name = 'Candle',
                    category = 'prop',
                    price = 0.50
                },
                {
                    hash = -1012195445,
                    name = 'Bottle Candle',
                    category = 'prop',
                    price = 0.75
                },
            },

            Beds = {
                {
                    hash = 'p_ambbed01x',
                    name = 'Log Bed',
                    category = 'prop',
                    price = 12
                },
                {
                    hash = 'p_bedindian01x',
                    name = 'Native Bed',
                    category = 'prop',
                    price = 12
                },
                {
                    hash = 'p_re_bedrollopen01x',
                    name = 'Open Bedroll',
                    category = 'prop',
                    price = 7
                },
                {
                    hash = 's_craftedbed01 x',
                    name = 'Crafted Bed',
                    category = 'prop',
                    price = 15
                },
            },
        },
        Decorations = {
            Decorations = {
                                {
                    hash = 'p_skullpost02x',
                    name = 'Skull Post',
                    category = 'prop',
                    price = 5

                },
                {
                    hash = 's_confedtarget',
                    name = 'Shooting Target',
                    category = 'prop',
                    price = 2
                },
                {
                    hash = 187048082,
                    name = 'Gun Barrel',
                    category = 'prop',
                    price = 6
                },
                {
                    hash = -156060815,
                    name = 'Apple Barrel',
                    category = 'prop',
                    price = 4
                },
                {
                    hash = -589926798,
                    name = 'Food Barrel',
                    category = 'prop',
                    price = 4
                },
                {
                    hash = 86968515,
                    name = 'Apple Basket',
                    category = 'prop',
                    price = 3
                },
                {
                    hash = -462883214,
                    name = 'Tool Barrel',
                    category = 'prop',
                    price = 4
                },
            },
            Taxidermy = {
                {
                    hash = 755719297,
                    name = 'Coyote Taxidermy',
                    category = 'prop',
                    price = 7
                },
                {
                    hash = -139659644,
                    name = 'Pheasant Taxidermy',
                    category = 'prop',
                    price = 6
                },
                {
                    hash = 270188936,
                    name = 'Deer Taxidermy',
                    category = 'prop',
                    price = 8
                },
                {
                    hash = 106531847,
                    name = 'Cougar Taxidermy',
                    category = 'prop',
                    price = 10
                },
                {
                    hash = 1751914218,
                    name = 'Vulture Taxidermy',
                    category = 'prop',
                    price = 6
                },
            },
        },
    },

    --------------------------------- Town Locations ------------------------------------------------------------------------------------
    ------------Ignore This for the most part. Unless you want to change the range of a town, or add more towns -------------------------
    Towns = {                                                     --creates a sub table in town table
        {
            coordinates = { x = -297.48, y = 791.1, z = 118.33 }, --Valentine (the towns coords)
            range = 150,                                          --The distance away you have to be to be considered outside of town
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
        },                                                           --You can add more towns by copy and pasting one of the tables above and changing the coords and range to your liking
    },
}

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
        CampItem = 'flag',
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

    collectTaxes = false,
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
    oxLogger = false,

    CommandName = 'SetTent', --name of the command to set the tent
    SetCampInTowns = true,   --If false players will be able to set camp inside of towns
    Cooldown = true,         --if enabled the cooldown will be active
    CooldownTime = 300000,   --time in ms before the player can set a camp again

    InventoryLimit = 200,    --the camps storage limit

    SetupTime = {            --time to setup each prop in ms
        CampSetupTime = 30000, 
        TentSetuptime = 30000,
        BenchSetupTime = 15000,
        FireSetupTime = 10000,
        StorageChestTime = 8000,
        HitchingPostTime = 12000,
        FastTravelPostTime = 35000,
    },
    MinDistanceFromTent = 125,
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
        FastTravelPost = {
            {
                hash = 'mp001_s_fasttravelmarker01x',
                name = 'Travel Post',
                category = 'prop',
                price = 25

            },
        },
        Utilities = {

            Campfires = {                    --campfire hash
                {
                    hash = 'p_campfire01x',  --model of fire
                    name = 'Large Campfire', -- Name for Menu
                    category = 'prop',
                    price = 12

                },
                {
                    hash = 'p_campfire05x',
                    name = 'Small Campfire',
                    category = 'prop',
                    price = 10

                },
                {
                    hash = 'p_campfirecombined03x',
                    name = 'StewPot',
                    category = 'prop',
                    price = 35

                },
                {
                    hash = -38096933,
                    name = 'Crafting Campfire',
                    category = 'prop',
                    price = 9

                },
            },
            HitchingPost = {
                {
                    hash = 'p_hitchingpost01x',
                    name = 'Double Hitching Post',
                    category = 'prop',
                    price = 10
                },
                --[[{
                    hash = 'pg_mp_possecamp_tent_collector07x',
                    name = "Horse Hitches Set",
                    category = 'set'

                },]]
                {
                    hash = 'p_hitchingpost01x',
                    name = "Hitching Post",
                    category = 'prop',
                    price = 10

                }
            },
            StorageChest = {
                {
                    hash = 's_lootablebedchest',
                    name = 'Storage Chest 1',
                    category = 'prop',
                    price = 300
                },
                {
                    hash = 's_lootablemiscchest_wagon',
                    name = 'Storage Chest 2',
                    category = 'prop',
                    price = 300
                },
                {
                    hash = 's_lootablebigbluechest03x',
                    name = 'Storage Chest 3',
                    category = 'prop',
                    price = 300
                },
            },
            Washing = {
                {
                    hash = -1315817616,
                    name = 'Water Barrel',
                    category = 'prop',
                    price = 25

                },
                {
                    hash = -40350080,
                    name = 'Water Pump',
                    category = 'prop',
                    price = 100

                },
                {
                    hash = -587276111,
                    name = 'Wash Tub',
                    category = 'prop',
                    price = 15

                }
            },
        },
        Furniture = {
            Benchs = {
                {
                    hash = 'p_bench_log03x',
                    name = 'Log Bench',
                    category = 'prop',
                    price = 15

                },
                {
                    hash = 'p_ambchair02x',
                    name = 'Small Camp Chair',
                    category = 'prop',
                    price = 15

                },
                {
                    hash = -191845882,
                    name = 'Bear Bench',
                    category = 'prop',
                    price = 20

                },
                {
                    hash = -359794697,
                    name = 'Log Bench 1',
                    category = 'prop',
                    price = 15

                },
                {
                    hash = 861210780,
                    name = 'Log Bench 2',
                    category = 'prop',
                    price = 15

                },
                {
                    hash = 964931263,
                    name = 'Cloth Bench',
                    category = 'prop',
                    price = 15

                },
                {
                    hash = 1057555344,
                    name = 'Wooden Bench',
                    category = 'prop',
                    price = 15

                },
                {
                    hash = 1220939063,
                    name = 'Wicker Bench',
                    category = 'prop',
                    price = 20

                },
            },
            Tables = {
                {
                    hash = 1070917324,
                    name = 'Round Table',
                    category = 'prop',
                    price = 12
                },
                {
                    hash = 85453683,
                    name = 'Table',
                    category = 'prop',
                    price = 12
                },
                {
                    hash = 1287780262,
                    name = 'Rectangle Table',
                category = 'prop',
                price = 12
                },
                {
                    hash = -154796631,
                    name = 'Nightstand',
                    category = 'prop',
                    price = 8

                },
                {
                    hash = 335118833,
                    name = 'Side Table 1',
                    category = 'prop',
                    price = 10

                },
                {
                    hash = -96741014,
                    name = 'Side Table 2',
                    category = 'prop',
                    price = 10

                },
                {
                    hash = 341544623,
                    name = 'Side Table 3',
                    category = 'prop',
                    price = 10

                },
            },
            Chairs = {
                {
                    hash = 'p_settee01x',
                    name = 'Lounge Chair 1',
                    category = 'prop',
                    price = 12
                },
                {
                    hash = 'p_settee_05x',
                    name = 'Lounge Chair 2',
                    category = 'prop',
                    price = 15
                },
                {
                    hash = 325252933,
                    name = 'Wood Chair 1',
                    category = 'prop',
                    price = 8
                },
                {
                    hash = 805425957,
                    name = 'Leather Chair 1',
                    category = 'prop',
                    price = 10
                },
            },
            Tent = {
                {
                    hash = 'p_ambtentscrub01b',
                    name = 'Small Tent',
                    category = 'prop',
                    price = 25
                },
                {
                    hash = 'p_ambtentgrass01x',
                    name = 'Medium Tent',
                    category = 'prop',
                    price = 25

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
                    price = 20
                },
                --[[{
                    hash = 'pg_mp_possecamp_tent_bounty07x',
                    name = 'Decor Tent 1 Set',
                    category = 'set'

                },
                {
                    hash = 'pg_mp_possecamp_tent_trader07x',
                    name = 'Decor Tent 2 Set',
                    category = 'set'

                },
                {
                    hash = 'pg_mp_possecamp_tent_collector07x',
                    name = 'Decor Tent 3 Set',
                    category = 'set'
                },]]
                {
                    hash = 'mp005_s_posse_tent_bountyhunter07x',
                    name = 'Bounty Hunter Tent',
                    category = 'prop',
                    price = 25
                },

            },
            LightsandLamps = {
                --[[{
                    hash = 'pg_ambient_camp_add_gamepole01',
                    name = 'Lamp Post 1 Set',
                    category = 'set'

                },
                {
                    hash = 'pg_ambient_camp_add_lamppost01',
                    name = 'Lamp Post 2 Set',
                    category = 'set'

                },]]
                {
                    hash = 'p_torchpostalwayson01x',
                    name = 'Standing Torch',
                    category = 'prop',
                    price = 8
                },
                {
                    hash = 319326044,
                    name = 'Lantern',
                    category = 'prop',
                    price = 8

                },
                {
                    hash = 1443543434,
                    name = 'Double Candle',
                    category = 'prop',
                    price = 4

                },
                {
                    hash = 526843578,
                    name = 'Candle',
                    category = 'prop',
                    price = 4

                },
                {
                    hash = -1200234060,
                    name = 'Small Melted Candle',
                    category = 'prop',
                    price = 4

                },
                {
                    hash = -1012195445,
                    name = 'Bottle Candle',
                    category = 'prop',
                    price = 4

                },
            },

            Beds = {
                {
                    hash = -335869017,
                    name = 'Old Bed',
                    category = 'prop',
                    price = 25

                },
                {
                    hash = -661790979,
                    name = 'Bunk Bed',
                    category = 'prop',
                    price = 25

                },
                {
                    hash = 1190865994,
                    name = 'Single Bed',
                    category = 'prop',
                    price = 25

                },
                {
                    hash = 204817984,
                    name = 'Fancy Bed',
                    category = 'prop',
                    price = 25
                },
            },
        },
        Sets = {
            ButcherTables = {
                {
                    hash = 'mp005_s_posse_goods03x',
                    name = 'Large Butcher Setup',
                    category = 'prop',
                    price = 50
                },
                {
                    hash = 'mp005_s_posse_goods02bx',
                    name = 'Medium Butcher Setup',
                    category = 'prop',
                    price = 50
                },
                {
                    hash = 'mp005_s_posse_goods01x',
                    name = 'Small Butcher Setup',
                    category = 'prop',
                    price = 50
                },
            },
        },
        Decorations = {
            Decorations = {
                --[[{
                    hash = 'PG_COMPANIONACTIVITY_ROBBERY',
                    name = "Robbery Planning Set",
                    category = 'set'

                },]]
                {
                    hash = 'p_kitchenhutch01x',
                    name = "Kitchen Counter",
                    category = 'prop',
                    price = 10
                },
                {
                    hash = 'p_skullpost02x',
                    name = 'Skull Post',
                    category = 'prop',
                    price = 8

                },
                {
                    hash = 's_loansharkundertaker01x',
                    name = 'Coffin',
                    category = 'prop',
                    price = 10
                },
                {
                    hash = 'mp004_s_mp_coffindecor01x',
                    name = 'Flower Coffin',
                    category = 'prop',
                    price = 15
                },
                {
                    hash = 's_confedtarget',
                    name = 'Shooting Target',
                    category = 'prop',
                    price = 5
                },
                {
                    hash = 'p_group_man01x_longtable',
                    name = 'Serving Table',
                    category = 'prop',
                    price = 10
                },
                {
                    hash = 'P_bottlecrate02X',
                    name = 'Beer Box',
                    category = 'prop',
                    price = 15
                },
                {
                    hash = -456717314,
                    name = 'Flower Boxes',
                    category = 'prop',
                    price = 25
                },
                {
                    hash = -944201792,
                    name = 'Deer Pelt',
                    category = 'prop',
                    price = 15
                },
                {
                    hash = -1156281048,
                    name = 'Coyote Pelt',
                    category = 'prop',
                    price = 15
                },
                {
                    hash = -542120195,
                    name = 'Blanket Box',
                    category = 'prop',
                    price = 25
                },
                {
                    hash = 187048082,
                    name = 'Gun Barrel',
                    category = 'prop',
                    price = 25
                },
                {
                    hash = -156060815,
                    name = 'Apple Barrel',
                    category = 'prop',
                    price = 25
                },
                {
                    hash = -589926798,
                    name = 'Food Barrel',
                    category = 'prop',
                    price = 25
                },
                {
                    hash = 86968515,
                    name = 'Apple Basket',
                    category = 'prop',
                    price = 25
                },
                {
                    hash = -25978087,
                    name = 'Clothes Line',
                    category = 'prop',
                    price = 8
                },
                {
                    hash = -462883214,
                    name = 'Tool Barrel',
                    category = 'prop',
                    price = 25
                },
            },
            Taxidermy = {
                {
                    hash = 755719297,
                    name = 'Coyote Taxidermy',
                    category = 'prop',
                    price = 15
                },
                {
                    hash = -139659644,
                    name = 'Pheasant Taxidermy',
                    category = 'prop',
                    price = 15
                },
                {
                    hash = 270188936,
                    name = 'Deer Taxidermy',
                    category = 'prop',
                    price = 15
                },
                {
                    hash = 106531847,
                    name = 'Cougar Taxidermy',
                    category = 'prop',
                    price = 15
                },
                {
                    hash = 1751914218,
                    name = 'Vulture Taxidermy',
                    category = 'prop',
                    price = 15
                },
            },
        },
        Native = {
            NativeFurniture = {
                {
                    hash = 's_wap_rainsfalls',
                    name = 'Native Tipi',
                    category = 'prop',
                    price = 25
                },
                {
                    hash = 'p_indiandream01x',
                    name = 'Native Dreamcatcher',
                    category = 'prop',
                    price = 8
                },
                {
                    hash = 'p_potteryindian02x',
                    name = 'Native Pot',
                    category = 'prop',
                    price = 8
                },
                {
                    hash = 'p_basketindian02x',
                    name = 'Native Basket 1',
                    category = 'prop',
                    price = 8
                },
                {
                    hash = 'p_basketindian03x',
                    name = 'Native Basket 2',
                    category = 'prop',
                    price = 8
                },
                {
                    hash = 'p_spookynative02x',
                    name = 'Native Decor 1',
                    category = 'prop',
                    price = 10
                },
                {
                    hash = 'pg_ambient_camp_add_native01',
                    name = 'Native Decor 2',
                    category = 'prop',
                    price = 10
                },
            },
        },
        --[[Misc = {
            Wagons = {
                {
                    hash = 'PG_MP005_COLLECTORWAGONCAMP01',
                    name = 'Gypsys Wagon Set',
                    category = 'set'
                    
                },
                {
                    hash = 'pg_mp007_naturalist_camp01x',
                    name = 'Naturalists Wagon Set',
                    category = 'set'

                }
            },
        },]]

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
        },]] --
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

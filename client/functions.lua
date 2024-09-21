----------------------------- Essentials ------------------------------
VORPcore = exports.vorp_core:GetCore()
FeatherMenu = exports["feather-menu"].initiate()
MiniGame = exports["bcc-minigames"].initiate()
progressbar = exports["feather-progressbar"]:initiate()
BccUtils = exports['bcc-utils'].initiate()

BCCcampMenu = FeatherMenu:RegisterMenu("bcc:camp:mainmenu",
    {
        top = "5%",
        left = "5%",
        ["720width"] = "500px",
        ["1080width"] = "600px",
        ["2kwidth"] = "700px",
        ["4kwidth"] = "900px",
        style = {},
        contentslot = {
            style = {
                ["height"] = "450px",
                ["min-height"] = "250px"
            }
        },
        draggable = true
    },
    {
        opened = function()
            DisplayRadar(false)
        end,
        closed = function()
            DisplayRadar(true)
        end
    }
)
---------------------------- Functions ------------------------------------------------
if Config.DevMode then
    -- Helper function for debugging
    function devPrint(message)
        print("^1[DEV MODE] ^4" .. message)
    end
else
    -- Define devPrint as a no-op function if DevMode is not enabled
    function devPrint(message)
    end
end

--Function to load model
function modelload(model) --model = variable with the models text hash
    RequestModel(model)
    if not HasModelLoaded(model) then
      RequestModel(model)
    end
    while not HasModelLoaded(model) do
      Wait(100)
    end
end

function IsThereAnyPropInFrontOfPed(playerPed, excludeEntity)
    -- Iterate over each furniture category in Config.Furniture
    for furnType, furnItems in pairs(Config.Furniture) do
        -- Iterate over each furniture item in the category
        for _, furnitureItem in ipairs(furnItems) do
            -- Get the furniture hash from the config
            local hashKey = GetHashKey(furnitureItem.hash)

            -- Get the player's coordinates and calculate the position in front of the player
            local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.5, 0))

            -- Check for the closest object of the same hash type
            local entity = GetClosestObjectOfType(x, y, z, 2.5, hashKey, false, false, false)

            -- Exclude the preview object from being detected
            if entity ~= 0 and entity ~= excludeEntity then
                return true -- Return true if there's an object in front of the player
            end
        end
    end
    return false -- No object found in front of the player
end

--Function used to spawn props
function PropCorrection(obj) --Fixes the heading, and places on ground, obj = CreatedObject
    SetEntityHeading(obj, GetEntityHeading(PlayerPedId()))
    Citizen.InvokeNative(0x9587913B9E772D29, obj, true)
end
--Function to check how close player is too thier tent
function notneartentdistcheck(tentobj) --returns true if your too far from tent
    local x,y,z = table.unpack(GetEntityCoords(tentobj))
    local x2,y2,z2 = table.unpack(GetEntityCoords(PlayerPedId()))
    if GetDistanceBetweenCoords(x, y, z, x2, y2, z2, true) > Config.CampRadius then return true else return false end
end

--Progressbar
function progressbarfunc(time, text)
    FreezeEntityPosition(PlayerPedId(), true)
    RequestAnimDict("mini_games@story@beechers@build_floor@john")
    while not HasAnimDictLoaded("mini_games@story@beechers@build_floor@john") do
        Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), "mini_games@story@beechers@build_floor@john","hammer_loop_good", 8.0, 8.0, 100000000000000, 1, 0, true, 0, false, 0, false)
    progressbar.start(text, time, function() --sets up progress bar to run while anim is
    end, 'circle') --part of progress bar
    Wait(time) --waits until the anim / progressbar above is over
    StopAnimTask(PlayerPedId(), "mini_games@story@beechers@build_floor@john","hammer_loop_good")
    FreezeEntityPosition(PlayerPedId(), false)
end

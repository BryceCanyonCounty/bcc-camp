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

--function to see if player is near any placed objects
function IsThereAnyPropInFrontOfPed(playerPed)
    for k,v in pairs(Config.PropHashes) do
        local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.5, 0))
        local Entity = (GetClosestObjectOfType(x,y,z, 2.5, GetHashKey(v), false, false, false))
        if Entity ~= 0 then
            return true
        end
    end
    return false
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
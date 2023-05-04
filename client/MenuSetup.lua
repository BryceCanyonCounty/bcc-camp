--------------- Pulling Menu Api ----------------------------------
TriggerEvent("menuapi:getData", function(call)
    MenuData = call
end)


------------ Events for cleanup ---------------

--this is used to close the menu while you are on the main menu and hit backspace button
local inmenu = false --var used to see if you are in the main menu or not
RegisterNetEvent('bcc-camp:MenuClose')
AddEventHandler('bcc-camp:MenuClose', function()
    while true do --loops will run permantely
        Citizen.Wait(10) --waits 10ms prevents crashing
        if IsControlJustReleased(0, 0x156F7119) then --if backspace is pressed then
            if inmenu then --if var is true then
                inmenu = false --resets var
                MenuData.CloseAll() --closes all menus
            end
        end
    end
end)


---------------------- Main Camp Menu Setup -----------------------------------

function MainTentmenu() --when triggered will open the main menu
    inmenu = true --changes var to true allowing the press of backspace to close the menu
    TriggerEvent('bcc-camp:MenuClose') --triggers the event
    MenuData.CloseAll() --closes all menus
    local elements = { --sets the main 3 elements up
        { label = Config.Language.SetTent, value = 'settent', desc = Config.Language.SetTent_desc }
    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi', --opens the menu
        {
            title = Config.Language.MenuName, --sets the title
            align = 'top-left', --aligns it too left side of screen
            elements = elements, --sets the elemnts
        },
        function(data) --creates a function with data as a var
            if data.current == "backup" then
                _G[data.trigger]()
            end
            if data.current.value == 'settent' then --if option clicked is this then
                MenuData.CloseAll()
                if Config.CampItem.enabled then
                    TriggerServerEvent('bcc-camp:RemoveCampItem')
                end
                spawnTent()
            end
        end)
end

function MainCampmenu() --when triggered will open the main menu
    inmenu = true --changes var to true allowing the press of backspace to close the menu
    TriggerEvent('bcc-camp:MenuClose') --triggers the event
    MenuData.CloseAll() --closes all menus
    local elements = { --sets the main 3 elements up
        { label = Config.Language.DestroyCamp, value = 'destroycamp', desc = Config.Language.DestroyCamp_desc },
        { label = Config.Language.SetFire, value = 'setcfire', desc = Config.Language.SetFire_desc },
        { label = Config.Language.SetBench, value = 'setcbench', desc = Config.Language.SetBench_desc },
        { label = Config.Language.SetStorageChest, value = 'setcstoragechest', desc = Config.Language.SetStorageChest_desc },
        { label = Config.Language.SetHitchPost, value = 'setchitchingpost', desc = Config.Language.SetHitchPost_desc },
        { label = Config.Language.SetupFTravelPost, value = 'setcftravelpost', desc = Config.Language.SetupFTravelPost_desc },
    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi', --opens the menu
        {
            title = Config.Language.MenuName, --sets the title
            align = 'top-left', --aligns it too left side of screen
            elements = elements, --sets the elemnts
        },
        function(data) --creates a function with data as a var
            if data.current == "backup" then
                _G[data.trigger]()
            end
            if data.current.value == 'destroycamp' then
                MenuData.CloseAll()
                delcamp()
            elseif data.current.value == 'setcfire' then --if option clicked is this then
                MenuData.CloseAll()
                spawnCampFire()
            elseif data.current.value == 'setcbench' then
                MenuData.CloseAll()
                spawnLogBench()
            elseif data.current.value == 'setcstoragechest' then
                MenuData.CloseAll()
                spawnStorageChest()
            elseif data.current.value == 'setchitchingpost' then
                MenuData.CloseAll()
                spawnHitchingPost()
            elseif data.current.value == 'setcftravelpost' then
                MenuData.CloseAll()
                if Config.FastTravel.enabled then
                    spawnFastTravelPost()
                else
                    VORPcore.NotifyRightTip(Config.Language.FTravelDisabled, 4000)
                end
            end
        end)
end

function Tpmenu() --when triggered will open the main menu
    inmenu = true --changes var to true allowing the press of backspace to close the menu
    TriggerEvent('bcc-camp:MenuClose') --triggers the event
    MenuData.CloseAll() --closes all menus
    local elements = {} --sets the var to a table
    local elementindex = 1 --sets the var too 1
    Citizen.Wait(100) --waits 100ms
    for k, v in pairs(Config.FastTravel.Locations) do --opens a for loop
        elements[elementindex] = { --sets the elemnents to this table
            label = v.name,
            value = 'tp' .. tostring(elementindex), --sets the value
            desc = Config.Language.TpDesc .. v.name, --empty desc
            info = v.coords
        }
        elementindex = elementindex + 1 --adds 1 to the var
    end
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi', {
        title = Config.Language.FastTravelMenuName,
        align = 'top-left',
        elements = elements,
        lastmenu = "MainMenu"
    },
        function(data)
            if (data.current == "backup") then
                _G[data.trigger]()
            else
                MenuData.CloseAll()
                local coords = data.current.info
                SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
            end
        end)
end
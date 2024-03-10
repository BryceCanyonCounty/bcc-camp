--------------- Pulling Menu Api ----------------------------------
TriggerEvent("menuapi:getData", function(call)
    MenuData = call
end)


------------ Events for cleanup ---------------

--this is used to close the menu while you are on the main menu and hit backspace button
local inmenu = false
AddEventHandler('bcc-camp:MenuClose', function()
    while true do --loops will run permantely
        Wait(10) --waits 10ms prevents crashing
        if IsControlJustReleased(0, 0x156F7119) then --if backspace is pressed then
            if inmenu then --if var is true then
                inmenu = false --resets var
                MenuData.CloseAll() --closes all menus
            end
        end
    end
end)


---------------------- Main Camp Menu Setup -----------------------------------
local cdown = false
function MainTentmenu() --when triggered will open the main menu
    inmenu = true --changes var to true allowing the press of backspace to close the menu
    TriggerEvent('bcc-camp:MenuClose') --triggers the event
    MenuData.CloseAll() --closes all menus
    local elements = { --sets the main 3 elements up
        { label = _U('SetTent'), value = 'settent', desc = _U('SetTent_desc') }
    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi', --opens the menu
        {
            title = _U('MenuName'), --sets the title
            align = 'top-left', --aligns it too left side of screen
            elements = elements, --sets the elemnts
        },
        function(data) --creates a function with data as a var
            if data.current == "backup" then
                _G[data.trigger]()
            end
            if data.current.value == 'settent' then --if option clicked is this then
                MenuData.CloseAll()
                if Config.Cooldown then
                    if not cdown then
                        if Config.CampItem.enabled then
                            TriggerServerEvent('bcc-camp:RemoveCampItem')
                        end
                        cdown = true
                        FurnMenu('tent')
                    else
                        VORPcore.NotifyRightTip(_U('Cdown'), 4000)
                    end
                else
                    if Config.CampItem.enabled then
                        TriggerServerEvent('bcc-camp:RemoveCampItem')
                    end
                    FurnMenu('tent')
                end
            end
        end)
end

function MainCampmenu() --when triggered will open the main menu
    inmenu = true --changes var to true allowing the press of backspace to close the menu
    TriggerEvent('bcc-camp:MenuClose') --triggers the event
    MenuData.CloseAll() --closes all menus
    local elements = { --sets the main 3 elements up
        { label = _U('DestroyCamp'), value = 'destroycamp', desc = _U('DestroyCamp_desc') },
        { label = _U('SetFire'), value = 'setcfire', desc = _U('SetFire_desc') },
        { label = _U('SetBench'), value = 'setcbench', desc = _U('SetBench_desc') },
        { label = _U('SetStorageChest'), value = 'setcstoragechest', desc = _U('SetStorageChest_desc') },
        { label = _U('SetHitchPost'), value = 'setchitchingpost', desc = _U('SetHitchPost_desc') },
        { label = _U('SetupFTravelPost'), value = 'setcftravelpost', desc = _U('SetupFTravelPost_desc') },
    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi', --opens the menu
        {
            title = _U('MenuName'), --sets the title
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
                FurnMenu('campfire')
            elseif data.current.value == 'setcbench' then
                MenuData.CloseAll()
                FurnMenu('bench')
            elseif data.current.value == 'setcstoragechest' then
                MenuData.CloseAll()
                FurnMenu('storagechest')
            elseif data.current.value == 'setchitchingpost' then
                MenuData.CloseAll()
                FurnMenu('hitchingpost')
            elseif data.current.value == 'setcftravelpost' then
                MenuData.CloseAll()
                if Config.FastTravel.enabled then
                    spawnFastTravelPost()
                else
                    VORPcore.NotifyRightTip(_U('FTravelDisabled'), 4000)
                end
            end
        end)
end

function Tpmenu() --when triggered will open the main menu
    inmenu = true --changes var to true allowing the press of backspace to close the menu
    TriggerEvent('bcc-camp:MenuClose') --triggers the event
    MenuData.CloseAll() --closes all menus
    local elements, elementindex = {}, 1
    Wait(100) --waits 100ms
    for k, v in pairs(Config.FastTravel.Locations) do --opens a for loop
        elements[elementindex] = { --sets the elemnents to this table
            label = v.name,
            value = 'tp' .. tostring(elementindex), --sets the value
            desc = _U('TpDesc') .. v.name, --empty desc
            info = v.coords
        }
        elementindex = elementindex + 1 --adds 1 to the var
    end
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi', {
        title = _U('FastTravelMenuName'),
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

-- Furniture Menu Setup
function FurnMenu(furntype)
    local elements = {}
    local elementindex = 1
    local lastmen
    if furntype == 'tent' then
        for k, v in pairs(Config.Furniture.Tent) do
            elements[elementindex] = {
                label = v.name,
                value = 'settent' .. tostring(elementindex),
                desc = _U('SetTent_desc'),
                info = v.hash
            }
            elementindex = elementindex + 1
        end
    elseif furntype == 'bench' then
        for k, v in pairs(Config.Furniture.Benchs) do
            elements[elementindex] = {
                label = v.name,
                value = 'settent' .. tostring(elementindex),
                desc = _U('SetBench_desc'),
                info = v.hash
            }
            elementindex = elementindex + 1
        end
    elseif furntype == 'hitchingpost' then
        for k, v in pairs(Config.Furniture.HitchingPost) do
            elements[elementindex] = {
                label = v.name,
                value = 'settent' .. tostring(elementindex),
                desc = _U('SetHitchPost_desc'),
                info = v.hash
            }
            elementindex = elementindex + 1
        end
    elseif furntype == 'campfire' then
        for k, v in pairs(Config.Furniture.Campfires) do
            elements[elementindex] = {
                label = v.name,
                value = 'settent' .. tostring(elementindex),
                desc = _U('SetFire_desc'),
                info = v.hash
            }
            elementindex = elementindex + 1
        end
    elseif furntype == 'storagechest' then
        for k, v in pairs(Config.Furniture.StorageChest) do
            elements[elementindex] = {
                label = v.name,
                value = 'settent' .. tostring(elementindex),
                desc = _U('SetStorageChest_desc'),
                info = v.hash
            }
            elementindex = elementindex + 1
        end
    end
    if furntype == 'tent' then
        lastmen = 'MainTentmenu'
    else
        lastmen = 'MainCampmenu'
    end
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi', {
        title = _U('FurnMenu'),
        align = 'top-left',
        elements = elements,
        lastmenu = lastmen
    },
        function(data)
            if (data.current == "backup") then
                _G[data.trigger]()
            else
                MenuData.CloseAll()
                local model = data.current.info
                if furntype == 'tent' then
                    spawnTent(model)
                elseif furntype == 'bench' then
                    spawnItem('bench', model)
                elseif furntype == 'hitchingpost' then
                    spawnItem('hitchingpost', model)
                elseif furntype == 'campfire' then
                    spawnItem('campfire', model)
                elseif furntype == 'storagechest' then
                    spawnStorageChest(model)
                end
            end
        end)
end
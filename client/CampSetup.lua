--------------------- Variables Used ----------------------------------
local tentcreated, benchcreated, campfirecreated, storagechestcreated, hitchpostcreated, fasttravelpostcreated = false, false, false, false, false, false
local hitchpost, tent, bench, campfire, storagechest, fasttravelpost, broll, blip, outoftown

devPrint("Variables initialized") -- Dev print

------- Event To Register Inv After Char Selection ------
RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function(charid)
    devPrint("Character selected with charid: " .. tostring(charid)) -- Dev print
    Wait(7000)
    TriggerServerEvent('bcc-camp:CampInvCreation', charid)
end)

---------------------- Prop Spawning -----------------------------------
function spawnTent(model)
    devPrint("spawnTent called with model: " .. tostring(model)) -- Dev print
    local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId())
    local PromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local OpenCampPrompt = PromptGroup:RegisterPrompt(_U('manageCamp'), BccUtils.Keys["G"], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    
    if infrontofplayer or tentcreated then
        VORPcore.NotifyRightTip(_U('CantBuild'), 4000)
        devPrint("Cannot build tent, prop in front or tent already created") -- Dev print
    else
        progressbarfunc(Config.SetupTime.TentSetuptime, _U('SettingTentPbar'))
        local model2 = 'p_bedrollopen01x'
        modelload(model)
        modelload(model2)
        -- Tent Spawn
        local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0))
        tent = CreateObject(model, x, y, z, true, true, false)
        PropCorrection(tent)
        tentcreated = true
        broll = CreateObject(model2, x, y, z, true, true, false)
        PropCorrection(broll)
        SetEntityHeading(broll, GetEntityHeading(broll) + 90)
        devPrint("Tent and bedroll created at coordinates: " .. x .. ", " .. y .. ", " .. z) -- Dev print

        if Config.CampBlips.enable then
            blip = BccUtils.Blips:SetBlip(Config.CampBlips.BlipName, Config.CampBlips.BlipHash, 0.2, x, y, z)
            devPrint("Blip created for tent") -- Dev print
        end

        while DoesEntityExist(tent) do
            Wait(5)
            local x2, y2, z2 = table.unpack(GetEntityCoords(PlayerPedId()))
            local dist = GetDistanceBetweenCoords(x, y, z, x2, y2, z2, true)
            if dist < 2 then
                PromptGroup:ShowGroup(_U('camp'))
                if OpenCampPrompt:HasCompleted() then
                    devPrint("OpenCampPrompt triggered, opening MainCampmenu") -- Dev print
                    MainCampmenu()
                end
            elseif dist > 200 then
                Wait(2000)
            end
        end
    end
end

function spawnItem(furntype, model)
    devPrint("spawnItem called for " .. furntype .. " with model: " .. tostring(model)) -- Dev print
    local PromptGroupItem = BccUtils.Prompts:SetupPromptGroup()
    local PlaceItemPrompt = PromptGroupItem:RegisterPrompt(_U('place') .. furntype, BccUtils.Keys["G"], 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})
    
    local placing = true
    VORPcore.NotifyRightTip(_U('MoveAroundToPlace'), 5000) -- Notify player to move around

    Citizen.CreateThread(function()
        while placing do
            Citizen.Wait(0) -- Run this loop to check placement conditions on each frame

            local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId())
            local notneartent = notneartentdistcheck(tent)
            local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0))

            PromptGroupItem:ShowGroup(_U('itemPlacement'))

            if PlaceItemPrompt:HasCompleted() then
                infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId())
                notneartent = notneartentdistcheck(tent)

                if infrontofplayer or notneartent then
                    VORPcore.NotifyRightTip(_U('cannotBuildNear'), 4000)
                    devPrint("Cannot place item, too close to tent or prop in front") -- Dev print
                else
                    placing = false -- Stop the loop when the player is in the correct location
                    modelload(model)
                    devPrint(furntype .. " model loaded, spawning item") -- Dev print

                    if furntype == 'bench' then
                        if benchcreated then
                            VORPcore.NotifyRightTip(_U('CantBuild'), 4000)
                        else
                            progressbarfunc(Config.SetupTime.BenchSetupTime, _U('SettingBucnhPbar'))
                            
                            bench = CreateObject(model, x, y, z, true, true, false)
                            benchcreated = true
                            PropCorrection(bench)
                            devPrint("Bench created at coordinates: " .. x .. ", " .. y .. ", " .. z) -- Dev print
                        end
                    elseif furntype == 'campfire' then
                        if campfirecreated then
                            VORPcore.NotifyRightTip(_U('CantBuild'), 4000)
                        else
                            progressbarfunc(Config.SetupTime.FireSetupTime, _U('FireSetup'))
                            campfire = CreateObject(model, x, y, z, true, true, false)
                            PropCorrection(campfire)
                            campfirecreated = true
                        end

                        -- Handle campfire interaction (removal)
                        while DoesEntityExist(campfire) do
                            Citizen.Wait(5)
                            local x2, y2, z2 = table.unpack(GetEntityCoords(PlayerPedId()))
                            local dist = GetDistanceBetweenCoords(x, y, z, x2, y2, z2, true)
                            if dist < 2 then
                                BccUtils.Misc.DrawText3D(x, y, z, _U('RemoveFire'))
                                if IsControlJustReleased(0, 0x156F7119) then -- Backspace to remove fire
                                    extinguishedCampfire()
                                end
                            elseif dist > 200 then
                                Citizen.Wait(2000)
                            end
                        end
                    elseif furntype == 'hitchingpost' then
                        if hitchpostcreated then
                            VORPcore.NotifyRightTip(_U('CantBuild'), 4000)
                        else
                            progressbarfunc(Config.SetupTime.HitchingPostTime, _('HitchingPostSetup'))
                            hitchpost = CreateObject(model, x, y, z, true, true, false)
                            PropCorrection(hitchpost)
                            hitchpostcreated = true
                            devPrint("Hitching post created at coordinates: " .. x .. ", " .. y .. ", " .. z) -- Dev print
                        end
                    end
                end
            end
        end
    end)
end

function spawnStorageChest(model)
    devPrint("spawnStorageChest called with model: " .. tostring(model)) -- Dev print
    local PromptGroupStorage = BccUtils.Prompts:SetupPromptGroup()
    local PlaceStorageChestPrompt = PromptGroupStorage:RegisterPrompt(_U('placeChest'), BccUtils.Keys["G"], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

    VORPcore.NotifyRightTip(_U('MoveAndPlace'), 5000)

    local placing = true
    Citizen.CreateThread(function()
        while placing do
            Citizen.Wait(0)
            local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId())
            local notneartent = notneartentdistcheck(tent)

            PromptGroupStorage:ShowGroup(_U('chestPlacement'))

            if PlaceStorageChestPrompt:HasCompleted() then
                if infrontofplayer or notneartent then
                    VORPcore.NotifyRightTip(_U('CantBuild'), 4000)
                    devPrint("Cannot place storage chest, too close to tent or prop in front") -- Dev print
                else
                    placing = false

                    progressbarfunc(Config.SetupTime.StorageChestTime, _U('StorageChestSetup'))
                    modelload(model)

                    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0))
                    storagechest = CreateObject(model, x, y, z, true, true, false)
                    PropCorrection(storagechest)
                    storagechestcreated = true
                    devPrint("Storage chest created at coordinates: " .. x .. ", " .. y .. ", " .. z) -- Dev print

                    while DoesEntityExist(storagechest) do
                        Citizen.Wait(10)
                        local x2, y2, z2 = table.unpack(GetEntityCoords(PlayerPedId()))
                        local dist = GetDistanceBetweenCoords(x, y, z, x2, y2, z2, true)

                        if dist < 2 then
                            BccUtils.Misc.DrawText3D(x, y, z - 1, _U('OpenCampStorage'))

                            if IsControlJustReleased(0, 0x760A9C6F) then
                                devPrint("Opening storage chest") -- Dev print
                                TriggerServerEvent('bcc-camp:OpenInv')
                            end
                        elseif dist > 200 then
                            Citizen.Wait(2000)
                        end
                    end
                end
            end
        end
    end)
end

function spawnFastTravelPost()
    devPrint("spawnFastTravelPost called") -- Dev print
    local PromptGroupTravel = BccUtils.Prompts:SetupPromptGroup()
    local PlaceFastTravelPrompt = PromptGroupTravel:RegisterPrompt(_U('placeTravelPost'), BccUtils.Keys["G"], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

    VORPcore.NotifyRightTip(_U('MoveAndPlace'), 5000)

    local placing = true
    Citizen.CreateThread(function()
        while placing do
            Citizen.Wait(0)
            local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId())
            local notneartent = notneartentdistcheck(tent)

            PromptGroupTravel:ShowGroup(_U('fastTravelPlace'))

            if PlaceFastTravelPrompt:HasCompleted() then
                if infrontofplayer or notneartent then
                    VORPcore.NotifyRightTip(_U('CantBuild'), 4000)
                    devPrint("Cannot place fast travel post, too close to tent or prop in front") -- Dev print
                else
                    placing = false
                    progressbarfunc(Config.SetupTime.FastTravelPostTime, _U('FastTravelPostSetup'))
                    local model = 'mp001_s_fasttravelmarker01x'
                    modelload(model)

                    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0))
                    fasttravelpost = CreateObject(model, x, y, z, true, true, false)
                    PropCorrection(fasttravelpost)
                    fasttravelpostcreated = true
                    devPrint("Fast travel post created at coordinates: " .. x .. ", " .. y .. ", " .. z) -- Dev print

                    while DoesEntityExist(fasttravelpost) do
                        Citizen.Wait(5)
                        local x2, y2, z2 = table.unpack(GetEntityCoords(PlayerPedId()))
                        local dist = GetDistanceBetweenCoords(x, y, z, x2, y2, z2, true)

                        if dist < 2 then
                            BccUtils.Misc.DrawText3D(x, y, z, _U('OpenFastTravel'))

                            if IsControlJustReleased(0, 0x760A9C6F) then
                                devPrint("Opening fast travel menu") -- Dev print
                                Tpmenu()
                            end
                        elseif dist > 200 then
                            Citizen.Wait(2000)
                        end
                    end
                end
            end
        end
    end)
end


------------------Player Left Handler--------------------
AddEventHandler('playerDropped', function()
    devPrint("Player dropped, deleting camp") -- Dev print
    delcamp()
end)

------------------- Destroy Camp Setup ------------------------------
function delcamp()
    devPrint("Deleting camp setup") -- Dev print
    if tentcreated then
        if Config.CampBlips then
            BccUtils.Blip:RemoveBlip(blip.rawblip)
            devPrint("Blip removed") -- Dev print
        end
        tentcreated = false
        DeleteObject(tent)
        DeleteObject(broll)
        devPrint("Tent and bedroll deleted") -- Dev print
    end
    if benchcreated then
        benchcreated = false
        DeleteObject(bench)
        devPrint("Bench deleted") -- Dev print
    end
    if campfirecreated then
        campfirecreated = false
        DeleteObject(campfire)
        devPrint("Campfire deleted") -- Dev print
    end
    if storagechestcreated then
        storagechestcreated = false
        DeleteObject(storagechest)
        devPrint("Storage chest deleted") -- Dev print
    end
    if hitchpostcreated then
        hitchpostcreated = false
        DeleteObject(hitchpost)
        devPrint("Hitching post deleted") -- Dev print
    end
    if fasttravelpostcreated then
        fasttravelpostcreated = false
        DeleteObject(fasttravelpost)
        devPrint("Fast travel post deleted") -- Dev print
    end
end

-- Command Setup
CreateThread(function()
    if Config.CampCommand then
        RegisterCommand(Config.CommandName, function()
            TriggerEvent('bcc-camp:NearTownCheck')
        end)
    end
end)

----------------------- Distance Check for player to town coordinates --------------------------------
RegisterNetEvent('bcc-camp:NearTownCheck')
AddEventHandler('bcc-camp:NearTownCheck', function()
    devPrint("Checking if player is near town") -- Dev print
    if not Config.SetCampInTowns then
        outoftown = true
        if Config.CampItem.enabled and Config.CampItem.RemoveItem then
            devPrint("Player out of town, removing camp item") -- Dev print
            TriggerServerEvent('bcc-camp:RemoveCampItem')
        end
    else
        local pl2 = PlayerPedId()
        for k, e in pairs(Config.Towns) do
            local pl = GetEntityCoords(pl2)
            if GetDistanceBetweenCoords(pl.x, pl.y, pl.z, e.coordinates.x, e.coordinates.y, e.coordinates.z, false) > e.range then
                outoftown = true
            else
                VORPcore.NotifyRightTip(_U('Tooclosetotown'), 4000)
                devPrint("Player too close to town") -- Dev print
                outoftown = false
                break
            end
        end
    end
    if outoftown then
        devPrint("Player is out of town, opening MainTentmenu") -- Dev print
        MainTentmenu()
    end
end)

----------------------------------- Delete camp fire -----------------------
function extinguishedCampfire()
    if campfirecreated then
        devPrint("Extinguishing campfire") -- Dev print
        local objectCoords = GetEntityCoords(campfire)
        progressbarfunc(Config.SetupTime.FireSetupTime, _U('extinguishCampfire'))
        DeleteObject(campfire)
        campfirecreated = false
    end
end

----------------------- Delete camp when resource stops -----------------------------------
AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        devPrint("Resource stopping, deleting camp") -- Dev print
        delcamp()
    end
end)

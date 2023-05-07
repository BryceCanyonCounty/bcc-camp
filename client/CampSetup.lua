--------------------- Variables Used ----------------------------------
local tentcreated, benchcreated, campfirecreated, storagechestcreated, hitchpostcreated, fasttravelpostcreated = false, false, false, false, false, false
local hitchpost, tent, bench, campfire, storagechest, fasttravelpost, broll, blip, outoftown

------- Event To Register Inv After Char Selection ------
RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function(charid)
    Wait(7000)
    TriggerServerEvent('bcc-camp:CampInvCreation', charid)
end)

---------------------- Prop Spawning -----------------------------------
function spawnTent()
    local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId())
    if infrontofplayer or tentcreated then
        VORPcore.NotifyRightTip(Config.Language.CantBuild, 4000)
    else
        progressbarfunc(Config.SetupTime.TentSetuptime, Config.Language.SettingTentPbar)
        local model = 'p_ambtentscrub01b'
        local model2 = 'p_bedrollopen01x'
        modelload(model)
        modelload(model2)
        --TentSpawn
        local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0))
        tent = CreateObject(model, x, y, z, true, true, false)
        PropCorrection(tent)
        tentcreated = true
        broll = CreateObject(model2, x,y,z, true, true, false)
        PropCorrection(broll)
        SetEntityHeading(broll, GetEntityHeading(broll) + 90) --this sets the beroll properly headed
        if Config.CampBlips.enable then
            blip = VORPutils.Blips:SetBlip(Config.CampBlips.BlipName, Config.CampBlips.BlipHash, 0.2, x, y, z)
        end
        while DoesEntityExist(tent) do
            Citizen.Wait(5)
            local x2,y2,z2 = table.unpack(GetEntityCoords(PlayerPedId()))
            local dist = GetDistanceBetweenCoords(x, y, z, x2, y2, z2, true)
            if dist < 2 then
                BccUtils.Misc.DrawText3D(x, y, z, Config.Language.OpenCampMenu)
                if IsControlJustReleased(0, 0x760A9C6F) then
                    MainCampmenu() --opens the menu
                end
            elseif dist > 200 then
                Citizen.Wait(2000)
            end
        end
    end
end

function spawnItem(furntype, model)
    local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId())
    local notneartent = notneartentdistcheck(tent)
    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0))
    if infrontofplayer or notneartent then
        VORPcore.NotifyRightTip(Config.Language.CantBuild, 4000)
    else
        modelload(model)
        if furntype == 'bench' then
            if benchcreated then
                VORPcore.NotifyRightTip(Config.Language.CantBuild, 4000)
            else
                progressbarfunc(Config.SetupTime.BenchSetupTime, Config.Language.SettingBucnhPbar)
                bench = CreateObject(model, x, y, z, true, true, false)
                benchcreated = true
                PropCorrection(bench)
            end
        elseif furntype == 'campfire' then
            if campfirecreated then
                VORPcore.NotifyRightTip(Config.Language.CantBuild, 4000)
            else
                progressbarfunc(Config.SetupTime.FireSetupTime, Config.Language.FireSetup)
                campfire = CreateObject(model, x, y, z, true, true, false)
                PropCorrection(campfire)
                campfirecreated = true
            end
        elseif furntype == 'hitchingpost' then
            if hitchpostcreated then
                VORPcore.NotifyRightTip(Config.Language.CantBuild, 4000)
            else
                progressbarfunc(Config.SetupTime.HitchingPostTime, Config.Language.HitchingPostSetup)
                hitchpost = CreateObject(model, x, y, z, true, true, false)
                PropCorrection(hitchpost)
                hitchpostcreated = true
            end
        end
    end
end


function spawnStorageChest()
    local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId())
    local notneartent = notneartentdistcheck(tent)
    if infrontofplayer or storagechestcreated or notneartent then
        VORPcore.NotifyRightTip(Config.Language.CantBuild, 4000)
    else
        progressbarfunc(Config.SetupTime.StorageChestTime, Config.Language.StorageChestSetup)
        local model = 'p_chest01x'
        modelload(model)
        local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0))
        storagechest = CreateObject(model, x, y, z, true, true, false)
        PropCorrection(storagechest)
        storagechestcreated = true
        while DoesEntityExist(storagechest) do
            Citizen.Wait(10)
            local x2,y2,z2 = table.unpack(GetEntityCoords(PlayerPedId()))
            local dist = GetDistanceBetweenCoords(x, y, z, x2, y2, z2, true)
            if dist < 2 then
                BccUtils.Misc.DrawText3D(x, y, z - 1, Config.Language.OpenCampStorage)
                if IsControlJustReleased(0, 0x760A9C6F) then
                    TriggerServerEvent('bcc-camp:OpenInv')
                end
            elseif dist > 200 then
                Citizen.Wait(2000)
            end
        end
    end
end

function spawnFastTravelPost()
    local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId())
    local notneartent = notneartentdistcheck(tent)
    if infrontofplayer or fasttravelpostcreated or notneartent then
        VORPcore.NotifyRightTip(Config.Language.CantBuild, 4000)
    else
        progressbarfunc(Config.SetupTime.FastTravelPostTime, Config.Language.FastTravelPostSetup)
        local model = 'mp001_s_fasttravelmarker01x'
        modelload(model)
        local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0))
        fasttravelpost = CreateObject(model, x, y, z, true, true, false)
        PropCorrection(fasttravelpost)
        fasttravelpostcreated = true
        while DoesEntityExist(fasttravelpost) do
            Citizen.Wait(5)
            local x2,y2,z2 = table.unpack(GetEntityCoords(PlayerPedId()))
            local dist = GetDistanceBetweenCoords(x, y, z, x2, y2, z2, true)
            if dist < 2 then
                BccUtils.Misc.DrawText3D(x, y, z, Config.Language.OpenFastTravel)
                if IsControlJustReleased(0, 0x760A9C6F) then
                    Tpmenu()
                end
            elseif dist > 200 then
                Citizen.Wait(2000)
            end
        end
    end
end



------------------Player Left Handler--------------------
--Event to detect if player leaves
AddEventHandler('playerDropped', function()
    delcamp()
end)

------------------- Destroy Camp Setup ------------------------------
function delcamp()
    if tentcreated then
        if Config.CampBlips then
            VORPutils.Blips:RemoveBlip(blip.rawblip)
        end
        tentcreated = false
        DeleteObject(tent)
        DeleteObject(broll)
    end
    if benchcreated then
        benchcreated = false
        DeleteObject(bench)
    end
    if campfirecreated then
        campfirecreated = false
        DeleteObject(campfire)
    end
    if storagechestcreated then
        storagechestcreated = false
        DeleteObject(storagechest)
    end
    if hitchpostcreated then
        hitchpostcreated = false
        DeleteObject(hitchpost)
    end
    if fasttravelpostcreated then
        fasttravelpostcreated = false
        DeleteObject(fasttravelpost)
    end
end


-- Command Setup
Citizen.CreateThread(function()
    if Config.CampCommand then
        RegisterCommand(Config.CommandName, function()
            TriggerEvent('bcc-camp:NearTownCheck')
        end)
    end
end)

----------------------- Distance Check for player to town coordinates --------------------------------
RegisterNetEvent('bcc-camp:NearTownCheck')
AddEventHandler('bcc-camp:NearTownCheck', function()
    if not Config.SetCampInTowns then
        outoftown = true
        if Config.CampItem.enabled and Config.CampItem.RemoveItem then
            TriggerServerEvent('bcc-camp:RemoveCampItem')
        end
    else
        local pl2 = PlayerPedId()
        for k, e in pairs(Config.Towns) do
            local pl = GetEntityCoords(pl2)
            if GetDistanceBetweenCoords(pl.x, pl.y, pl.z, e.coordinates.x, e.coordinates.y, e.coordinates.z, false) > e.range then
                outoftown = true
            else
                VORPcore.NotifyRightTip(Config.Language.Tooclosetotown, 4000)
                outoftown = false break
            end
        end
    end
    if outoftown then
        MainTentmenu()
    end
end)
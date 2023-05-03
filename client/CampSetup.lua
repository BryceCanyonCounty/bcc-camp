--------------------- Variables Used ----------------------------------
local tentcreated = false
local benchcreated = false
local campfirecreated = false
local storagechestcreated = false
local hitchpostcreated = false
local fasttravelpostcreated = false
local hitchpost
local tent
local bench
local campfire
local storagechest
local fasttravelpost
local broll
local blip

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
            if GetDistanceBetweenCoords(x, y, z, x2, y2, z2, true) < 2 then --if dist less than 2 then
                DrawText3D(x, y, z, Config.Language.OpenCampMenu)
                if IsControlJustReleased(0, 0x760A9C6F) then
                    MainCampmenu() --opens the menu
                end
            end
        end
    end
end

function spawnLogBench()
    local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId())
    local notneartent = notneartentdistcheck(tent)
    if infrontofplayer or benchcreated or notneartent then
        VORPcore.NotifyRightTip(Config.Language.CantBuild, 4000)
    else
        local model = 'p_bench_log03x'
        progressbarfunc(Config.SetupTime.BenchSetupTime, Config.Language.SettingBucnhPbar)
        modelload(model)
        local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0))
        bench = CreateObject(model, x, y, z, true, true, false)
        PropCorrection(bench)
        benchcreated = true
    end
end

function spawnCampFire()
    local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId())
    local notneartent = notneartentdistcheck(tent)
    if infrontofplayer or campfirecreated or notneartent then
        VORPcore.NotifyRightTip(Config.Language.CantBuild, 4000)
    else
        progressbarfunc(Config.SetupTime.FireSetupTime, Config.Language.FireSetup)
        local model = 'p_campfire01x'
        modelload(model)
        local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0))
        campfire = CreateObject(model, x, y, z, true, true, false)
        PropCorrection(campfire)
        campfirecreated = true
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
            if GetDistanceBetweenCoords(x, y, z, x2, y2, z2, true) < 2 then --if dist less than 2 then
                DrawText3D(x, y, z - 1, Config.Language.OpenCampStorage)
                if IsControlJustReleased(0, 0x760A9C6F) then
                    TriggerServerEvent('bcc-camp:OpenInv')
                end
            end
        end
    end
end

function spawnHitchingPost()
    local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId())
    local notneartent = notneartentdistcheck(tent)
    if infrontofplayer or hitchpostcreated or notneartent then
        VORPcore.NotifyRightTip(Config.Language.CantBuild, 4000)
    else
        progressbarfunc(Config.SetupTime.HitchingPostTime, Config.Language.HitchingPostSetup)
        local model = 'p_hitchingpost01x'
        modelload(model)
        local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0))
        hitchpost = CreateObject(model, x, y, z, true, true, false)
        PropCorrection(hitchpost)
        hitchpostcreated = true
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
            Citizen.Wait(10)
            local x2,y2,z2 = table.unpack(GetEntityCoords(PlayerPedId()))
            if GetDistanceBetweenCoords(x, y, z, x2, y2, z2, true) < 2 then
                DrawText3D(x, y, z, Config.Language.OpenFastTravel)
                if IsControlJustReleased(0, 0x760A9C6F) then
                    Tpmenu()
                end
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
        hitchpostcreated =false
        DeleteObject(hitchpost)
    end
    if fasttravelpostcreated then
        fasttravelpostcreated = false
        DeleteObject(fasttravelpost)
    end
end


-- Command Setup
RegisterCommand(Config.CommandName, function()
    MainTentmenu()
end)
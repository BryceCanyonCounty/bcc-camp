--------------------- Variables Used ----------------------------------
local tentcreated, benchcreated, campfirecreated, storagechestcreated, hitchpostcreated, fasttravelpostcreated = false, false, false, false, false, false
local hitchpost, tent, bench, campfire, storagechest, fasttravelpost, broll, blip, outoftown
-- Global references to the spawned furniture objects
local spawnedFurniture = {}

devPrint("Variables initialized") -- Dev print

RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function(charid)
    devPrint("Character selected with charid: " .. tostring(charid)) -- Dev print
    TriggerServerEvent('bcc-camp:CampInvCreation', charid)
end)                                                                 -- Create a thread to handle delayed server event triggers

Citizen.CreateThread(function()
    Wait(7000)                                                                            -- Wait for 7 seconds
    TriggerServerEvent('bcc-camp:loadCampData')                                           -- This triggers the server to load saved data
    devPrint("Server events for camp inventory creation and camp data loading triggered") -- Dev print
end)

RegisterNetEvent('bcc-camp:loadTentAndFurniture')
AddEventHandler('bcc-camp:loadTentAndFurniture', function(campData)
    if campData then
        devPrint("Client received data: " .. json.encode(campData)) -- Add this debug print

        if campData.tentCoords then
            devPrint("Client received tent model: " .. tostring(campData.tentModel))
            spawnTentAndFurniture(campData.tentModel, campData.furniture, campData.tentCoords)
        else
            print("No tent coordinates found in camp data.")
        end
    else
        print("No camp data found on client.")
    end
end)

-- Client-side function to spawn tents and furniture from database
function spawnTentAndFurniture(tentModel, furnitureModels, campCoords)
    devPrint("spawnTentAndFurniture called with model: " .. tostring(tentModel))

    -- Load and spawn the tent model and bedroll
    local model2 = 'p_bedrollopen01x'
    modelload(tentModel)
    modelload(model2)

    -- Tent spawn at the provided coordinates
    local x, y, z = campCoords.x, campCoords.y, campCoords.z
    tent = CreateObject(tentModel, x, y, z - 1, true, true, false)
    PropCorrection(tent)
    tentcreated = true

    -- Bedroll spawn
    broll = CreateObject(model2, x, y, z - 1, true, true, false)
    PropCorrection(broll)
    SetEntityHeading(broll, GetEntityHeading(broll) + 90)

    devPrint("Tent and bedroll created at coordinates: " .. x .. ", " .. y .. ", " .. z)

    -- Initialize furniture variables (set to nil)
    campfire, fasttravelpost, storagechest = nil, nil, nil

    -- Clear previous furniture objects if any
    spawnedFurniture = {}

    -- Reset furniture existence flags
    campfireExists, benchExists, storagechestExists, hitchingpostExists, fasttravelExists = false, false, false, false,
        false

    -- Loop through and spawn all the furniture models from the database
    for i, furniture in ipairs(furnitureModels) do
        local fx, fy, fz = furniture.x, furniture.y, furniture.z
        local furnitureModel = getFurnitureHash(furniture.type)

        if furnitureModel then
            modelload(furnitureModel)

            -- Create and place the furniture object
            devPrint("Attempting to create object: " .. tostring(furniture.type))
            local furnitureObject = CreateObject(furnitureModel, fx, fy, fz, true, true, false)
            if DoesEntityExist(furnitureObject) then
                -- Assign the correct variable for each furniture type
                if furniture.type == "campfire" then
                    campfireExists = true
                    campfire = furnitureObject
                    campfireX, campfireY, campfireZ = fx, fy, fz
                    devPrint("Campfire created at: " .. fx .. ", " .. fy .. ", " .. fz)
                elseif furniture.type == "bench" then
                    benchExists = true
                elseif furniture.type == "hitchingpost" then
                    hitchingpostExists = true
                elseif furniture.type == "fasttravelpost" then
                    fasttravelExists = true
                    fasttravelpost = furnitureObject
                    fastTravelX, fastTravelY, fastTravelZ = fx, fy, fz
                    devPrint("Fast travel post created at: " .. fx .. ", " .. fy .. ", " .. fz)
                elseif furniture.type == "storagechest" then
                    storagechestExists = true
                    storagechest = furnitureObject
                    storageChestX, storageChestY, storageChestZ = fx, fy, fz
                    devPrint("Storage chest created at: " .. fx .. ", " .. fy .. ", " .. fz)
                end

                table.insert(spawnedFurniture, furnitureObject) -- Store reference
            else
                devPrint("Failed to create " .. furniture.type)
            end

            PropCorrection(furnitureObject)
            devPrint("Furniture created: " .. furniture.type .. " at coordinates: " .. fx .. ", " .. fy .. ", " .. fz)
        else
            devPrint("No model hash found for furniture type: " .. furniture.type)
        end
    end

    -- Create blip if enabled
    if Config.CampBlips.enable then
        blip = BccUtils.Blips:SetBlip(Config.CampBlips.BlipName, Config.CampBlips.BlipHash, 0.2, x, y, z)
        devPrint("Blip created for tent at: " .. x .. ", " .. y .. ", " .. z)
    end

    -- Manage tent prompt interaction
    local PromptGroup1 = BccUtils.Prompts:SetupPromptGroup()
    local OpenCampPrompt1 = PromptGroup1:RegisterPrompt(_U('manageCamp'), BccUtils.Keys["G"], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    local PromptFastTravel = BccUtils.Prompts:SetupPromptGroup()
    local OpenFastTravel = PromptFastTravel:RegisterPrompt(_U('OpenFastTravel'), BccUtils.Keys["G"], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    local PromptCampStorage = BccUtils.Prompts:SetupPromptGroup()
    local OpenCampStorage = PromptCampStorage:RegisterPrompt(_U('OpenCampStorage'), BccUtils.Keys["G"], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    local PromptRemoveFire = BccUtils.Prompts:SetupPromptGroup()
    local OpenRemoveFire = PromptRemoveFire:RegisterPrompt(_U('RemoveFire'), BccUtils.Keys["G"], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

    Citizen.CreateThread(function()
        while DoesEntityExist(tent) do
            Wait(5)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local dist = GetDistanceBetweenCoords(x, y, z, playerCoords.x, playerCoords.y, playerCoords.z, true)
            if dist < 2 then
                PromptGroup1:ShowGroup(_U('camp'))
                if OpenCampPrompt1:HasCompleted() then
                    devPrint("OpenCampPrompt triggered, opening MainCampmenu")
                    MainCampmenu()
                end
            elseif dist > 200 then
                Wait(2000)
            end
        end
    end)

    -- Proximity Check for Campfire
    if campfire then
        Citizen.CreateThread(function()
            while DoesEntityExist(campfire) do
                Wait(5)
                local playerCoords = GetEntityCoords(PlayerPedId())
                local dist = GetDistanceBetweenCoords(campfireX, campfireY, campfireZ, playerCoords.x, playerCoords.y,
                    playerCoords.z, true)
                if dist < 2 then
                    PromptRemoveFire:ShowGroup(_U('camp'))
                    if OpenRemoveFire:HasCompleted() then
                        extinguishedCampfire()
                    end
                elseif dist > 200 then
                    Wait(2000)
                end
            end
        end)
    end

    -- Proximity Check for Fast Travel Post
    if fasttravelpost then
        Citizen.CreateThread(function()
            while DoesEntityExist(fasttravelpost) do
                Wait(5)
                local playerCoords = GetEntityCoords(PlayerPedId())
                local dist = GetDistanceBetweenCoords(fastTravelX, fastTravelY, fastTravelZ, playerCoords.x,
                    playerCoords.y, playerCoords.z, true)
                if dist < 2 then
                    PromptFastTravel:ShowGroup(_U('camp'))
                    if OpenFastTravel:HasCompleted() then
                        devPrint("Opening fast travel menu")
                        Tpmenu()
                    end
                elseif dist > 200 then
                    Wait(2000)
                end
            end
        end)
    end

    -- Proximity Check for Storage Chest
    if storagechest then
        Citizen.CreateThread(function()
            while DoesEntityExist(storagechest) do
                Wait(10)
                local playerCoords = GetEntityCoords(PlayerPedId())
                local dist = GetDistanceBetweenCoords(storageChestX, storageChestY, storageChestZ, playerCoords.x,
                    playerCoords.y, playerCoords.z, true)
                if dist < 2 then
                    PromptCampStorage:ShowGroup(_U('camp'))
                    if OpenCampStorage:HasCompleted() then
                        devPrint("Opening storage chest")
                        TriggerServerEvent('bcc-camp:OpenInv')
                    end
                elseif dist > 200 then
                    Wait(2000)
                end
            end
        end)
    end
end

function spawnTent(model)
    devPrint("spawnTent called with model: " .. tostring(model)) -- Dev print
    local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId())
    local PromptGroup = BccUtils.Prompts:SetupPromptGroup()
    local OpenCampPrompt = PromptGroup:RegisterPrompt(_U('manageCamp'), BccUtils.Keys["G"], 1, 1, true, 'hold',
        { timedeventhash = "MEDIUM_TIMED_EVENT" })

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

        -- Save the tent data to the database
        local tentCoords = { x = x, y = y, z = z }
        TriggerServerEvent('bcc-camp:saveCampData', tentCoords, nil, model) -- Pass tent_model here

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
    local PlaceItemPrompt = PromptGroupItem:RegisterPrompt(_U('place') .. furntype, BccUtils.Keys["G"], 1, 1, true,
        'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

    local placing = true
    VORPcore.NotifyRightTip(_U('MoveAroundToPlace'), 5000) -- Notify player to move around

    Citizen.CreateThread(function()
        -- Load the model for the item
        modelload(model)

        -- Create a semi-transparent, non-collidable preview object for the item
        local item_preview = CreateObjectNoOffset(model, 0.0, 0.0, 0.0, false, false, false) -- Create locally
        SetEntityAlpha(item_preview, 150, false)                                             -- Semi-transparent
        SetEntityCollision(item_preview, false, false)                                       -- No collision for preview
        FreezeEntityPosition(item_preview, true)                                             -- Prevent movement

        while placing do
            Citizen.Wait(0) -- Run this loop to check placement conditions on each frame

            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local playerHeading = GetEntityHeading(playerPed)
            local forwardVector = GetEntityForwardVector(playerPed)

            -- Calculate the position in front of the player
            local objectOffset = 1.0 -- Distance in front of the player
            local newObjectPos = playerCoords + forwardVector * objectOffset

            -- Get the ground Z coordinate at the new position
            local foundGround, groundZ = GetGroundZFor_3dCoord(newObjectPos.x, newObjectPos.y, playerCoords.z + 10.0,
                false)
            if foundGround then
                newObjectPos = vector3(newObjectPos.x, newObjectPos.y, groundZ)
            else
                newObjectPos = vector3(newObjectPos.x, newObjectPos.y, playerCoords.z)
            end

            -- Update the preview object's position and rotation
            SetEntityCoordsNoOffset(item_preview, newObjectPos.x, newObjectPos.y, newObjectPos.z, false, false, false)
            SetEntityHeading(item_preview, playerHeading)

            -- Show prompt to confirm placement
            PromptGroupItem:ShowGroup(_U('itemPlacement'))

            if PlaceItemPrompt:HasCompleted() then
                -- Recheck conditions before placing the item
                local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId(), item_preview)
                local notneartent = notneartentdistcheck(tent)

                if infrontofplayer or notneartent then
                    VORPcore.NotifyRightTip(_U('cannotBuildNear'), 4000)
                    devPrint("Cannot place item, too close to tent or prop in front")
                else
                    placing = false                                      -- Stop the loop when the player is in the correct location
                    devPrint(furntype .. " model loaded, spawning item") -- Dev print

                    -- Delete the preview object and spawn the final item
                    DeleteObject(item_preview)

                    -- Prepare furniture data with coordinates and type
                    local furnitureCoords = {
                        x = newObjectPos.x,
                        y = newObjectPos.y,
                        z = newObjectPos.z,
                        type = furntype -- Important to send the furniture type
                    }

                    -- Handle different furniture types
                    if furntype == 'bench' then
                        if benchcreated then
                            VORPcore.NotifyRightTip(_U('CantBuild'), 4000)
                        else
                            progressbarfunc(Config.SetupTime.BenchSetupTime, _U('SettingBenchPbar'))
                            bench = CreateObject(model, newObjectPos.x, newObjectPos.y, newObjectPos.z, true, true, false)
                            PropCorrection(bench)
                            benchcreated = true
                            devPrint("Bench created at coordinates: " ..
                            newObjectPos.x .. ", " .. newObjectPos.y .. ", " .. newObjectPos.z)

                            -- Save bench to the database
                            local furnitureCoords = {
                                type = 'bench',
                                model = model,
                                x = newObjectPos.x,
                                y = newObjectPos.y,
                                z = newObjectPos.z
                            }
                            TriggerServerEvent('bcc-camp:InsertFurnitureIntoCampDB', furnitureCoords)
                        end
                    elseif furntype == 'campfire' then
                        if campfirecreated then
                            VORPcore.NotifyRightTip(_U('CantBuild'), 4000)
                        else
                            progressbarfunc(Config.SetupTime.FireSetupTime, _U('FireSetup'))
                            campfire = CreateObject(model, newObjectPos.x, newObjectPos.y, newObjectPos.z, true, true,
                                false)
                            PropCorrection(campfire)
                            campfirecreated = true
                            devPrint("Campfire created at coordinates: " ..
                            newObjectPos.x .. ", " .. newObjectPos.y .. ", " .. newObjectPos.z)

                            -- Save campfire to the database
                            local furnitureCoords = {
                                type = 'campfire',
                                model = model,
                                x = newObjectPos.x,
                                y = newObjectPos.y,
                                z = newObjectPos.z
                            }
                            TriggerServerEvent('bcc-camp:InsertFurnitureIntoCampDB', furnitureCoords)
                        end

                        -- Handle campfire interaction (removal)
                        while DoesEntityExist(campfire) do
                            local PromptRemoveFire = BccUtils.Prompts:SetupPromptGroup()
                            local OpenRemoveFire = PromptRemoveFire:RegisterPrompt(_U('RemoveFire'), BccUtils.Keys["G"], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

                            Citizen.Wait(5)
                            local x2, y2, z2 = table.unpack(GetEntityCoords(PlayerPedId()))
                            local dist = GetDistanceBetweenCoords(x, y, z, x2, y2, z2, true)
                            if dist < 2 then
                                PromptRemoveFire:ShowGroup(_U('camp'))
                                if OpenRemoveFire:HasCompleted() then
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
                            hitchpost = CreateObject(model, newObjectPos.x, newObjectPos.y, newObjectPos.z, true, true, false)
                            PropCorrection(hitchpost)
                            hitchpostcreated = true
                            devPrint("Hitching post created at coordinates: " .. newObjectPos.x .. ", " .. newObjectPos.y .. ", " .. newObjectPos.z)

                            -- Save hitching post to the database
                            local furnitureCoords = {
                                type = 'hitchingpost',
                                model = model,
                                x = newObjectPos.x,
                                y = newObjectPos.y,
                                z = newObjectPos.z
                            }
                            TriggerServerEvent('bcc-camp:InsertFurnitureIntoCampDB', furnitureCoords)
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

    local placing = true
    VORPcore.NotifyRightTip(_U('MoveAndPlace'), 5000)

    Citizen.CreateThread(function()
        -- Load the model for the storage chest
        modelload(model)

        -- Create a semi-transparent, non-collidable preview object for the storage chest
        local storagechest_preview = CreateObjectNoOffset(model, 0.0, 0.0, 0.0, false, false, false) -- Create locally
        SetEntityAlpha(storagechest_preview, 150, false)                                             -- Semi-transparent
        SetEntityCollision(storagechest_preview, false, false)                                       -- No collision during preview
        FreezeEntityPosition(storagechest_preview, true)                                             -- Prevent movement

        while placing do
            Citizen.Wait(0)
            local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId(), storagechest_preview) -- Ignore preview object
            local notneartent = notneartentdistcheck(tent)

            -- Get player position and calculate the offset for object placement
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local playerHeading = GetEntityHeading(playerPed)
            local forwardVector = GetEntityForwardVector(playerPed)

            -- Calculate the position in front of the player
            local objectOffset = 1.0 -- Distance in front of the player
            local newObjectPos = playerCoords + forwardVector * objectOffset

            -- Get the ground Z coordinate at the new position
            local foundGround, groundZ = GetGroundZFor_3dCoord(newObjectPos.x, newObjectPos.y, playerCoords.z + 10.0,
                false)
            if foundGround then
                newObjectPos = vector3(newObjectPos.x, newObjectPos.y, groundZ)
            else
                newObjectPos = vector3(newObjectPos.x, newObjectPos.y, playerCoords.z)
            end

            -- Update the preview object's position and rotation
            SetEntityCoordsNoOffset(storagechest_preview, newObjectPos.x, newObjectPos.y, newObjectPos.z, false, false, false)
            SetEntityHeading(storagechest_preview, playerHeading)

            -- Show prompt to confirm placement
            PromptGroupStorage:ShowGroup(_U('chestPlacement'))
            local PromptCampStorage = BccUtils.Prompts:SetupPromptGroup()
            local OpenCampStorage = PromptCampStorage:RegisterPrompt(_U('OpenCampStorage'), BccUtils.Keys["G"], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
            if PlaceStorageChestPrompt:HasCompleted() then
                if infrontofplayer or notneartent then
                    VORPcore.NotifyRightTip(_U('CantBuild'), 4000)
                    devPrint("Cannot place storage chest, too close to tent or prop in front") -- Dev print
                else
                    -- Confirm placement
                    placing = false

                    progressbarfunc(Config.SetupTime.StorageChestTime, _U('StorageChestSetup'))

                    -- Delete the preview object and spawn the final storage chest
                    DeleteObject(storagechest_preview)

                    storagechest = CreateObject(model, newObjectPos.x, newObjectPos.y, newObjectPos.z, true, true, false)
                    SetEntityHeading(storagechest, playerHeading)
                    PropCorrection(storagechest) -- Correct position/heading
                    storagechestcreated = true

                    -- Save the furniture to the database
                    TriggerServerEvent('bcc-camp:InsertFurnitureIntoCampDB', {
                        type = 'storagechest',
                        x = newObjectPos.x,
                        y = newObjectPos.y,
                        z = newObjectPos.z
                    })
                    devPrint("Storage chest created at coordinates: " .. newObjectPos.x .. ", " .. newObjectPos.y .. ", " .. newObjectPos.z)                                                      -- Dev print

                    -- Interaction loop for the storage chest
                    Citizen.CreateThread(function()
                        while DoesEntityExist(storagechest) do
                            Citizen.Wait(10)
                            local playerCoords = GetEntityCoords(PlayerPedId())
                            local dist = GetDistanceBetweenCoords(newObjectPos.x, newObjectPos.y, newObjectPos.z,
                                playerCoords.x, playerCoords.y, playerCoords.z, true)

                            if dist < 2 then
                                PromptCampStorage:ShowGroup(_U('camp'))
                                if OpenCampStorage:HasCompleted() then
                                    devPrint("Opening storage chest") -- Dev print
                                    TriggerServerEvent('bcc-camp:OpenInv')
                                end
                            elseif dist > 200 then
                                Citizen.Wait(2000)
                            end
                        end
                    end)
                end
            end
        end
    end)
end

function spawnFastTravelPost()
    devPrint("spawnFastTravelPost called") -- Dev print
    local PromptGroupTravel = BccUtils.Prompts:SetupPromptGroup()
    local PlaceFastTravelPrompt = PromptGroupTravel:RegisterPrompt(_U('placeTravelPost'), BccUtils.Keys["G"], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    local PromptFastTravel = BccUtils.Prompts:SetupPromptGroup()
    local OpenFastTravel = PromptFastTravel:RegisterPrompt(_U('OpenFastTravel'), BccUtils.Keys["G"], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    local placing = true

    VORPcore.NotifyRightTip(_U('MoveAndPlace'), 5000)

    Citizen.CreateThread(function()
        -- Load the model for the fast travel post
        local model = 'mp001_s_fasttravelmarker01x'
        modelload(model)

        -- Create a non-collidable, semi-transparent local object for preview
        local fasttravelpost_preview = CreateObjectNoOffset(model, 0.0, 0.0, 0.0, false, false, false) -- Create locally
        SetEntityAlpha(fasttravelpost_preview, 150, false)                                             -- Semi-transparent
        SetEntityCollision(fasttravelpost_preview, false, false)                                       -- No collision for preview
        FreezeEntityPosition(fasttravelpost_preview, true)                                             -- Prevent movement

        while placing do
            Citizen.Wait(0)
            -- Check for other objects, excluding the preview object itself
            local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId(), fasttravelpost_preview)
            local notneartent = notneartentdistcheck(tent)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local playerHeading = GetEntityHeading(playerPed)
            local forwardVector = GetEntityForwardVector(playerPed)

            -- Calculate the position in front of the player
            local objectOffset = 1.0 -- Distance in front of the player
            local newObjectPos = playerCoords + forwardVector * objectOffset

            -- Get the ground Z coordinate at the new position
            local foundGround, groundZ = GetGroundZFor_3dCoord(newObjectPos.x, newObjectPos.y, playerCoords.z + 10.0,
                false)
            if foundGround then
                newObjectPos = vector3(newObjectPos.x, newObjectPos.y, groundZ)
            else
                newObjectPos = vector3(newObjectPos.x, newObjectPos.y, playerCoords.z)
            end

            -- Update the preview object's position and rotation
            SetEntityCoordsNoOffset(fasttravelpost_preview, newObjectPos.x, newObjectPos.y, newObjectPos.z, false, false,
                false)
            SetEntityHeading(fasttravelpost_preview, playerHeading)

            -- Show prompt to confirm placement
            PromptGroupTravel:ShowGroup("Camp")

            if PlaceFastTravelPrompt:HasCompleted() then
                if infrontofplayer or notneartent then
                    VORPcore.NotifyRightTip(_U('CantBuild'), 4000)
                    devPrint("Cannot place fast travel post, too close to tent or prop in front") -- Dev print
                else
                    -- Confirm placement
                    placing = false
                    progressbarfunc(Config.SetupTime.FastTravelPostTime, _U('FastTravelPostSetup'))

                    -- Delete the preview object and spawn the final fast travel post
                    DeleteObject(fasttravelpost_preview)

                    fasttravelpost = CreateObject(model, newObjectPos.x, newObjectPos.y, newObjectPos.z, true, true,
                        false)
                    SetEntityHeading(fasttravelpost, playerHeading)
                    PropCorrection(fasttravelpost) -- Corrects position/heading
                    fasttravelpostcreated = true

                    -- Save the furniture to the database
                    TriggerServerEvent('bcc-camp:InsertFurnitureIntoCampDB', {
                        type = 'fasttravelpost',
                        x = newObjectPos.x,
                        y = newObjectPos.y,
                        z = newObjectPos.z
                    })

                    -- Make the final object solid and visible
                    SetEntityCollision(fasttravelpost, true, true) -- Enable collision
                    ResetEntityAlpha(fasttravelpost)               -- Make fully visible

                    devPrint("Fast travel post created at coordinates: " ..
                        newObjectPos.x .. ", " .. newObjectPos.y .. ", " .. newObjectPos.z) -- Dev print

                    -- Interaction loop for the fast travel post
                    Citizen.CreateThread(function()
                        while DoesEntityExist(fasttravelpost) do
                            Citizen.Wait(5)
                            local playerCoords = GetEntityCoords(PlayerPedId())
                            local dist = GetDistanceBetweenCoords(newObjectPos.x, newObjectPos.y, newObjectPos.z,
                                playerCoords.x, playerCoords.y, playerCoords.z, true)

                            if dist < 2 then
                                PromptFastTravel:ShowGroup(_U('camp'))
                                if OpenFastTravel:HasCompleted() then
                                    devPrint("Opening fast travel menu") -- Dev print
                                    Tpmenu()
                                end
                            elseif dist > 200 then
                                Citizen.Wait(2000)
                            end
                        end
                    end)
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
    devPrint("Deleting camp setup")

    -- Delete tent
    if tentcreated then
        if Config.CampBlips and blip then
            BccUtils.Blip:RemoveBlip(blip.rawblip)
            devPrint("Blip removed")
        end
        tentcreated = false
        DeleteObject(tent)
        DeleteObject(broll)
        devPrint("Tent and bedroll deleted")
    end

    -- Delete all spawned furniture
    for _, furnitureObject in ipairs(spawnedFurniture) do
        if DoesEntityExist(furnitureObject) then
            DeleteObject(furnitureObject)
            devPrint("Furniture object deleted")
        end
    end

    -- Clear the furniture table after deletion
    spawnedFurniture = {}
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

----------------------------------- Delete campfire -----------------------
function extinguishedCampfire()
    if campfire and DoesEntityExist(campfire) then -- Check if campfire exists
        devPrint("Extinguishing campfire")         -- Dev print

        -- Show a progress bar while extinguishing the campfire
        progressbarfunc(Config.SetupTime.FireSetupTime, _U('extinguishCampfire'))

        -- Delete the campfire object from the game world
        DeleteObject(campfire)
        campfire = nil          -- Reset campfire reference
        campfirecreated = false -- Mark campfire as deleted

        -- Trigger the server event to remove the campfire from the database
        TriggerServerEvent('bcc-camp:removeFurnitureFromDB', 'campfire')
    else
        devPrint("Campfire does not exist")
    end
end

----------------------------------- Delete bench --------------------------
function deleteBench()
    if bench and DoesEntityExist(bench) then -- Check if bench exists
        devPrint("Deleting bench")           -- Dev print

        -- Delete the bench object from the game world
        DeleteObject(bench)
        bench = nil         -- Reset bench reference
        benchExists = false -- Mark bench as deleted

        -- Trigger the server event to remove the bench from the database
        TriggerServerEvent('bcc-camp:removeFurnitureFromDB', 'bench')
    else
        devPrint("Bench does not exist")
    end
end

----------------------------------- Delete hitching post -----------------------
function deleteHitchPost()
    if hitchingpost and DoesEntityExist(hitchingpost) then -- Check if hitching post exists
        devPrint("Deleting hitching post")                 -- Dev print

        -- Delete the hitching post object from the game world
        DeleteObject(hitchingpost)
        hitchingpost = nil       -- Reset hitching post reference
        hitchpostcreated = false -- Mark hitching post as deleted

        -- Trigger the server event to remove the hitching post from the database
        TriggerServerEvent('bcc-camp:removeFurnitureFromDB', 'hitchingpost')
    else
        devPrint("Hitching post does not exist")
    end
end

----------------------------------- Delete storage chest -----------------------
function deleteStorageChest()
    if storagechest and DoesEntityExist(storagechest) then -- Check if storage chest exists
        devPrint("Deleting storage chest")                 -- Dev print

        -- Delete the storage chest object from the game world
        DeleteObject(storagechest)
        storagechest = nil          -- Reset storage chest reference
        storagechestcreated = false -- Mark storage chest as deleted

        -- Trigger the server event to remove the storage chest from the database
        TriggerServerEvent('bcc-camp:removeFurnitureFromDB', 'storagechest')
    else
        devPrint("Storage chest does not exist")
    end
end

----------------------- Delete camp when resource stops -----------------------------------
-- Delete camp when resource stops
AddEventHandler("onResourceStop", function(resource)
    local currentResource = GetCurrentResourceName()
    devPrint("Resource stopping event triggered for: " .. resource) -- Add debug info

    if resource == currentResource then
        devPrint("Stopping resource: " .. currentResource .. ", deleting camp") -- Dev print
        delcamp()
    end
end)

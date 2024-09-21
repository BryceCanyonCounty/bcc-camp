--------------------- Variables Used ----------------------------------
local tentcreated =  false
local tent, storagechest, fasttravelpost, broll, blip, outoftown
local spawnedFurniture = {}
furnitureExists = {}

devPrint("Variables initialized") -- Dev print

RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function(charid)
    devPrint("Character selected with charid: " .. tostring(charid)) -- Dev print
    TriggerServerEvent('bcc-camp:CampInvCreation', charid)
    Wait(3000)

    -- Trigger the server event to load the camp data
    TriggerServerEvent('bcc-camp:loadCampData')
    devPrint("Server events camp data loading triggered") -- Dev print
end)
CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(100) -- Wait until the session is started
    end

    -- Once the session is started, wait an additional 3 seconds to ensure everything is loaded
    Wait(3000)

    -- Trigger the server event to load the camp data
    TriggerServerEvent('bcc-camp:loadCampData')
    devPrint("Server events for camp inventory creation and camp data loading triggered") -- Dev print
end)

RegisterNetEvent('bcc-camp:loadTentAndFurniture')
AddEventHandler('bcc-camp:loadTentAndFurniture', function(campData)
    if campData then
        devPrint("Client received data: " .. json.encode(campData))
        furnitureExists = {} -- Reset furnitureExists table

        -- Loop through furniture from the database and populate furnitureExists
        for _, furniture in ipairs(campData.furniture) do
            local furnType = furniture.type:lower() -- Normalize the furniture type to lowercase

            -- Validate if this type exists in the config
            if Config.Furniture[furnType] then
                furnitureExists[furnType] = furnitureExists[furnType] or {}
                furnitureExists[furnType][furniture.model] = true
            else
                devPrint("Unknown furniture type: " .. tostring(furnType))
            end
        end

        -- Proceed to spawn tent and other furniture
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

function spawnTentAndFurniture(tentModel, furnitureModels, campCoords)
    devPrint("spawnTentAndFurniture called with model: " .. tostring(tentModel))

    -- Initialize the `furnitureExists` table (reset it)
    furnitureExists = {}

    -- Load and spawn the tent model and bedroll
    local bedrollModel = Config.BedRollModel or 'p_bedrollopen01x'
    modelload(tentModel)
    modelload(bedrollModel)

    -- Tent spawn at the provided coordinates
    local x, y, z = campCoords.x, campCoords.y, campCoords.z
    tent = CreateObject(tentModel, x, y, z - 1, true, true, false)
    PropCorrection(tent)
    tentcreated = true

    -- Bedroll spawn
    broll = CreateObject(bedrollModel, x, y, z - 1, true, true, false)
    PropCorrection(broll)
    SetEntityHeading(broll, GetEntityHeading(broll) + 90)

    devPrint("Tent and bedroll created at coordinates: " .. x .. ", " .. y .. ", " .. z)

    -- Initialize furniture variables
    campfire, fasttravelpost, storagechest = nil, nil, nil
    spawnedFurniture = {}

    -- Loop through and spawn all the furniture models from the database
    for i, furniture in ipairs(furnitureModels) do
        local fx, fy, fz = furniture.x, furniture.y, furniture.z
        local furnitureModel = furniture.model

        -- Check if the furniture model already exists
        if furnitureExists[furniture.type] and furnitureExists[furniture.type][furnitureModel] then
            devPrint(furniture.type .. " with model " .. furnitureModel .. " already exists.")
            goto continue -- Skip spawning if it already exists
        end

        -- Check if furniture model exists in config
        if furnitureModel then
            modelload(furnitureModel)

            -- Create and place the furniture object
            devPrint("Attempting to create object: " .. tostring(furniture.type) .. " with model: " .. furnitureModel)
            local furnitureObject = CreateObject(furnitureModel, fx, fy, fz, true, true, false)

            if DoesEntityExist(furnitureObject) then
                -- Track existence in `furnitureExists`
                furnitureExists[furniture.type] = furnitureExists[furniture.type] or {}
                furnitureExists[furniture.type][furnitureModel] = {
                    object = furnitureObject,
                    x = fx,
                    y = fy,
                    z = fz
                }

                -- Add to the spawned furniture table
                table.insert(spawnedFurniture, furnitureObject)

                -- Set specific references for furniture types
                if furniture.type == 'Campfires' then
                    campfire = furnitureObject
                elseif furniture.type == 'FastTravelPost' then
                    fasttravelpost = furnitureObject
                elseif furniture.type == 'StorageChest' then
                    storagechest = furnitureObject
                end

            else
                devPrint("Failed to create " .. furniture.type .. " with model " .. furnitureModel)
            end

            -- Correct position/heading
            PropCorrection(furnitureObject)
            devPrint("Furniture created: " .. furniture.type .. " at coordinates: " .. fx .. ", " .. fy .. ", " .. fz)
        else
            devPrint("No model hash found for furniture type: " .. furniture.type)
        end

        ::continue::
    end

    -- Create a blip if enabled
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
        while true do
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

            -- Loop through furniture in `furnitureExists` and check proximity
            for furnType, models in pairs(furnitureExists) do
                for modelHash, data in pairs(models) do
                    -- Check if data is a table and has the necessary properties
                    if type(data) == "table" and data.object then
                        local furnitureObject = data.object
                        local fx, fy, fz = data.x, data.y, data.z
            
                        local dist = GetDistanceBetweenCoords(fx, fy, fz, playerCoords.x, playerCoords.y, playerCoords.z, true)
            
                        if dist < 2 then
                            -- Show specific prompt based on the furniture type
                            if furnType == "Campfires" then
                                PromptRemoveFire:ShowGroup(_U('camp'))
                                if OpenRemoveFire:HasCompleted() then
                                    extinguishedCampfire()
                                end
                            elseif furnType == "FastTravelPost" then
                                PromptFastTravel:ShowGroup(_U('camp'))
                                if OpenFastTravel:HasCompleted() then
                                    devPrint("Opening fast travel menu")
                                    Tpmenu()
                                end
                            elseif furnType == "StorageChest" then
                                PromptCampStorage:ShowGroup(_U('camp'))
                                if OpenCampStorage:HasCompleted() then
                                    devPrint("Opening storage chest")
                                    TriggerServerEvent('bcc-camp:OpenInv')
                                end
                            end
                        elseif dist > 200 then
                            Wait(2000) -- Reduce loop frequency if the player is far away
                        end
                    else
                        devPrint("Warning: Invalid furniture data for " .. tostring(furnType) .. " with model hash: " .. tostring(modelHash))
                    end
                end
            end
            
        end
    end)
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

function spawnItem(furnType, selectedModel)
    devPrint("spawnItem called for " .. furnType .. " with model: " .. tostring(selectedModel))

    -- Check if this model has already been placed
    if furnitureExists[furnType] and furnitureExists[furnType][selectedModel] then
        VORPcore.NotifyRightTip(_U('FurnitureExists', furnType), 4000)
        devPrint(furnType .. " with model " .. selectedModel .. " already exists.")
        return
    end

    -- Set up prompts for placing, rotating, and canceling the item
    local PromptGroupItem = BccUtils.Prompt:SetupPromptGroup()
    local RotateLeftPrompt = PromptGroupItem:RegisterPrompt("Rotate Left", BccUtils.Keys["LEFT"], 1, 1, true, 'click', nil)
    local RotateRightPrompt = PromptGroupItem:RegisterPrompt("Rotate Right", BccUtils.Keys["RIGHT"], 1, 1, true, 'click', nil)
    local PlaceItemPrompt = PromptGroupItem:RegisterPrompt(_U('place'), BccUtils.Keys["G"], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    local CancelPrompt = PromptGroupItem:RegisterPrompt("Cancel Placement", BccUtils.Keys["BACKSPACE"], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

    local placing = true
    local currentHeading = 0  -- Keep track of the current rotation of the object

    -- Notify the player to move around and place the item
    VORPcore.NotifyRightTip(_U('MoveAroundToPlace'), 5000)

    Citizen.CreateThread(function()
        -- Load the model for the selected item
        modelload(selectedModel)

        -- Create a semi-transparent, non-collidable preview object
        local item_preview = CreateObjectNoOffset(selectedModel, 0.0, 0.0, 0.0, false, false, false)
        SetEntityCompletelyDisableCollision(item_preview, false, false)
        Citizen.InvokeNative(0x7DFB49BCDB73089A, item_preview, true)

        -- Retrieve the current heading using GetEntityHeading
        currentHeading = GetEntityHeading(item_preview)

        while placing do
            Citizen.Wait(0)

            -- Update position logic
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local forwardVector = GetEntityForwardVector(playerPed)
            local objectOffset = 1.0 -- Distance in front of the player
            local newObjectPos = playerCoords + forwardVector * objectOffset
            
            -- Get the ground Z coordinate at the new position
            local foundGround, groundZ = GetGroundZFor_3dCoord(newObjectPos.x, newObjectPos.y, playerCoords.z + 10.0, false)
            if foundGround then
                newObjectPos = vector3(newObjectPos.x, newObjectPos.y, groundZ)
            else
                newObjectPos = vector3(newObjectPos.x, newObjectPos.y, playerCoords.z)
            end

            -- Update the preview object's position
            SetEntityCoordsNoOffset(item_preview, newObjectPos.x, newObjectPos.y, newObjectPos.z, false, false, false)

            -- Apply the currentHeading rotation
            SetEntityHeading(item_preview, currentHeading)

            -- Handle object rotation using the rotation logic
            if RotateLeftPrompt:HasCompleted() then
                currentHeading = (currentHeading - 3) % 360  -- Rotate left by 1 degree
                SetEntityHeading(item_preview, currentHeading)  -- Directly apply the new heading
                devPrint("Item rotated left to heading: " .. currentHeading)
            end

            if RotateRightPrompt:HasCompleted() then
                currentHeading = (currentHeading + 3) % 360  -- Rotate right by 1 degree
                SetEntityHeading(item_preview, currentHeading)  -- Directly apply the new heading
                devPrint("Item rotated right to heading: " .. currentHeading)
            end

            PromptGroupItem:ShowGroup(_U('itemPlacement'))

            -- Handle object placement confirmation
            if PlaceItemPrompt:HasCompleted() then
                local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId(), item_preview)
                local notneartent = notneartentdistcheck(tent)

                if infrontofplayer or notneartent then
                    VORPcore.NotifyRightTip(_U('cannotBuildNear'), 4000)
                    devPrint("Cannot place item, too close to tent or prop in front.")
                else
                    placing = false -- Stop the loop when the player is in the correct location

                    -- Delete the preview object
                    DeleteObject(item_preview)

                    -- Final object creation with a progress bar
                    progressbarfunc(Config.SetupTime.BenchSetupTime, _U('SettingItemPbar'))
                    local finalObject = CreateObject(selectedModel, newObjectPos.x, newObjectPos.y, newObjectPos.z, true, true, false)
                    SetEntityHeading(finalObject, currentHeading) -- Apply the final rotation
                    PropCorrection(finalObject)

                    -- Mark the furniture model as created
                    furnitureExists[furnType] = furnitureExists[furnType] or {}
                    furnitureExists[furnType][selectedModel] = {
                        object = finalObject, -- Store the object reference
                        x = newObjectPos.x,
                        y = newObjectPos.y,
                        z = newObjectPos.z
                    }

                    -- Add to the spawnedFurniture table
                    table.insert(spawnedFurniture, finalObject)

                    -- Save furniture data to the database
                    local furnitureCoords = {
                        x = newObjectPos.x,
                        y = newObjectPos.y,
                        z = newObjectPos.z,
                        type = furnType,
                        model = selectedModel
                    }
                    TriggerServerEvent('bcc-camp:InsertFurnitureIntoCampDB', furnitureCoords)

                    devPrint(furnType .. " model placed successfully.")
                end
            end

            -- Handle placement cancellation
            if CancelPrompt:HasCompleted() then
                DeleteObject(item_preview)
                devPrint("Item placement canceled.")
                placing = false
            end
        end
    end)
end

function spawnStorageChest(model)
    devPrint("spawnStorageChest called with model: " .. tostring(model)) -- Dev print

    -- Set up prompts for placing, rotating, and canceling the item
    local PromptGroupStorage = BccUtils.Prompt:SetupPromptGroup()
    local RotateLeftPrompt = PromptGroupStorage:RegisterPrompt("Rotate Left", BccUtils.Keys["LEFT"], 1, 1, true, 'click', nil)
    local RotateRightPrompt = PromptGroupStorage:RegisterPrompt("Rotate Right", BccUtils.Keys["RIGHT"], 1, 1, true, 'click', nil)
    local PlaceStorageChestPrompt = PromptGroupStorage:RegisterPrompt(_U('placeChest'), BccUtils.Keys["G"], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    local CancelPrompt = PromptGroupStorage:RegisterPrompt("Cancel Placement", BccUtils.Keys["BACKSPACE"], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

    local placing = true
    local currentHeading = 0 -- Keep track of the current rotation of the object

    VORPcore.NotifyRightTip(_U('MoveAndPlace'), 5000)

    Citizen.CreateThread(function()
        -- Load the model for the storage chest
        modelload(model)

        -- Create a semi-transparent, non-collidable preview object
        local storagechest_preview = CreateObjectNoOffset(model, 0.0, 0.0, 0.0, false, false, false)
        SetEntityCompletelyDisableCollision(storagechest_preview, false, false)
        Citizen.InvokeNative(0x7DFB49BCDB73089A, storagechest_preview, true)

        -- Retrieve the current heading
        currentHeading = GetEntityHeading(storagechest_preview)

        while placing do
            Citizen.Wait(0)

            -- Update position logic
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local forwardVector = GetEntityForwardVector(playerPed)
            local objectOffset = 1.0 -- Distance in front of the player
            local newObjectPos = playerCoords + forwardVector * objectOffset

            -- Get the ground Z coordinate at the new position
            local foundGround, groundZ = GetGroundZFor_3dCoord(newObjectPos.x, newObjectPos.y, playerCoords.z + 10.0, false)
            if foundGround then
                newObjectPos = vector3(newObjectPos.x, newObjectPos.y, groundZ)
            else
                newObjectPos = vector3(newObjectPos.x, newObjectPos.y, playerCoords.z)
            end

            -- Update the preview object's position and rotation
            SetEntityCoordsNoOffset(storagechest_preview, newObjectPos.x, newObjectPos.y, newObjectPos.z, false, false, false)
            SetEntityHeading(storagechest_preview, currentHeading)

            -- Handle rotation
            if RotateLeftPrompt:HasCompleted() then
                currentHeading = (currentHeading - 3) % 360
                SetEntityHeading(storagechest_preview, currentHeading)
                devPrint("Storage chest rotated left to heading: " .. currentHeading)
            end

            if RotateRightPrompt:HasCompleted() then
                currentHeading = (currentHeading + 3) % 360
                SetEntityHeading(storagechest_preview, currentHeading)
                devPrint("Storage chest rotated right to heading: " .. currentHeading)
            end

            -- Show prompt to confirm placement
            PromptGroupStorage:ShowGroup(_U('chestPlacement'))

            -- Handle placement confirmation
            if PlaceStorageChestPrompt:HasCompleted() then
                local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId(), storagechest_preview)
                local notneartent = notneartentdistcheck(tent)

                if infrontofplayer or notneartent then
                    VORPcore.NotifyRightTip(_U('CantBuild'), 4000)
                    devPrint("Cannot place storage chest, too close to tent or prop in front")
                else
                    placing = false -- Confirm placement

                    -- Final object creation
                    DeleteObject(storagechest_preview)
                    progressbarfunc(Config.SetupTime.StorageChestTime, _U('StorageChestSetup'))
                    local finalObject = CreateObject(model, newObjectPos.x, newObjectPos.y, newObjectPos.z, true, true, false)
                    SetEntityHeading(finalObject, currentHeading)
                    PropCorrection(finalObject)

                    -- Save to the database
                    TriggerServerEvent('bcc-camp:InsertFurnitureIntoCampDB', {
                        type = 'StorageChest',
                        x = newObjectPos.x,
                        y = newObjectPos.y,
                        z = newObjectPos.z,
                        model = model
                    })

                    -- Track the created storage chest
                    storagechest = finalObject
                    furnitureExists['StorageChest'] = furnitureExists['StorageChest'] or {}
                    furnitureExists['StorageChest'][model] = {
                        object = finalObject,
                        x = newObjectPos.x,
                        y = newObjectPos.y,
                        z = newObjectPos.z
                    }

                    -- Add to the spawned furniture table for deletion
                    table.insert(spawnedFurniture, finalObject)

                    devPrint("Storage chest created at coordinates: " .. newObjectPos.x .. ", " .. newObjectPos.y .. ", " .. newObjectPos.z)
                end
            end

            -- Handle placement cancellation
            if CancelPrompt:HasCompleted() then
                DeleteObject(storagechest_preview)
                devPrint("Storage chest placement canceled.")
                placing = false
            end
        end
    end)
end

function spawnFastTravelPost(furnType, selectedModel)
    devPrint("spawnFastTravelPost called for " .. furnType .. " with model: " .. tostring(selectedModel))

    -- Check if this model has already been placed
    if furnitureExists[furnType] and furnitureExists[furnType][selectedModel] then
        VORPcore.NotifyRightTip(_U('FurnitureExists', furnType), 4000)
        devPrint(furnType .. " with model " .. selectedModel .. " already exists.")
        return
    end

    -- Set up prompts for placing, rotating, and canceling the item
    local PromptGroupTravel = BccUtils.Prompt:SetupPromptGroup()
    local RotateLeftPrompt = PromptGroupTravel:RegisterPrompt("Rotate Left", BccUtils.Keys["LEFT"], 1, 1, true, 'click', nil)
    local RotateRightPrompt = PromptGroupTravel:RegisterPrompt("Rotate Right", BccUtils.Keys["RIGHT"], 1, 1, true, 'click', nil)
    local PlaceFastTravelPrompt = PromptGroupTravel:RegisterPrompt(_U('placeTravelPost'), BccUtils.Keys["G"], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
    local CancelPrompt = PromptGroupTravel:RegisterPrompt("Cancel Placement", BccUtils.Keys["BACKSPACE"], 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

    local placing = true
    local currentHeading = 0 -- Keep track of the current rotation of the object

    VORPcore.NotifyRightTip(_U('MoveAndPlace'), 5000)

    Citizen.CreateThread(function()
        -- Load the model for the fast travel post
        modelload(selectedModel)

        -- Create a semi-transparent, non-collidable preview object
        local fasttravelpost_preview = CreateObjectNoOffset(selectedModel, 0.0, 0.0, 0.0, false, false, false)
        SetEntityCompletelyDisableCollision(fasttravelpost_preview, false, false)
        Citizen.InvokeNative(0x7DFB49BCDB73089A, fasttravelpost_preview, true)

        -- Retrieve the current heading
        currentHeading = GetEntityHeading(fasttravelpost_preview)

        while placing do
            Citizen.Wait(0)

            -- Update position logic
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local forwardVector = GetEntityForwardVector(playerPed)
            local objectOffset = 1.0 -- Distance in front of the player
            local newObjectPos = playerCoords + forwardVector * objectOffset

            -- Get the ground Z coordinate at the new position
            local foundGround, groundZ = GetGroundZFor_3dCoord(newObjectPos.x, newObjectPos.y, playerCoords.z + 10.0, false)
            if foundGround then
                newObjectPos = vector3(newObjectPos.x, newObjectPos.y, groundZ)
            else
                newObjectPos = vector3(newObjectPos.x, newObjectPos.y, playerCoords.z)
            end

            -- Update the preview object's position and rotation
            SetEntityCoordsNoOffset(fasttravelpost_preview, newObjectPos.x, newObjectPos.y, newObjectPos.z, false, false, false)
            SetEntityHeading(fasttravelpost_preview, currentHeading)

            -- Handle rotation
            if RotateLeftPrompt:HasCompleted() then
                currentHeading = (currentHeading - 3) % 360
                SetEntityHeading(fasttravelpost_preview, currentHeading)
                devPrint("Fast travel post rotated left to heading: " .. currentHeading)
            end

            if RotateRightPrompt:HasCompleted() then
                currentHeading = (currentHeading + 3) % 360
                SetEntityHeading(fasttravelpost_preview, currentHeading)
                devPrint("Fast travel post rotated right to heading: " .. currentHeading)
            end

            -- Show prompt to confirm placement
            PromptGroupTravel:ShowGroup(_U('camp'))

            -- Handle placement confirmation
            if PlaceFastTravelPrompt:HasCompleted() then
                local infrontofplayer = IsThereAnyPropInFrontOfPed(PlayerPedId(), fasttravelpost_preview)
                local notneartent = notneartentdistcheck(tent)

                if infrontofplayer or notneartent then
                    VORPcore.NotifyRightTip(_U('CantBuild'), 4000)
                    devPrint("Cannot place fast travel post, too close to tent or prop in front")
                else
                    placing = false -- Confirm placement

                    -- Final object creation
                    DeleteObject(fasttravelpost_preview)
                    progressbarfunc(Config.SetupTime.FastTravelPostTime, _U('FastTravelPostSetup'))
                    local finalObject = CreateObject(selectedModel, newObjectPos.x, newObjectPos.y, newObjectPos.z, true, true, false)
                    SetEntityHeading(finalObject, currentHeading)
                    PropCorrection(finalObject)

                    -- Save to the database
                    TriggerServerEvent('bcc-camp:InsertFurnitureIntoCampDB', {
                        x = newObjectPos.x,
                        y = newObjectPos.y,
                        z = newObjectPos.z,
                        type = furnType,
                        model = selectedModel
                    })

                    -- Track the created fast travel post
                    fasttravelpost = finalObject
                    furnitureExists['FastTravelPost'] = furnitureExists['FastTravelPost'] or {}
                    furnitureExists['FastTravelPost'][selectedModel] = {
                        object = finalObject,
                        x = newObjectPos.x,
                        y = newObjectPos.y,
                        z = newObjectPos.z
                    }

                    -- Add to the spawned furniture table for deletion
                    table.insert(spawnedFurniture, finalObject)

                    devPrint("Fast travel post created at coordinates: " .. newObjectPos.x .. ", " .. newObjectPos.y .. ", " .. newObjectPos.z)
                end
            end

            -- Handle placement cancellation
            if CancelPrompt:HasCompleted() then
                DeleteObject(fasttravelpost_preview)
                devPrint("Fast travel post placement canceled.")
                placing = false
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


function DeleteFurniture(furntype, selectedModel)
    local furnitureObject = furnitureExists[furntype][selectedModel].object

    if DoesEntityExist(furnitureObject) then
        -- Delete the object
        DeleteObject(furnitureObject)
        devPrint("Deleted " .. furntype .. " with model " .. selectedModel)

        -- Remove from the furnitureExists table
        furnitureExists[furntype][selectedModel] = nil

        -- Trigger server event to remove the item from the database
        TriggerServerEvent('bcc-camp:removeFurnitureFromDB', furntype, selectedModel)
    else
        devPrint(furntype .. " with model " .. selectedModel .. " does not exist")
    end
end

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	
        return
    end
    delcamp()
end)

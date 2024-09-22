----------------------------------- Pulling Essentials --------------------------------------------
local VORPcore = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()
Discord = BccUtils.Discord.setup(Config.WebhookLink, Config.WebhookTitle, Config.WebhookAvatar)

-- Helper function for debugging in DevMode
if Config.DevMode then
    function devPrint(message)
        print("^1[DEV MODE] ^4" .. message)
    end
else
    function devPrint(message) end -- No-op if DevMode is disabled
end

----------------------------------- Inventory Handling --------------------------------------------
-- Create camp inventory for the player
RegisterServerEvent('bcc-camp:CampInvCreation', function(charid)
    devPrint("Creating camp inventory for charid: " .. tostring(charid))
    local data = {
        id = 'Player_' .. tostring(charid) .. '_bcc-campinv',
        name = _U('InventoryName'),
        limit = Config.InventoryLimit,
        acceptWeapons = false,
        shared = false,
        ignoreItemStackLimit = true,
        whitelistItems = false,
        UsePermissions = false,
        UseBlackList = false,
        whitelistWeapons = false
    }
    exports.vorp_inventory:registerInventory(data)
    devPrint("Inventory registered with ID: " .. data.id)
end)

-- Open the camp inventory
RegisterServerEvent('bcc-camp:OpenInv', function()
    local src = source
    devPrint("Opening inventory for source: " .. tostring(src))
    local user = VORPcore.getUser(src)
    if not user then
        devPrint("ERROR: User not found for source: " .. tostring(src))
        return
    end
    local Character = user.getUsedCharacter
    exports.vorp_inventory:openInventory(src, 'Player_' .. Character.charIdentifier .. '_bcc-campinv')
    devPrint("Opened camp inventory for charIdentifier: " .. Character.charIdentifier)
end)

-- Register usable camp item (if enabled)
if Config.CampItem.enabled then
    exports.vorp_inventory:registerUsableItem(Config.CampItem.CampItem, function(data)
        devPrint("Camp item used by source: " .. tostring(data.source))
        local user = VORPcore.getUser(data.source)
        if not user then
            devPrint("ERROR: User not found for source: " .. tostring(data.source))
            return
        end
        exports.vorp_inventory:closeInventory(data.source)
        devPrint("Closed inventory for source: " .. tostring(data.source))
        TriggerClientEvent('bcc-camp:NearTownCheck', data.source)
    end)
end

-- Remove camp item when necessary
RegisterServerEvent('bcc-camp:RemoveCampItem', function()
    local src = source
    devPrint("Removing camp item for source: " .. tostring(src))
    local user = VORPcore.getUser(src)
    if not user then
        devPrint("ERROR: User not found for source: " .. tostring(src))
        return
    end
    if Config.CampItem.RemoveItem then
        exports.vorp_inventory:subItem(src, Config.CampItem.CampItem, 1)
        devPrint("Removed camp item from source: " .. tostring(src))
    end
end)

----------------------------------- Camp Data Handling --------------------------------------------
-- Save camp data including tent coordinates, furniture, and tent model
RegisterServerEvent('bcc-camp:saveCampData')
AddEventHandler('bcc-camp:saveCampData', function(tentCoords, furnitureCoords, tentModel)
    local src = source
    local character = VORPcore.getUser(src).getUsedCharacter
    local campCoords = json.encode(tentCoords)
    local furniture = json.encode(furnitureCoords or {})  -- Ensure furniture is not nil
    tentModel = tentModel or 'default_tent_model'  -- Fallback to a default tent model if not provided
    devPrint("Saving camp data for charIdentifier: " .. character.charIdentifier)

    local param = {
        ['charidentifier'] = character.charIdentifier,
        ['firstname'] = character.firstname,
        ['lastname'] = character.lastname,
        ['campname'] = 'My Camp',
        ['stash'] = 0,
        ['camp_coordinates'] = campCoords,
        ['furniture'] = furniture,
        ['tent_model'] = tentModel
    }

    local result = MySQL.query.await("SELECT * FROM bcc_camp WHERE charidentifier=@charidentifier", {
        ['charidentifier'] = character.charIdentifier
    })

    if #result == 0 then
        -- Insert new camp (tent)
        MySQL.insert("INSERT INTO bcc_camp (`charidentifier`, `firstname`, `lastname`, `campname`, `stash`, `camp_coordinates`, `furniture`, `tent_model`) VALUES (@charidentifier, @firstname, @lastname, @campname, @stash, @camp_coordinates, @furniture, @tent_model)", param)
        VORPcore.NotifyRightTip(src, "Camp created successfully", 4000)
        Discord:sendMessage("**Camp Created**\nCharacter: " .. character.firstname .. " " .. character.lastname .. "\nCamp Name: " .. param['campname'] .. "\nCoordinates: " .. campCoords)
        devPrint("Camp created for charIdentifier: " .. character.charIdentifier)
    else
        -- Update the existing camp coordinates and furniture
        MySQL.update('UPDATE bcc_camp SET camp_coordinates=@camp_coordinates, furniture=@furniture, tent_model=@tent_model WHERE charidentifier=@charidentifier', {
            ['@charidentifier'] = character.charIdentifier,
            ['@camp_coordinates'] = campCoords,
            ['@furniture'] = furniture,
            ['@tent_model'] = tentModel
        })
        VORPcore.NotifyRightTip(src, "Camp updated", 4000)
        Discord:sendMessage("**Camp Updated**\nCharacter: " .. character.firstname .. " " .. character.lastname .. "\nUpdated Coordinates: " .. campCoords)
        devPrint("Updated camp coordinates, furniture, and tent model for charIdentifier: " .. character.charIdentifier)
    end
end)

-- Helper function to map old furniture types to the config keys
local function mapOldTypeToConfig(furnType)
    local typeMap = {
        campfire = "Campfires",
        bench = "Benchs",
        hitchingpost = "HitchingPost",
        storagechest = "StorageChest",
        fasttravelpost = "FastTravelPost"
    }

    return typeMap[furnType] or furnType -- Return mapped type or original if no match found
end

-- Helper function to find correct model from config
local function getCorrectFurnitureModel(furnType)
    local mappedType = mapOldTypeToConfig(furnType)

    if Config.Furniture[mappedType] then
        -- Return the first model in the list, assuming it's correct (you can modify this logic)
        return Config.Furniture[mappedType][1].hash
    end
    return nil
end

-- Load camp data for a character and correct mismatches
RegisterServerEvent('bcc-camp:loadCampData')
AddEventHandler('bcc-camp:loadCampData', function()
    local src = source
    local user = VORPcore.getUser(src)

    if not user then 
        devPrint("No user found for source: " .. tostring(src))
        return 
    end

    local character = user.getUsedCharacter

    -- Check if the character has been loaded and charIdentifier exists
    if not character or not character.charIdentifier then
        devPrint("Character data is not available for source: " .. tostring(src))
        return
    end

    local charId = character.charIdentifier
    devPrint("Loading camp data for charIdentifier: " .. charId)

    -- Fetch the saved tent, furniture, and tent model data from the database
    local result = MySQL.query.await("SELECT camp_coordinates, furniture, tent_model FROM bcc_camp WHERE charidentifier = @charidentifier", {
        ['@charidentifier'] = charId
    })

    if result and #result > 0 then
        local campData = result[1]
        local decodedCampCoordinates = json.decode(campData.camp_coordinates)
        local decodedFurniture = json.decode(campData.furniture)

        devPrint("Server sending camp data to client: " .. json.encode(campData))

        -- Check if the data in the database matches the config and correct if needed
        local needsUpdate = false
        for _, furnitureItem in ipairs(decodedFurniture) do
            local furnType = furnitureItem.type
            local modelHash = furnitureItem.model

            -- Map the old type to the correct one from the config
            local correctType = mapOldTypeToConfig(furnType)

            -- If the type needs updating
            if correctType ~= furnType then
                devPrint("Updating furniture type from " .. furnType .. " to " .. correctType)
                furnitureItem.type = correctType -- Correct the type
                needsUpdate = true
            end

            -- If model is missing or incorrect, insert correct model
            if not modelHash or not isModelInConfig(correctType, modelHash) then
                local correctModel = getCorrectFurnitureModel(correctType)
                if correctModel then
                    devPrint("Updating model for type " .. correctType .. " to " .. correctModel)
                    furnitureItem.model = correctModel -- Correct the model
                    needsUpdate = true
                else
                    devPrint("No correct model found for type: " .. correctType)
                end
            end
        end

        -- If any updates were made, save the corrected furniture data back to the database
        if needsUpdate then
            local updatedFurnitureJson = json.encode(decodedFurniture)
            MySQL.Async.execute("UPDATE bcc_camp SET furniture = @furniture WHERE charidentifier = @charidentifier", {
                ['@furniture'] = updatedFurnitureJson,
                ['@charidentifier'] = charId
            })
            devPrint("Database updated with correct furniture data for charIdentifier: " .. charId)
        end

        -- Send the updated camp data to the client
        TriggerClientEvent('bcc-camp:loadTentAndFurniture', src, {
            tentCoords = decodedCampCoordinates,
            furniture = decodedFurniture,
            tentModel = campData.tent_model,
            selectedModel = campData.tent_model
        })
    else
        devPrint("No camp data found for character " .. charId)
    end
end)

-- Helper function to check if a model exists in the config exactly as it is
function isModelInConfig(furnType, modelHash)
    local mappedType = mapOldTypeToConfig(furnType)

    -- Check if furniture type exists in the config
    if Config.Furniture[mappedType] then
        for _, furnitureItem in ipairs(Config.Furniture[mappedType]) do
            -- Compare model hash exactly as it is
            if furnitureItem.hash == modelHash then
                return true
            end
        end
    end
    return false
end

-- Server event to correct mismatched furniture data in the database
RegisterServerEvent('bcc-camp:correctFurnitureData')
AddEventHandler('bcc-camp:correctFurnitureData', function(charId, furnType, correctModel)
    -- Fetch the current camp data to modify
    local result = MySQL.query.await("SELECT furniture FROM bcc_camp WHERE charidentifier = @charidentifier", {
        ['@charidentifier'] = charId
    })

    if result and #result > 0 then
        local campData = result[1]
        local decodedFurniture = json.decode(campData.furniture)

        -- Correct the mismatched data
        for _, furnitureItem in ipairs(decodedFurniture) do
            if furnitureItem.type == furnType then
                furnitureItem.model = correctModel -- Update the model with the correct one
                devPrint("Correcting model for type: " .. furnType .. " to model: " .. correctModel)
            end
        end

        -- Save the corrected data back to the database
        local updatedFurnitureJson = json.encode(decodedFurniture)
        MySQL.Async.execute("UPDATE bcc_camp SET furniture = @furniture WHERE charidentifier = @charidentifier", {
            ['@furniture'] = updatedFurnitureJson,
            ['@charidentifier'] = charId
        })

        devPrint("Database updated with correct furniture data for charIdentifier: " .. charId)
    else
        devPrint("No camp data found for character " .. charId .. " during correction")
    end
end)

-- Insert furniture into camp data
RegisterServerEvent('bcc-camp:InsertFurnitureIntoCampDB')
AddEventHandler('bcc-camp:InsertFurnitureIntoCampDB', function(furnitureData)
    local src = source
    local user = VORPcore.getUser(src)

    if not user then 
        devPrint("No user found for source: " .. tostring(src))
        return 
    end

    local character = user.getUsedCharacter

    devPrint("Inserting furniture for character ID: " .. tostring(character.charIdentifier))

    -- Fetch the current furniture data for this character
    local result = MySQL.query.await("SELECT furniture FROM bcc_camp WHERE charidentifier = @charidentifier", {
        ['@charidentifier'] = character.charIdentifier
    })

    if result and #result > 0 then
        local currentFurniture = result[1].furniture and json.decode(result[1].furniture) or {}

        for _, furn in ipairs(currentFurniture) do
            if furn.model == furnitureData.model then
                -- Notify the player that the furniture with the same model already exists
                VORPcore.NotifyRightTip(src, _U('FurnitureExists', furnitureData.type), 4000)
                devPrint(furnitureData.type .. " with model " .. furnitureData.model .. " already exists for charidentifier: " .. character.charIdentifier)
                return
            end
        end

        -- Insert the new furniture if not existing
        table.insert(currentFurniture, furnitureData)
        MySQL.update.await("UPDATE bcc_camp SET furniture = @furniture WHERE charidentifier = @charidentifier", {
            ['@furniture'] = json.encode(currentFurniture),
            ['@charidentifier'] = character.charIdentifier
        })

        devPrint(furnitureData.type .. " successfully inserted into the database for charidentifier: " .. character.charIdentifier)
        VORPcore.NotifyRightTip(src, _U('FurniturePlaced', furnitureData.type), 4000)
        Discord:sendMessage("**Furniture Inserted**\nCharacter: " .. character.firstname .. " " .. character.lastname .. "\nFurniture Type: " .. furnitureData.type .. "\nModel: " .. furnitureData.model)
    else
        -- If no furniture exists, create a new entry with the first piece of furniture
        local newFurniture = {furnitureData}

        MySQL.update.await("UPDATE bcc_camp SET furniture = @furniture WHERE charidentifier = @charidentifier", {
            ['@furniture'] = json.encode(newFurniture),
            ['@charidentifier'] = character.charIdentifier
        })

        devPrint(furnitureData.type .. " inserted as new furniture into the database for charidentifier: " .. character.charIdentifier)
        VORPcore.NotifyRightTip(src, _U('FurniturePlaced', furnitureData.type), 4000)
        Discord:sendMessage("**New Furniture Inserted**\nCharacter: " .. character.firstname .. " " .. character.lastname .. "\nFurniture Type: " .. furnitureData.type .. "\nModel: " .. furnitureData.model)
    end
end)

-- Server-side: Delete camp from the database
RegisterServerEvent('bcc-camp:DeleteCamp')
AddEventHandler('bcc-camp:DeleteCamp', function()
    local src = source
    local user = VORPcore.getUser(src)

    if not user then
        devPrint("No user found for source: " .. tostring(src))
        return
    end

    local character = user.getUsedCharacter
    local charIdentifier = character.charIdentifier

    devPrint("Deleting camp for character ID: " .. tostring(charIdentifier))

    -- Delete the camp from the database
    MySQL.update("DELETE FROM bcc_camp WHERE charidentifier = @charidentifier", { ['@charidentifier'] = charIdentifier })

    -- Notify the client that the camp has been deleted
    VORPcore.NotifyRightTip(src, "Camp deleted successfully", 4000)
    TriggerEvent('bcc-camp:loadCampData')
    -- Send a Discord notification for logging purposes
    Discord:sendMessage("**Camp Deleted**\nCharacter: " .. character.firstname .. " " .. character.lastname)
    if Config.CampItem.enabled then
        if Config.CampItem.GiveBack then
            exports.vorp_inventory:addItem(src, Config.CampItem.CampItem, 1)
        end
    end
end)


-- Server-side: Remove furniture from the database
RegisterServerEvent('bcc-camp:removeFurnitureFromDB')
AddEventHandler('bcc-camp:removeFurnitureFromDB', function(furnitureType)
    local src = source
    local user = VORPcore.getUser(src)
    
    if not user then 
        devPrint("No user found for source: " .. tostring(src)) -- Dev print
        return 
    end

    local character = user.getUsedCharacter
    local charIdentifier = character.charIdentifier

    devPrint("Attempting to remove furniture for character ID: " .. tostring(charIdentifier)) -- Dev print

    -- Fetch current furniture data from the database
    local result = MySQL.query.await("SELECT furniture FROM bcc_camp WHERE charidentifier = @charidentifier", {
        ['@charidentifier'] = charIdentifier
    })

    if result and #result > 0 then
        devPrint("Furniture data found for character ID: " .. tostring(charIdentifier)) -- Dev print
        local currentFurniture = result[1].furniture and json.decode(result[1].furniture) or {}

        -- Find the furniture to remove based on the furniture type
        for i, furn in ipairs(currentFurniture) do
            if furn.type == furnitureType then
                devPrint("Removing furniture: " .. furnitureType .. " for character ID: " .. tostring(charIdentifier)) -- Dev print
                table.remove(currentFurniture, i)
                break
            end
        end

        -- Update the database with the new furniture data (without the removed furniture)
        MySQL.update.await("UPDATE bcc_camp SET furniture = @furniture WHERE charidentifier = @charidentifier", {
            ['@furniture'] = json.encode(currentFurniture),
            ['@charidentifier'] = charIdentifier
        })

        -- Notify the client that the furniture was removed
        VORPcore.NotifyRightTip(src, "Furniture removed successfully", 4000)
        devPrint("Furniture removed successfully for character ID: " .. tostring(charIdentifier)) -- Dev print

        -- Send Discord notification
        Discord:sendMessage("**Furniture Removed**\nCharacter: " .. character.firstname .. " " .. character.lastname .. "\nRemoved Furniture: " .. furnitureType)
    else
        -- No furniture found
        VORPcore.NotifyRightTip(src, "No furniture found to remove", 4000)
        devPrint("No furniture found for character ID: " .. tostring(charIdentifier)) -- Dev print
    end
end)

-- Version check
devPrint("Checking version for resource: " .. GetCurrentResourceName())
BccUtils.Versioner.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-camp')

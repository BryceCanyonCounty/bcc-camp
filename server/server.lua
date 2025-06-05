----------------------------------- Pulling Essentials --------------------------------------------
local Core = exports.vorp_core:GetCore()

local BccUtils = exports['bcc-utils'].initiate()
Discord = BccUtils.Discord.setup(Config.WebhookLink, Config.WebhookTitle,
                                 Config.WebhookAvatar)

-- Helper function for debugging in DevMode
if Config.DevMode then
    function devPrint(message) print("^1[DEV MODE] ^4" .. message) end
else
    function devPrint(message) end -- No-op if DevMode is disabled
end

local function formatCoords(jsonString)
    local z = jsonString:match('"z":([%-?%d%.]+)')
    local y = jsonString:match('"y":([%-?%d%.]+)')
    local x = jsonString:match('"x":([%-?%d%.]+)')

    z = z:gsub("-", "")
    y = y:gsub("-", "")
    x = x:gsub("-", "")

    return string.format("x %s y %s z %s", x, y, z)
end

-- Function to update camp conditions
RegisterServerEvent('bcc-camp:UpdateCampCondition')
AddEventHandler('bcc-camp:UpdateCampCondition',
                function(DecreaseCondition, ChoreCondition)
    if DecreaseCondition then
        MySQL.Async.fetchAll('SELECT * FROM bcc_camp', {}, function(camps)
            for _, camp in ipairs(camps) do
                -- Convert timestamps to days
                local lastUpdatedTime = math.floor(camp.last_updated / 1000) -- Convert from milliseconds if needed
                local currentTime = os.time()
                local daysPassed = (currentTime - lastUpdatedTime) / (24 * 3600) -- Convert seconds to days

                if daysPassed >= 7 then -- Ensure 7-day reduction
                    local newCondition =
                        math.max(camp.condition - Config.ReduceCondition, 0) -- Prevent condition below 0
                    MySQL.Async.execute(
                        'UPDATE bcc_camp SET `condition` = @condition, last_updated = NOW() WHERE id = @id',
                        {['@condition'] = newCondition, ['@id'] = camp.id})
                end
            end
        end)
    else
        local increment = tonumber(ChoreCondition) or 0
        if increment > 0 then
            MySQL.update.await(
                'UPDATE bcc_camp SET `condition` = GREATEST(condition + @increment, 0), last_updated = NOW()',
                {['@increment'] = increment})
        end
    end
end)

-- Call the function every hour
CreateThread(function()
    while true do
        -- Wait(60000*60*Config.ReduceConditionTime)                                             -- Wait for 1 hour (3600000 milliseconds)
        Wait(60000 * 60) -- Wait for 1 hour (3600000 milliseconds)
        TriggerEvent('bcc-camp:UpdateCampCondition', true, nil) -- Update camp conditions
    end
end)

----------------------------------- Inventory Handling --------------------------------------------
-- Create camp inventory for the player
RegisterServerEvent('bcc-camp:CampInvCreation', function(charid)
    devPrint("Creating camp inventory for charid: " .. tostring(charid))
    
    local result = MySQL.query.await(
                       "SELECT id FROM bcc_camp WHERE charidentifier=@charidentifier",
                       {['charidentifier'] = tostring(charid) })

    local campid = result[1] and result[1].id or "" -- Extract the id from the first result
    local data = {
        id = 'Player_' .. tostring(charid) .. '_bcc-campinv_'.. tostring(campid),
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
    local user = Core.getUser(src)
    if not user then
        devPrint("ERROR: User not found for source: " .. tostring(src))
        return
    end
    local Character = user.getUsedCharacter
    exports.vorp_inventory:openInventory(src, 'Player_' .. Character.charIdentifier .. '_bcc-campinv')
    devPrint("Opened camp inventory for charIdentifier: " ..
                 Character.charIdentifier)
end)

-- Register usable camp item (if enabled)
if Config.CampItem.enabled then
    exports.vorp_inventory:registerUsableItem(Config.CampItem.CampItem, function(data)
        devPrint("Camp item used by source: " .. tostring(data.source))
        local user = Core.getUser(data.source)
        if not user then
            devPrint("ERROR: User not found for source: " ..
                         tostring(data.source))
            return
        end
        exports.vorp_inventory:closeInventory(data.source)
        devPrint("Closed inventory for source: " .. tostring(data.source))
        TriggerClientEvent('bcc-camp:NearTownCheck', data.source)
    end,GetCurrentResourceName())
end

-- Remove camp item when necessary
RegisterServerEvent('bcc-camp:RemoveCampItem', function()
    local src = source
    devPrint("Removing camp item for source: " .. tostring(src))
    local user = Core.getUser(src)
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
    local character = Core.getUser(src).getUsedCharacter
    local campCoords = json.encode(tentCoords)
    local furniture = json.encode(furnitureCoords or {}) -- Ensure furniture is not nil
    tentModel = tentModel or 'default_tent_model' -- Fallback to a default tent model if not provided
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

    local result = MySQL.query.await(
                       "SELECT * FROM bcc_camp WHERE charidentifier=@charidentifier",
                       {['charidentifier'] = character.charIdentifier})

    if #result == 0 then
        -- Insert new camp (tent)
        MySQL.insert(
            "INSERT INTO bcc_camp (`charidentifier`, `firstname`, `lastname`, `campname`, `stash`, `camp_coordinates`, `furniture`, `tent_model`) VALUES (@charidentifier, @firstname, @lastname, @campname, @stash, @camp_coordinates, @furniture, @tent_model)",
            param)
        if Config.notify == "vorp" then
            Core.NotifyRightTip(src, "Camp created successfully", 4000)
        elseif Config.notify == "ox" then
            lib.notify(src, {
                description = "Camp created successfully",
                duration = 4000,
                type = 'success',
                style = Config.oxstyle,
                position = Config.oxposition
            })
        end
        if Config.discordlog then     
            Discord:sendMessage("**Camp Created**\nCharacter: " ..
                                    character.firstname .. " " .. character.lastname ..
                                    "\nCamp Name: " .. param['campname'] ..
                                    "\nCoordinates: " .. campCoords)
        end
        if Config.oxLogger then
            -- Fromat the JSON data
            local formattedCoords = formatCoords(campCoords)
            lib.logger(src, _U('oxLogCampCreated'), _U('oxLogMessageStart') ..
                character.firstname .. ' ' .. character.lastname,
                _U('oxLogCampName') .. param['campname'],
                _U('oxLogCampCoords') .. formattedCoords,
                _U('oxLogPID') .. src)
        end
        devPrint("Camp created for charIdentifier: " .. character.charIdentifier)
    else
        -- Update the existing camp coordinates and furniture
        MySQL.update(
            'UPDATE bcc_camp SET camp_coordinates=@camp_coordinates, furniture=@furniture, tent_model=@tent_model WHERE charidentifier=@charidentifier',
            {
                ['@charidentifier'] = character.charIdentifier,
                ['@camp_coordinates'] = campCoords,
                ['@furniture'] = furniture,
                ['@tent_model'] = tentModel
            })
        if Config.notify == "vorp" then
            Core.NotifyRightTip(src, "Camp updated successfully", 4000)
        elseif Config.notify == "ox" then
            lib.notify(src, {
                description = "Camp updated successfully",
                duration = 4000,
                type = 'success',
                style = Config.oxstyle,
                position = Config.oxposition
            })
        end
        if Config.discordlog then
            Discord:sendMessage("**Camp Updated**\nCharacter: " ..
                                character.firstname .. " " .. character.lastname ..
                                "\nUpdated Coordinates: " .. campCoords)
        end
        if Config.oxLogger then
            -- Fromat the JSON data
            local formattedCoords = formatCoords(campCoords)
            lib.logger(src, _U('oxLogCampUpdated'), _U('oxLogUpdateMessageStart') ..
                character.firstname .. ' ' .. character.lastname,
                _U('oxLogCampName') .. param['campname'],
                _U('oxLogCampCoords') .. formattedCoords,
                _U('oxLogPID') .. src)
        end
        devPrint(
            "Updated camp coordinates, furniture, and tent model for charIdentifier: " ..
                character.charIdentifier)
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
        for key, value in ipairs(Config.Furniture[mappedType]) do
            return value.hash
        end
        -- Return the first model in the list, assuming it's correct (you can modify this logic)
    end
    return nil
end

-- Load camp data for a character and correct mismatches
RegisterServerEvent('bcc-camp:loadCampData')
AddEventHandler('bcc-camp:loadCampData', function()
    local src = source
    local user = Core.getUser(src)

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
    local result = MySQL.query.await(
                       "SELECT campname, camp_coordinates, furniture, tent_model, members FROM bcc_camp WHERE charidentifier = @charidentifier OR JSON_CONTAINS(members, JSON_OBJECT('id', @charidentifier))",
                       {['@charidentifier'] = charId})

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
                devPrint(
                    "Updating furniture type from " .. furnType .. " to " ..
                        correctType)
                furnitureItem.type = correctType -- Correct the type
                needsUpdate = true
            end

            -- If model is missing or incorrect, insert correct model
            if not modelHash or not isModelInConfig(correctType, modelHash) then
                local correctModel = getCorrectFurnitureModel(correctType)
                if correctModel then
                    devPrint(
                        "Updating model for type " .. correctType .. " to " ..
                            correctModel)
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
            MySQL.Async.execute(
                "UPDATE bcc_camp SET furniture = @furniture WHERE charidentifier = @charidentifier",
                {
                    ['@furniture'] = updatedFurnitureJson,
                    ['@charidentifier'] = charId
                })
            devPrint(
                "Database updated with correct furniture data for charIdentifier: " ..
                    charId)
        end

        -- Send the updated camp data to the client
        TriggerClientEvent('bcc-camp:loadTentAndFurniture', src, {
            tentCoords = decodedCampCoordinates,
            furniture = decodedFurniture,
            tentModel = campData.tent_model,
            selectedModel = campData.tent_model
        }, true)
    else
        local result = MySQL.query.await("SELECT * FROM bcc_camp", {})
        for index, campData in ipairs(result) do
            local decodedCampCoordinates =
                json.decode(campData.camp_coordinates)
            local decodedFurniture = json.decode(campData.furniture)
            TriggerClientEvent('bcc-camp:loadTentAndFurniture', src, {
                tentCoords = decodedCampCoordinates,
                furniture = decodedFurniture,
                tentModel = campData.tent_model,
                selectedModel = campData.tent_model
            }, false)
        end
    end
end)

-- Helper function to check if a model exists in the config exactly as it is
function isModelInConfig(furnType, modelHash)
    local mappedType = mapOldTypeToConfig(furnType)

    -- Check if furniture type exists in the config
    if Config.Furniture[mappedType] then
        for _, furnitureItem in ipairs(Config.Furniture[mappedType]) do
            -- Compare model hash exactly as it is
            if furnitureItem.hash == modelHash then return true end
        end
    end
    return false
end

-- Server event to correct mismatched furniture data in the database
RegisterServerEvent('bcc-camp:correctFurnitureData')
AddEventHandler('bcc-camp:correctFurnitureData',
                function(charId, furnType, correctModel)
    -- Fetch the current camp data to modify
    local result = MySQL.query.await(
                       "SELECT furniture FROM bcc_camp WHERE charidentifier = @charidentifier OR JSON_CONTAINS(members, JSON_OBJECT('id', @charidentifier))",
                       {['@charidentifier'] = charId})

    if result and #result > 0 then
        local campData = result[1]
        local decodedFurniture = json.decode(campData.furniture)

        -- Correct the mismatched data
        for _, furnitureItem in ipairs(decodedFurniture) do
            if furnitureItem.type == furnType then
                furnitureItem.model = correctModel -- Update the model with the correct one
                devPrint("Correcting model for type: " .. furnType ..
                             " to model: " .. correctModel)
            end
        end

        -- Save the corrected data back to the database
        local updatedFurnitureJson = json.encode(decodedFurniture)
        MySQL.Async.execute(
            "UPDATE bcc_camp SET furniture = @furniture WHERE charidentifier = @charidentifier OR JSON_CONTAINS(members, JSON_OBJECT('id', @charidentifier))",
            {
                ['@furniture'] = updatedFurnitureJson,
                ['@charidentifier'] = charId
            })

        devPrint(
            "Database updated with correct furniture data for charIdentifier: " ..
                charId)
    else
        devPrint("No camp data found for character " .. charId ..
                     " during correction")
    end
end)

-- Insert furniture into camp data
RegisterServerEvent('bcc-camp:InsertFurnitureIntoCampDB')
AddEventHandler('bcc-camp:InsertFurnitureIntoCampDB', function(furnitureData)
    local src = source
    local user = Core.getUser(src)

    if not user then
        devPrint("No user found for source: " .. tostring(src))
        return
    end

    local character = user.getUsedCharacter

    devPrint("Inserting furniture for character ID: " ..
                 tostring(character.charIdentifier))

    -- Fetch the current furniture data for this character
    local result = MySQL.query.await(
                       "SELECT furniture FROM bcc_camp WHERE charidentifier = @charidentifier OR JSON_CONTAINS(members, JSON_OBJECT('id', @charidentifier))",
                       {['@charidentifier'] = character.charIdentifier})

    if result and #result > 0 then
        local currentFurniture = result[1].furniture and
                                     json.decode(result[1].furniture) or {}

        for _, furn in ipairs(currentFurniture) do
            if furn.model == furnitureData.model then
                -- Notify the player that the furniture with the same model already exists
                if Config.notify == "vorp" then
                    Core.NotifyRightTip(src, _U('FurnitureExists',
                                                    furnitureData.type), 4000)
                elseif Config.notify == "ox" then
                    lib.notify(src, {
                        description = _U('FurnitureExists', furnitureData.type),
                        duration = 4000,
                        type = 'error',
                        style = Config.oxstyle,
                        position = Config.oxposition
                    })
                end
                devPrint(furnitureData.type .. " with model " ..
                             furnitureData.model ..
                             " already exists for charidentifier: " ..
                             character.charIdentifier)
                return
            end
        end

        -- Insert the new furniture if not existing
        table.insert(currentFurniture, furnitureData)
        MySQL.update.await(
            "UPDATE bcc_camp SET furniture = @furniture WHERE charidentifier = @charidentifier OR JSON_CONTAINS(members, JSON_OBJECT('id', @charidentifier))",
            {
                ['@furniture'] = json.encode(currentFurniture),
                ['@charidentifier'] = character.charIdentifier
            })

        devPrint(furnitureData.type ..
                     " successfully inserted into the database for charidentifier: " ..
                     character.charIdentifier)
        if Config.notify == "vorp" then
            Core.NotifyRightTip(src, _U('FurniturePlaced', furnitureData.type),
                                    4000)
        elseif Config.notify == "ox" then
            lib.notify(src, {
                description = _U('FurniturePlaced', furnitureData.type),
                duration = 4000,
                type = 'success',
                style = Config.oxstyle,
                position = Config.oxposition
            })
        end
        character.removeCurrency(0, furnitureData.price)
        if Config.discordlog then
            Discord:sendMessage("**Furniture Inserted**\nCharacter: " ..
                                    character.firstname .. " " .. character.lastname ..
                                    "\nFurniture Type: " .. furnitureData.type ..
                                    "\nModel: " .. furnitureData.model)
        end
        if Config.oxLogger then
            lib.logger(src, _U('oxLogFurnitureInserted'),
                _U('oxLogFurnitureInsertMessageStart') .. character.firstname .. ' ' ..
                    character.lastname .. _U('oxLogFurnitureType') ..
                    furnitureData.type .. _U('oxLogModel') .. furnitureData.model,
                _U('oxLogPID') .. src)
        end

    else
        -- If no furniture exists, create a new entry with the first piece of furniture
        local newFurniture = {furnitureData}

        MySQL.update.await(
            "UPDATE bcc_camp SET furniture = @furniture WHERE charidentifier = @charidentifier OR JSON_CONTAINS(members, JSON_OBJECT('id', @charidentifier))",
            {
                ['@furniture'] = json.encode(newFurniture),
                ['@charidentifier'] = character.charIdentifier
            })

        devPrint(furnitureData.type ..
                     " inserted as new furniture into the database for charidentifier: " ..
                     character.charIdentifier)
        if Config.notify == "vorp" then
            Core.NotifyRightTip(src, _U('FurniturePlaced', furnitureData.type),
                                    4000)
        elseif Config.notify == "ox" then
            lib.notify(src, {
                description = _U('FurniturePlaced', furnitureData.type),
                duration = 4000,
                type = 'success',
                style = Config.oxstyle,
                position = Config.oxposition
            })
        end
        character.removeCurrency(0, furnitureData.price)
        if Config.discordlog then
            Discord:sendMessage("**New Furniture Inserted**\nCharacter: " ..
                                    character.firstname .. " " .. character.lastname ..
                                    "\nFurniture Type: " .. furnitureData.type ..
                                    "\nModel: " .. furnitureData.model)
        end
        if Config.oxLogger then
            lib.logger(src, _U('oxLogFurnitureInserted'),
                _U('oxLogFurnitureInsertMessageStart') .. character.firstname .. ' ' ..
                    character.lastname .. _U('oxLogFurnitureType') ..
                    furnitureData.type .. _U('oxLogModel') .. furnitureData.model,
                _U('oxLogPID') .. src, "CharacterID: " ..
                    character.charIdentifier)
        end

    end
end)

-- Server-side: Delete camp from the database
RegisterServerEvent('bcc-camp:DeleteCamp')
AddEventHandler('bcc-camp:DeleteCamp', function()
    local src = source
    local user = Core.getUser(src)

    if not user then
        devPrint("No user found for source: " .. tostring(src))
        return
    end

    local character = user.getUsedCharacter
    local charIdentifier = character.charIdentifier

    local result = MySQL.query.await(
                       "SELECT * FROM bcc_camp WHERE charidentifier = @charidentifier",
                       {['@charidentifier'] = character.charIdentifier})
    if result[1] then
        MySQL.update(
            "DELETE FROM bcc_camp WHERE charidentifier = @charidentifier",
            {['@charidentifier'] = charIdentifier})
        devPrint("Deleting camp for character ID: " .. tostring(charIdentifier))

        -- Notify the client that the camp has been deleted
        TriggerEvent('bcc-camp:loadCampData')
        -- Send a Discord notification for logging purposes
        if Config.discordlog then
            Discord:sendMessage("**Camp Deleted**\nCharacter: " ..
                                    character.firstname .. " " .. character.lastname)
        end
        if Config.oxLogger then
            lib.logger(src, _U('oxLogCampDeleted'),
                _U('oxLogDeleteMessageStart') .. character.firstname .. ' ' ..
                    character.lastname, _U('oxLogPID') .. src)
        end
        if Config.CampItem.enabled then
            if Config.CampItem.GiveBack then
                exports.vorp_inventory:addItem(src, Config.CampItem.CampItem, 1)
            end
            TriggerClientEvent('bcc-camp:DeleteCampFurniture', src)
        end
        if Config.notify == "vorp" then
            Core.NotifyRightTip(src, "Camp deleted successfully", 4000)
        elseif Config.notify == "ox" then
            lib.notify(src, {
                description = "Camp deleted successfully",
                duration = 4000,
                type = 'success',
                style = Config.oxstyle,
                position = Config.oxposition
            })
        end
    else
        if Config.notify == "vorp" then
            Core.NotifyRightTip(src, "You are not the camp owner", 4000)
        elseif Config.notify == "ox" then
            lib.notify(src, {
                description = "You are not the camp owner",
                duration = 4000,
                type = 'error',
                style = Config.oxstyle,
                position = Config.oxposition
            })
        end
    end
end)

-- Server-side: Remove furniture from the database
RegisterServerEvent('bcc-camp:removeFurnitureFromDB')
AddEventHandler('bcc-camp:removeFurnitureFromDB', function(furnitureType,model,price)
    local src = source
    local user = Core.getUser(src)

    if not user then
        devPrint("No user found for source: " .. tostring(src)) -- Dev print
        return
    end
    local character = user.getUsedCharacter
    local charIdentifier = character.charIdentifier

    devPrint("Attempting to remove furniture for character ID: " ..
                 tostring(charIdentifier)) -- Dev print

    -- Fetch current furniture data from the database
    local result = MySQL.query.await(
                       "SELECT furniture FROM bcc_camp WHERE charidentifier = @charidentifier OR JSON_CONTAINS(members, JSON_OBJECT('id', @charidentifier))",
                       {['@charidentifier'] = charIdentifier})

    if result and #result > 0 then
        devPrint("Furniture data found for character ID: " ..
                     tostring(charIdentifier)) -- Dev print
        local currentFurniture = result[1].furniture and
                                     json.decode(result[1].furniture) or {}

        -- Find the furniture to remove based on the furniture type
        for i, furn in ipairs(currentFurniture) do
            if furn.type == furnitureType then
                devPrint("Removing furniture: " .. furnitureType ..
                             " for character ID: " .. tostring(charIdentifier)) -- Dev print
                table.remove(currentFurniture, i)
                break
            end
        end

        -- Update the database with the new furniture data (without the removed furniture)
        MySQL.update.await(
            "UPDATE bcc_camp SET furniture = @furniture WHERE charidentifier = @charidentifier OR JSON_CONTAINS(members, JSON_OBJECT('id', @charidentifier))",
            {
                ['@furniture'] = json.encode(currentFurniture),
                ['@charidentifier'] = charIdentifier
            })

        -- Notify the client that the furniture was removed
        if Config.notify == "vorp" then
            Core.NotifyRightTip(src, "Furniture removed successfully", 4000)
        elseif Config.notify == "ox" then
            lib.notify(src, {
                description = "Furniture removed successfully",
                duration = 4000,
                type = 'success',
                style = Config.oxstyle,
                position = Config.oxposition
            })
        end
        character.addCurrency(0, price)
        devPrint("Furniture removed successfully for character ID: " ..
                     tostring(charIdentifier)) -- Dev print

        -- Send Discord notification
        if Config.discordlog then
            Discord:sendMessage("**Furniture Removed**\nCharacter: " ..
                                    character.firstname .. " " .. character.lastname ..
                                    "\nRemoved Furniture: " .. furnitureType)
        end
        if Config.oxLogger then
            lib.logger(src, _U('oxLogFurnitureRemoved'),
                _U('oxLogFurnitureRemoveMessageStart') .. character.firstname .. ' ' ..
                    character.lastname .. _U('oxLogFurnitureType') .. furnitureType,
                _U('oxLogPID') .. src)
        end
    else
        -- No furniture found
        if Config.notify == "vorp" then
            Core.NotifyRightTip(src, "No furniture found to remove", 4000)
        elseif Config.notify == "ox" then
            lib.notify(src, {
                description = "No furniture found to remove",
                duration = 4000,
                type = 'error',
                style = Config.oxstyle,
                position = Config.oxposition
            })
        end
        devPrint("No furniture found for character ID: " ..
                     tostring(charIdentifier)) -- Dev print
    end
end)

RegisterServerEvent('bcc-camp:DonateCampItems')
AddEventHandler('bcc-camp:DonateCampItems', function(DonatedItems)
    local src = source
    local user = Core.getUser(src)
    if not user then
        devPrint("ERROR: User not found for source: " .. tostring(src))
        return
    end
    local Character = user.getUsedCharacter
    local gainpercent = 0
    for key, value in pairs(DonatedItems) do
        exports.vorp_inventory:subItem(src, key, value)
        for _, item in ipairs(Config.CampUpkeepItems) do
            if item.dbname == key then
                gainpercent = gainpercent + item.percent * value
            end
        end
    end

    MySQL.update.await(
        'UPDATE bcc_camp SET `condition` = `condition` + @newcondition WHERE charidentifier = @charid OR JSON_CONTAINS(members, JSON_OBJECT("id", @charid))',
        {
            ['@newcondition'] = gainpercent,
            ['@charid'] = Character.charIdentifier
        })
end)

Core.Callback.Register('bcc-camp:GetCampCondition', function(source, callback)
    local _source = source
    local user = Core.getUser(_source)
    if not user then
        devPrint("ERROR: User not found for source: " .. tostring(_source))
        return
    end
    local Character = user.getUsedCharacter
    local charid = Character.charIdentifier
    local result = MySQL.query.await(
                       'SELECT * FROM bcc_camp WHERE charidentifier = @charid OR JSON_CONTAINS(members, JSON_OBJECT("id", @charid))',
                       {['@charid'] = charid})
    local condition = result[1].condition
    callback(condition)
end)

Core.Callback.Register('bcc-camp:GetPlayerItems', function(source, callback)
    local src = source
    local user = Core.getUser(src)
    if not user then
        devPrint("ERROR: User not found for source: " .. tostring(src))
        return
    end
    local userInv = exports.vorp_inventory:getUserInventoryItems(src)
    local campupkeepitems = Config.CampUpkeepItems
    local ItemsFound = false
    local PlayerItems = {}

    for _, value in pairs(userInv) do
        for _, v in pairs(campupkeepitems) do
            if value.name == v.dbname then
                ItemsFound = true
                PlayerItems[value.name] = {
                    label = value.label,
                    count = value.count
                }
            end
        end
    end
    if ItemsFound then
        local data = {PlayerItems}
        callback(data)
    else
        callback(false)
    end
end)

CreateThread(function() -- Tax handling
    if Config.collectTaxes then -- Check if tax collection is enabled
        local date = os.date("%d")
        local result = MySQL.query.await("SELECT * FROM bcc_camp")
        if tonumber(date) == tonumber(Config.TaxDay) then -- for some reason these have to be tonumbered
            if #result > 0 then
                for k, v in pairs(result) do
                    local param = {['campid'] = v.id}
                    if v.taxes_collected == 'false' then
                        if tonumber(v.condition) < Config.TaxRepoCondition or
                            tonumber(v.condition) == 0 then
                            exports.oxmysql:execute(
                                "DELETE FROM bcc_camp WHERE id=@campid", param)
                            -- Discord:sendMessage(_U("houseIdWebhook") .. tostring(v.campid), _U("taxPaidFailedWebhook"))
                        else
                            exports.oxmysql:execute(
                                "UPDATE bcc_camp SET taxes_collected='true' WHERE id=@campid",
                                param)
                            -- Discord:sendMessage(_U("houseIdWebhook") .. tostring(v.campid), _U("taxPaidWebhook"))
                        end
                    end
                end
            end
        elseif tonumber(date) == tonumber(Config.TaxResetDay) then
            if #result > 0 then
                for k, v in pairs(result) do
                    local param = {['campid'] = v.campid}
                    exports.oxmysql:execute(
                        "UPDATE bcc_camp SET taxes_collected='false' WHERE id=@campid",
                        param)
                end
            end
        end
    end
end)

-- Server-side: Delete camp from the database
RegisterServerEvent('bcc-camp:AddCampMember')
AddEventHandler('bcc-camp:AddCampMember', function(charid)
    local src = source
    local user = Core.getUser(charid)
    local user1 = Core.getUser(src)
    if not user then
        devPrint("No user found for source: " .. tostring(charid))
        return
    end
    if not user1 then
        devPrint("No user found for source: " .. tostring(charid))
        return
    end

    local character1 = user1.getUsedCharacter
    local charIdentifier1 = character1.charIdentifier

    local target = user.getUsedCharacter
    local targIdentifier = target.charIdentifier
    local firstname = target.firstname
    local newmember = {name = firstname, id = targIdentifier}

    local memberResult = MySQL.query.await(
                             'SELECT members FROM bcc_camp WHERE charidentifier = @charid',
                             {['charid'] = charIdentifier1})

    local currentMembers = {}

    if memberResult and memberResult[1] and memberResult[1].members then
        local membersData = memberResult[1].members

        -- Decode JSON string to Lua table if it exists
        if type(membersData) == "string" and membersData ~= "{}" then
            currentMembers = json.decode(membersData) or {}
        elseif type(membersData) == "table" then
            currentMembers = membersData
        end
    end

    -- Add the new member to the members list
    table.insert(currentMembers, newmember)

    -- Update the database with the updated members list
    MySQL.Async.execute(
        'UPDATE bcc_camp SET members = @newmembers WHERE charidentifier = @id',
        {
            ['@newmembers'] = json.encode(currentMembers),
            ['@id'] = charIdentifier1
        })

    devPrint("Updated members: " .. json.encode(currentMembers))
end)

Core.Callback.Register('bcc-camp:CheckMoney', function(source, callback, price)
    local _source = source
    local user = Core.getUser(_source)
    if not user then
        devPrint("ERROR: User not found for source: " .. tostring(_source))
        return
    end
    local Character = user.getUsedCharacter
    if Character.money >= price then
        callback(true)
    else
        callback(false)

    end
end)

-- Version check
devPrint("Checking version for resource: " .. GetCurrentResourceName())
BccUtils.Versioner.checkFile(GetCurrentResourceName(),
                             'https://github.com/BryceCanyonCounty/bcc-camp')

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

    local result = MySQL.query.await("SELECT * FROM bcc_camp WHERE charidentifier=@charidentifier",
        { ['charidentifier'] = character.charIdentifier })

    if #result == 0 then
        -- Insert new camp (tent)
        MySQL.insert("INSERT INTO bcc_camp (`charidentifier`, `firstname`, `lastname`, `campname`, `stash`, `camp_coordinates`, `furniture`, `tent_model`) VALUES (@charidentifier, @firstname, @lastname, @campname, @stash, @camp_coordinates, @furniture, @tent_model)",
            param)

        VORPcore.NotifyRightTip(src, "Camp created successfully", 4000)
        Discord:sendMessage("**Camp Created**\nCharacter: " .. character.firstname .. " " .. character.lastname .. "\nCamp Name: " .. param['campname'] .. "\nCoordinates: " .. campCoords)
    else
        -- Update the existing camp coordinates and furniture
        MySQL.update('UPDATE bcc_camp SET camp_coordinates=@camp_coordinates, furniture=@furniture, tent_model=@tent_model WHERE charidentifier=@charidentifier', {
            ['@charidentifier'] = character.charIdentifier,
            ['@camp_coordinates'] = campCoords,
            ['@furniture'] = furniture,
            ['@tent_model'] = tentModel
        })
        devPrint("Updated camp coordinates, furniture, and tent model for charIdentifier: " .. character.charIdentifier)
        VORPcore.NotifyRightTip(src, "Camp updated", 4000)
        Discord:sendMessage("**Camp Updated**\nCharacter: " .. character.firstname .. " " .. character.lastname .. "\nUpdated Coordinates: " .. campCoords)
    end
end)

RegisterServerEvent('bcc-camp:loadCampData')
AddEventHandler('bcc-camp:loadCampData', function()
    local src = source
    local character = VORPcore.getUser(src).getUsedCharacter
    local charId = character.charIdentifier

    -- Fetch the saved tent, furniture, and tent model data from the database
    local result = MySQL.query.await("SELECT camp_coordinates, furniture, tent_model FROM bcc_camp WHERE charidentifier = @charidentifier", {
        ['@charidentifier'] = charId
    })

    if result and #result > 0 then
        local campData = result[1]

        -- Decode the camp_coordinates and furniture fields before sending
        local decodedCampCoordinates = json.decode(campData.camp_coordinates)
        local decodedFurniture = json.decode(campData.furniture)

        devPrint("Server sending camp data to client: " .. json.encode(campData))

        -- Consolidate the data and send to the client with proper decoding
        TriggerClientEvent('bcc-camp:loadTentAndFurniture', src, {
            tentCoords = decodedCampCoordinates or nil,
            furniture = decodedFurniture or nil,
            tentModel = campData.tent_model
        })
    else
        print("No camp data found for character " .. tostring(charId))
    end
end)
RegisterServerEvent('bcc-camp:InsertFurnitureIntoCampDB')
AddEventHandler('bcc-camp:InsertFurnitureIntoCampDB', function(furnitureData)
    local src = source
    local character = VORPcore.getUser(src).getUsedCharacter

    -- First, fetch the current furniture data for this character
    local result = MySQL.query.await("SELECT furniture FROM bcc_camp WHERE charidentifier = @charidentifier", {
        ['@charidentifier'] = character.charIdentifier
    })

    -- Check if the query returned any result and handle nil furniture data
    if result and #result > 0 then
        local currentFurniture = result[1].furniture and json.decode(result[1].furniture) or {}

        -- Check if the same furniture type already exists (storagechest or fasttravelpost)
        for _, furn in ipairs(currentFurniture) do
            if furn.type == furnitureData.type then
                -- Notify the player that the furniture already exists
                TriggerClientEvent('vorp:NotifyRightTip', src, _U('FurnitureExists', furnitureData.type), 4000)
                devPrint(furnitureData.type .. " already exists for charidentifier: " .. character.charIdentifier)
                return -- Stop further execution
            end
        end

        -- If the furniture does not exist, insert it into the current furniture data
        table.insert(currentFurniture, furnitureData)

        -- Update the database with the new furniture data
        MySQL.update.await("UPDATE bcc_camp SET furniture = @furniture WHERE charidentifier = @charidentifier", {
            ['@furniture'] = json.encode(currentFurniture),
            ['@charidentifier'] = character.charIdentifier
        })

        -- Notify the player of successful insertion
        devPrint(furnitureData.type .. " successfully inserted into the database for charidentifier: " .. character.charIdentifier)
        TriggerClientEvent('vorp:NotifyRightTip', src, _U('FurniturePlaced', furnitureData.type), 4000)

        -- Send Discord notification for furniture insertion
        Discord:sendMessage("**Furniture Inserted**\nCharacter: " .. character.firstname .. " " .. character.lastname .. "\nFurniture Type: " .. furnitureData.type)

    else
        -- If no furniture exists, create a new entry with the first piece of furniture
        local newFurniture = {furnitureData}

        -- Update the database with the new furniture data
        MySQL.update.await("UPDATE bcc_camp SET furniture = @furniture WHERE charidentifier = @charidentifier", {
            ['@furniture'] = json.encode(newFurniture),
            ['@charidentifier'] = character.charIdentifier
        })

        -- Notify the player of successful insertion
        devPrint(furnitureData.type .. " inserted as new furniture into the database for charidentifier: " .. character.charIdentifier)
        TriggerClientEvent('vorp:NotifyRightTip', src, _U('FurniturePlaced', furnitureData.type), 4000)

        -- Send Discord notification for new furniture insertion
        Discord:sendMessage("**New Furniture Inserted**\nCharacter: " .. character.firstname .. " " .. character.lastname .. "\nFurniture Type: " .. furnitureData.type)
    end
end)

----------------------------------- Update Camp Position --------------------------------------------
RegisterServerEvent('bcc-camp:UpdateCampPosition')
AddEventHandler('bcc-camp:UpdateCampPosition', function(charid, newCoords)
    MySQL.update('UPDATE bcc_camp SET camp_coordinates=@camp_coordinates WHERE charidentifier=@charidentifier', {
        ['camp_coordinates'] = json.encode(newCoords),
        ['charidentifier'] = charid
    })
    TriggerClientEvent('vorp:TipBottom', source, "Camp position updated", 4000)

    -- Send Discord notification for camp position update
    Discord:sendMessage("**Camp Position Updated**\nCharacter ID: " .. charid .. "\nNew Coordinates: " .. json.encode(newCoords))
end)

----------------------------------- Delete Camp --------------------------------------------
RegisterServerEvent('bcc-camp:DeleteCamp')
AddEventHandler('bcc-camp:DeleteCamp', function(campId)
    MySQL.update("DELETE FROM bcc_camp WHERE id=@campid", { ['campid'] = campId })
    TriggerClientEvent('vorp:TipBottom', source, "Camp deleted", 4000)

    -- Send Discord notification for camp deletion
    Discord:sendMessage("**Camp Deleted**\nCamp ID: " .. campId)
end)

-- Server-side: Remove furniture from the database
RegisterServerEvent('bcc-camp:removeFurnitureFromDB')
AddEventHandler('bcc-camp:removeFurnitureFromDB', function(furnitureType)
    local src = source
    local user = VORPcore.getUser(src)
    if not user then return end

    local character = user.getUsedCharacter
    local charIdentifier = character.charIdentifier

    -- Fetch current furniture data from the database
    local result = MySQL.query.await("SELECT furniture FROM bcc_camp WHERE charidentifier = @charidentifier", {
        ['@charidentifier'] = charIdentifier
    })

    if result and #result > 0 then
        local currentFurniture = result[1].furniture and json.decode(result[1].furniture) or {}

        -- Find the furniture to remove based on the furniture type
        for i, furn in ipairs(currentFurniture) do
            if furn.type == furnitureType then
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
        TriggerClientEvent('vorp:NotifyRightTip', src, "Furniture removed successfully", 4000)

        -- Send Discord notification
        Discord:sendMessage("**Furniture Removed**\nCharacter: " .. character.firstname .. " " .. character.lastname .. "\nRemoved Furniture: " .. furnitureType)
    else
        -- No furniture found
        TriggerClientEvent('vorp:NotifyRightTip', src, "No furniture found to remove", 4000)
    end
end)

-- Version check
devPrint("Checking version for resource: " .. GetCurrentResourceName())
BccUtils.Versioner.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-camp')

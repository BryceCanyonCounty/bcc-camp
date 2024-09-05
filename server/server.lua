----------------------------------- Pulling Essentials --------------------------------------------
local VORPcore = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()

if Config.DevMode then
    -- Helper function for debugging
    function devPrint(message)
        print("^1[DEV MODE] ^4" .. message)
    end
else
    -- Define devPrint as a no-op function if DevMode is not enabled
    function devPrint(message) end
end

-- Inv creation for camp
RegisterServerEvent('bcc-camp:CampInvCreation', function(charid)
    devPrint("Creating camp inventory for charid: " .. tostring(charid))
    
    -- Define the camp inventory data
    local data = {
        id = 'Player_' .. tostring(charid) .. '_bcc-campinv',
        name = _U('InventoryName'),
        limit = Config.InventoryLimit,
        acceptWeapons = false,       -- Set to true if you want weapons to be stored
        shared = false,              -- Change to true if this inventory should be shared
        ignoreItemStackLimit = true, -- Set to false if you want item stack limits
        whitelistItems = false,      -- Set to true if only certain items can be stored
        UsePermissions = false,      -- Set to true if specific permissions are required to access
        UseBlackList = false,        -- Set to true if there is a blacklist of items
        whitelistWeapons = false     -- Set to true if only specific weapons can be stored
    }

    -- Register the inventory using VORP inventory
    exports.vorp_inventory:registerInventory(data)
    devPrint("Inventory registered with ID: " .. data.id)
end)

-- Camp inventory open
RegisterServerEvent('bcc-camp:OpenInv', function()
    local src = source
    devPrint("Opening inventory for source: " .. tostring(src))
    local user = VORPcore.getUser(src)
    if not user then 
        devPrint("ERROR: User not found for source: " .. tostring(src))
        return 
    end
    local Character = user.getUsedCharacter
    devPrint("Opening inventory for character: " .. Character.charIdentifier)
    exports.vorp_inventory:openInventory(src, 'Player_' .. Character.charIdentifier .. '_bcc-campinv')
end)

if Config.CampItem.enabled then
    exports.vorp_inventory:registerUsableItem(Config.CampItem.CampItem, function(data)
        local user = VORPcore.getUser(data.source)
        devPrint("Using camp item for source: " .. tostring(data.source))
        if not user then 
            devPrint("ERROR: User not found for source: " .. tostring(data.source))
            return 
        end
        exports.vorp_inventory:closeInventory(data.source)
        devPrint("Closed inventory for source: " .. tostring(data.source))
        TriggerClientEvent('bcc-camp:NearTownCheck', data.source)
    end)
end

-- Removing camp item
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

-- Version check
devPrint("Checking version for resource: " .. GetCurrentResourceName())
BccUtils.Versioner.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-stables')

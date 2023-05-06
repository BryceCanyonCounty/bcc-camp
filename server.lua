------------------------------- Pulling Essentials --------------------------------------------
local VORPInv = {}
VORPInv = exports.vorp_inventory:vorp_inventoryApi()
local VORPcore = {}
TriggerEvent("getCore", function(core)
  VORPcore = core
end)
local BccUtils = {}
TriggerEvent('bcc:getUtils', function(bccutils)
  BccUtils = bccutils
end)

--Inv creation for camp
RegisterServerEvent('bcc-camp:CampInvCreation', function(charid)
  VORPInv.registerInventory('Player_' .. charid .. '_bcc-campinv', Config.Language.InventoryName, Config.InventoryLimit)
end)

-- camp inv open
RegisterServerEvent('bcc-camp:OpenInv', function()
  local _source = source
  local Character = VORPcore.getUser(_source).getUsedCharacter
  VORPInv.OpenInv(_source, 'Player_' .. Character.charIdentifier.. '_bcc-campinv')
end)

---- Registering Camp Item -----
Citizen.CreateThread(function()
  if Config.CampItem.enabled then
    VORPInv.RegisterUsableItem(Config.CampItem.CampItem, function(data)
      TriggerClientEvent('bcc-camp:NearTownCheck', data.source)
    end)
  end
end)

----Removing camp item ---
RegisterServerEvent('bcc-camp:RemoveCampItem', function()
  local _source = source
  if Config.CampItem.RemoveItem then
    VORPInv.subItem(_source, Config.CampItem.CampItem, 1)
  end
end)
--This handles the version check
BccUtils.Versioner.checkRelease(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-camp')

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

RegisterServerEvent('bcc-camp:CampInvCreation', function(charid)
  VORPInv.registerInventory('Player_' .. charid .. '_bcc-campinv', Config.Language.InventoryName, Config.InventoryLimit)
end)

RegisterServerEvent('bcc-camp:OpenInv', function()
  local _source = source
  local Character = VORPcore.getUser(_source).getUsedCharacter
  VORPInv.OpenInv(_source, 'Player_' .. Character.charIdentifier.. '_bcc-campinv')
end)

--This handles the version check
BccUtils.Versioner.checkRelease(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-camp')

game 'rdr3'
fx_version "adamant"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'
author 'Jake2k4'

shared_scripts {
    'config.lua',
    'locale.lua',
	'languages/*.lua',
}

client_scripts {
    'client/functions.lua',
    'client/MenuSetup.lua',
    'client/CampSetup.lua',
}

server_scripts {
    'server/server.lua',
}

version '1.0.6'

dependencies {
    'vorp_core',
    'vorp_inventory',
    'vorp_character',
    'feather-menu',
    'feather-progressbar',
    'bcc-utils'
}

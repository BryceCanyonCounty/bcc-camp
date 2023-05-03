game 'rdr3'
fx_version "adamant"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'
author 'Jake2k4'

server_scripts {
    'server.lua',
}

shared_scripts {
    'config.lua',
}


client_scripts {
    '/client/functions.lua',
    '/client/MenuSetup.lua',
    '/client/CampSetup.lua',
}


version '1.0.1'

dependencies {
    'vorp_core',
    'vorp_inventory',
    'vorp_utils',
    'bcc-utils',
    'vorp_character',
}

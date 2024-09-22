game 'rdr3'
fx_version "adamant"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'
author 'Jake2k4'
description 'Create your own camp in RedM!'

shared_scripts {
    'config.lua',
    'locale.lua',
    'languages/*.lua',
}

client_scripts {
    'client/functions.lua',
    'client/CampSetup.lua',
    'client/MenuSetup.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/dbUpdater.lua',
    'server/server.lua',
}

version '1.0.10'

dependencies {
    'vorp_core',
    'vorp_inventory',
    'vorp_character',
    'feather-menu',
    'feather-progressbar',
    'bcc-utils'
}

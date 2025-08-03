game 'rdr3'
fx_version "adamant"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'
author 'BCC Scripts'
description 'Create your own camp in RedM!'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locale.lua',
    'languages/*.lua',
}

client_scripts {
    'client/functions.lua',
    'client/CampSetup.lua',
    'client/MenuSetup.lua',
    'client/dataview.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/dbUpdater.lua',
    'server/server.lua',
}

version '1.2.0'

dependencies {
    'vorp_core',
    'vorp_inventory',
    'vorp_character',
    'feather-menu',
    'feather-progressbar',
    'bcc-utils'
}

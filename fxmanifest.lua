--[[
    ec_outfitbag — FiveM Resource Manifest
    ---------------------------------------------------------------------------
    Abhängigkeiten: oxmysql, ox_lib
    Dokumentation:   README.md
]]

fx_version 'cerulean'
game 'gta5'

name 'ec_outfitbag'
description 'Outfit Bag – Tactical clothing storage (ESX / QBCore / QBox)'
author 'EuroCent'
version '0.0.1'

lua54 'yes'

dependencies {
    'oxmysql',
    'ox_lib',
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'locales/de.lua',
    'locales/en.lua',
    'shared/locales.lua',
    'shared/clothing.lua',
    'shared/events.lua',
    'shared/bridge.lua',
}

client_scripts {
    'framework/client/target_ox.lua',
    'framework/client/target_esx.lua',
    'framework/client/init.lua',
    'framework/client/animations.lua',
    'framework/client/clothing.lua',
    'framework/client/appearance.lua',
    'client/bags.lua',
    'client/hologram.lua',
    'client/nui.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'framework/server/mysql.lua',
    'framework/server/esx.lua',
    'framework/server/qbcore.lua',
    'framework/server/qbox.lua',
    'framework/server/inventory.lua',
    'framework/server/init.lua',
    'server/database.lua',
    'server/bags.lua',
    'server/outfits.lua',
    'server/slots.lua',
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js',
    'html/img/outfitbag.png',
    'sql/install.sql',
    'locales/de.lua',
    'locales/en.lua',
    'data/ox_inventory_item.lua',
}

exports {
    'OpenBag',
    'CloseBag',
    'IsBagOpen',
    'useItem',
    'GetPlayerMaxSlots',
    'SetPlayerMaxSlots',
    'AddPlayerMaxSlots',
    'OpenBagForPlayer',
    'CloseBagForPlayer',
    'PlaceBagForPlayer',
    'GetWorldBags',
    'HasRequiredItem',
}

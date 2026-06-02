--[[
    ec_outfitbag — OX Inventory Item-Definition (Snippet)
    ---------------------------------------------------------------------------
    Label/Beschreibung: statisch in ox_inventory/data/items.lua pflegen.
    Für mehrsprachige Item-Namen ggf. ox_lib locale oder separates Item-Resource nutzen.
    Referenz-Texte aus locales: _L('item.label'), _L('item.description')

    In ox_inventory/data/items.lua einfügen:

    ['outfitbag'] = {
        label = 'Outfit-Tasche',          -- oder EN: 'Outfit Bag'
        weight = 1200,
        stack = false,
        close = true,
        consume = 0,                      -- WICHTIG: 0 — Item wird erst bei ConsumeOnPlace entfernt
        description = 'Taktische Tasche zum Speichern und Wechseln von Outfits.',
        server = {
            export = 'ec_outfitbag.useItem',
        },
    },
]]

return {
    name = 'outfitbag',
    label = 'Outfit-Tasche',
    weight = 1200,
    stack = false,
    close = true,
    consume = 0,
    server = {
        export = 'ec_outfitbag.useItem',
    },
}

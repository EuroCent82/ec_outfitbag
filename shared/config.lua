--[[
    ec_outfitbag — Konfiguration
    ---------------------------------------------------------------------------
    Passe diese Datei pro Server an (ESX / QBCore / QBox).
    Sprache: Config.Language = 'DE' | 'EN'  → locales/de.lua | locales/en.lua
]]

Config = {}

--- Framework-Bridge
---@type 'ESX'|'QBCore'|'QBox'
Config.Framework = 'ESX'

--- Inventar-Bridge: ESX = natives Inventar / qb-inventory, OX = ox_inventory
---@type 'ESX'|'OX'
Config.Inventory = 'OX'

--- Target-Bridge: OX = ox_target, ESX = qb-target oder TextUI-Fallback
---@type 'ESX'|'OX'
Config.Target = 'OX'

--- UI- & Notify-Sprache (Datei in locales/<lang>.lua)
---@type 'DE'|'EN'|string
Config.Language = 'DE'

Config.RequiredItem = {
    --- Item zum Platzieren/Öffnen erforderlich?
    Enabled = true,
    --- Item-Name im Inventar (ox_inventory / qb-core / ESX)
    Name = 'outfitbag',
    --- Item beim Platzieren aus dem Inventar entfernen? (beim Aufheben zurück)
    ConsumeOnPlace = true,
}

--- Standard-Slots pro Charakter (kann per Export/Command erhöht werden)
Config.DefaultSlots = 5

--- Debug-/Test-Command zum UI-Öffnen ohne Item
Config.Command = 'outfitbag'

--- Wer darf eine liegende Tasche aufheben?
---@type 'everyone'|'owner'
Config.PickupAccess = 'owner'

--- Wer darf eine liegende Tasche benutzen (UI öffnen)?
---@type 'everyone'|'owner'
Config.UseAccess = 'owner'

Config.Bag = {
    --- GTA-Prop-Hash für die liegende Tasche
    Prop = `prop_cs_heist_bag_02`,
    --- Abstand vor dem Spieler beim Platzieren
    PlaceDistance = 1.2,
    --- ox_target / qb-target Interaktionsradius (Öffnen)
    InteractDistance = 2.0,
    --- Interaktionsradius (Aufheben)
    PickupDistance = 2.0,
}

--- 3D-Hologramm-Vorschau (Ped-Klon mit Outfit neben der Tasche)
Config.Hologram = {
    Enabled = true,
    --- Standard: Holo in der UI eingeschaltet
    DefaultUiEnabled = true,
    --- Position relativ zur Tasche (x = seitlich, y = vor/zurück)
    Offset = vector3(0.85, 0.0, 0.0),
    --- Zusätzlicher Höhen-Offset nach Bodenplatzierung
    GroundOffset = 0.0,
    --- Raycast-Höhe für Bodenfindung
    GroundProbe = 50.0,
    --- Blickrichtung relativ zur Tasche
    HeadingOffset = 160.0,
    Alpha = 185,
    AlphaPulse = false,
    Outline = true,
    OutlineColor = { r = 74, g = 200, b = 255, a = 255 },
    --- Position-Update-Intervall (ms) — niedrig = weniger Flackern
    UpdateInterval = 400,
}

--- ox_lib Progressbar bei Anziehen, Speichern, Tasche legen/aufheben
Config.Progress = {
    Enabled = true,
    DisableMove = false,
}

Config.Admin = {
    --- ESX-Gruppen / QB-Permissions mit Slot-Command-Zugriff
    Groups = { 'admin', 'superadmin', 'god' },
    --- Admin-Command: /giveslots <id> <5|+2|-1>
    SlotCommand = 'giveslots',
}

--- Konsolen-Debug (Bridge-Auflösung, Item-Registrierung)
Config.Debug = false

--- Kleidungs-Animationen (Kategorie-Vorschau & Anziehen)
Config.Animations = {
    Enabled = true,
    --- Vor dem Anziehen erst ausziehen (Remove-Anim + Strip)
    StripBeforeApply = true,
    --- Dauer-Fallback wenn Anim-Länge unbekannt (ms)
    DefaultDuration = 1800,
    --- Flag für TaskPlayAnim (49 = upper body, beweglich)
    Flag = 49,
    --- Reihenfolge beim vollständigen Anziehen
    ApplyOrder = { 'body', 'legs', 'feet', 'head', 'misc' },
    Categories = {
        head = { dict = 'mp_masks@on_foot@male_a', clip = 'put_on_mask', duration = 2000 },
        body = { dict = 'clothingshirt', clip = 'try_shirt_positive_d', duration = 2500 },
        legs = { dict = 'clothingtrousers', clip = 'try_trousers_neutral_c', duration = 2500 },
        feet = { dict = 'clothingshoes', clip = 'try_shoes_positive_d', duration = 2200 },
        misc = { dict = 'oddjobs@basejump@ig_15', clip = 'puton_parachute', duration = 2800 },
    },
    Save = { dict = 'clothingshirt', clip = 'try_shirt_positive_d', duration = 2000 },
    --- Animation pro Kleidungsstück (nur wenn am Outfit/Ped vorhanden)
    Items = {
        mask      = { dict = 'mp_masks@on_foot@male_a', clip = 'put_on_mask', duration = 2000 },
        hat       = { dict = 'missheistdockssetup1hardhat@', clip = 'put_on_hat', duration = 2000 },
        glasses   = { dict = 'clothingspecs', clip = 'take_off', duration = 1800 },
        ears      = { dict = 'mp_masks@on_foot@male_a', clip = 'put_on_mask', duration = 1500 },
        tshirt    = { dict = 'clothingshirt', clip = 'try_shirt_positive_d', duration = 2500 },
        torso     = { dict = 'clothingshirt', clip = 'try_shirt_positive_d', duration = 2500 },
        arms      = { dict = 'clothingshirt', clip = 'try_shirt_positive_d', duration = 2000 },
        vest      = { dict = 'clothingshirt', clip = 'try_shirt_positive_d', duration = 2000 },
        decals    = { dict = 'clothingshirt', clip = 'try_shirt_positive_d', duration = 1500 },
        chain     = { dict = 'clothingtie', clip = 'try_tie_positive_a', duration = 2000 },
        pants     = { dict = 'clothingtrousers', clip = 'try_trousers_neutral_c', duration = 2500 },
        shoes     = { dict = 'clothingshoes', clip = 'try_shoes_positive_d', duration = 2200 },
        bag       = { dict = 'oddjobs@basejump@ig_15', clip = 'puton_parachute', duration = 2800 },
        watch     = { dict = 'nmissmic4', clip = 'michael_tux_fidget', duration = 1800 },
        bracelet  = { dict = 'nmissmic4', clip = 'michael_tux_fidget', duration = 1800 },
    },
    --- Auszieh-Animationen (vor dem Anlegen eines neuen Teils)
    RemoveItems = {
        mask      = { dict = 'mp_masks@on_foot@male_a', clip = 'put_on_mask', duration = 1500 },
        hat       = { dict = 'missheistdockssetup1hardhat@', clip = 'take_off_hat', duration = 1200 },
        glasses   = { dict = 'clothingspecs', clip = 'take_off', duration = 1500 },
        ears      = { dict = 'mp_masks@on_foot@male_a', clip = 'put_on_mask', duration = 1200 },
        tshirt    = { dict = 'clothingshirt', clip = 'try_shirt_negative_a', duration = 2000 },
        torso     = { dict = 'clothingshirt', clip = 'try_shirt_negative_a', duration = 2000 },
        arms      = { dict = 'clothingshirt', clip = 'try_shirt_negative_a', duration = 1800 },
        vest      = { dict = 'clothingshirt', clip = 'try_shirt_negative_a', duration = 1800 },
        decals    = { dict = 'clothingshirt', clip = 'try_shirt_negative_a', duration = 1500 },
        chain     = { dict = 'clothingtie', clip = 'try_tie_negative_a', duration = 1800 },
        pants     = { dict = 'clothingtrousers', clip = 'try_trousers_negative_a', duration = 2200 },
        shoes     = { dict = 'clothingshoes', clip = 'try_shoes_negative_d', duration = 2000 },
        bag       = { dict = 'oddjobs@basejump@ig_15', clip = 'puton_parachute', duration = 2000 },
        watch     = { dict = 'nmissmic4', clip = 'michael_tux_fidget', duration = 1500 },
        bracelet  = { dict = 'nmissmic4', clip = 'michael_tux_fidget', duration = 1500 },
    },
    --- Tasche auf Boden legen / aufheben
    Bag = {
        Place  = { dict = 'pickup_object', clip = 'putdown_low', duration = 1200 },
        Pickup = { dict = 'pickup_object', clip = 'pickup_low', duration = 1200 },
    },
}

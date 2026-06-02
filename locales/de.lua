--[[
    ec_outfitbag — Deutsche Übersetzungen
    Sprache: de (Config.Language = 'DE')
]]

Locales = Locales or {}
Locales['de'] = {
    notify = {
        no_item = 'Du brauchst eine Outfit-Tasche.',
        no_access = 'Das darfst du nicht.',
        bag_placed = 'Outfit-Tasche platziert.',
        bag_picked = 'Outfit-Tasche aufgehoben.',
        outfit_saved = 'Outfit gespeichert.',
        outfit_applied = 'Outfit angezogen.',
        outfit_deleted = 'Outfit gelöscht.',
        outfit_renamed = 'Outfit umbenannt: %s',
        outfit_empty = 'Kein Outfit in diesem Slot.',
        no_free_slot = 'Kein freier Outfit-Slot verfügbar.',
        save_name_invalid = 'Bitte einen gültigen Outfit-Namen eingeben.',
        save_failed = 'Outfit konnte nicht gespeichert werden.',
        slots_updated = 'Outfit-Slots aktualisiert: %s',
        db_missing = 'Datenbank-Tabelle fehlt: %s — sql/install.sql importieren.',
        slots_usage = '/%s <spielerId|identifier> <slots|+3|-2>',
        slots_console = 'Nutzung: %s <serverId|identifier> <slots|+/-delta>',
    },
    ui = {
        close = 'Schließen',
        apply = 'Anziehen',
        edit = 'Bearbeiten',
        edit_tip = 'Outfit-Namen bearbeiten',
        delete = 'Löschen',
        save = 'Speichern',
        save_tip = 'Aktuelles Outfit speichern',
        badge_default = 'Wählen',
        badge_selected = 'Gewählt',
        badge_active = 'Aktiv',
        badge_empty = '—',
        empty_slot = 'Leer',
        outfit_slot = 'Outfit %s',
        outfit_name_default = 'Outfit %s',
        holo_preview = 'Vorschau',
        holo_none = 'Kein Outfit gewählt',
        holo_toggle = '3D-Hologramm',
        holo_on = 'Hologramm an',
        holo_off = 'Hologramm aus',
        cat = {
            head = 'Kopf',
            body = 'Torso',
            legs = 'Beine',
            feet = 'Füße',
            misc = 'Extra',
        },
    },
    progress = {
        apply = 'Outfit anziehen…',
        remove = 'Ausziehen…',
        save = 'Outfit speichern…',
        category = 'Vorschau…',
        bag_place = 'Tasche platzieren…',
        bag_pickup = 'Tasche aufheben…',
    },
    dialog = {
        save_title = 'Outfit speichern',
        save_name = 'Outfit-Name',
        save_desc = 'Nur Kleidung & Accessoires werden gespeichert — nicht dein Gesicht.',
        edit_title = 'Outfit bearbeiten',
        edit_desc = 'Neuen Namen für das gespeicherte Outfit eingeben.',
    },
    target = {
        open = 'Outfit-Tasche öffnen',
        pickup = 'Outfit-Tasche aufheben',
        fallback = '[E] Öffnen  \n[G] Aufheben',
    },
    item = {
        label = 'Outfit-Tasche',
        description = 'Taktische Tasche zum Speichern und Wechseln von Outfits.',
    },
}

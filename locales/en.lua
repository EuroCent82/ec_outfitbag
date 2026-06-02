--[[
    ec_outfitbag — English translations
    Language: en (Config.Language = 'EN')
]]

Locales = Locales or {}
Locales['en'] = {
    notify = {
        no_item = 'You need an outfit bag.',
        no_access = 'You are not allowed to do that.',
        bag_placed = 'Outfit bag placed.',
        bag_picked = 'Outfit bag picked up.',
        outfit_saved = 'Outfit saved.',
        outfit_applied = 'Outfit applied.',
        outfit_deleted = 'Outfit deleted.',
        outfit_renamed = 'Outfit renamed: %s',
        outfit_empty = 'No outfit in this slot.',
        no_free_slot = 'No free outfit slot available.',
        save_name_invalid = 'Please enter a valid outfit name.',
        save_failed = 'Could not save outfit.',
        slots_updated = 'Outfit slots updated: %s',
        db_missing = 'Database table missing: %s — import sql/install.sql.',
        slots_usage = '/%s <playerId|identifier> <slots|+3|-2>',
        slots_console = 'Usage: %s <serverId|identifier> <slots|+/-delta>',
    },
    ui = {
        close = 'Close',
        apply = 'Wear',
        edit = 'Edit',
        edit_tip = 'Edit outfit name',
        delete = 'Delete',
        save = 'Save',
        save_tip = 'Save current outfit',
        badge_default = 'Select',
        badge_selected = 'Selected',
        badge_active = 'Active',
        badge_empty = '—',
        empty_slot = 'Empty',
        outfit_slot = 'Outfit %s',
        outfit_name_default = 'Outfit %s',
        holo_preview = 'Preview',
        holo_none = 'No outfit selected',
        holo_toggle = '3D hologram',
        holo_on = 'Hologram on',
        holo_off = 'Hologram off',
        cat = {
            head = 'Head',
            body = 'Torso',
            legs = 'Legs',
            feet = 'Feet',
            misc = 'Extra',
        },
    },
    progress = {
        apply = 'Changing outfit…',
        remove = 'Taking off…',
        save = 'Saving outfit…',
        category = 'Previewing…',
        bag_place = 'Placing bag…',
        bag_pickup = 'Picking up bag…',
    },
    dialog = {
        save_title = 'Save outfit',
        save_name = 'Outfit name',
        save_desc = 'Only clothing and accessories are saved — not your face.',
        edit_title = 'Edit outfit',
        edit_desc = 'Enter a new name for the saved outfit.',
    },
    target = {
        open = 'Open outfit bag',
        pickup = 'Pick up outfit bag',
        fallback = '[E] Open  \n[G] Pick up',
    },
    item = {
        label = 'Outfit Bag',
        description = 'Tactical bag for saving and switching outfits.',
    },
}

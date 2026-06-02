--[[ ec_outfitbag — Server: MySQL-Zugriff & UI-Payload ]]

ECOFBDatabase = ECOFBDatabase or {}

function ECOFBDatabase.IsReady()
    local tables = ECOFBBridgeServerSchema.RequiredTables()
    for i = 1, #tables do
        local row = ECOFBBridge.MySQL.SingleSync(
            'SELECT 1 AS ok FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = ? LIMIT 1',
            { tables[i] }
        )
        if not row then
            return false, tables[i]
        end
    end
    return true
end

function ECOFBDatabase.EnsureReady()
    local ok, missing = ECOFBDatabase.IsReady()
    if not ok then
        print(('^1[ec_outfitbag]^0 %s'):format(_L('notify.db_missing', missing)))
        print(('^3[ec_outfitbag]^0 Admin: %s check | %s fix'):format(
            (Config.Database or {}).checkCommand or 'obdb',
            (Config.Database or {}).checkCommand or 'obdb'
        ))
        return false
    end
    return true
end

function ECOFBDatabase.EnsureProfile(identifier)
    local row = ECOFBBridge.MySQL.SingleSync(
        'SELECT * FROM ec_outfitbag_profiles WHERE identifier = ? LIMIT 1',
        { identifier }
    )
    if row then return row end

    ECOFBBridge.MySQL.InsertSync(
        'INSERT INTO ec_outfitbag_profiles (identifier, max_slots) VALUES (?, ?)',
        { identifier, Config.DefaultSlots }
    )

    return ECOFBBridge.MySQL.SingleSync(
        'SELECT * FROM ec_outfitbag_profiles WHERE identifier = ? LIMIT 1',
        { identifier }
    )
end

function ECOFBDatabase.GetMaxSlots(identifier)
    local profile = ECOFBDatabase.EnsureProfile(identifier)
    return profile and tonumber(profile.max_slots) or Config.DefaultSlots
end

function ECOFBDatabase.SetMaxSlots(identifier, slots)
    slots = math.max(1, math.floor(tonumber(slots) or Config.DefaultSlots))
    ECOFBDatabase.EnsureProfile(identifier)
    ECOFBBridge.MySQL.UpdateSync(
        'UPDATE ec_outfitbag_profiles SET max_slots = ? WHERE identifier = ?',
        { slots, identifier }
    )
    return slots
end

function ECOFBDatabase.AddMaxSlots(identifier, delta)
    local current = ECOFBDatabase.GetMaxSlots(identifier)
    return ECOFBDatabase.SetMaxSlots(identifier, current + (tonumber(delta) or 0))
end

function ECOFBDatabase.GetOutfits(identifier)
    return ECOFBBridge.MySQL.QuerySync(
        'SELECT slot, name, icon, color, appearance FROM ec_outfitbag_outfits WHERE identifier = ? ORDER BY slot ASC',
        { identifier }
    )
end

function ECOFBDatabase.GetActiveSlot(identifier)
    local profile = ECOFBDatabase.EnsureProfile(identifier)
    return profile and profile.active_slot and tonumber(profile.active_slot) or nil
end

function ECOFBDatabase.SetActiveSlot(identifier, slot)
    ECOFBDatabase.EnsureProfile(identifier)
    ECOFBBridge.MySQL.UpdateSync(
        'UPDATE ec_outfitbag_profiles SET active_slot = ? WHERE identifier = ?',
        { slot, identifier }
    )
end

function ECOFBDatabase.SaveOutfit(identifier, slot, name, icon, color, appearanceJson)
    ECOFBBridge.MySQL.UpdateSync([[
        INSERT INTO ec_outfitbag_outfits (identifier, slot, name, icon, color, appearance)
        VALUES (?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            name = VALUES(name),
            icon = VALUES(icon),
            color = VALUES(color),
            appearance = VALUES(appearance)
    ]], { identifier, slot, name, icon or 'shirt', color or 'red', appearanceJson })
end

function ECOFBDatabase.DeleteOutfit(identifier, slot)
    ECOFBBridge.MySQL.UpdateSync(
        'DELETE FROM ec_outfitbag_outfits WHERE identifier = ? AND slot = ?',
        { identifier, slot }
    )
end

function ECOFBDatabase.RenameOutfit(identifier, slot, name)
    ECOFBBridge.MySQL.UpdateSync(
        'UPDATE ec_outfitbag_outfits SET name = ? WHERE identifier = ? AND slot = ?',
        { name, identifier, slot }
    )
end

function ECOFBDatabase.GetOutfit(identifier, slot)
    return ECOFBBridge.MySQL.SingleSync(
        'SELECT * FROM ec_outfitbag_outfits WHERE identifier = ? AND slot = ? LIMIT 1',
        { identifier, slot }
    )
end

function ECOFBDatabase.GetWorldBags()
    return ECOFBBridge.MySQL.QuerySync('SELECT * FROM ec_outfitbag_world')
end

function ECOFBDatabase.CreateWorldBag(bagUid, ownerIdentifier, coords, heading)
    return ECOFBBridge.MySQL.InsertSync(
        'INSERT INTO ec_outfitbag_world (bag_uid, owner_identifier, pos_x, pos_y, pos_z, heading) VALUES (?, ?, ?, ?, ?, ?)',
        { bagUid, ownerIdentifier, coords.x, coords.y, coords.z, heading or 0.0 }
    )
end

function ECOFBDatabase.DeleteWorldBag(bagUid)
    ECOFBBridge.MySQL.UpdateSync('DELETE FROM ec_outfitbag_world WHERE bag_uid = ?', { bagUid })
end

function ECOFBDatabase.GetWorldBag(bagUid)
    return ECOFBBridge.MySQL.SingleSync(
        'SELECT * FROM ec_outfitbag_world WHERE bag_uid = ? LIMIT 1',
        { bagUid }
    )
end

function ECOFBDatabase.BuildUiPayload(identifier)
    local maxSlots = ECOFBDatabase.GetMaxSlots(identifier)
    local rows = ECOFBDatabase.GetOutfits(identifier)
    local outfits = {}

    for i = 1, #rows do
        local row = rows[i]
        outfits[#outfits + 1] = {
            slot = tonumber(row.slot),
            name = row.name,
            icon = row.icon,
            color = row.color,
        }
    end

    return {
        ownerIdentifier = identifier,
        maxSlots = maxSlots,
        outfits = outfits,
        activeOutfit = ECOFBDatabase.GetActiveSlot(identifier),
    }
end

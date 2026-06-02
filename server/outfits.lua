--[[ ec_outfitbag — Server: Outfit-Speichern, Anziehen, Löschen ]]

ECOFBOutfits = ECOFBOutfits or {}

function ECOFBOutfits.GetOwnerForSource(source, bagUid)
    if bagUid then
        local bag = ECOFBBags.World[bagUid] or ECOFBDatabase.GetWorldBag(bagUid)
        if bag then return bag.owner_identifier end
    end
    return ECOFBBridge.Server.GetIdentifier(source)
end

function ECOFBOutfits.FindFreeSlot(identifier)
    local maxSlots = ECOFBDatabase.GetMaxSlots(identifier)
    local used = {}
    local rows = ECOFBDatabase.GetOutfits(identifier)
    for i = 1, #rows do
        used[tonumber(rows[i].slot)] = true
    end
    for slot = 1, maxSlots do
        if not used[slot] then return slot end
    end
    return nil
end

function ECOFBOutfits.CanManage(source, bagUid)
    local owner = ECOFBOutfits.GetOwnerForSource(source, bagUid)
    local playerId = ECOFBBridge.Server.GetIdentifier(source)
    return owner ~= nil and owner == playerId
end

function ECOFBOutfits.RefreshBagUi(source, owner, bagUid)
    local payload = ECOFBDatabase.BuildUiPayload(owner)
    payload.bagUid = bagUid
    payload.canEdit = ECOFBOutfits.CanManage(source, bagUid)
    TriggerClientEvent(ECOFB.Events.Client.OpenBag, source, payload)
end

ECOFBBridge.Server.RegisterCallback(ECOFB.Callbacks.FindFreeSlot, function(source, bagUid)
    if not ECOFBOutfits.CanManage(source, bagUid) then return nil end
    local owner = ECOFBOutfits.GetOwnerForSource(source, bagUid)
    return ECOFBOutfits.FindFreeSlot(owner)
end)

ECOFBBridge.Server.RegisterCallback(ECOFB.Callbacks.GetOutfitAppearance, function(source, slot, bagUid)
    slot = tonumber(slot)
    if not slot then return nil end

    local owner = ECOFBOutfits.GetOwnerForSource(source, bagUid)
    local outfit = ECOFBDatabase.GetOutfit(owner, slot)
    if not outfit then return nil end

    return json.decode(outfit.appearance)
end)

ECOFBBridge.Server.RegisterCallback(ECOFB.Callbacks.GetOutfitDetails, function(source, slot, bagUid)
    slot = tonumber(slot)
    if not slot then return nil end

    local owner = ECOFBOutfits.GetOwnerForSource(source, bagUid)
    local outfit = ECOFBDatabase.GetOutfit(owner, slot)
    if not outfit then return nil end

    return {
        slot = tonumber(outfit.slot),
        name = outfit.name,
        icon = outfit.icon,
        color = outfit.color,
    }
end)

RegisterNetEvent(ECOFB.Events.Server.ApplyOutfit, function(slot, bagUid)
    local src = source
    slot = tonumber(slot)
    if not slot then return end

    local owner = ECOFBOutfits.GetOwnerForSource(src, bagUid)
    local outfit = ECOFBDatabase.GetOutfit(owner, slot)
    if not outfit then
        ECOFBBridge.Server.Notify(src, _L('notify.outfit_empty'), 'error')
        return
    end

    local appearance = json.decode(outfit.appearance)
    TriggerClientEvent(ECOFB.Events.Client.OpenAppearance, src, {
        mode = 'apply',
        appearance = appearance,
    })

    ECOFBDatabase.SetActiveSlot(owner, slot)
    ECOFBBridge.Server.Notify(src, _L('notify.outfit_applied'), 'success')
    ECOFBOutfits.RefreshBagUi(src, owner, bagUid)
end)

RegisterNetEvent(ECOFB.Events.Server.DeleteOutfit, function(slot, bagUid)
    local src = source
    slot = tonumber(slot)
    if not slot then return end

    if not ECOFBOutfits.CanManage(src, bagUid) then
        ECOFBBridge.Server.Notify(src, _L('notify.no_access'), 'error')
        return
    end

    local owner = ECOFBOutfits.GetOwnerForSource(src, bagUid)
    ECOFBDatabase.DeleteOutfit(owner, slot)
    ECOFBBridge.Server.Notify(src, _L('notify.outfit_deleted'), 'success')
    ECOFBOutfits.RefreshBagUi(src, owner, bagUid)
end)

RegisterNetEvent(ECOFB.Events.Server.SelectOutfit, function(_, _)
    -- Vorschau läuft clientseitig (Kategorie + Animation)
end)

RegisterNetEvent(ECOFB.Events.Server.EditOutfit, function(slot, name, bagUid)
    local src = source
    slot = tonumber(slot)
    if not slot then return end

    if not ECOFBOutfits.CanManage(src, bagUid) then
        ECOFBBridge.Server.Notify(src, _L('notify.no_access'), 'error')
        return
    end

    local owner = ECOFBOutfits.GetOwnerForSource(src, bagUid)
    local outfit = ECOFBDatabase.GetOutfit(owner, slot)
    if not outfit then
        ECOFBBridge.Server.Notify(src, _L('notify.outfit_empty'), 'error')
        return
    end

    name = tostring(name or ''):gsub('^%s+', ''):gsub('%s+$', '')
    if name == '' then
        ECOFBBridge.Server.Notify(src, _L('notify.save_name_invalid'), 'error')
        return
    end

    ECOFBDatabase.RenameOutfit(owner, slot, name)
    ECOFBBridge.Server.Notify(src, _L('notify.outfit_renamed', name), 'success')
    ECOFBOutfits.RefreshBagUi(src, owner, bagUid)
end)

RegisterNetEvent(ECOFB.Events.Server.SetCategory, function(_)
    -- Kategorie läuft clientseitig (Animation + Teil-Vorschau)
end)

--- Speichern nach Client-Dialog + Kleidungs-Capture
RegisterNetEvent('ECOFB:Server:AppearanceCaptured', function(payload, bagUid)
    local src = source
    if type(payload) ~= 'table' or type(payload.appearance) ~= 'table' then return end

    if not ECOFBOutfits.CanManage(src, bagUid) then
        ECOFBBridge.Server.Notify(src, _L('notify.no_access'), 'error')
        return
    end

    local owner = ECOFBBridge.Server.GetIdentifier(src)
    if not owner then return end

    local slot = tonumber(payload.slot) or ECOFBOutfits.FindFreeSlot(owner)
    if not slot then
        ECOFBBridge.Server.Notify(src, _L('notify.no_free_slot'), 'error')
        return
    end

    local name = tostring(payload.name or ''):gsub('^%s+', ''):gsub('%s+$', '')
    if name == '' then
        ECOFBBridge.Server.Notify(src, _L('notify.save_name_invalid'), 'error')
        return
    end

    local appearance = ECOFBClothing.NormalizeAppearance(payload.appearance)
    if not appearance then
        ECOFBBridge.Server.Notify(src, _L('notify.save_failed'), 'error')
        return
    end

    ECOFBDatabase.SaveOutfit(
        owner,
        slot,
        name,
        payload.icon or 'shirt',
        payload.color or 'red',
        json.encode(appearance)
    )

    ECOFBBridge.Server.Notify(src, _L('notify.outfit_saved'), 'success')
    ECOFBOutfits.RefreshBagUi(src, owner, bagUid)
end)

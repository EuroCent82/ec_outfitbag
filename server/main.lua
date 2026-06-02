--[[ ec_outfitbag — Server: Bootstrap, Exports, Item-Registrierung ]]

exports('OpenBagForPlayer', function(source, ownerIdentifier, bagUid)
    ECOFBBags.OpenForPlayer(source, ownerIdentifier, bagUid)
end)

exports('CloseBagForPlayer', function(source)
    TriggerClientEvent(ECOFB.Events.Client.CloseBag, source)
end)

exports('PlaceBagForPlayer', function(source)
    ECOFBBags.MarkPendingPlacement(source)
    TriggerClientEvent('ECOFB:Client:StartPlacement', source)
end)

exports('GetWorldBags', function()
    return ECOFBBags.World
end)

exports('HasRequiredItem', function(source)
    return ECOFBBridge.Server.HasRequiredItem(source)
end)

--- OX Inventory item export (items.lua: server.export = 'ec_outfitbag.useItem')
exports('useItem', function(event, item, inventory, slot, data)
    if event ~= 'usingItem' then return end

    local src = inventory and tonumber(inventory.id)
    if not src or src <= 0 then return false end

    if Config.RequiredItem.Enabled and not ECOFBBridge.Server.HasRequiredItem(src) then
        ECOFBBridge.Server.Notify(src, _L('notify.no_item'), 'error')
        return false
    end

    ECOFBBags.MarkPendingPlacement(src)
    TriggerClientEvent('ECOFB:Client:StartPlacement', src)

    -- ox_inventory darf das Item hier nicht entfernen — nur bei ConsumeOnPlace nach dem Legen.
    return false
end)

CreateThread(function()
    ECOFBBridge.MySQL.WaitReady()
    if not ECOFBDatabase.EnsureReady() then return end

    ECOFBBags.LoadWorld()
    ECOFBBags.SyncToAll()

    ECOFBBridge.Server.RegisterItemUse(function(source)
        ECOFBBags.MarkPendingPlacement(source)
        TriggerClientEvent('ECOFB:Client:StartPlacement', source)
    end)

    ECOFBBridge.Server.RegisterCallback(ECOFB.Callbacks.GetBagData, function(source, ownerIdentifier, bagUid)
        local owner = ownerIdentifier or ECOFBBridge.Server.GetIdentifier(source)
        return ECOFBDatabase.BuildUiPayload(owner)
    end)

    ECOFBBridge.Server.RegisterCallback(ECOFB.Callbacks.CanAccessBag, function(source, bagUid, accessType)
        local bag = ECOFBBags.World[bagUid] or ECOFBDatabase.GetWorldBag(bagUid)
        if not bag then return false end
        if accessType == 'pickup' then
            return ECOFBBags.CanPickup(source, bag)
        end
        return ECOFBBags.CanUse(source, bag)
    end)

    if Config.Command and Config.Command ~= '' then
        RegisterCommand(Config.Command, function(source)
            if source == 0 then return end
            ECOFBBags.OpenForPlayer(source, nil, nil)
        end, false)
    end

    print('^2[ec_outfitbag]^0 gestartet — Framework: ' .. ECOFBBridge.Framework()
        .. ' | Inventory: ' .. ECOFBBridge.Inventory()
        .. ' | Target: ' .. ECOFBBridge.Target())
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if ECOFBDatabase.EnsureReady() then
        ECOFBBags.LoadWorld()
        ECOFBBags.SyncToAll()
    end
end)

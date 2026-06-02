--[[ ec_outfitbag — Server: Welt-Taschen (Platzieren, Aufheben, Sync) ]]

ECOFBBags = ECOFBBags or {}
ECOFBBags.World = ECOFBBags.World or {}
ECOFBBags.PendingPlacement = ECOFBBags.PendingPlacement or {}

local PENDING_PLACE_MS = 30000

local function newUid()
    return ('bag_%s_%s'):format(os.time(), math.random(100000, 999999))
end

function ECOFBBags.CanPickup(source, bag)
    local identifier = ECOFBBridge.Server.GetIdentifier(source)
    if not identifier or not bag then return false end
    return ECOFBBridge.CanAccess(bag.owner_identifier, identifier, Config.PickupAccess)
end

function ECOFBBags.CanUse(source, bag)
    local identifier = ECOFBBridge.Server.GetIdentifier(source)
    if not identifier or not bag then return false end
    return ECOFBBridge.CanAccess(bag.owner_identifier, identifier, Config.UseAccess)
end

function ECOFBBags.MarkPendingPlacement(source)
    if not source then return end
    ECOFBBags.PendingPlacement[source] = GetGameTimer()
    SetTimeout(PENDING_PLACE_MS, function()
        if ECOFBBags.PendingPlacement[source] then
            ECOFBBags.PendingPlacement[source] = nil
        end
    end)
end

function ECOFBBags.CanPlace(source)
    local item = Config.RequiredItem
    if not item or not item.Enabled then return true end
    if ECOFBBags.PendingPlacement[source] then return true end
    return ECOFBBridge.Server.HasRequiredItem(source)
end

function ECOFBBags.ShouldConsumeOnPlace()
    local item = Config.RequiredItem
    return item and item.Enabled and item.ConsumeOnPlace == true
end

function ECOFBBags.Place(source, coords, heading)
    if not ECOFBBags.CanPlace(source) then
        ECOFBBridge.Server.Notify(source, _L('notify.no_item'), 'error')
        return
    end

    ECOFBBags.PendingPlacement[source] = nil

    local owner = ECOFBBridge.Server.GetIdentifier(source)
    if not owner then return end

    if ECOFBBags.ShouldConsumeOnPlace() then
        if not ECOFBBridge.Server.TakeRequiredItem(source) then
            ECOFBBridge.Server.Notify(source, _L('notify.no_item'), 'error')
            return
        end
    end

    local bagUid = newUid()
    ECOFBDatabase.CreateWorldBag(bagUid, owner, coords, heading)
    ECOFBBags.World[bagUid] = {
        bag_uid = bagUid,
        owner_identifier = owner,
        pos_x = coords.x,
        pos_y = coords.y,
        pos_z = coords.z,
        heading = heading or 0.0,
    }

    TriggerClientEvent(ECOFB.Events.Client.SpawnBag, -1, ECOFBBags.World[bagUid])
    ECOFBBridge.Server.Notify(source, _L('notify.bag_placed'), 'success')
end

function ECOFBBags.Pickup(source, bagUid)
    local bag = ECOFBBags.World[bagUid] or ECOFBDatabase.GetWorldBag(bagUid)
    if not bag then return end

    if not ECOFBBags.CanPickup(source, bag) then
        ECOFBBridge.Server.Notify(source, _L('notify.no_access'), 'error')
        return
    end

    ECOFBDatabase.DeleteWorldBag(bagUid)
    ECOFBBags.World[bagUid] = nil

    if ECOFBBags.ShouldConsumeOnPlace() then
        ECOFBBridge.Server.GiveRequiredItem(source)
    end

    TriggerClientEvent(ECOFB.Events.Client.RemoveBag, -1, bagUid)
    ECOFBBridge.Server.Notify(source, _L('notify.bag_picked'), 'success')
end

function ECOFBBags.OpenForPlayer(source, ownerIdentifier, bagUid)
    local playerIdentifier = ECOFBBridge.Server.GetIdentifier(source)
    if not playerIdentifier then return end

    local bag = bagUid and (ECOFBBags.World[bagUid] or ECOFBDatabase.GetWorldBag(bagUid)) or nil
    if bag and not ECOFBBags.CanUse(source, bag) then
        ECOFBBridge.Server.Notify(source, _L('notify.no_access'), 'error')
        return
    end

    local owner = ownerIdentifier or playerIdentifier
    ECOFBOutfits.RefreshBagUi(source, owner, bagUid)
end

function ECOFBBags.LoadWorld()
    local rows = ECOFBDatabase.GetWorldBags()
    ECOFBBags.World = {}
    for i = 1, #rows do
        local row = rows[i]
        ECOFBBags.World[row.bag_uid] = row
    end
end

function ECOFBBags.SyncToPlayer(source)
    TriggerClientEvent(ECOFB.Events.Client.SyncWorldBags, source, ECOFBBags.World)
end

function ECOFBBags.SyncToAll()
    TriggerClientEvent(ECOFB.Events.Client.SyncWorldBags, -1, ECOFBBags.World)
end

RegisterNetEvent(ECOFB.Events.Server.SyncWorldBags, function()
    ECOFBBags.SyncToPlayer(source)
end)

RegisterNetEvent(ECOFB.Events.Server.RequestPlace, function(coords, heading)
    local src = source
    if type(coords) ~= 'table' then return end
    ECOFBBags.Place(src, vector3(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0), heading or 0.0)
end)

RegisterNetEvent(ECOFB.Events.Server.RequestPickup, function(bagUid)
    ECOFBBags.Pickup(source, bagUid)
end)

RegisterNetEvent(ECOFB.Events.Server.RequestOpen, function(ownerIdentifier, bagUid)
    ECOFBBags.OpenForPlayer(source, ownerIdentifier, bagUid)
end)

RegisterNetEvent(ECOFB.Events.Server.CloseBag, function()
    TriggerClientEvent(ECOFB.Events.Client.CloseBag, source)
end)

AddEventHandler('playerDropped', function()
    ECOFBBags.PendingPlacement[source] = nil
end)

AddEventHandler('playerJoining', function()
    local src = source
    SetTimeout(1500, function()
        ECOFBBags.SyncToPlayer(src)
    end)
end)

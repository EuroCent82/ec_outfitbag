--[[ ec_outfitbag — Client: Welt-Taschen (Spawn, Placement, Sync) ]]

ECOFBClientBags = ECOFBClientBags or {}
ECOFBClientBags.Spawned = ECOFBClientBags.Spawned or {}

local function loadModel(model)
    if not IsModelInCdimage(model) then return false end
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then return false end
        Wait(0)
    end
    return true
end

function ECOFBClientBags.GetBagEntity(bagUid)
    local entry = bagUid and ECOFBClientBags.Spawned[bagUid]
    return entry and entry.entity
end

function ECOFBClientBags.Spawn(bag)
    if not bag or not bag.bag_uid then return end
    if ECOFBClientBags.Spawned[bag.bag_uid] then return end

    local model = Config.Bag.Prop
    if not loadModel(model) then return end

    local obj = CreateObject(model, bag.pos_x + 0.0, bag.pos_y + 0.0, bag.pos_z + 0.0, false, false, false)
    SetEntityHeading(obj, bag.heading or 0.0)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    SetEntityAsMissionEntity(obj, true, true)

    local function openBag()
        TriggerServerEvent(ECOFB.Events.Server.RequestOpen, bag.owner_identifier, bag.bag_uid)
    end

    local function pickupBag()
        CreateThread(function()
            ECOFBBridgeClientAnimations.PlayBagPickup(true)
            TriggerServerEvent(ECOFB.Events.Server.RequestPickup, bag.bag_uid)
        end)
    end

    ECOFBBridgeClientTarget.RegisterBag(obj, bag, openBag, pickupBag)

    ECOFBClientBags.Spawned[bag.bag_uid] = {
        entity = obj,
        data = bag,
    }
end

function ECOFBClientBags.Remove(bagUid)
    local entry = ECOFBClientBags.Spawned[bagUid]
    if not entry then return end

    if DoesEntityExist(entry.entity) then
        ECOFBBridgeClientTarget.RemoveBag(entry.entity)
        DeleteEntity(entry.entity)
    end

    ECOFBClientBags.Spawned[bagUid] = nil
end

function ECOFBClientBags.Sync(world)
    for bagUid in pairs(ECOFBClientBags.Spawned) do
        if not world[bagUid] then
            ECOFBClientBags.Remove(bagUid)
        end
    end

    for bagUid, bag in pairs(world or {}) do
        ECOFBClientBags.Spawn(bag)
    end
end

function ECOFBClientBags.StartPlacement()
    CreateThread(function()
        ECOFBBridgeClientAnimations.PlayBagPlace(true)

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local forward = GetEntityForwardVector(ped)
        local place = coords + forward * Config.Bag.PlaceDistance

        TriggerServerEvent(ECOFB.Events.Server.RequestPlace, {
            x = place.x,
            y = place.y,
            z = place.z - 0.95,
        }, GetEntityHeading(ped))
    end)
end

RegisterNetEvent(ECOFB.Events.Client.SpawnBag, function(bag)
    ECOFBClientBags.Spawn(bag)
end)

RegisterNetEvent(ECOFB.Events.Client.RemoveBag, function(bagUid)
    ECOFBClientBags.Remove(bagUid)
end)

RegisterNetEvent(ECOFB.Events.Client.SyncWorldBags, function(world)
    ECOFBClientBags.Sync(world)
end)

RegisterNetEvent('ECOFB:Client:StartPlacement', function()
    ECOFBClientBags.StartPlacement()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for bagUid in pairs(ECOFBClientBags.Spawned) do
        ECOFBClientBags.Remove(bagUid)
    end
end)

--[[ ec_outfitbag — Client: ox_target Integration ]]

ECOFBBridgeClientTargetOx = ECOFBBridgeClientTargetOx or {}

function ECOFBBridgeClientTargetOx.RegisterBag(entity, bag, onOpen, onPickup)
    if GetResourceState('ox_target') ~= 'started' then return false end

    exports.ox_target:addLocalEntity(entity, {
        {
            name = ('ecofb_open_%s'):format(bag.bag_uid),
            icon = 'fa-solid fa-shirt',
            label = _L('target.open'),
            distance = Config.Bag.InteractDistance,
            onSelect = onOpen,
        },
        {
            name = ('ecofb_pickup_%s'):format(bag.bag_uid),
            icon = 'fa-solid fa-hand',
            label = _L('target.pickup'),
            distance = Config.Bag.PickupDistance,
            onSelect = onPickup,
        },
    })
    return true
end

function ECOFBBridgeClientTargetOx.RemoveBag(entity)
    if GetResourceState('ox_target') ~= 'started' then return end
    pcall(function()
        exports.ox_target:removeLocalEntity(entity)
    end)
end

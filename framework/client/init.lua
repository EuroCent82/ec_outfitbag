--[[ ec_outfitbag — Client: Notify + Target-Router ]]

ECOFBBridgeClientTarget = ECOFBBridgeClientTarget or {}

function ECOFBBridgeClientTarget.RegisterBag(entity, bag, onOpen, onPickup)
    if ECOFBBridge.Target() == 'ox' then
        if ECOFBBridgeClientTargetOx.RegisterBag(entity, bag, onOpen, onPickup) then
            return
        end
    end

    if ECOFBBridgeClientTargetEsx.RegisterBag(entity, bag, onOpen, onPickup) then
        return
    end

    ECOFBBridgeClientTargetEsx.RegisterFallback(entity, bag, onOpen, onPickup)
end

function ECOFBBridgeClientTarget.RemoveBag(entity)
    if ECOFBBridge.Target() == 'ox' then
        ECOFBBridgeClientTargetOx.RemoveBag(entity)
    end
    ECOFBBridgeClientTargetEsx.RemoveBag(entity)
end

function ECOFBBridgeClientTarget.Notify(message, nType)
    if lib and lib.notify then
        lib.notify({ description = message, type = nType or 'inform' })
        return
    end

    if ECOFBBridge.Framework() == 'esx' and GetResourceState('esx_notify') == 'started' then
        TriggerEvent('esx:showNotification', message)
        return
    end

    if GetResourceState('qb-core') == 'started' then
        TriggerEvent('QBCore:Notify', message, nType or 'primary')
        return
    end

    print('[ec_outfitbag]', message)
end

RegisterNetEvent(ECOFB.Events.Client.Notify, function(message, nType)
    ECOFBBridgeClientTarget.Notify(message, nType)
end)

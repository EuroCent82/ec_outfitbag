--[[ ec_outfitbag — Client: Appearance-Bridge (Anziehen & Speichern) ]]

ECOFBBridgeClientAppearance = ECOFBBridgeClientAppearance or {}

function ECOFBBridgeClientAppearance.GetClothingOnly()
    return ECOFBBridgeClientClothing.Capture()
end

function ECOFBBridgeClientAppearance.Apply(appearance, animated)
    if animated then
        return ECOFBBridgeClientClothing.ApplyWithAnimations(appearance)
    end
    return ECOFBBridgeClientClothing.Apply(appearance)
end

RegisterNetEvent(ECOFB.Events.Client.OpenAppearance, function(payload)
    payload = payload or {}
    if payload.mode == 'apply' then
        ECOFBBridgeClientAppearance.Apply(payload.appearance, true)
        return
    end

    if payload.mode == 'preview' then
        ECOFBBridgeClientAppearance.Apply(payload.appearance, false)
        return
    end

    if payload.mode == 'category' then
        ECOFBBridgeClientClothing.PreviewCategory(payload.category, payload.appearance)
    end
end)

RegisterNetEvent(ECOFB.Events.Client.StartSaveOutfit, function(payload)
    payload = payload or {}

    CreateThread(function()
        local appearance = ECOFBBridgeClientAppearance.GetClothingOnly()
        if not appearance then
            ECOFBBridgeClientTarget.Notify(_L('notify.save_failed'), 'error')
            return
        end

        local items = ECOFBClothing.GetActiveItems(appearance)
        ECOFBBridgeClientAnimations.PlaySave(items)

        TriggerServerEvent('ECOFB:Server:AppearanceCaptured', {
            slot = payload.slot,
            name = payload.name,
            appearance = appearance,
        }, payload.bagUid)
    end)
end)

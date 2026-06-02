--[[ ec_outfitbag — Client: NUI-Bridge (Open/Close/Refresh, Callbacks) ]]

ECOFBNui = ECOFBNui or {}

local isOpen = false
local currentBagUid = nil
local currentOwner = nil
local previewAppearance = nil
local previewSlot = nil

local function buildPayload(data)
    return {
        maxSlots = data.maxSlots,
        outfits = data.outfits,
        activeOutfit = data.activeOutfit,
        locale = ECOFBLocales.GetUiTable(),
        language = ECOFBLocales.GetLanguage(),
        holoDefault = Config.Hologram and Config.Hologram.DefaultUiEnabled ~= false,
    }
end

local function refreshPreviewHologram()
    if not ECOFBClientHologram.IsUserEnabled() then
        ECOFBClientHologram.Hide()
        return
    end

    if not previewSlot then return end

    CreateThread(function()
        previewAppearance = lib.callback.await(
            ECOFB.Callbacks.GetOutfitAppearance,
            false,
            previewSlot,
            currentBagUid
        )

        if previewAppearance then
            ECOFBClientHologram.Show(currentBagUid, previewAppearance)
        else
            ECOFBClientHologram.Hide()
        end
    end)
end

local function syncPreviewFromPayload(data)
    if not data or not data.outfits then return end

    local slot = data.activeOutfit
    if not slot then
        for i = 1, #data.outfits do
            local outfit = data.outfits[i]
            if outfit.state == 'selected' and outfit.name then
                slot = outfit.slot
                break
            end
        end
    end

    if not slot then
        for i = 1, #data.outfits do
            local outfit = data.outfits[i]
            if outfit.name then
                slot = outfit.slot
                break
            end
        end
    end

    if slot then
        previewSlot = slot
        refreshPreviewHologram()
    else
        ECOFBClientHologram.Hide()
    end
end

function ECOFBNui.Open(data)
    isOpen = true
    currentBagUid = data and data.bagUid or nil
    currentOwner = data and data.ownerIdentifier or nil

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        data = buildPayload(data),
    })

    syncPreviewFromPayload(data)
end

--- UI aktualisieren ohne Fokus zu verlieren (z. B. nach Speichern).
function ECOFBNui.Refresh(data)
    if data then
        currentBagUid = data.bagUid or currentBagUid
        currentOwner = data.ownerIdentifier or currentOwner
    end

    SendNUIMessage({
        action = 'update',
        data = buildPayload(data or {}),
    })

    if isOpen then
        syncPreviewFromPayload(data)
    end
end

function ECOFBNui.Close()
    if not isOpen then return end
    isOpen = false
    currentBagUid = nil
    currentOwner = nil
    previewAppearance = nil
    previewSlot = nil
    ECOFBClientHologram.Hide()
    ECOFBBridgeClientAnimations.CancelProgress()
    ECOFBBridgeClientAnimations.Stop()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNetEvent(ECOFB.Events.Client.OpenBag, function(data)
    if isOpen then
        ECOFBNui.Refresh(data)
    else
        ECOFBNui.Open(data)
    end
end)

RegisterNetEvent(ECOFB.Events.Client.CloseBag, function()
    ECOFBNui.Close()
end)

RegisterNUICallback('close', function(_, cb)
    ECOFBNui.Close()
    TriggerServerEvent(ECOFB.Events.Server.CloseBag)
    cb('ok')
end)

RegisterNUICallback('selectOutfit', function(data, cb)
    cb('ok')
    previewSlot = tonumber(data.slot)
    refreshPreviewHologram()
end)

RegisterNUICallback('applyOutfit', function(data, cb)
    TriggerServerEvent(ECOFB.Events.Server.ApplyOutfit, data.slot, currentBagUid)
    cb('ok')
end)

RegisterNUICallback('editOutfit', function(data, cb)
    cb('ok')

    CreateThread(function()
        local slot = tonumber(data.slot)
        if not slot then return end

        local outfit = lib.callback.await(
            ECOFB.Callbacks.GetOutfitDetails,
            false,
            slot,
            currentBagUid
        )
        if not outfit then
            ECOFBBridgeClientTarget.Notify(_L('notify.outfit_empty'), 'error')
            return
        end

        local input = lib.inputDialog(_L('dialog.edit_title'), {
            {
                type = 'input',
                label = _L('dialog.save_name'),
                description = _L('dialog.edit_desc'),
                default = outfit.name,
                required = true,
                min = 1,
                max = 32,
            },
        })

        if not input or not input[1] then return end

        local name = tostring(input[1]):gsub('^%s+', ''):gsub('%s+$', '')
        if name == '' then
            ECOFBBridgeClientTarget.Notify(_L('notify.save_name_invalid'), 'error')
            return
        end

        if name == outfit.name then return end

        TriggerServerEvent(ECOFB.Events.Server.EditOutfit, slot, name, currentBagUid)
    end)
end)

RegisterNUICallback('deleteOutfit', function(data, cb)
    TriggerServerEvent(ECOFB.Events.Server.DeleteOutfit, data.slot, currentBagUid)
    cb('ok')
end)

--- Speichern: Name abfragen → Kleidung erfassen → Server
RegisterNUICallback('saveOutfit', function(_, cb)
    cb('ok')

    CreateThread(function()
        local slot = lib.callback.await(ECOFB.Callbacks.FindFreeSlot, false, currentBagUid)
        if not slot then
            ECOFBBridgeClientTarget.Notify(_L('notify.no_free_slot'), 'error')
            return
        end

        local input = lib.inputDialog(_L('dialog.save_title'), {
            {
                type = 'input',
                label = _L('dialog.save_name'),
                description = _L('dialog.save_desc'),
                required = true,
                min = 1,
                max = 32,
            },
        })

        if not input or not input[1] then return end

        local name = tostring(input[1]):gsub('^%s+', ''):gsub('%s+$', '')
        if name == '' then
            ECOFBBridgeClientTarget.Notify(_L('notify.save_name_invalid'), 'error')
            return
        end

        TriggerEvent(ECOFB.Events.Client.StartSaveOutfit, {
            slot = slot,
            name = name,
            bagUid = currentBagUid,
        })
    end)
end)

RegisterNUICallback('setCategory', function(data, cb)
    cb('ok')
    if not data or not data.category then return end
    ECOFBBridgeClientClothing.PreviewCategory(data.category, previewAppearance)
    if previewAppearance and ECOFBClientHologram.IsUserEnabled() then
        ECOFBClientHologram.PreviewCategory(data.category, previewAppearance)
    end
end)

RegisterNUICallback('setHoloEnabled', function(data, cb)
    cb('ok')
    local enabled = data and data.enabled == true
    ECOFBClientHologram.SetUserEnabled(enabled)
    if enabled then
        refreshPreviewHologram()
    end
end)

exports('OpenBag', function(data)
    ECOFBNui.Open(data or {})
end)

exports('CloseBag', ECOFBNui.Close)
exports('IsBagOpen', function() return isOpen end)

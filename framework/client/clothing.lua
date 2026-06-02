--[[ ec_outfitbag — Client: Kleidung erfassen & anwenden (Framework-spezifisch) ]]

ECOFBBridgeClientClothing = ECOFBBridgeClientClothing or {}

local function pedProp(ped, id)
    local drawable = GetPedPropIndex(ped, id)
    if drawable == -1 then
        return { item = -1, texture = 0 }
    end
    return { item = drawable, texture = GetPedPropTextureIndex(ped, id) }
end

local function pedComp(ped, id)
    return {
        item = GetPedDrawableVariation(ped, id),
        texture = GetPedTextureVariation(ped, id),
    }
end

function ECOFBBridgeClientClothing.CaptureFromPed()
    return ECOFBBridgeClientClothing.Capture()
end

--- Welche Items trägt der Ped gerade in einer Kategorie?
function ECOFBBridgeClientClothing.GetCategoryItemsFromPed(category)
    local captured = ECOFBBridgeClientClothing.Capture()
    if not captured then return {} end
    return ECOFBClothing.GetActiveItems(captured, category)
end

function ECOFBBridgeClientClothing.Capture()
    local fw = ECOFBBridge.Framework()

    if fw == 'esx' and GetResourceState('skinchanger') == 'started' then
        local skin = exports['skinchanger']:GetSkin()
        return ECOFBClothing.Wrap('esx', ECOFBClothing.ExtractEsx(skin or {}))
    end

    if fw == 'qbcore' then
        local ped = PlayerPedId()
        return ECOFBClothing.Wrap('qb', {
            ['pants'] = pedComp(ped, 4),
            ['arms'] = pedComp(ped, 3),
            ['t-shirt'] = pedComp(ped, 8),
            ['vest'] = pedComp(ped, 9),
            ['torso2'] = pedComp(ped, 11),
            ['shoes'] = pedComp(ped, 6),
            ['mask'] = pedComp(ped, 1),
            ['decals'] = pedComp(ped, 10),
            ['accessory'] = pedComp(ped, 7),
            ['bag'] = pedComp(ped, 5),
            ['hat'] = pedProp(ped, 0),
            ['glass'] = pedProp(ped, 1),
            ['ear'] = pedProp(ped, 2),
            ['watch'] = pedProp(ped, 6),
            ['bracelet'] = pedProp(ped, 7),
        })
    end

    if fw == 'qbox' and GetResourceState('illenium-appearance') == 'started' then
        local appearance = exports['illenium-appearance']:getPedAppearance(PlayerPedId())
        local components, props = {}, {}

        if appearance and appearance.components then
            for _, comp in pairs(appearance.components) do
                local id = comp.component_id
                if id and not ECOFBClothing.IlleniumSkipComponents[id] then
                    components[#components + 1] = {
                        component_id = id,
                        drawable = comp.drawable,
                        texture = comp.texture,
                    }
                end
            end
        end

        if appearance and appearance.props then
            for _, prop in pairs(appearance.props) do
                props[#props + 1] = {
                    prop_id = prop.prop_id,
                    drawable = prop.drawable,
                    texture = prop.texture,
                }
            end
        end

        return ECOFBClothing.Wrap('illenium', { components = components, props = props })
    end

    return nil
end

local function applyQbProp(ped, id, entry)
    if not entry then return end
    if entry.item == -1 or entry.item == 0 then
        ClearPedProp(ped, id)
        return
    end
    SetPedPropIndex(ped, id, entry.item, entry.texture or 0, true)
end

local function applyEsxClothesToPed(ped, data)
    if not data then return end

    if data.mask_1 ~= nil then SetPedComponentVariation(ped, 1, data.mask_1, data.mask_2 or 0, 0) end
    if data.arms ~= nil then SetPedComponentVariation(ped, 3, data.arms, data.arms_2 or 0, 0) end
    if data.pants_1 ~= nil then SetPedComponentVariation(ped, 4, data.pants_1, data.pants_2 or 0, 0) end
    if data.bags_1 ~= nil then SetPedComponentVariation(ped, 5, data.bags_1, data.bags_2 or 0, 0) end
    if data.shoes_1 ~= nil then SetPedComponentVariation(ped, 6, data.shoes_1, data.shoes_2 or 0, 0) end
    if data.chain_1 ~= nil then SetPedComponentVariation(ped, 7, data.chain_1, data.chain_2 or 0, 0) end
    if data.tshirt_1 ~= nil then SetPedComponentVariation(ped, 8, data.tshirt_1, data.tshirt_2 or 0, 0) end
    if data.bproof_1 ~= nil then SetPedComponentVariation(ped, 9, data.bproof_1, data.bproof_2 or 0, 0) end
    if data.decals_1 ~= nil then SetPedComponentVariation(ped, 10, data.decals_1, data.decals_2 or 0, 0) end
    if data.torso_1 ~= nil then SetPedComponentVariation(ped, 11, data.torso_1, data.torso_2 or 0, 0) end

    if data.helmet_1 ~= nil then
        if data.helmet_1 == -1 then ClearPedProp(ped, 0)
        else SetPedPropIndex(ped, 0, data.helmet_1, data.helmet_2 or 0, true) end
    end
    if data.glasses_1 ~= nil then
        if data.glasses_1 == -1 then ClearPedProp(ped, 1)
        else SetPedPropIndex(ped, 1, data.glasses_1, data.glasses_2 or 0, true) end
    end
    if data.ears_1 ~= nil then
        if data.ears_1 == -1 then ClearPedProp(ped, 2)
        else SetPedPropIndex(ped, 2, data.ears_1, data.ears_2 or 0, true) end
    end
    if data.watches_1 ~= nil then
        if data.watches_1 == -1 then ClearPedProp(ped, 6)
        else SetPedPropIndex(ped, 6, data.watches_1, data.watches_2 or 0, true) end
    end
    if data.bracelets_1 ~= nil then
        if data.bracelets_1 == -1 then ClearPedProp(ped, 7)
        else SetPedPropIndex(ped, 7, data.bracelets_1, data.bracelets_2 or 0, true) end
    end
end

function ECOFBBridgeClientClothing.ApplyToPed(ped, rawAppearance)
    local appearance = ECOFBClothing.NormalizeAppearance(rawAppearance)
    if not ped or not DoesEntityExist(ped) or not appearance or not appearance.format then return false end

    if appearance.format == 'esx' then
        applyEsxClothesToPed(ped, appearance.data)
        return true
    end

    if appearance.format == 'qb' then
        local d = appearance.data
        if d['pants'] then SetPedComponentVariation(ped, 4, d['pants'].item, d['pants'].texture, 0) end
        if d['arms'] then SetPedComponentVariation(ped, 3, d['arms'].item, d['arms'].texture, 0) end
        if d['t-shirt'] then SetPedComponentVariation(ped, 8, d['t-shirt'].item, d['t-shirt'].texture, 0) end
        if d['vest'] then SetPedComponentVariation(ped, 9, d['vest'].item, d['vest'].texture, 0) end
        if d['torso2'] then SetPedComponentVariation(ped, 11, d['torso2'].item, d['torso2'].texture, 0) end
        if d['shoes'] then SetPedComponentVariation(ped, 6, d['shoes'].item, d['shoes'].texture, 0) end
        if d['mask'] then SetPedComponentVariation(ped, 1, d['mask'].item, d['mask'].texture, 0) end
        if d['decals'] then SetPedComponentVariation(ped, 10, d['decals'].item, d['decals'].texture, 0) end
        if d['accessory'] then SetPedComponentVariation(ped, 7, d['accessory'].item, d['accessory'].texture, 0) end
        if d['bag'] then SetPedComponentVariation(ped, 5, d['bag'].item, d['bag'].texture, 0) end
        if d['hat'] then applyQbProp(ped, 0, d['hat']) end
        if d['glass'] then applyQbProp(ped, 1, d['glass']) end
        if d['ear'] then applyQbProp(ped, 2, d['ear']) end
        if d['watch'] then applyQbProp(ped, 6, d['watch']) end
        if d['bracelet'] then applyQbProp(ped, 7, d['bracelet']) end
        return true
    end

    if appearance.format == 'illenium' then
        if GetResourceState('illenium-appearance') ~= 'started' then return false end
        if appearance.data.components then
            exports['illenium-appearance']:setPedComponents(ped, appearance.data.components)
        end
        if appearance.data.props then
            exports['illenium-appearance']:setPedProps(ped, appearance.data.props)
        end
        return true
    end

    return false
end

function ECOFBBridgeClientClothing.Apply(rawAppearance)
    local appearance = ECOFBClothing.NormalizeAppearance(rawAppearance)
    if not appearance or not appearance.format then return false end

    if appearance.format == 'esx' and GetResourceState('skinchanger') == 'started' then
        local current = exports['skinchanger']:GetSkin()
        exports['skinchanger']:LoadClothes(current, appearance.data)
        return true
    end

    return ECOFBBridgeClientClothing.ApplyToPed(PlayerPedId(), appearance)
end

--- Outfit schrittweise mit Animation anziehen (nur vorhandene Teile).
function ECOFBBridgeClientClothing.ApplyWithAnimations(rawAppearance)
    local appearance = ECOFBClothing.NormalizeAppearance(rawAppearance)
    if not appearance then return false end

    local cfg = Config.Animations or {}
    if cfg.Enabled == false then
        return ECOFBBridgeClientClothing.Apply(appearance)
    end

    local merged = ECOFBBridgeClientClothing.Capture() or appearance

    ECOFBBridgeClientAnimations.PlayApplySequence(appearance, function(itemKey)
        if itemKey == 'all' then
            ECOFBBridgeClientClothing.Apply(appearance)
            return
        end

        local partial = ECOFBClothing.ExtractItem(appearance, itemKey)
        if partial then
            merged = ECOFBClothing.MergePartial(merged, partial)
            ECOFBBridgeClientClothing.Apply(merged)
        end
    end, function(itemKey)
        local strip = ECOFBClothing.StripItem(merged, itemKey)
        if strip then
            merged = ECOFBClothing.MergePartial(merged, strip)
            ECOFBBridgeClientClothing.Apply(merged)
        end
    end)

    return true
end

--- Kategorie-Vorschau: Item-Animationen + Teil-Outfit wenn gewählt.
function ECOFBBridgeClientClothing.PreviewCategory(category, rawAppearance)
    CreateThread(function()
        local partial = rawAppearance and ECOFBClothing.ExtractCategory(rawAppearance, category)
        local items

        if partial then
            items = ECOFBClothing.GetActiveItems(partial, category)
        else
            local current = ECOFBBridgeClientClothing.Capture()
            items = current and ECOFBClothing.GetActiveItems(current, category) or {}
        end

        if #items > 0 then
            ECOFBBridgeClientAnimations.PlayItems(items, true, 'progress.category')
        elseif not partial then
            ECOFBBridgeClientAnimations.PlayCategory(category, true, true)
        end

        if partial then
            local current = ECOFBBridgeClientClothing.Capture()
            local merged = current and ECOFBClothing.MergePartial(current, partial) or partial
            ECOFBBridgeClientClothing.Apply(merged)
        end
    end)
end

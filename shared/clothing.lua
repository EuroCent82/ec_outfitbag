--[[
    ec_outfitbag — Kleidungs-Filter (nur Klamotten, kein Charakter-Aussehen)
    ---------------------------------------------------------------------------
    Gespeichert werden Komponenten & Props laut skinchanger:
    Maske, Torso, Decals, Arme, Hose, Schuhe, Weste, Kette, Rucksack,
    Helm, Brille, Ohrringe, Uhr, Armband.
]]

ECOFBClothing = ECOFBClothing or {}

--- ESX / skinchanger Schlüssel (ValidClothes-kompatibel)
ECOFBClothing.EsxKeys = {
    'mask_1', 'mask_2',
    'arms', 'arms_2',
    'pants_1', 'pants_2',
    'shoes_1', 'shoes_2',
    'tshirt_1', 'tshirt_2',
    'torso_1', 'torso_2',
    'decals_1', 'decals_2',
    'bproof_1', 'bproof_2',
    'chain_1', 'chain_2',
    'bags_1', 'bags_2',
    'helmet_1', 'helmet_2',
    'glasses_1', 'glasses_2',
    'ears_1', 'ears_2',
    'watches_1', 'watches_2',
    'bracelets_1', 'bracelets_2',
}

--- Illenium: component_id 0 = Gesicht, 2 = Haare → nicht speichern
ECOFBClothing.IlleniumSkipComponents = { [0] = true, [2] = true }

function ECOFBClothing.NormalizeAppearance(raw)
    if type(raw) ~= 'table' then return nil end
    if raw.v == 1 and raw.format and raw.data then return raw end

    -- Legacy: voller ESX-Skin → nur Kleidung extrahieren
    if raw.tshirt_1 or raw.torso_1 or raw.pants_1 then
        return { v = 1, format = 'esx', data = ECOFBClothing.ExtractEsx(raw) }
    end

    return raw
end

function ECOFBClothing.ExtractEsx(skin)
    local clothes = {}
    for i = 1, #ECOFBClothing.EsxKeys do
        local key = ECOFBClothing.EsxKeys[i]
        if skin[key] ~= nil then
            clothes[key] = skin[key]
        end
    end
    return clothes
end

function ECOFBClothing.Wrap(format, data)
    return { v = 1, format = format, data = data }
end

--- Kategorie → Kleidungsteile (Vorschau / animiertes Anziehen)
ECOFBClothing.CategoryKeys = {
    head = {
        esx = { 'helmet_1', 'helmet_2', 'glasses_1', 'glasses_2', 'ears_1', 'ears_2', 'mask_1', 'mask_2' },
        qb = { 'hat', 'glass', 'ear', 'mask' },
        illenium_components = { 1 },
        illenium_props = { 0, 1, 2 },
    },
    body = {
        esx = { 'tshirt_1', 'tshirt_2', 'torso_1', 'torso_2', 'arms', 'arms_2', 'decals_1', 'decals_2', 'bproof_1', 'bproof_2', 'chain_1', 'chain_2' },
        qb = { 't-shirt', 'torso2', 'arms', 'vest', 'decals', 'accessory' },
        illenium_components = { 3, 7, 8, 9, 10, 11 },
    },
    legs = {
        esx = { 'pants_1', 'pants_2' },
        qb = { 'pants' },
        illenium_components = { 4 },
    },
    feet = {
        esx = { 'shoes_1', 'shoes_2' },
        qb = { 'shoes' },
        illenium_components = { 6 },
    },
    misc = {
        esx = { 'bags_1', 'bags_2', 'watches_1', 'watches_2', 'bracelets_1', 'bracelets_2' },
        qb = { 'bag', 'watch', 'bracelet' },
        illenium_components = { 5 },
        illenium_props = { 6, 7 },
    },
}

local function listToSet(list)
    local set = {}
    for i = 1, #list do set[list[i]] = true end
    return set
end

function ECOFBClothing.ExtractCategory(appearance, category)
    appearance = ECOFBClothing.NormalizeAppearance(appearance)
    if not appearance then return nil end

    local keys = ECOFBClothing.CategoryKeys[category]
    if not keys then return nil end

    if appearance.format == 'esx' then
        local partial = {}
        for i = 1, #(keys.esx or {}) do
            local key = keys.esx[i]
            if appearance.data[key] ~= nil then
                partial[key] = appearance.data[key]
            end
        end
        return ECOFBClothing.Wrap('esx', partial)
    end

    if appearance.format == 'qb' then
        local partial = {}
        for i = 1, #(keys.qb or {}) do
            local key = keys.qb[i]
            if appearance.data[key] then
                partial[key] = appearance.data[key]
            end
        end
        return ECOFBClothing.Wrap('qb', partial)
    end

    if appearance.format == 'illenium' then
        local compSet = listToSet(keys.illenium_components or {})
        local propSet = listToSet(keys.illenium_props or {})
        local components, props = {}, {}

        for _, comp in pairs(appearance.data.components or {}) do
            if compSet[comp.component_id] then
                components[#components + 1] = comp
            end
        end
        for _, prop in pairs(appearance.data.props or {}) do
            if propSet[prop.prop_id] then
                props[#props + 1] = prop
            end
        end

        return ECOFBClothing.Wrap('illenium', { components = components, props = props })
    end

    return nil
end

function ECOFBClothing.MergePartial(base, partial)
    base = ECOFBClothing.NormalizeAppearance(base)
    partial = ECOFBClothing.NormalizeAppearance(partial)
    if not base or not partial or base.format ~= partial.format then return partial or base end

    if base.format == 'esx' then
        local merged = {}
        for k, v in pairs(base.data) do merged[k] = v end
        for k, v in pairs(partial.data) do merged[k] = v end
        return ECOFBClothing.Wrap('esx', merged)
    end

    if base.format == 'qb' then
        local merged = {}
        for k, v in pairs(base.data) do merged[k] = v end
        for k, v in pairs(partial.data) do merged[k] = v end
        return ECOFBClothing.Wrap('qb', merged)
    end

    if base.format == 'illenium' then
        local compById, propById = {}, {}
        for _, comp in pairs(base.data.components or {}) do
            compById[comp.component_id] = comp
        end
        for _, prop in pairs(base.data.props or {}) do
            propById[prop.prop_id] = prop
        end
        for _, comp in pairs(partial.data.components or {}) do
            compById[comp.component_id] = comp
        end
        for _, prop in pairs(partial.data.props or {}) do
            propById[prop.prop_id] = prop
        end
        local components, props = {}, {}
        for _, comp in pairs(compById) do components[#components + 1] = comp end
        for _, prop in pairs(propById) do props[#props + 1] = prop end
        return ECOFBClothing.Wrap('illenium', { components = components, props = props })
    end

    return partial
end

--- Reihenfolge für Item-Animationen (Anziehen / Vorschau)
ECOFBClothing.ItemPlayOrder = {
    'shoes', 'pants', 'arms', 'tshirt', 'torso', 'vest', 'decals', 'chain',
    'mask', 'hat', 'glasses', 'ears',
    'bag', 'watch', 'bracelet',
}

--- Kategorie → Item-Schlüssel
ECOFBClothing.CategoryItems = {
    head = { 'mask', 'hat', 'glasses', 'ears' },
    body = { 'tshirt', 'torso', 'arms', 'vest', 'decals', 'chain' },
    legs = { 'pants' },
    feet = { 'shoes' },
    misc = { 'bag', 'watch', 'bracelet' },
}

local function esxPropPresent(value)
    return value ~= nil and value ~= -1
end

local function esxCompPresent(value)
    return value ~= nil and value > 0
end

local function qbPropPresent(entry)
    if type(entry) ~= 'table' then return false end
    local item = entry.item
    return item ~= nil and item ~= -1 and item ~= 0
end

local function qbCompPresent(entry)
    if type(entry) ~= 'table' then return false end
    return entry.item ~= nil and entry.item >= 0
end

function ECOFBClothing.HasItem(appearance, itemKey)
    appearance = ECOFBClothing.NormalizeAppearance(appearance)
    if not appearance or not itemKey then return false end

    local d = appearance.data or {}

    if appearance.format == 'esx' then
        if itemKey == 'hat' then return esxPropPresent(d.helmet_1) end
        if itemKey == 'glasses' then return esxPropPresent(d.glasses_1) end
        if itemKey == 'ears' then return esxPropPresent(d.ears_1) end
        if itemKey == 'mask' then return esxCompPresent(d.mask_1) end
        if itemKey == 'bag' then return esxCompPresent(d.bags_1) end
        if itemKey == 'pants' then return d.pants_1 ~= nil end
        if itemKey == 'shoes' then return d.shoes_1 ~= nil end
        if itemKey == 'tshirt' then return d.tshirt_1 ~= nil end
        if itemKey == 'torso' then return d.torso_1 ~= nil end
        if itemKey == 'arms' then return d.arms ~= nil end
        if itemKey == 'vest' then return esxCompPresent(d.bproof_1) end
        if itemKey == 'decals' then return esxCompPresent(d.decals_1) end
        if itemKey == 'chain' then return esxCompPresent(d.chain_1) end
        if itemKey == 'watch' then return esxPropPresent(d.watches_1) end
        if itemKey == 'bracelet' then return esxPropPresent(d.bracelets_1) end
        return false
    end

    if appearance.format == 'qb' then
        if itemKey == 'hat' then return qbPropPresent(d['hat']) end
        if itemKey == 'glasses' then return qbPropPresent(d['glass']) end
        if itemKey == 'ears' then return qbPropPresent(d['ear']) end
        if itemKey == 'mask' then return qbCompPresent(d['mask']) and d['mask'].item > 0 end
        if itemKey == 'bag' then return qbCompPresent(d['bag']) and d['bag'].item > 0 end
        if itemKey == 'watch' then return qbPropPresent(d['watch']) end
        if itemKey == 'bracelet' then return qbPropPresent(d['bracelet']) end
        if itemKey == 'pants' then return qbCompPresent(d['pants']) end
        if itemKey == 'shoes' then return qbCompPresent(d['shoes']) end
        if itemKey == 'tshirt' then return qbCompPresent(d['t-shirt']) end
        if itemKey == 'torso' then return qbCompPresent(d['torso2']) end
        if itemKey == 'arms' then return qbCompPresent(d['arms']) end
        if itemKey == 'vest' then return qbCompPresent(d['vest']) and d['vest'].item > 0 end
        if itemKey == 'decals' then return qbCompPresent(d['decals']) and d['decals'].item > 0 end
        if itemKey == 'chain' then return qbCompPresent(d['accessory']) and d['accessory'].item > 0 end
        return false
    end

    if appearance.format == 'illenium' then
        local compMap = {
            mask = 1, bag = 5, pants = 4, shoes = 6, tshirt = 8, torso = 11,
            arms = 3, vest = 9, decals = 10, chain = 7,
        }
        local propMap = { hat = 0, glasses = 1, ears = 2, watch = 6, bracelet = 7 }

        local compId = compMap[itemKey]
        if compId then
            for _, comp in pairs(d.components or {}) do
                if comp.component_id == compId then
                    if itemKey == 'pants' or itemKey == 'shoes' or itemKey == 'tshirt' or itemKey == 'torso' or itemKey == 'arms' then
                        return comp.drawable ~= nil
                    end
                    return comp.drawable and comp.drawable > 0
                end
            end
            return false
        end

        local propId = propMap[itemKey]
        if propId then
            for _, prop in pairs(d.props or {}) do
                if prop.prop_id == propId then
                    return prop.drawable ~= nil and prop.drawable ~= -1
                end
            end
        end
    end

    return false
end

function ECOFBClothing.GetActiveItems(appearance, category)
    appearance = ECOFBClothing.NormalizeAppearance(appearance)
    if not appearance then return {} end

    local pool = ECOFBClothing.ItemPlayOrder
    if category and ECOFBClothing.CategoryItems[category] then
        pool = ECOFBClothing.CategoryItems[category]
    end

    local items = {}
    for i = 1, #pool do
        local key = pool[i]
        if ECOFBClothing.HasItem(appearance, key) then
            items[#items + 1] = key
        end
    end
    return items
end

local function esxItemData(d, itemKey)
    if itemKey == 'hat' then return d.helmet_1, d.helmet_2 end
    if itemKey == 'glasses' then return d.glasses_1, d.glasses_2 end
    if itemKey == 'ears' then return d.ears_1, d.ears_2 end
    if itemKey == 'mask' then return d.mask_1, d.mask_2 end
    if itemKey == 'bag' then return d.bags_1, d.bags_2 end
    if itemKey == 'pants' then return d.pants_1, d.pants_2 end
    if itemKey == 'shoes' then return d.shoes_1, d.shoes_2 end
    if itemKey == 'tshirt' then return d.tshirt_1, d.tshirt_2 end
    if itemKey == 'torso' then return d.torso_1, d.torso_2 end
    if itemKey == 'arms' then return d.arms, d.arms_2 end
    if itemKey == 'vest' then return d.bproof_1, d.bproof_2 end
    if itemKey == 'decals' then return d.decals_1, d.decals_2 end
    if itemKey == 'chain' then return d.chain_1, d.chain_2 end
    if itemKey == 'watch' then return d.watches_1, d.watches_2 end
    if itemKey == 'bracelet' then return d.bracelets_1, d.bracelets_2 end
    return nil, nil
end

function ECOFBClothing.ItemsEqual(a, b, itemKey)
    a = ECOFBClothing.NormalizeAppearance(a)
    b = ECOFBClothing.NormalizeAppearance(b)
    if not a or not b or a.format ~= b.format or not itemKey then return false end

    if a.format == 'esx' then
        local a1, a2 = esxItemData(a.data or {}, itemKey)
        local b1, b2 = esxItemData(b.data or {}, itemKey)
        return a1 == b1 and (a2 or 0) == (b2 or 0)
    end

    if a.format == 'qb' then
        local map = {
            hat = 'hat', glasses = 'glass', ears = 'ear', mask = 'mask', bag = 'bag',
            watch = 'watch', bracelet = 'bracelet', pants = 'pants', shoes = 'shoes',
            tshirt = 't-shirt', torso = 'torso2', arms = 'arms', vest = 'vest',
            decals = 'decals', chain = 'accessory',
        }
        local key = map[itemKey]
        if not key then return false end
        local ea, eb = a.data[key], b.data[key]
        if type(ea) ~= 'table' or type(eb) ~= 'table' then return ea == eb end
        return ea.item == eb.item and (ea.texture or 0) == (eb.texture or 0)
    end

    if a.format == 'illenium' then
        local compMap = {
            mask = 1, bag = 5, pants = 4, shoes = 6, tshirt = 8, torso = 11,
            arms = 3, vest = 9, decals = 10, chain = 7,
        }
        local propMap = { hat = 0, glasses = 1, ears = 2, watch = 6, bracelet = 7 }
        local compId, propId = compMap[itemKey], propMap[itemKey]

        local function findComp(data, id)
            for _, comp in pairs(data.components or {}) do
                if comp.component_id == id then return comp end
            end
        end
        local function findProp(data, id)
            for _, prop in pairs(data.props or {}) do
                if prop.prop_id == id then return prop end
            end
        end

        if compId then
            local ca, cb = findComp(a.data, compId), findComp(b.data, compId)
            if not ca and not cb then return true end
            if not ca or not cb then return false end
            return ca.drawable == cb.drawable and (ca.texture or 0) == (cb.texture or 0)
        end
        if propId then
            local pa, pb = findProp(a.data, propId), findProp(b.data, propId)
            if not pa and not pb then return true end
            if not pa or not pb then return false end
            return pa.drawable == pb.drawable and (pa.texture or 0) == (pb.texture or 0)
        end
    end

    return false
end

function ECOFBClothing.ExtractItem(appearance, itemKey)
    appearance = ECOFBClothing.NormalizeAppearance(appearance)
    if not appearance or not itemKey then return nil end

    if appearance.format == 'esx' then
        local partial = {}
        local k1, k2 = esxItemData(appearance.data or {}, itemKey)
        if k1 == nil and k2 == nil then return nil end
        if itemKey == 'hat' then partial.helmet_1, partial.helmet_2 = k1, k2 or 0
        elseif itemKey == 'glasses' then partial.glasses_1, partial.glasses_2 = k1, k2 or 0
        elseif itemKey == 'ears' then partial.ears_1, partial.ears_2 = k1, k2 or 0
        elseif itemKey == 'mask' then partial.mask_1, partial.mask_2 = k1, k2 or 0
        elseif itemKey == 'bag' then partial.bags_1, partial.bags_2 = k1, k2 or 0
        elseif itemKey == 'pants' then partial.pants_1, partial.pants_2 = k1, k2 or 0
        elseif itemKey == 'shoes' then partial.shoes_1, partial.shoes_2 = k1, k2 or 0
        elseif itemKey == 'tshirt' then partial.tshirt_1, partial.tshirt_2 = k1, k2 or 0
        elseif itemKey == 'torso' then partial.torso_1, partial.torso_2 = k1, k2 or 0
        elseif itemKey == 'arms' then partial.arms, partial.arms_2 = k1, k2 or 0
        elseif itemKey == 'vest' then partial.bproof_1, partial.bproof_2 = k1, k2 or 0
        elseif itemKey == 'decals' then partial.decals_1, partial.decals_2 = k1, k2 or 0
        elseif itemKey == 'chain' then partial.chain_1, partial.chain_2 = k1, k2 or 0
        elseif itemKey == 'watch' then partial.watches_1, partial.watches_2 = k1, k2 or 0
        elseif itemKey == 'bracelet' then partial.bracelets_1, partial.bracelets_2 = k1, k2 or 0
        end
        return ECOFBClothing.Wrap('esx', partial)
    end

    if appearance.format == 'qb' then
        local map = {
            hat = 'hat', glasses = 'glass', ears = 'ear', mask = 'mask', bag = 'bag',
            watch = 'watch', bracelet = 'bracelet', pants = 'pants', shoes = 'shoes',
            tshirt = 't-shirt', torso = 'torso2', arms = 'arms', vest = 'vest',
            decals = 'decals', chain = 'accessory',
        }
        local key = map[itemKey]
        local entry = key and appearance.data[key]
        if not entry then return nil end
        return ECOFBClothing.Wrap('qb', { [key] = entry })
    end

    if appearance.format == 'illenium' then
        local compMap = {
            mask = 1, bag = 5, pants = 4, shoes = 6, tshirt = 8, torso = 11,
            arms = 3, vest = 9, decals = 10, chain = 7,
        }
        local propMap = { hat = 0, glasses = 1, ears = 2, watch = 6, bracelet = 7 }
        local compId, propId = compMap[itemKey], propMap[itemKey]
        local components, props = {}, {}

        if compId then
            for _, comp in pairs(appearance.data.components or {}) do
                if comp.component_id == compId then components[#components + 1] = comp end
            end
        end
        if propId then
            for _, prop in pairs(appearance.data.props or {}) do
                if prop.prop_id == propId then props[#props + 1] = prop end
            end
        end
        if #components == 0 and #props == 0 then return nil end
        return ECOFBClothing.Wrap('illenium', { components = components, props = props })
    end

    return nil
end

function ECOFBClothing.StripItem(appearance, itemKey)
    appearance = ECOFBClothing.NormalizeAppearance(appearance)
    if not appearance or not itemKey then return nil end

    if appearance.format == 'esx' then
        local partial = {}
        if itemKey == 'hat' then partial.helmet_1, partial.helmet_2 = -1, 0
        elseif itemKey == 'glasses' then partial.glasses_1, partial.glasses_2 = -1, 0
        elseif itemKey == 'ears' then partial.ears_1, partial.ears_2 = -1, 0
        elseif itemKey == 'watch' then partial.watches_1, partial.watches_2 = -1, 0
        elseif itemKey == 'bracelet' then partial.bracelets_1, partial.bracelets_2 = -1, 0
        elseif itemKey == 'mask' then partial.mask_1, partial.mask_2 = 0, 0
        elseif itemKey == 'bag' then partial.bags_1, partial.bags_2 = 0, 0
        elseif itemKey == 'vest' then partial.bproof_1, partial.bproof_2 = 0, 0
        elseif itemKey == 'decals' then partial.decals_1, partial.decals_2 = 0, 0
        elseif itemKey == 'chain' then partial.chain_1, partial.chain_2 = 0, 0
        else return nil end
        return ECOFBClothing.Wrap('esx', partial)
    end

    if appearance.format == 'qb' then
        local map = {
            hat = 'hat', glasses = 'glass', ears = 'ear', mask = 'mask', bag = 'bag',
            watch = 'watch', bracelet = 'bracelet', vest = 'vest', decals = 'decals', chain = 'accessory',
        }
        local key = map[itemKey]
        if not key then return nil end
        if itemKey == 'hat' or itemKey == 'glasses' or itemKey == 'ears' or itemKey == 'watch' or itemKey == 'bracelet' then
            return ECOFBClothing.Wrap('qb', { [key] = { item = -1, texture = 0 } })
        end
        return ECOFBClothing.Wrap('qb', { [key] = { item = 0, texture = 0 } })
    end

    if appearance.format == 'illenium' then
        local compMap = { mask = 1, bag = 5, vest = 9, decals = 10, chain = 7 }
        local propMap = { hat = 0, glasses = 1, ears = 2, watch = 6, bracelet = 7 }
        local compId, propId = compMap[itemKey], propMap[itemKey]
        local components, props = {}, {}

        if compId then
            components[#components + 1] = { component_id = compId, drawable = 0, texture = 0 }
        elseif propId then
            props[#props + 1] = { prop_id = propId, drawable = -1, texture = 0 }
        else
            return nil
        end
        return ECOFBClothing.Wrap('illenium', { components = components, props = props })
    end

    return nil
end

--- Welche Teile müssen beim Anziehen gewechselt werden? (remove / apply)
function ECOFBClothing.GetApplyChanges(current, target)
    current = ECOFBClothing.NormalizeAppearance(current)
    target = ECOFBClothing.NormalizeAppearance(target)
    if not current or not target or current.format ~= target.format then return {} end

    local changes = {}
    for i = 1, #ECOFBClothing.ItemPlayOrder do
        local key = ECOFBClothing.ItemPlayOrder[i]
        local hasCur = ECOFBClothing.HasItem(current, key)
        local hasTgt = ECOFBClothing.HasItem(target, key)
        local same = hasCur and hasTgt and ECOFBClothing.ItemsEqual(current, target, key)

        if not same then
            changes[#changes + 1] = {
                key = key,
                remove = hasCur,
                apply = hasTgt,
            }
        end
    end
    return changes
end

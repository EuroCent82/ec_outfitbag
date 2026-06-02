--[[
    ec_outfitbag — Shared Bridge (Framework / Inventory / Target Auflösung)
    ---------------------------------------------------------------------------
    ECOFBBridge.Framework()  → 'esx' | 'qbcore' | 'qbox'
    ECOFBBridge.Inventory()  → 'esx' | 'ox'
    ECOFBBridge.Target()     → 'esx' | 'ox'
]]

ECOFBBridge = ECOFBBridge or {}

local function norm(value)
    return string.lower(tostring(value or '')):gsub('^%s+', ''):gsub('%s+$', '')
end

function ECOFBBridge.Debug(...)
    if Config.Debug then
        print('^3[ec_outfitbag]^0', ...)
    end
end

function ECOFBBridge.Framework()
    local fw = norm(Config.Framework)
    if fw == 'qbcore' then return 'qbcore' end
    if fw == 'qbox' then return 'qbox' end
    return 'esx'
end

function ECOFBBridge.Inventory()
    local inv = norm(Config.Inventory)
    if inv == 'ox' or inv == 'ox_inventory' then return 'ox' end
    return 'esx'
end

function ECOFBBridge.Target()
    local tgt = norm(Config.Target)
    if tgt == 'ox' or tgt == 'ox_target' then return 'ox' end
    return 'esx'
end

--- Appearance-Ressource je nach Framework (Client-Bridge).
function ECOFBBridge.AppearanceResource()
    local fw = ECOFBBridge.Framework()
    if fw == 'qbox' then return 'illenium-appearance' end
    if fw == 'qbcore' then return 'qb-clothing' end
    return 'skinchanger'
end

function ECOFBBridge.IsOwnerOnly(mode)
    return norm(mode or Config.UseAccess) == 'owner'
end

--- Prüft Besitzer-Zugriff (Pickup / Use).
function ECOFBBridge.CanAccess(ownerIdentifier, playerIdentifier, mode)
    if not ECOFBBridge.IsOwnerOnly(mode) then return true end
    return ownerIdentifier ~= nil and ownerIdentifier == playerIdentifier
end

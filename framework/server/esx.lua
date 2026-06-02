ECOFBBridgeServerEsx = ECOFBBridgeServerEsx or {}

local ESX

function ECOFBBridgeServerEsx.GetEsx()
    if ESX then return ESX end
    if GetResourceState('es_extended') ~= 'started' then return nil end
    local ok, obj = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)
    if ok then ESX = obj end
    return ESX
end

function ECOFBBridgeServerEsx.GetPlayer(source)
    local esx = ECOFBBridgeServerEsx.GetEsx()
    return esx and esx.GetPlayerFromId and esx.GetPlayerFromId(source) or nil
end

function ECOFBBridgeServerEsx.GetIdentifier(source)
    local xPlayer = ECOFBBridgeServerEsx.GetPlayer(source)
    if not xPlayer then return nil end
    return xPlayer.identifier or (xPlayer.getIdentifier and xPlayer.getIdentifier())
end

function ECOFBBridgeServerEsx.GetGroup(source)
    local xPlayer = ECOFBBridgeServerEsx.GetPlayer(source)
    if not xPlayer then return nil end
    return xPlayer.getGroup and xPlayer.getGroup() or xPlayer.group
end

function ECOFBBridgeServerEsx.IsAdmin(source)
    local group = ECOFBBridgeServerEsx.GetGroup(source)
    if not group then return false end
    for _, allowed in ipairs(Config.Admin.Groups or {}) do
        if group == allowed then return true end
    end
    return false
end

function ECOFBBridgeServerEsx.RegisterCallback(name, handler)
    local esx = ECOFBBridgeServerEsx.GetEsx()
    if esx and esx.RegisterServerCallback then
        esx.RegisterServerCallback(name, function(src, cb, ...)
            cb(handler(src, ...))
        end)
        return true
    end
    return false
end

function ECOFBBridgeServerEsx.RegisterUsableItem(itemName, handler)
    local esx = ECOFBBridgeServerEsx.GetEsx()
    if esx and esx.RegisterUsableItem then
        esx.RegisterUsableItem(itemName, handler)
        return true
    end
    return false
end

function ECOFBBridgeServerEsx.AddItem(source, itemName, amount)
    local xPlayer = ECOFBBridgeServerEsx.GetPlayer(source)
    if xPlayer and xPlayer.addInventoryItem then
        xPlayer.addInventoryItem(itemName, amount or 1)
        return true
    end
    return false
end

function ECOFBBridgeServerEsx.RemoveItem(source, itemName, amount)
    local xPlayer = ECOFBBridgeServerEsx.GetPlayer(source)
    if xPlayer and xPlayer.removeInventoryItem then
        xPlayer.removeInventoryItem(itemName, amount or 1)
        return true
    end
    return false
end

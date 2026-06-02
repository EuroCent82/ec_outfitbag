ECOFBBridgeServerQbcore = ECOFBBridgeServerQbcore or {}

local QBCore

function ECOFBBridgeServerQbcore.GetCore()
    if QBCore then return QBCore end
    if GetResourceState('qb-core') ~= 'started' then return nil end
    local ok, obj = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)
    if ok then QBCore = obj end
    return QBCore
end

function ECOFBBridgeServerQbcore.GetPlayer(source)
    local core = ECOFBBridgeServerQbcore.GetCore()
    return core and core.Functions.GetPlayer(source) or nil
end

function ECOFBBridgeServerQbcore.GetIdentifier(source)
    local player = ECOFBBridgeServerQbcore.GetPlayer(source)
    if not player or not player.PlayerData then return nil end
    return player.PlayerData.citizenid
end

function ECOFBBridgeServerQbcore.GetGroup(source)
    local player = ECOFBBridgeServerQbcore.GetPlayer(source)
    if not player or not player.PlayerData then return nil end
    local perm = QBCore and QBCore.Functions.GetPermission(source)
    if type(perm) == 'table' then
        for group in pairs(perm) do return group end
    end
    return player.PlayerData.group or player.PlayerData.job and player.PlayerData.job.name
end

function ECOFBBridgeServerQbcore.IsAdmin(source)
    local group = ECOFBBridgeServerQbcore.GetGroup(source)
    if not group then return false end
    for _, allowed in ipairs(Config.Admin.Groups or {}) do
        if group == allowed then return true end
    end
    if QBCore and QBCore.Functions.HasPermission then
        return QBCore.Functions.HasPermission(source, 'admin') or QBCore.Functions.HasPermission(source, 'god')
    end
    return false
end

function ECOFBBridgeServerQbcore.RegisterCallback(name, handler)
    local core = ECOFBBridgeServerQbcore.GetCore()
    if core and core.Functions.CreateCallback then
        core.Functions.CreateCallback(name, function(src, cb, ...)
            cb(handler(src, ...))
        end)
        return true
    end
    return false
end

function ECOFBBridgeServerQbcore.RegisterUsableItem(itemName, handler)
    local core = ECOFBBridgeServerQbcore.GetCore()
    if core and core.Functions.CreateUseableItem then
        core.Functions.CreateUseableItem(itemName, function(src)
            handler(src)
        end)
        return true
    end
    return false
end

function ECOFBBridgeServerQbcore.AddItem(source, itemName, amount)
    local player = ECOFBBridgeServerQbcore.GetPlayer(source)
    if player and player.Functions.AddItem then
        return player.Functions.AddItem(itemName, amount or 1)
    end
    return false
end

function ECOFBBridgeServerQbcore.RemoveItem(source, itemName, amount)
    local player = ECOFBBridgeServerQbcore.GetPlayer(source)
    if player and player.Functions.RemoveItem then
        return player.Functions.RemoveItem(itemName, amount or 1)
    end
    return false
end

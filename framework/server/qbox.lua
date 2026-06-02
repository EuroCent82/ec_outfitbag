ECOFBBridgeServerQbox = ECOFBBridgeServerQbox or {}

function ECOFBBridgeServerQbox.GetPlayer(source)
    if GetResourceState('qbx_core') ~= 'started' then return nil end
    local ok, player = pcall(function()
        return exports.qbx_core:GetPlayer(source)
    end)
    return ok and player or nil
end

function ECOFBBridgeServerQbox.GetIdentifier(source)
    local player = ECOFBBridgeServerQbox.GetPlayer(source)
    if not player or not player.PlayerData then return nil end
    return player.PlayerData.citizenid
end

function ECOFBBridgeServerQbox.GetGroup(source)
    local player = ECOFBBridgeServerQbox.GetPlayer(source)
    if not player or not player.PlayerData then return nil end
    return player.PlayerData.group
end

function ECOFBBridgeServerQbox.IsAdmin(source)
    local group = ECOFBBridgeServerQbox.GetGroup(source)
    if not group then return false end
    for _, allowed in ipairs(Config.Admin.Groups or {}) do
        if group == allowed then return true end
    end
    if GetResourceState('qbx_core') == 'started' then
        local ok, result = pcall(function()
            return exports.qbx_core:HasPermission(source, 'admin') or exports.qbx_core:HasPermission(source, 'god')
        end)
        return ok and result or false
    end
    return false
end

function ECOFBBridgeServerQbox.RegisterCallback(name, handler)
    if lib and lib.callback and lib.callback.register then
        lib.callback.register(name, function(src, ...)
            return handler(src, ...)
        end)
        return true
    end
    return ECOFBBridgeServerQbcore.RegisterCallback(name, handler)
end

function ECOFBBridgeServerQbox.RegisterUsableItem(itemName, handler)
    if GetResourceState('ox_inventory') == 'started' then
        return false
    end
    return ECOFBBridgeServerQbcore.RegisterUsableItem(itemName, handler)
end

function ECOFBBridgeServerQbox.AddItem(source, itemName, amount)
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:AddItem(source, itemName, amount or 1)
    end
    return ECOFBBridgeServerQbcore.AddItem(source, itemName, amount)
end

function ECOFBBridgeServerQbox.RemoveItem(source, itemName, amount)
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:RemoveItem(source, itemName, amount or 1)
    end
    return ECOFBBridgeServerQbcore.RemoveItem(source, itemName, amount)
end

ECOFBBridgeServerQbox.GetCore = ECOFBBridgeServerQbcore.GetCore

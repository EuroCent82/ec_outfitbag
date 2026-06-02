--[[ ec_outfitbag — Server: Framework-Bridge (ESX / QBCore / QBox) ]]

ECOFBBridge = ECOFBBridge or {}
ECOFBBridge.Server = ECOFBBridge.Server or {}

function ECOFBBridge.Server.GetFrameworkModule()
    local fw = ECOFBBridge.Framework()
    if fw == 'qbcore' then return ECOFBBridgeServerQbcore end
    if fw == 'qbox' then return ECOFBBridgeServerQbox end
    return ECOFBBridgeServerEsx
end

function ECOFBBridge.Server.GetPlayer(source)
    local mod = ECOFBBridge.Server.GetFrameworkModule()
    return mod and mod.GetPlayer(source) or nil
end

function ECOFBBridge.Server.GetIdentifier(source)
    local mod = ECOFBBridge.Server.GetFrameworkModule()
    if mod and mod.GetIdentifier then
        local id = mod.GetIdentifier(source)
        if id then return id end
    end

    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local ident = GetPlayerIdentifier(source, i)
        if ident and ident:find('license:') then
            return ident
        end
    end
    return nil
end

function ECOFBBridge.Server.IsAdmin(source)
    local mod = ECOFBBridge.Server.GetFrameworkModule()
    return mod and mod.IsAdmin and mod.IsAdmin(source) or false
end

function ECOFBBridge.Server.RegisterCallback(name, handler)
    if lib and lib.callback and lib.callback.register then
        lib.callback.register(name, function(src, ...)
            return handler(src, ...)
        end)
        return true
    end

    local mod = ECOFBBridge.Server.GetFrameworkModule()
    if mod and mod.RegisterCallback then
        return mod.RegisterCallback(name, handler)
    end
    return false
end

function ECOFBBridge.Server.Notify(source, message, nType)
    TriggerClientEvent(ECOFB.Events.Client.Notify, source, message, nType or 'inform')
end

function ECOFBBridge.Server.RegisterItemUse(handler)
    local item = Config.RequiredItem
    if not item or not item.Enabled then return end

    local name = item.Name
    if ECOFBBridgeServerInventory.RegisterOxItem(name, handler) then
        ECOFBBridge.Debug('OX item hook registriert:', name)
        return
    end

    if ECOFBBridgeServerInventory.RegisterUsableItem(name, handler) then
        ECOFBBridge.Debug('Framework usable item registriert:', name)
    end
end

function ECOFBBridge.Server.HasRequiredItem(source)
    local item = Config.RequiredItem
    if not item or not item.Enabled then return true end
    return ECOFBBridgeServerInventory.HasItem(source, item.Name, 1)
end

function ECOFBBridge.Server.GiveRequiredItem(source)
    local item = Config.RequiredItem
    if not item or not item.Name then return false end
    return ECOFBBridgeServerInventory.AddItem(source, item.Name, 1)
end

function ECOFBBridge.Server.TakeRequiredItem(source)
    local item = Config.RequiredItem
    if not item or not item.Name then return false end
    return ECOFBBridgeServerInventory.RemoveItem(source, item.Name, 1) == true
end

--[[ ec_outfitbag — Server: Slot-Verwaltung (Exports + Admin-Command) ]]

ECOFBSlots = ECOFBSlots or {}

function ECOFBSlots.ResolveIdentifier(sourceOrIdentifier)
    if type(sourceOrIdentifier) == 'number' then
        return ECOFBBridge.Server.GetIdentifier(sourceOrIdentifier)
    end
    return sourceOrIdentifier
end

function ECOFBSlots.Get(sourceOrIdentifier)
    local identifier = ECOFBSlots.ResolveIdentifier(sourceOrIdentifier)
    if not identifier then return Config.DefaultSlots end
    return ECOFBDatabase.GetMaxSlots(identifier)
end

function ECOFBSlots.Set(sourceOrIdentifier, slots)
    local identifier = ECOFBSlots.ResolveIdentifier(sourceOrIdentifier)
    if not identifier then return false end
    return ECOFBDatabase.SetMaxSlots(identifier, slots)
end

function ECOFBSlots.Add(sourceOrIdentifier, delta)
    local identifier = ECOFBSlots.ResolveIdentifier(sourceOrIdentifier)
    if not identifier then return false end
    return ECOFBDatabase.AddMaxSlots(identifier, delta)
end

local function notifySlots(source, identifier)
    local slots = ECOFBDatabase.GetMaxSlots(identifier)
    ECOFBBridge.Server.Notify(source, _L('notify.slots_updated', slots), 'success')
end

RegisterCommand(Config.Admin.SlotCommand, function(source, args)
    if source == 0 then
        print(('[ec_outfitbag] %s'):format(_L('notify.slots_console', Config.Admin.SlotCommand)))
        return
    end

    if not ECOFBBridge.Server.IsAdmin(source) then
        ECOFBBridge.Server.Notify(source, _L('notify.no_access'), 'error')
        return
    end

    local target = args[1]
    local value = args[2]
    if not target or not value then
        ECOFBBridge.Server.Notify(source, _L('notify.slots_usage', Config.Admin.SlotCommand), 'error')
        return
    end

    local targetSource = tonumber(target)
    local identifier = targetSource and ECOFBBridge.Server.GetIdentifier(targetSource) or target

    if value:sub(1, 1) == '+' or value:sub(1, 1) == '-' then
        ECOFBSlots.Add(identifier, tonumber(value))
    else
        ECOFBSlots.Set(identifier, tonumber(value))
    end

    notifySlots(source, identifier)
end, false)

exports('GetPlayerMaxSlots', function(sourceOrIdentifier)
    return ECOFBSlots.Get(sourceOrIdentifier)
end)

exports('SetPlayerMaxSlots', function(sourceOrIdentifier, slots)
    return ECOFBSlots.Set(sourceOrIdentifier, slots)
end)

exports('AddPlayerMaxSlots', function(sourceOrIdentifier, delta)
    return ECOFBSlots.Add(sourceOrIdentifier, delta)
end)

ECOFBBridge.Server.RegisterCallback(ECOFB.Callbacks.GetPlayerSlots, function(source, targetIdentifier)
    local identifier = targetIdentifier or ECOFBBridge.Server.GetIdentifier(source)
    return ECOFBDatabase.GetMaxSlots(identifier)
end)

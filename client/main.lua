CreateThread(function()
    Wait(1500)
    TriggerServerEvent(ECOFB.Events.Server.SyncWorldBags)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Wait(1000)
    TriggerServerEvent(ECOFB.Events.Server.SyncWorldBags)
end)

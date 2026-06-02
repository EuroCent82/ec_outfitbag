ECOFBBridgeServerInventory = ECOFBBridgeServerInventory or {}

function ECOFBBridgeServerInventory.HasItem(source, itemName, amount)
    amount = tonumber(amount) or 1
    itemName = tostring(itemName or '')
    if itemName == '' then return false end

    if ECOFBBridge.Inventory() == 'ox' and GetResourceState('ox_inventory') == 'started' then
        local count = exports.ox_inventory:GetItemCount(source, itemName)
        if count == nil then
            count = exports.ox_inventory:Search(source, 'count', itemName) or 0
        end
        return count >= amount
    end

    local xPlayer = ECOFBBridgeServerEsx.GetPlayer(source)
    if xPlayer and xPlayer.getInventoryItem then
        local item = xPlayer.getInventoryItem(itemName)
        return item and (item.count or 0) >= amount
    end

    local qb = ECOFBBridgeServerQbcore.GetPlayer(source)
    if qb and qb.Functions and qb.Functions.GetItemByName then
        local item = qb.Functions.GetItemByName(itemName)
        return item and (item.amount or 0) >= amount
    end

    return false
end

function ECOFBBridgeServerInventory.AddItem(source, itemName, amount)
    if ECOFBBridge.Inventory() == 'ox' and GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:AddItem(source, itemName, amount or 1)
    end

    local fw = ECOFBBridge.Framework()
    if fw == 'esx' then
        return ECOFBBridgeServerEsx.AddItem(source, itemName, amount)
    end
    if fw == 'qbox' then
        return ECOFBBridgeServerQbox.AddItem(source, itemName, amount)
    end
    return ECOFBBridgeServerQbcore.AddItem(source, itemName, amount)
end

function ECOFBBridgeServerInventory.RemoveItem(source, itemName, amount)
    if ECOFBBridge.Inventory() == 'ox' and GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:RemoveItem(source, itemName, amount or 1)
    end

    local fw = ECOFBBridge.Framework()
    if fw == 'esx' then
        return ECOFBBridgeServerEsx.RemoveItem(source, itemName, amount)
    end
    if fw == 'qbox' then
        return ECOFBBridgeServerQbox.RemoveItem(source, itemName, amount)
    end
    return ECOFBBridgeServerQbcore.RemoveItem(source, itemName, amount)
end

function ECOFBBridgeServerInventory.RegisterUsableItem(itemName, handler)
    if ECOFBBridge.Inventory() == 'ox' and GetResourceState('ox_inventory') == 'started' then
        return false
    end

    local fw = ECOFBBridge.Framework()
    if fw == 'esx' then
        return ECOFBBridgeServerEsx.RegisterUsableItem(itemName, handler)
    end
    if fw == 'qbox' then
        return ECOFBBridgeServerQbox.RegisterUsableItem(itemName, handler)
    end
    return ECOFBBridgeServerQbcore.RegisterUsableItem(itemName, handler)
end

function ECOFBBridgeServerInventory.RegisterOxItem(itemName, handler)
    -- OX: items.lua → server.export = 'ec_outfitbag.useItem'
    return GetResourceState('ox_inventory') == 'started'
end

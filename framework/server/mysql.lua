ECOFBBridge = ECOFBBridge or {}
ECOFBBridge.MySQL = ECOFBBridge.MySQL or {}

function ECOFBBridge.MySQL.WaitReady()
    while GetResourceState('oxmysql') ~= 'started' do
        Wait(200)
    end
end

function ECOFBBridge.MySQL.Query(query, params, cb)
    exports.oxmysql:query(query, params or {}, cb or function() end)
end

function ECOFBBridge.MySQL.Single(query, params, cb)
    exports.oxmysql:single(query, params or {}, cb or function() end)
end

function ECOFBBridge.MySQL.Insert(query, params, cb)
    exports.oxmysql:insert(query, params or {}, cb or function() end)
end

function ECOFBBridge.MySQL.Update(query, params, cb)
    exports.oxmysql:update(query, params or {}, cb or function() end)
end

local function await(run)
    local done, result = false, nil
    run(function(value)
        result = value
        done = true
    end)
    while not done do Wait(0) end
    return result
end

function ECOFBBridge.MySQL.QuerySync(query, params)
    return await(function(cb)
        ECOFBBridge.MySQL.Query(query, params, function(rows)
            cb(rows or {})
        end)
    end)
end

function ECOFBBridge.MySQL.SingleSync(query, params)
    return await(function(cb)
        ECOFBBridge.MySQL.Single(query, params, function(row)
            cb(row)
        end)
    end)
end

function ECOFBBridge.MySQL.InsertSync(query, params)
    return await(function(cb)
        ECOFBBridge.MySQL.Insert(query, params, function(id)
            cb(id)
        end)
    end)
end

function ECOFBBridge.MySQL.UpdateSync(query, params)
    return await(function(cb)
        ECOFBBridge.MySQL.Update(query, params, function(affected)
            cb(affected)
        end)
    end)
end

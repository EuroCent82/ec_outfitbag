ECOFBBridgeClientTargetEsx = ECOFBBridgeClientTargetEsx or {}

local function qbTargetExport()
    if GetResourceState('qb-target') == 'started' then
        return exports['qb-target']
    end
    if GetResourceState('qtarget') == 'started' then
        return exports.qtarget
    end
    return nil
end

function ECOFBBridgeClientTargetEsx.RegisterBag(entity, bag, onOpen, onPickup)
    local target = qbTargetExport()
    if target and target.AddTargetEntity then
        target:AddTargetEntity(entity, {
            options = {
                {
                    icon = 'fas fa-shirt',
                    label = _L('target.open'),
                    action = onOpen,
                },
                {
                    icon = 'fas fa-hand',
                    label = _L('target.pickup'),
                    action = onPickup,
                },
            },
            distance = Config.Bag.InteractDistance,
        })
        return true
    end

    return false
end

function ECOFBBridgeClientTargetEsx.RemoveBag(entity)
    local target = qbTargetExport()
    if not target then return end
    pcall(function()
        if target.RemoveTargetEntity then
            target:RemoveTargetEntity(entity)
        end
    end)
end

function ECOFBBridgeClientTargetEsx.RegisterFallback(entity, bag, onOpen, onPickup)
    CreateThread(function()
        local bagUid = bag.bag_uid
        while DoesEntityExist(entity) do
            local sleep = 1000
            local ped = PlayerPedId()
            local dist = #(GetEntityCoords(ped) - GetEntityCoords(entity))
            if dist <= Config.Bag.InteractDistance then
                sleep = 0
                if lib and lib.showTextUI then
                    lib.showTextUI(_L('target.fallback'))
                end
                if IsControlJustReleased(0, 38) then onOpen() end
                if IsControlJustReleased(0, 47) then onPickup() end
            elseif lib and lib.hideTextUI then
                lib.hideTextUI()
            end
            Wait(sleep)
        end
        if lib and lib.hideTextUI then lib.hideTextUI() end
    end)
end

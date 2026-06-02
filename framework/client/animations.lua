--[[
    ec_outfitbag — Client: Kleidungs-Animationen
    ---------------------------------------------------------------------------
    Spielt Item-spezifische Animationen nur wenn Hut/Brille/Rucksack etc. vorhanden.
    Konfiguration: Config.Animations in shared/config.lua
]]

ECOFBBridgeClientAnimations = ECOFBBridgeClientAnimations or {}

local animBusy = false
local loadedDicts = {}

local function animCfg()
    return Config.Animations or {}
end

local function progressCfg()
    return Config.Progress or {}
end

local function animDuration(anim)
    return (anim and anim.duration) or animCfg().DefaultDuration or 1800
end

local function itemAnim(itemKey)
    local cfg = animCfg()
    local items = cfg.Items or {}
    return items[itemKey] or cfg.Categories and cfg.Categories[itemKey]
end

local function removeAnim(itemKey)
    local cfg = animCfg()
    local remove = cfg.RemoveItems or {}
    return remove[itemKey] or itemAnim(itemKey)
end

local function changeDuration(change)
    local total = 0
    if change.remove then total = total + animDuration(removeAnim(change.key)) end
    if change.apply then total = total + animDuration(itemAnim(change.key)) end
    return total
end

local function changesDuration(changes)
    local total = 0
    for i = 1, #changes do
        total = total + changeDuration(changes[i])
    end
    return total
end

function ECOFBBridgeClientAnimations.CancelProgress()
    if lib and lib.progressActive and lib.progressActive() then
        lib.cancelProgress()
    end
end

local function runProgress(durationMs, localeKey)
    local cfg = progressCfg()
    if cfg.Enabled == false or not durationMs or durationMs <= 0 then return end
    if not lib or not lib.progressBar then return end

    CreateThread(function()
        lib.progressBar({
            duration = durationMs,
            label = _L(localeKey),
            useWhileDead = false,
            canCancel = false,
            disable = {
                move = cfg.DisableMove == true,
                car = true,
                combat = true,
            },
        })
    end)
end

function ECOFBBridgeClientAnimations.IsBusy()
    return animBusy
end

function ECOFBBridgeClientAnimations.Stop()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    animBusy = false
end

local function loadDict(dict)
    if loadedDicts[dict] then return true end
    if not DoesAnimDictExist(dict) then return false end

    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > timeout then return false end
        Wait(10)
    end

    loadedDicts[dict] = true
    return true
end

local function playAnimDef(anim, waitComplete)
    local cfg = animCfg()
    if cfg.Enabled == false or not anim or not anim.dict then return false end
    if not loadDict(anim.dict) then
        ECOFBBridge.Debug('Anim-Dict fehlt:', anim.dict)
        return false
    end

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then return false end

    animBusy = true
    local duration = anim.duration or cfg.DefaultDuration or 1800

    TaskPlayAnim(
        ped,
        anim.dict,
        anim.clip,
        4.0, 3.0,
        duration,
        cfg.Flag or 49,
        0.0,
        false, false, false
    )

    if waitComplete then
        Wait(duration)
        animBusy = false
    else
        SetTimeout(duration, function()
            animBusy = false
        end)
    end

    return true
end

--- Einzelnes Kleidungsstück animieren (z. B. hat, bag, glasses).
function ECOFBBridgeClientAnimations.PlayItem(itemKey, waitComplete)
    return playAnimDef(itemAnim(itemKey), waitComplete)
end

function ECOFBBridgeClientAnimations.PlayRemoveItem(itemKey, waitComplete)
    return playAnimDef(removeAnim(itemKey), waitComplete)
end

local function itemsDuration(itemKeys)
    local total = 0
    if type(itemKeys) ~= 'table' then return 0 end
    for i = 1, #itemKeys do
        total = total + animDuration(itemAnim(itemKeys[i]))
    end
    return total
end

--- Mehrere Items nacheinander — nur übergebene Keys (bereits gefiltert).
function ECOFBBridgeClientAnimations.PlayItems(itemKeys, waitComplete, progressKey)
    if type(itemKeys) ~= 'table' or #itemKeys == 0 then return false end

    local cfg = animCfg()
    if cfg.Enabled == false then return false end

    if progressKey then
        runProgress(itemsDuration(itemKeys), progressKey)
    end

    for i = 1, #itemKeys do
        ECOFBBridgeClientAnimations.PlayItem(itemKeys[i], waitComplete ~= false)
    end

    return true
end

--- Fallback: alte Kategorie-Animation
function ECOFBBridgeClientAnimations.PlayCategory(category, waitComplete, withProgress)
    local cfg = animCfg()
    local cats = cfg.Categories or {}
    local anim = cats[category]
    if withProgress then
        runProgress(animDuration(anim), 'progress.category')
    end
    return playAnimDef(anim, waitComplete)
end

function ECOFBBridgeClientAnimations.PlaySave(itemKeys)
    local cfg = animCfg()
    if cfg.Enabled == false then return false end

    if type(itemKeys) == 'table' and #itemKeys > 0 then
        return ECOFBBridgeClientAnimations.PlayItems(itemKeys, true, 'progress.save')
    end

    runProgress(animDuration(cfg.Save), 'progress.save')
    return playAnimDef(cfg.Save, true)
end

function ECOFBBridgeClientAnimations.PlayBagPlace(waitComplete)
    local cfg = animCfg()
    local anim = cfg.Bag and cfg.Bag.Place
    runProgress(animDuration(anim), 'progress.bag_place')
    return playAnimDef(anim, waitComplete)
end

function ECOFBBridgeClientAnimations.PlayBagPickup(waitComplete)
    local cfg = animCfg()
    local anim = cfg.Bag and cfg.Bag.Pickup
    runProgress(animDuration(anim), 'progress.bag_pickup')
    return playAnimDef(anim, waitComplete)
end

--- Vollständiges Outfit: erst ausziehen, dann anziehen (nur geänderte Teile).
function ECOFBBridgeClientAnimations.PlayApplySequence(targetAppearance, onApplyStep, onRemoveStep)
    local cfg = animCfg()
    if cfg.Enabled == false then
        if onApplyStep then onApplyStep('all') end
        return
    end

    CreateThread(function()
        local current = ECOFBBridgeClientClothing.Capture()
        local target = ECOFBClothing.NormalizeAppearance(targetAppearance)
        if not target then return end

        local changes = ECOFBClothing.GetApplyChanges(current, target)
        if #changes == 0 then
            if onApplyStep then onApplyStep('all') end
            return
        end

        local stripFirst = cfg.StripBeforeApply ~= false
        runProgress(changesDuration(changes), 'progress.apply')

        animBusy = true
        for i = 1, #changes do
            local change = changes[i]

            if stripFirst and change.remove then
                ECOFBBridgeClientAnimations.PlayRemoveItem(change.key, true)
                if onRemoveStep then onRemoveStep(change.key) end
            end

            if change.apply then
                ECOFBBridgeClientAnimations.PlayItem(change.key, true)
                if onApplyStep then onApplyStep(change.key) end
            elseif change.remove and not stripFirst and onRemoveStep then
                onRemoveStep(change.key)
            end
        end
        animBusy = false
    end)
end

RegisterNetEvent(ECOFB.Events.Client.CloseBag, function()
    ECOFBBridgeClientAnimations.CancelProgress()
    ECOFBBridgeClientAnimations.Stop()
end)

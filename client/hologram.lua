--[[ ec_outfitbag — Client: 3D-Hologramm (Ped-Klon mit Outfit-Vorschau) ]]

ECOFBClientHologram = ECOFBClientHologram or {}

local holoPed = nil
local anchorBagUid = nil
local updateActive = false
ECOFBClientHologram.userEnabled = Config.Hologram and Config.Hologram.DefaultUiEnabled ~= false

local function holoCfg()
    return Config.Hologram or {}
end

function ECOFBClientHologram.IsUserEnabled()
    local cfg = holoCfg()
    if cfg.Enabled == false then return false end
    return ECOFBClientHologram.userEnabled ~= false
end

function ECOFBClientHologram.SetUserEnabled(enabled)
    ECOFBClientHologram.userEnabled = enabled == true
    if not ECOFBClientHologram.IsUserEnabled() then
        ECOFBClientHologram.Destroy()
    end
end

local function rotateOffset(offset, heading)
    local rad = math.rad(heading)
    return vector3(
        offset.x * math.cos(rad) - offset.y * math.sin(rad),
        offset.x * math.sin(rad) + offset.y * math.cos(rad),
        offset.z
    )
end

local function groundZ(x, y, referenceZ)
    local cfg = holoCfg()
    local probe = (referenceZ or 0.0) + (cfg.GroundProbe or 50.0)
    local found, z = GetGroundZFor_3dCoord(x, y, probe, false)
    if found then
        return z + (cfg.GroundOffset or 0.0)
    end
    return (referenceZ or 0.0) + (cfg.GroundOffset or 0.0)
end

function ECOFBClientHologram.GetAnchorCoords()
    local cfg = holoCfg()
    local offset = cfg.Offset or vector3(0.85, 0.0, 0.0)
    local headingOffset = cfg.HeadingOffset or 160.0
    local playerCoords = GetEntityCoords(PlayerPedId())

    if anchorBagUid and ECOFBClientBags.Spawned[anchorBagUid] then
        local entry = ECOFBClientBags.Spawned[anchorBagUid]
        if entry.entity and DoesEntityExist(entry.entity) then
            local bagCoords = GetEntityCoords(entry.entity)
            local bagHeading = GetEntityHeading(entry.entity)
            local rotated = rotateOffset(offset, bagHeading)
            local x = bagCoords.x + rotated.x
            local y = bagCoords.y + rotated.y
            local z = groundZ(x, y, playerCoords.z)
            return vector3(x, y, z), bagHeading + headingOffset
        end
    end

    local heading = GetEntityHeading(PlayerPedId())
    local rotated = rotateOffset(offset, heading)
    local x = playerCoords.x + rotated.x
    local y = playerCoords.y + rotated.y
    local z = groundZ(x, y, playerCoords.z)
    return vector3(x, y, z), heading + headingOffset
end

local function loadModel(model)
    if not IsModelInCdimage(model) then return false end
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then return false end
        Wait(0)
    end
    return true
end

local function applyVisuals(ped)
    local cfg = holoCfg()
    local alpha = cfg.Alpha or 185

    SetEntityAlpha(ped, alpha, false)
    SetEntityInvincible(ped, true)
    SetEntityCollision(ped, false, false)
    SetPedCanRagdoll(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedAoBlobRendering(ped, false)

    if cfg.Outline then
        local c = cfg.OutlineColor or { r = 74, g = 200, b = 255, a = 255 }
        SetEntityDrawOutline(ped, true)
        SetEntityDrawOutlineColor(c.r or 74, c.g or 200, c.b or 255, c.a or 255)
        pcall(SetEntityDrawOutlineShader, 1)
    end
end

local function placePed(ped)
    if not ped or not DoesEntityExist(ped) then return end

    local coords, heading = ECOFBClientHologram.GetAnchorCoords()
    FreezeEntityPosition(ped, false)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z + 0.15, false, false, false)
    PlaceEntityOnGroundProperly(ped)
    SetEntityHeading(ped, heading)
    FreezeEntityPosition(ped, true)
end

local function ensurePed()
    local playerPed = PlayerPedId()
    local model = GetEntityModel(playerPed)

    if holoPed and DoesEntityExist(holoPed) and GetEntityModel(holoPed) ~= model then
        ECOFBClientHologram.Destroy()
    end

    if not holoPed or not DoesEntityExist(holoPed) then
        if not loadModel(model) then return nil end

        local coords, heading = ECOFBClientHologram.GetAnchorCoords()
        holoPed = CreatePed(4, model, coords.x, coords.y, coords.z + 0.15, heading, false, false)

        if not holoPed or holoPed == 0 then return nil end

        SetEntityAsMissionEntity(holoPed, true, true)
        SetPedDefaultComponentVariation(holoPed)
        ClonePedToTarget(playerPed, holoPed)
        TaskStandStill(holoPed, -1)
        SetModelAsNoLongerNeeded(model)
        placePed(holoPed)
        applyVisuals(holoPed)
    end

    return holoPed
end

local function buildMergedAppearance(rawAppearance)
    if not rawAppearance then return nil end
    local outfit = ECOFBClothing.NormalizeAppearance(rawAppearance)
    if not outfit then return nil end
    local base = ECOFBBridgeClientClothing.Capture()
    return base and ECOFBClothing.MergePartial(base, outfit) or outfit
end

function ECOFBClientHologram.ApplyAppearance(rawAppearance)
    if not ECOFBClientHologram.IsUserEnabled() then return end

    local ped = ensurePed()
    if not ped then return end

    ClonePedToTarget(PlayerPedId(), ped)

    local merged = buildMergedAppearance(rawAppearance)
    if merged then
        ECOFBBridgeClientClothing.ApplyToPed(ped, merged)
    end

    placePed(ped)
    applyVisuals(ped)
end

local function startUpdateLoop()
    if updateActive then return end
    updateActive = true

    CreateThread(function()
        local interval = holoCfg().UpdateInterval or 400

        while holoPed and DoesEntityExist(holoPed) do
            placePed(holoPed)
            Wait(interval)
        end

        updateActive = false
    end)
end

function ECOFBClientHologram.Show(bagUid, rawAppearance)
    if not ECOFBClientHologram.IsUserEnabled() then return end

    anchorBagUid = bagUid

    CreateThread(function()
        ECOFBClientHologram.ApplyAppearance(rawAppearance)
        startUpdateLoop()
    end)
end

function ECOFBClientHologram.PreviewCategory(_category, rawAppearance)
    if rawAppearance then
        ECOFBClientHologram.ApplyAppearance(rawAppearance)
    end
end

function ECOFBClientHologram.Hide()
    ECOFBClientHologram.Destroy()
end

function ECOFBClientHologram.Destroy()
    if holoPed and DoesEntityExist(holoPed) then
        SetEntityDrawOutline(holoPed, false)
        DeleteEntity(holoPed)
    end
    holoPed = nil
    anchorBagUid = nil
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    ECOFBClientHologram.Destroy()
end)

--[[ ec_outfitbag — obdb check / obdb fix (Datenbank-Schema) ]]

local function dbCheckCommand()
    local cfg = Config.Database or {}
    local name = cfg.checkCommand
    if type(name) ~= 'string' or name == '' then
        return 'obdb'
    end
    return name
end

local function canRunDbCheck(source)
    if source == 0 then
        return true
    end

    if (Config.Database or {}).checkConsoleOnly == true then
        return false
    end

    return ECOFBBridge.Server.IsAdmin(source)
end

local function reply(source, message)
    if source == 0 then
        print(message)
        return
    end

    TriggerClientEvent('chat:addMessage', source, {
        color = { 45, 106, 79 },
        multiline = true,
        args = { 'Outfit Bag DB', message },
    })
end

local function printReport(source, report)
    local lines = {
        ('Framework: %s | Install: %s'):format(report.framework or '?', report.installFile or '?'),
        ('Tabellen: %d/%d OK'):format(#report.presentTables, #report.requiredTables),
    }

    if #report.missingTables > 0 then
        lines[#lines + 1] = 'FEHLEND: ' .. table.concat(report.missingTables, ', ')
    end

    if report.ok then
        lines[#lines + 1] = 'Status: OK'
    else
        lines[#lines + 1] = ('Status: Reparatur nötig (%s fix)'):format(dbCheckCommand())
    end

    for i = 1, #lines do
        reply(source, lines[i])
    end
end

local function runCheck(source)
    ECOFBBridgeServerSchema.GetSchemaReport(function(report)
        printReport(source, report)
    end)
end

local function runFix(source)
    reply(source, 'Schema-Reparatur läuft…')

    ECOFBBridgeServerSchema.RepairSchema(function(ok, reason, report)
        if not ok then
            reply(source, ('Reparatur fehlgeschlagen (%s)'):format(reason or 'unknown'))
            if report then
                printReport(source, report)
            end
            return
        end

        if report then
            printReport(source, report)
        else
            reply(source, 'Reparatur abgeschlossen.')
        end
    end)
end

RegisterCommand(dbCheckCommand(), function(source, args)
    if not canRunDbCheck(source) then
        if source ~= 0 then
            reply(source, ('Keine Berechtigung für %s.'):format(dbCheckCommand()))
        end
        return
    end

    local sub = string.lower(tostring(args[1] or 'check'))

    if sub == 'check' or sub == '' then
        runCheck(source)
        return
    end

    if sub == 'fix' or sub == 'repair' then
        runFix(source)
        return
    end

    reply(source, ('Nutze: %s check | %s fix'):format(dbCheckCommand(), dbCheckCommand()))
end, false)

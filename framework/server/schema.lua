--[[ ec_outfitbag — Datenbank-Schema: prüfen, anlegen, reparieren ]]

ECOFBBridgeServerSchema = ECOFBBridgeServerSchema or {}

local REQUIRED_TABLES = {
    'ec_outfitbag_profiles',
    'ec_outfitbag_outfits',
    'ec_outfitbag_world',
}

local DEFAULT_INSTALL_FILE = 'sql/install.sql'

local function dbConfig()
    return Config.Database or {}
end

function ECOFBBridgeServerSchema.RequiredTables()
    return REQUIRED_TABLES
end

function ECOFBBridgeServerSchema.ResolveInstallFile()
    local cfg = dbConfig()
    if type(cfg.installFile) == 'string' and cfg.installFile ~= '' then
        return cfg.installFile
    end
    return DEFAULT_INSTALL_FILE
end

local function stripLineComments(content)
    local lines = {}
    for line in content:gmatch('[^\r\n]+') do
        if not line:match('^%s*%-%-') then
            lines[#lines + 1] = line
        end
    end
    return table.concat(lines, '\n')
end

function ECOFBBridgeServerSchema.ParseStatements(content)
    local body = stripLineComments(content)
    local statements = {}

    for chunk in body:gmatch('([^;]+);') do
        local statement = chunk:match('^%s*(.-)%s*$')
        if statement and statement ~= '' then
            statements[#statements + 1] = statement
        end
    end

    return statements
end

local function rowTableName(row)
    if not row then
        return nil
    end
    return row.table_name or row.TABLE_NAME or row.name or row.NAME
end

function ECOFBBridgeServerSchema.GetMissingTables(cb)
    local placeholders = {}
    for _ = 1, #REQUIRED_TABLES do
        placeholders[#placeholders + 1] = '?'
    end

    local query = ([[
        SELECT table_name AS name
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
          AND table_name IN (%s)
    ]]):format(table.concat(placeholders, ', '))

    ECOFBBridge.MySQL.Query(query, REQUIRED_TABLES, function(result)
        local present = {}

        for _, row in ipairs(result or {}) do
            local name = rowTableName(row)
            if name then
                present[string.lower(name)] = true
            end
        end

        local missing = {}
        for _, name in ipairs(REQUIRED_TABLES) do
            if not present[string.lower(name)] then
                missing[#missing + 1] = name
            end
        end

        cb(missing)
    end)
end

local function runStatements(statements, index, cb)
    if index > #statements then
        cb(true)
        return
    end

    ECOFBBridge.MySQL.Query(statements[index], {}, function()
        runStatements(statements, index + 1, cb)
    end)
end

local function executeInstall(filePath, missingBefore, cb)
    local resource = GetCurrentResourceName()
    local content = LoadResourceFile(resource, filePath)

    if not content or content == '' then
        print(('^1[ec_outfitbag]^0 SQL-Datei nicht gefunden oder leer: %s'):format(filePath))
        cb(false, 'missing_file')
        return
    end

    local statements = ECOFBBridgeServerSchema.ParseStatements(content)
    if #statements == 0 then
        print(('^1[ec_outfitbag]^0 Keine SQL-Statements in %s'):format(filePath))
        cb(false, 'empty_file')
        return
    end

    runStatements(statements, 1, function(ok)
        if not ok then
            cb(false, 'failed')
            return
        end

        ECOFBBridgeServerSchema.GetMissingTables(function(stillMissing)
            if #stillMissing > 0 then
                print(('^1[ec_outfitbag]^0 Nach Install fehlen noch Tabellen: %s'):format(
                    table.concat(stillMissing, ', ')
                ))
                cb(false, 'incomplete')
                return
            end

            print(('^2[ec_outfitbag]^0 Datenbank-Schema ausgeführt (%s)%s'):format(
                filePath,
                #missingBefore > 0 and (' — neu angelegt: ' .. table.concat(missingBefore, ', ')) or ''
            ))
            cb(true, 'installed')
        end)
    end)
end

function ECOFBBridgeServerSchema.Install(cb)
    cb = cb or function() end

    local cfg = dbConfig()
    if cfg.autoInstall == false then
        ECOFBBridge.Debug('Datenbank autoInstall deaktiviert — übersprungen')
        cb(true, 'disabled')
        return
    end

    local filePath = ECOFBBridgeServerSchema.ResolveInstallFile()
    if not filePath then
        print('^3[ec_outfitbag]^0 Kein Install-SQL — bitte Config.Database.installFile setzen')
        cb(false, 'no_mapping')
        return
    end

    ECOFBBridgeServerSchema.GetMissingTables(function(missing)
        if #missing == 0 then
            if cfg.skipIfInstalled ~= false then
                ECOFBBridge.Debug('Alle', #REQUIRED_TABLES, 'Datenbank-Tabellen vorhanden — nichts anzulegen')
                cb(true, 'complete')
                return
            end

            ECOFBBridge.Debug('Alle Tabellen vorhanden — erzwinge SQL-Lauf (skipIfInstalled = false)')
            executeInstall(filePath, {}, cb)
            return
        end

        print(('^3[ec_outfitbag]^0 Fehlende Tabellen (%d/%d): %s'):format(
            #missing,
            #REQUIRED_TABLES,
            table.concat(missing, ', ')
        ))

        executeInstall(filePath, missing, cb)
    end)
end

--- @param cb fun(report: table)
function ECOFBBridgeServerSchema.GetSchemaReport(cb)
    cb = cb or function() end

    ECOFBBridgeServerSchema.GetMissingTables(function(missingTables)
        local presentTables = {}
        for _, name in ipairs(REQUIRED_TABLES) do
            local found = true
            for _, miss in ipairs(missingTables) do
                if miss == name then
                    found = false
                    break
                end
            end
            if found then
                presentTables[#presentTables + 1] = name
            end
        end

        cb({
            ok = #missingTables == 0,
            framework = ECOFBBridge.Framework(),
            installFile = ECOFBBridgeServerSchema.ResolveInstallFile(),
            requiredTables = REQUIRED_TABLES,
            presentTables = presentTables,
            missingTables = missingTables,
            missingPatches = {},
            patchCount = 0,
        })
    end)
end

function ECOFBBridgeServerSchema.RepairSchema(cb)
    cb = cb or function() end

    ECOFBBridgeServerSchema.Install(function(installOk, installReason)
        if not installOk and installReason ~= 'disabled' and installReason ~= 'complete' then
            cb(false, 'install_failed', nil, {})
            return
        end

        ECOFBBridgeServerSchema.GetSchemaReport(function(report)
            cb(report.ok == true, report.ok and 'ok' or 'incomplete', report, {})
        end)
    end)
end

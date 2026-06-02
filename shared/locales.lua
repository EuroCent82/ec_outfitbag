--[[
    ec_outfitbag — Locale-System
    ---------------------------------------------------------------------------
    Config.Language steuert die aktive Sprache (DE, EN, …).
    In Lua:  _L('notify.no_item')  oder  _L('ui.outfit_slot', 3)
    In NUI:  ECOFBLocales.GetUiTable() wird beim Öffnen mitgesendet.
]]

ECOFBLocales = ECOFBLocales or {}
Locales = Locales or {}

--- Normalisiert Config.Language → Kleinbuchstaben-Schlüssel (DE → de).
local function configuredLang()
    local lang = tostring((Config and Config.Language) or 'DE'):lower()
    if lang == '' then return 'de' end
    return lang
end

local function firstAvailableLang()
    if Locales['de'] then return 'de' end
    if Locales['en'] then return 'en' end
    for key in pairs(Locales) do return key end
    return nil
end

function ECOFBLocales.GetLanguage()
    return configuredLang()
end

function ECOFBLocales.ResolveTable(lang)
    local requested = tostring(lang or configuredLang()):lower()
    return Locales[requested] or Locales[firstAvailableLang()] or {}
end

--- Punkt-Notation: 'ui.cat.head' → verschachtelter Tabellen-Zugriff.
local function resolveKey(localeTable, key)
    local current = localeTable
    for part in tostring(key):gmatch('[^%.]+') do
        if type(current) ~= 'table' then return nil end
        current = current[part]
    end
    return current
end

--- Übersetzt einen Schlüssel; optional string.format-Argumente.
---@param key string z. B. 'notify.outfit_saved' oder 'ui.outfit_slot'
---@return string
function ECOFBLocales.Translate(key, ...)
    local localeTable = ECOFBLocales.ResolveTable(configuredLang())
    local template = resolveKey(localeTable, key)

    if type(template) ~= 'string' then
        local fallback = resolveKey(ECOFBLocales.ResolveTable('en'), key)
        template = type(fallback) == 'string' and fallback or tostring(key)
    end

    if select('#', ...) > 0 then
        local ok, text = pcall(string.format, template, ...)
        if ok then return text end
    end

    return template
end

--- UI-Strings für NUI (html/js/app.js).
function ECOFBLocales.GetUiTable()
    local ui = ECOFBLocales.ResolveTable(configuredLang()).ui
    if type(ui) == 'table' then return ui end
    local fallbackUi = ECOFBLocales.ResolveTable('en').ui
    return type(fallbackUi) == 'table' and fallbackUi or {}
end

--- Kurzalias für Server/Client-Skripte.
_L = ECOFBLocales.Translate

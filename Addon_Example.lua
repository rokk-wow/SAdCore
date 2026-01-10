local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

function addon.LoadConfig()
    addon.config.version = "1.0"
    
    -- Optional: Set custom author name (defaults to "SAdCore Framework" if not set)
    addon.author = "Rôkk-Wyrmrest Accord"

    -- Example - Add Settings to Main Settings Panel
    addon.config.settings.main = {
        title = "myAddonSettingsTitle",
        controls = {
            -- Header
            {
                type = "header",
                name = "exampleHeader"
            },
            -- Checkbox (persisted to database)
            {
                type = "checkbox",
                name = "exampleCheckbox",
                default = true,
                persistent = true,
                onValueChange = addon.exampleCheckbox,
                onLoad = addon.exampleCheckbox
            },
        }
    }

    function addon.exampleCheckbox(isChecked)
        addon.info("Checkbox changed to: " .. tostring(isChecked))
    end

    -- Example - Add a New Child Settings Panel
    addon.config.settings.example = {
        title = "exampleTitle",
        controls = {
            -- Header
            {
                type = "header",
                name = "exampleHeader"
            },            
            -- Checkbox (persisted to database)
            {
                type = "checkbox",
                name = "exampleCheckbox2",
                default = true,
                persistent = true,
                onValueChange = addon.exampleCheckbox2,
                onLoad = addon.exampleCheckbox2
            },
        }
    }

    function addon.exampleCheckbox2(isChecked)
        addon.info("Checkbox changed to: " .. tostring(isChecked))
    end
end

-- Example Registration Functions
function addon.RegisterFunctions()
    addon.RegisterSlashCommand("hello", addon.HelloCommand)
    addon.RegisterEvent("PLAYER_ENTERING_WORLD", addon.OnPlayerEnteringWorld)
end

function addon.HelloCommand()
    addon.info("Hello, World!")
end

function addon.OnPlayerEnteringWorld(event)
    addon.info("Player has entered the world!")
end

-- Addon Setup: Simplified initialization using addon.Setup()
-- This automatically handles ADDON_LOADED event registration and initialization
addon.Setup(MyAddon_Settings_Global, MyAddon_Settings_Char, "MyAddon_Compartment_Func")

-- Localization
-- All user-facing text should be localized. Keys are used in your config (e.g., name = "exampleHeader")
-- and SAdCore automatically displays the localized text based on the client's language.
-- If a key is missing, it will display as [keyName] to alert you during development.
addon.locale = {}

-- English (default)
addon.locale.enEN = {
    -- Core
    ["SAdCore"] = "SAdCore",
    ["versionPrefix"] = "v",
    ["close"] = "Close",
    
    -- Settings Panel Headers
    ["loggingHeader"] = "Logging",
    ["profile"] = "Profile",
    
    -- Settings Options
    ["logVersion"] = "Log Version on Load",
    ["logVersionTooltip"] = "Log the current version of the addon to the chat window on start up.",
    ["enableDebugging"] = "Enable Debugging",
    ["enableDebuggingTooltip"] = "Enable debug messages in the chat window.",
    ["useCharacterSettings"] = "Use Character-Specific Settings",
    ["characterSpecificSettingsTooltip"] = "When enabled, settings will be saved per character instead of account-wide.",
    
    -- Import/Export
    ["loadSettings"] = "Load Settings from String",
    ["loadSettingsTooltip"] = "Paste an exported settings string and click Load to import settings.",
    ["loadSettingsButton"] = "Load",
    ["shareSettings"] = "Share",
    ["shareSettingsTooltip"] = "Export your current settings as a string that can be shared with others.",
    ["shareSettingsTitle"] = "Share Settings",
    ["shareSettingsLabel"] = "Press CTRL + C to Copy",
    
    -- Import Messages
    ["importDecodeFailed"] = "Decode failed.",
    ["importDeserializeFailed"] = "Deserialize failed.",
    ["importInvalidData"] = "Invalid data structure.",
    ["importWrongAddon"] = "Imported settings are for a different addon.",
    ["importVersionMismatch"] = "Version mismatch.",
    ["importSuccess"] = "Settings imported successfully.",
    ["imported"] = "Imported",
    ["current"] = "Current",
    
    -- Author Info
    ["tagline"] = "Simple Addons—Bare minimum addons for bare minimum brains.",
    ["authorTitle"] = "Author",
    ["authorName"] = "Press CTRL + C to Copy",
    
    -- Inspect Utility
    ["inspectResult"] = "Structure",
}

-- Russian
-- Additional locales are optional. If not provided, enEN will be used as fallback.
addon.locale.ruRU = {
    -- Core
    ["SAdCore"] = "SAdCore",
    ["versionPrefix"] = "v",
    ["close"] = "Закрыть",
    
    -- Settings Panel Headers
    ["loggingHeader"] = "Логирование",
    ["profile"] = "Профиль",
    
    -- Settings Options
    ["logVersion"] = "Записывать версию при загрузке",
    ["logVersionTooltip"] = "Выводить текущую версию аддона в чат при запуске.",
    ["enableDebugging"] = "Включить отладку",
    ["enableDebuggingTooltip"] = "Включить отладочные сообщения в окне чата.",
    ["useCharacterSettings"] = "Использовать настройки персонажа",
    ["characterSpecificSettingsTooltip"] = "Когда включено, настройки сохраняются для каждого персонажа отдельно, а не для всей учетной записи.",
    
    -- Import/Export
    ["loadSettings"] = "Загрузить настройки из строки",
    ["loadSettingsTooltip"] = "Вставьте экспортированную строку настроек и нажмите Загрузить для импорта.",
    ["loadSettingsButton"] = "Загрузить",
    ["shareSettings"] = "Поделиться",
    ["shareSettingsTooltip"] = "Экспортировать текущие настройки в виде строки, которой можно поделиться с другими.",
    ["shareSettingsTitle"] = "Поделиться настройками",
    ["shareSettingsLabel"] = "Нажмите CTRL + C для копирования",
    
    -- Import Messages
    ["importDecodeFailed"] = "Ошибка декодирования.",
    ["importDeserializeFailed"] = "Ошибка десериализации.",
    ["importInvalidData"] = "Неверная структура данных.",
    ["importWrongAddon"] = "Импортированные настройки предназначены для другого аддона.",
    ["importVersionMismatch"] = "Несоответствие версий.",
    ["importSuccess"] = "Настройки успешно импортированы.",
    ["imported"] = "Импортировано",
    ["current"] = "Текущая",
    
    -- Author Info
    ["tagline"] = "Простые аддоны. Минимальные аддоны для минимальных мозгов.",
    ["authorTitle"] = "Автор",
    ["authorName"] = "Нажмите CTRL + C для копирования",
}

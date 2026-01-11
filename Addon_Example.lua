local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

-- Saved Variable definitions and Addon Compartment Function must match what's in your .toc
addon.savedVarsGlobalName = "MyAddon_Settings_Global"
addon.savedVarsPerCharName = "MyAddon_Settings_Char"
addon.compartmentFuncName = "MyAddon_Compartment_Func"

function addon:LoadConfig()
    self.config.version = "1.0"
    self.author = "Rôkk-Wyrmrest Accord"

    -- Example - Add Settings to Main Settings Panel
    self.config.settings.main = {
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
                onValueChange = self.exampleCheckbox
            },
        }
    }

    function addon:exampleCheckbox(isChecked)
        self:debug(addonName .. ": " .. tostring(isChecked))
    end

    -- Example - Add a New Child Settings Panel
    self.config.settings.example = {
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
                onValueChange = self.exampleCheckbox2
            },
        }
    }

    function addon:exampleCheckbox2(isChecked)
        self:info("Checkbox changed to: " .. tostring(isChecked))
    end
end

-- Example Registration Functions
function addon:RegisterFunctions()
    self:RegisterSlashCommand("hello", self.HelloCommand)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", self.OnPlayerEnteringWorld)
end

function addon:HelloCommand()
    self:info("Hello, World!")
end

function addon:OnPlayerEnteringWorld(event)
    self:info("Player has entered the world!")
end

-- Localization
-- Config keys (e.g., name = "exampleHeader") are automatically localized to the player's region.
-- Missing keys show as [keyName] on the settings panel.
addon.locale = {}

addon.locale.enEN = {
    SAdCore = "SAdCore",
    versionPrefix = "v",
    close = "Close",
    loggingHeader = "Logging",
    profile = "Profile",
    logVersion = "Log Version on Load",
    logVersionTooltip = "Log the current version of the addon to the chat window on start up.",
    enableDebugging = "Enable Debugging",
    enableDebuggingTooltip = "Enable debug messages in the chat window.",
    useCharacterSettings = "Use Character-Specific Settings",
    characterSpecificSettingsTooltip = "When enabled, settings will be saved per character instead of account-wide.",
    loadSettings = "Load Settings from String",
    loadSettingsTooltip = "Paste an exported settings string and click Load to import settings.",
    loadSettingsButton = "Load",
    shareSettings = "Share",
    shareSettingsTooltip = "Export your current settings as a string that can be shared with others.",
    shareSettingsTitle = "Share Settings",
    shareSettingsLabel = "Press CTRL + C to Copy",
    importDecodeFailed = "Decode failed.",
    importDeserializeFailed = "Deserialize failed.",
    importInvalidData = "Invalid data structure.",
    importWrongAddon = "Imported settings are for a different addon.",
    importVersionMismatch = "Version mismatch.",
    importSuccess = "Settings imported successfully.",
    imported = "Imported",
    current = "Current",
    tagline = "Simple Addons—Bare minimum addons for bare minimum brains.",
    authorTitle = "Author",
    authorName = "Press CTRL + C to Copy",
    inspectResult = "Structure",
}

-- Russian
addon.locale.ruRU = {
    SAdCore = "SAdCore",
    versionPrefix = "v",
    close = "Закрыть",
    loggingHeader = "Логирование",
    profile = "Профиль",
    logVersion = "Записывать версию при загрузке",
    logVersionTooltip = "Выводить текущую версию аддона в чат при запуске.",
    enableDebugging = "Включить отладку",
    enableDebuggingTooltip = "Включить отладочные сообщения в окне чата.",
    useCharacterSettings = "Использовать настройки персонажа",
    characterSpecificSettingsTooltip = "Когда включено, настройки сохраняются для каждого персонажа отдельно, а не для всей учетной записи.",
    loadSettings = "Загрузить настройки из строки",
    loadSettingsTooltip = "Вставьте экспортированную строку настроек и нажмите Загрузить для импорта.",
    loadSettingsButton = "Загрузить",
    shareSettings = "Поделиться",
    shareSettingsTooltip = "Экспортировать текущие настройки в виде строки, которой можно поделиться с другими.",
    shareSettingsTitle = "Поделиться настройками",
    shareSettingsLabel = "Нажмите CTRL + C для копирования",
    importDecodeFailed = "Ошибка декодирования.",
    importDeserializeFailed = "Ошибка десериализации.",
    importInvalidData = "Неверная структура данных.",
    importWrongAddon = "Импортированные настройки предназначены для другого аддона.",
    importVersionMismatch = "Несоответствие версий.",
    importSuccess = "Настройки успешно импортированы.",
    imported = "Импортировано",
    current = "Текущая",
    tagline = "Простые аддоны—Минимальные аддоны для минимального ума.",
    authorTitle = "Автор",
    authorName = "Нажмите CTRL + C для копирования",
}

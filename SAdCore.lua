--[[
    SAdCore - Simple Addons Core Framework
    
    An embeddable library for building consistent WoW addons with auto-generated settings UI.
    Designed to be lightweight and flexible - use only the features you need.
    
    CRITICAL CODING CONSTRAINTS FOR THIS FILE:
    
    SCOPE: These constraints apply ONLY to addon.* functions (functions on the addon table).
    Local (private) functions are NOT subject to these requirements as they cannot be
    hooked by external addons.
    
    1. HOOK REQUIREMENT - Every addon.* function MUST include:
       - callHook(self, "BeforeFunctionName", ...) as the first line
       - callHook(self, "AfterFunctionName", returnValue) before EVERY return statement
       
    2. RETURN VALUE REQUIREMENT - Every addon.* function MUST explicitly return a value:
       - Success functions typically return true or the actual result
       - Failed/error conditions MUST return false or the actual result (NEVER nil)
       - NO function should end without an explicit return statement
       - NEVER return nil - use false for failures, true for success, or actual data
       
    3. SHORT-CIRCUIT RETURNS - When returning early (error conditions, validation failures):
       - MUST call the After hook with the return value
       - MUST explicitly return that value (false for errors, never nil)
       Example:
           if not data then
               callHook(self, "AfterFunctionName", false)
               return false
           end
    
    4. STANDARD FUNCTION PATTERN:
       function addon:FunctionName(params)
           callHook(self, "BeforeFunctionName", params)
           
           -- Early return example
           if errorCondition then
               callHook(self, "AfterFunctionName", false)
               return false
           end
           
           -- Function logic here
           
           local returnValue = true
           callHook(self, "AfterFunctionName", returnValue)
           return returnValue
       end
    
    These constraints enable external addons to hook into ANY addon.* function's execution
    for monitoring, modification, or extension purposes. Failure to follow these
    patterns breaks the extensibility contract of the framework.
]] -- SAdCore Library
local SADCORE_MAJOR, SADCORE_MINOR = "SAdCore-1", 1
local SAdCore, oldminor = LibStub:NewLibrary(SADCORE_MAJOR, SADCORE_MINOR)
if not SAdCore then
    return
end -- Already loaded newer version

SAdCore.addons = SAdCore.addons or {}
SAdCore.prototype = SAdCore.prototype or {}

-- addon will reference the prototype for all method definitions
local addon = SAdCore.prototype

-- callHook must receive the addon instance as first parameter
local function callHook(addonInstance, hookName, ...)
    local hook = addonInstance[hookName]
    if hook then
        return hook(...)
    end
    return ...
end

function SAdCore:GetAddon(addonName)
    if not self.addons[addonName] then
        local newAddon = {
            addonName = addonName,
            core = self
        }
        -- Set metatable so newAddon inherits methods from prototype
        setmetatable(newAddon, { __index = self.prototype })
        self.addons[addonName] = newAddon
        
        -- Automatically register for ADDON_LOADED event
        local addonInstance = newAddon
        local eventFrame = CreateFrame("Frame")
        eventFrame:RegisterEvent("ADDON_LOADED")
        eventFrame:SetScript("OnEvent", function(self, event, loadedAddon)
            if loadedAddon == addonInstance.addonName then
                -- Initialize addon with SavedVariables (look up by name in global scope)
                -- addonInstance stores the variable NAMES as strings, we look them up in _G
                local savedVarsGlobal = addonInstance.savedVarsGlobalName and _G[addonInstance.savedVarsGlobalName] or nil
                local savedVarsPerChar = addonInstance.savedVarsPerCharName and _G[addonInstance.savedVarsPerCharName] or nil
                
                addonInstance:Initialize(savedVarsGlobal, savedVarsPerChar)
                
                -- Register addon compartment function if provided
                if addonInstance.compartmentFuncName then
                    _G[addonInstance.compartmentFuncName] = function()
                        addonInstance:OpenSettings()
                    end
                end
                
                -- Unregister the event
                self:UnregisterEvent("ADDON_LOADED")
            end
        end)
    end
    return self.addons[addonName]
end

do -- Initialization

    function addon:Initialize(savedVarsGlobal, savedVarsPerChar)
        callHook(self, "BeforeInitialize", savedVarsGlobal, savedVarsPerChar)

        self.config = self.config or {}
        self.config.settings = self.config.settings or {}
        self.sadCore = self.sadCore or {}
        self.sadCore.version = "1.1"
        self.apiVersion = select(4, GetBuildInfo())

        local clientLocale = GetLocale()
        self.localization = self.locale[clientLocale] or self.locale.enEN

        self.config.ui = self.config.ui or {
            spacing = {
                panelTop = -25,
                panelBottom = 20,
                headerHeight = 60,
                controlHeight = 38,
                buttonHeight = 50,
                descriptionPadding = 6,
                contentLeft = 10,
                contentRight = -10,
                controlLeft = 30,
                controlRight = -10,
                textInset = 17
            },
            dialog = {
                defaultWidth = 500,
                titleHeight = 40,
                buttonHeight = 50,
                contentPadding = 20,
                titleOffset = -15,
                contentTop = -40,
                contentBottom = 50,
                buttonSize = {
                    width = 100,
                    height = 25
                },
                buttonOffset = 15,
                initialYOffset = -10
            },
            dropdown = {
                width = 150
            },
            slider = {
                width = 205
            },
            backdrop = {
                edgeSize = 2,
                insets = {
                    left = 2,
                    right = 2,
                    top = 2,
                    bottom = 2
                }
            }
        }

        if self.LoadConfig then
            self:LoadConfig()
        end

        self.author = self.author or "SAdCore Framework"
        self:InitializeSavedVariables(savedVarsGlobal, savedVarsPerChar)

        self.LibSerialize = LibStub("LibSerialize")
        self.LibCompress = LibStub("LibCompress")

        self:CreateSlashCommand()
        self:InitializeSettingsPanel()

        if self.RegisterFunctions then
            self:RegisterFunctions()
        end

        if self.settings.main.logVersion then
            self:info(self:L("versionPrefix") .. self.config.version)
        end

        local returnValue = true
        callHook(self, "AfterInitialize", returnValue)

        self.initialized = true

        return returnValue
    end

    function addon:InitializeSavedVariables(savedVarsGlobal, savedVarsPerChar)
        savedVarsGlobal, savedVarsPerChar =
            callHook(self, "BeforeInitializeSavedVariables", savedVarsGlobal, savedVarsPerChar)

        if savedVarsGlobal then
            self.settingsGlobal = savedVarsGlobal
            self.settingsGlobal.main = self.settingsGlobal.main or {}
        else
            self.settingsGlobal = {}
            self.settingsGlobal.main = {}
        end

        if savedVarsPerChar then
            self.settingsChar = savedVarsPerChar
            self.settingsChar.main = self.settingsChar.main or {}
        else
            self.settingsChar = {}
            self.settingsChar.main = {}
        end

        self.settings = (self.settingsChar.useCharacterSettings) and self.settingsChar or self.settingsGlobal

        local returnValue = true
        callHook(self, "AfterInitializeSavedVariables", returnValue)
        return returnValue
    end

    -- Setup: Simplified initialization that automatically handles ADDON_LOADED event
    function addon:Setup(savedVarsGlobal, savedVarsPerChar, compartmentFuncName)
        local addonInstance = self
        savedVarsGlobal, savedVarsPerChar, compartmentFuncName = 
            callHook(self, "BeforeSetup", savedVarsGlobal, savedVarsPerChar, compartmentFuncName)
        
        -- Store the setup parameters for use when ADDON_LOADED fires
        self.setupConfig = {
            savedVarsGlobal = savedVarsGlobal,
            savedVarsPerChar = savedVarsPerChar,
            compartmentFuncName = compartmentFuncName
        }
        
        -- Register for ADDON_LOADED if not already registered
        if not self.setupEventFrame then
            self.setupEventFrame = CreateFrame("Frame")
            self.setupEventFrame:RegisterEvent("ADDON_LOADED")
            self.setupEventFrame:SetScript("OnEvent", function(self, event, loadedAddon)
                if loadedAddon == addonInstance.addonName then
                    -- Initialize addon with SavedVariables
                    addonInstance:Initialize(addonInstance.setupConfig.savedVarsGlobal, addonInstance.setupConfig.savedVarsPerChar)
                    
                    -- Register addon compartment function if provided
                    if addonInstance.setupConfig.compartmentFuncName then
                        _G[addonInstance.setupConfig.compartmentFuncName] = function()
                            addonInstance:OpenSettings()
                        end
                    end
                    
                    -- Unregister the event
                    self:UnregisterEvent("ADDON_LOADED")
                    addonInstance.setupEventFrame = nil
                end
            end)
        end
        
        local returnValue = true
        callHook(self, "AfterSetup", returnValue)
        return returnValue
    end
end

do -- Registration functions

    function addon:RegisterEvent(eventName, callback)
        local addonInstance = self
        eventName, callback = callHook(self, "BeforeRegisterEvent", eventName, callback)

        if self.eventFrame == nil then
            self.eventFrame = CreateFrame("Frame", nil, UIParent)
            self.eventCallbacks = {}
            self.eventFrame:SetScript("OnEvent", function(self, event, ...)
                local eventCallback = addonInstance.eventCallbacks[event]
                if eventCallback then
                    eventCallback(event, ...)
                end
            end)
        end

        self.eventFrame:RegisterEvent(eventName)
        self.eventCallbacks[eventName] = callback

        local returnValue = true
        callHook(self, "AfterRegisterEvent", returnValue)
        return returnValue
    end

    function addon:RegisterSlashCommand(command, callback)
        command, callback = callHook(self, "BeforeRegisterSlashCommand", command, callback)

        if not self.slashCommands then
            self.slashCommands = {}
        end

        self.slashCommands[command:lower()] = callback

        local returnValue = true
        callHook(self, "AfterRegisterSlashCommand", returnValue)
        return returnValue
    end

    function addon:CreateSlashCommand()
        local addonInstance = self
        callHook(self, "BeforeCreateSlashCommand")

        self.slashCommands = {}
        self.slashCommands["inspect"] = function(...) return addonInstance:InspectCommand(...) end

        local slashCommandName = self.addonName:upper()
        _G["SLASH_" .. slashCommandName .. "1"] = "/" .. self.addonName:lower()
        SlashCmdList[slashCommandName] = function(message)
            local command, rest = message:match("^(%S*)%s*(.-)$")
            command = command and command:lower() or ""

            if command ~= "" and addonInstance.slashCommands[command] then
                local params = {}
                if rest and rest ~= "" then
                    for param in rest:gmatch("%S+") do
                        table.insert(params, param)
                    end
                end
                addonInstance.slashCommands[command](unpack(params))
            else
                addonInstance:OpenSettings()
            end
        end

        local returnValue = true
        callHook(self, "AfterCreateSlashCommand", returnValue)
        return returnValue
    end
end

do -- Zone Management

    addon.zones = {"arena", "battleground", "dungeon", "raid", "world"}

    function addon:RegisterZone(zoneName, enterCallback)
        zoneName, enterCallback = callHook(self, "BeforeRegisterZone", zoneName, enterCallback)

        if not self.zoneCallbacks then
            self.zoneCallbacks = {}
            self.currentZone = nil
            self.previousZone = nil

            -- Create closure that calls HandleZoneChange with correct self
            local handleZoneChangeCallback = function(event, ...)
                self:HandleZoneChange()
            end

            self:RegisterEvent("PLAYER_ENTERING_WORLD", handleZoneChangeCallback)
            self:RegisterEvent("ZONE_CHANGED_NEW_AREA", handleZoneChangeCallback)
            self:RegisterEvent("PVP_MATCH_ACTIVE", handleZoneChangeCallback)
            self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", handleZoneChangeCallback)
            self:RegisterEvent("ARENA_OPPONENT_UPDATE", handleZoneChangeCallback)
            self:RegisterEvent("PVP_MATCH_INACTIVE", handleZoneChangeCallback)
            self:RegisterEvent("PLAYER_ROLES_ASSIGNED", handleZoneChangeCallback)
        end

        local normalizedZoneName = zoneName:upper()

        self.zoneCallbacks[normalizedZoneName] = enterCallback

        local returnValue = true
        callHook(self, "AfterRegisterZone", returnValue)
        return returnValue
    end

    function addon:GetCurrentZone()
        callHook(self, "BeforeGetCurrentZone")

        local zoneName = "WORLD"
        local instanceName, instanceType = GetInstanceInfo()

        if instanceType == "arena" then
            zoneName = "ARENA"
        elseif instanceType == "pvp" then
            zoneName = "BATTLEGROUND"
        elseif instanceType == "party" then
            zoneName = "DUNGEON"
        elseif instanceType == "raid" then
            zoneName = "RAID"
        else
            zoneName = "WORLD"
        end

        local returnValue = zoneName
        callHook(self, "AfterGetCurrentZone", returnValue)
        return returnValue
    end

    function addon:HandleZoneChange()
        callHook(self, "BeforeHandleZoneChange")

        if not self.initialized then
            local returnValue = false
            callHook(self, "AfterHandleZoneChange", returnValue)
            return returnValue
        end

        local newZone = self:GetCurrentZone()

        if newZone == self.currentZone then
            local returnValue = false
            callHook(self, "AfterHandleZoneChange", returnValue)
            return returnValue
        end

        self.previousZone = self.currentZone
        self.currentZone = newZone

        if self.zoneCallbacks and self.zoneCallbacks[self.currentZone] then
            local zoneName = self.currentZone:lower()
            if self.L then
                addon.coreInfo(self:L("entering") .. " " .. self:L(zoneName) .. ".")
            end

            local enterCallback = self.zoneCallbacks[self.currentZone]
            if enterCallback and type(enterCallback) == "function" then
                enterCallback()
            end
        end

        local returnValue = true
        callHook(self, "AfterHandleZoneChange", returnValue)
        return returnValue
    end
end

do -- Settings Panels

    function addon:ConfigureMainSettings()
        callHook(self, "BeforeConfigureMainSettings")

        local headerControls = {}
        local footerControls = {{
            type = "header",
            name = "loggingHeader"
        }, {
            type = "checkbox",
            name = "logVersion",
            default = false,
            persistent = true
        }, {
            type = "checkbox",
            name = "enableDebugging",
            default = false,
            persistent = true
        }, {
            type = "header",
            name = "profile"
        }, {
            type = "checkbox",
            name = "useCharacterSettings",
            default = false,
            onValueChange = function(value) self:UpdateActiveSettings(value) end,
            skipRefresh = true
        }, {
            type = "inputBox",
            name = "loadSettings",
            buttonText = "loadSettingsButton",
            onClick = function(inputText, editBox)
                self:ImportSettings(inputText)
                editBox:SetText("")
            end
        }, {
            type = "button",
            name = "shareSettings",
            onClick = function() self:ExportSettings() end
        }, {
            type = "description",
            name = "tagline"
        }, {
            type = "description",
            name = "author",
            onClick = function()
                self:ShowDialog({
                    title = "authorTitle",
                    controls = {{
                        type = "inputBox",
                        name = "authorName",
                        default = self.author,
                        highlightText = true
                    }}
                })
            end
        }}

        local main = {}
        main.title = (self.config.settings.main and self.config.settings.main.title) or self.addonName
        main.controls = {}

        for _, control in ipairs(headerControls) do
            table.insert(main.controls, control)
        end

        if self.config.settings.main and self.config.settings.main.controls then
            for _, control in ipairs(self.config.settings.main.controls) do
                table.insert(main.controls, control)
            end
        end

        for _, control in ipairs(footerControls) do
            table.insert(main.controls, control)
        end

        self.config.settings.main = main

        local returnValue = true
        callHook(self, "AfterConfigureMainSettings", returnValue)
        return returnValue
    end

    function addon:InitializeSettingsPanel()
        callHook(self, "BeforeInitializeSettingsPanel")

        if self.ConfigureMainSettings then
            self:ConfigureMainSettings()
        end

        self.settingsPanels = {}
        self.mainSettingsPanel = self:BuildMainSettingsPanel()
        self.settingsCategory = Settings.RegisterCanvasLayoutCategory(self.mainSettingsPanel, self.addonName)
        Settings.RegisterAddOnCategory(self.settingsCategory)
        self.settingsPanels["main"] = self.mainSettingsPanel

        local sortedPanelKeys = {}
        for panelKey in pairs(self.config.settings) do
            if panelKey ~= "main" then
                table.insert(sortedPanelKeys, panelKey)
            end
        end
        table.sort(sortedPanelKeys)

        for _, panelKey in ipairs(sortedPanelKeys) do
            local panelConfig = self.config.settings[panelKey]
            local childPanel = self:BuildChildSettingsPanel(panelKey)
            if childPanel then
                local categoryName = self:L(panelConfig.title or panelKey)
                Settings.RegisterCanvasLayoutSubcategory(self.settingsCategory, childPanel, categoryName)
                self.settingsPanels[panelKey] = childPanel
            end
        end

        local returnValue = true
        callHook(self, "AfterInitializeSettingsPanel", returnValue)
        return returnValue
    end

    function addon:BuildSettingsPanelHelper(panelKey, config)
        panelKey, config = callHook(self, "BeforeBuildSettingsPanelHelper", panelKey, config)

        if not config then
            callHook(self, "AfterBuildSettingsPanelHelper", false)
            return false
        end

        local panel = self:CreateSettingsPanel(panelKey)
        local titleText = panelKey == "main" and (self:L(config.title) or self:L(self.addonName)) or self:L(config.title)
        panel.Title:SetText(titleText)
        panel.controlRefreshers = {}

        local content = panel.ScrollFrame.Content
        local yOffset = self.config.ui.spacing.panelTop

        if config.controls then
            for _, controlConfig in ipairs(config.controls) do
                local control, newYOffset = self:AddControl(content, yOffset, panelKey, controlConfig)
                if control and control.refresh then
                    table.insert(panel.controlRefreshers, control.refresh)
                end
                yOffset = newYOffset
            end
        end

        content:SetHeight(math.abs(yOffset) + self.config.ui.spacing.panelBottom)

        callHook(self, "AfterBuildSettingsPanelHelper", panel)
        return panel
    end

    function addon:BuildMainSettingsPanel()
        callHook(self, "BeforeBuildMainSettingsPanel")

        local panel = self:BuildSettingsPanelHelper("main", self.config.settings.main)

        callHook(self, "AfterBuildMainSettingsPanel", panel)
        return panel
    end

    function addon:BuildChildSettingsPanel(panelKey)
        panelKey = callHook(self, "BeforeBuildChildSettingsPanel", panelKey)

        local panel = self:BuildSettingsPanelHelper(panelKey, self.config.settings[panelKey])

        callHook(self, "AfterBuildChildSettingsPanel", panel)
        return panel
    end

    function addon:CreateSettingsPanel(panelKey)
        panelKey = callHook(self, "BeforeCreateSettingsPanel", panelKey)

        local panel = CreateFrame("Frame", self.addonName .. "_" .. panelKey .. "_Panel")
        panel.panelKey = panelKey

        panel.Title = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge")
        panel.Title:SetPoint("TOPLEFT", 7, -22)
        panel.Title:SetJustifyH("LEFT")
        panel.Title:SetTextColor(1, 1, 1)

        panel.HorizontalLine = panel:CreateTexture(nil, "ARTWORK")
        panel.HorizontalLine:SetSize(0, 1)
        panel.HorizontalLine:SetPoint("TOPLEFT", panel.Title, "BOTTOMLEFT", 0, -8)
        panel.HorizontalLine:SetPoint("TOPRIGHT", -30, -63)
        panel.HorizontalLine:SetColorTexture(0.25, 0.25, 0.25, 1)

        panel.ScrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
        panel.ScrollFrame:SetPoint("TOPLEFT", 0, -28)
        panel.ScrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

        panel.ScrollFrame.Content = CreateFrame("Frame", nil, panel.ScrollFrame)
        panel.ScrollFrame.Content:SetSize(600, 1)
        panel.ScrollFrame:SetScrollChild(panel.ScrollFrame.Content)

        callHook(self, "AfterCreateSettingsPanel", panel)
        return panel
    end
end

do -- Controls

    function addon:AddHeader(parent, yOffset, panelKey, name)
        parent, yOffset, panelKey, name = callHook(self, "BeforeAddHeader", parent, yOffset, panelKey, name)

        local header = CreateFrame("Frame", nil, parent)
        header:SetHeight(50)
        header:SetPoint("TOPLEFT", self.config.ui.spacing.contentLeft, yOffset)
        header:SetPoint("TOPRIGHT", self.config.ui.spacing.contentRight, yOffset)

        header.Title = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        header.Title:SetPoint("BOTTOMLEFT", 7, 4)
        header.Title:SetJustifyH("LEFT")
        header.Title:SetJustifyV("BOTTOM")
        header.Title:SetText(self:L(name))

        local newYOffset = yOffset - self.config.ui.spacing.headerHeight
        callHook(self, "AfterAddHeader", header, newYOffset)
        return header, newYOffset
    end

    function addon:AddCheckbox(parent, yOffset, panelKey, name, defaultValue, onValueChange, skipRefresh, persistent)
        local addonInstance = self
        parent, yOffset, panelKey, name, defaultValue, onValueChange, skipRefresh, persistent = callHook(self,
            "BeforeAddCheckbox", parent, yOffset, panelKey, name, defaultValue, onValueChange, skipRefresh, persistent)

        local getValue, setValue

        if persistent ~= true then
            local tempValue = defaultValue
            getValue = function()
                return tempValue
            end
            setValue = function(value)
                tempValue = value
                if onValueChange then
                    onValueChange(addonInstance, value)
                end
            end
        elseif name == "useCharacterSettings" then
            getValue = function()
                return self.settingsChar.useCharacterSettings
            end
            setValue = function(value)
                self.settingsChar.useCharacterSettings = value
                if onValueChange then
                    onValueChange(addonInstance, value)
                end
            end
            if getValue() == nil then
                self.settingsChar.useCharacterSettings = defaultValue
            end
        else
            self.settings[panelKey] = self.settings[panelKey] or {}
            if self.settings[panelKey][name] == nil then
                self.settings[panelKey][name] = defaultValue
            end

            getValue = function()
                self.settings[panelKey] = self.settings[panelKey] or {}
                return self.settings[panelKey][name]
            end

            setValue = function(value)
                self.settings[panelKey] = self.settings[panelKey] or {}
                self.settings[panelKey][name] = value
                if onValueChange then
                    onValueChange(addonInstance, value)
                end
            end
        end

        local checkbox = CreateFrame("Frame", nil, parent)
        checkbox:SetHeight(32)
        checkbox:SetPoint("TOPLEFT", self.config.ui.spacing.controlLeft, yOffset)
        checkbox:SetPoint("TOPRIGHT", self.config.ui.spacing.controlRight, yOffset)

        checkbox.Text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        checkbox.Text:SetSize(205, 0)
        checkbox.Text:SetPoint("LEFT", 17, 0)
        checkbox.Text:SetJustifyH("LEFT")
        checkbox.Text:SetWordWrap(false)
        checkbox.Text:SetText(self:L(name))

        checkbox.CheckBox = CreateFrame("CheckButton", nil, checkbox)
        checkbox.CheckBox:SetSize(26, 26)
        checkbox.CheckBox:SetPoint("LEFT", 215, 0)
        checkbox.CheckBox:SetMotionScriptsWhileDisabled(true)
        checkbox.CheckBox:SetNormalAtlas("checkbox-minimal")
        checkbox.CheckBox:SetPushedAtlas("checkbox-minimal")
        checkbox.CheckBox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
        checkbox.CheckBox:GetCheckedTexture():SetAtlas("checkmark-minimal")
        checkbox.CheckBox:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
        checkbox.CheckBox:GetDisabledCheckedTexture():SetAtlas("checkmark-minimal-disabled")

        local currentValue = getValue()
        if currentValue == nil then
            currentValue = defaultValue
        end
        checkbox.CheckBox:SetChecked(currentValue)

        if onValueChange then
            onValueChange(addonInstance, currentValue)
        end

        checkbox.CheckBox:SetScript("OnClick", function(checkboxFrame)
            setValue(checkboxFrame:GetChecked())
        end)

        if not skipRefresh then
            checkbox.refresh = function()
                local value = getValue()
                if value == nil then
                    value = defaultValue
                end
                checkbox.CheckBox:SetChecked(value)
            end
        end

        local tooltipKey = name .. "Tooltip"
        local tooltipText = addonInstance:L(tooltipKey)
        if tooltipText ~= "[" .. tooltipKey .. "]" then
            checkbox.CheckBox:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(addonInstance:L(name), 1, 1, 1)
                GameTooltip:AddLine(tooltipText, nil, nil, nil, true)
                GameTooltip:Show()
            end)
            checkbox.CheckBox:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
        end

        local newYOffset = yOffset - self.config.ui.spacing.controlHeight
        callHook(self, "AfterAddCheckbox", checkbox, newYOffset)
        return checkbox, newYOffset
    end

    function addon:AddDropdown(parent, yOffset, panelKey, name, defaultValue, options, onValueChange, skipRefresh,
        persistent)
        local addonInstance = self
        parent, yOffset, panelKey, name, defaultValue, options, onValueChange, skipRefresh, persistent =
            callHook(self, "BeforeAddDropdown", parent, yOffset, panelKey, name, defaultValue, options, onValueChange,
                skipRefresh, persistent)

        local currentValue = defaultValue

        if persistent == true then
            self.settings[panelKey] = self.settings[panelKey] or {}
            if self.settings[panelKey][name] == nil then
                self.settings[panelKey][name] = defaultValue
            end
            currentValue = self.settings[panelKey][name]
        end

        local dropdown = CreateFrame("Frame", nil, parent)
        dropdown:SetHeight(32)
        dropdown:SetPoint("TOPLEFT", self.config.ui.spacing.controlLeft, yOffset)
        dropdown:SetPoint("TOPRIGHT", self.config.ui.spacing.controlRight, yOffset)

        dropdown.Text = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        dropdown.Text:SetSize(205, 0)
        dropdown.Text:SetPoint("LEFT", 17, 0)
        dropdown.Text:SetJustifyH("LEFT")
        dropdown.Text:SetWordWrap(false)
        dropdown.Text:SetText(self:L(name))

        dropdown.Dropdown = CreateFrame("Frame", nil, dropdown, "UIDropDownMenuTemplate")
        dropdown.Dropdown:SetPoint("LEFT", 200, 3)
        UIDropDownMenu_SetWidth(dropdown.Dropdown, self.config.ui.dropdown.width)

        local initializeFunc = function(dropdownFrame, level)
            local savedValue = persistent and addonInstance.settings[panelKey][name] or currentValue
            for _, option in ipairs(options) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = addonInstance:L(option.label)
                info.value = option.value
                info.func = function(self)
                    if persistent == true then
                        addonInstance.settings[panelKey][name] = self.value
                    else
                        currentValue = self.value
                    end
                    UIDropDownMenu_SetSelectedValue(dropdown.Dropdown, self.value)
                    UIDropDownMenu_Initialize(dropdown.Dropdown, initializeFunc) -- Reinitialize to update checked states
                    if onValueChange then
                        onValueChange(addonInstance, self.value)
                    end
                end
                info.checked = (savedValue == option.value)
                UIDropDownMenu_AddButton(info, level)
            end
        end

        UIDropDownMenu_Initialize(dropdown.Dropdown, initializeFunc)
        UIDropDownMenu_SetSelectedValue(dropdown.Dropdown, currentValue or defaultValue)

        if onValueChange then
            onValueChange(addonInstance, currentValue or defaultValue)
        end

        if not skipRefresh and persistent == true then
            dropdown.refresh = function()
                addonInstance.settings[panelKey] = addonInstance.settings[panelKey] or {}
                local value = addonInstance.settings[panelKey][name]
                if value == nil then
                    value = defaultValue
                end
                UIDropDownMenu_SetSelectedValue(dropdown.Dropdown, value)
            end
        end

        local newYOffset = yOffset - self.config.ui.spacing.controlHeight
        callHook(self, "AfterAddDropdown", dropdown, newYOffset)
        return dropdown, newYOffset
    end

    function addon:AddSlider(parent, yOffset, panelKey, name, defaultValue, minValue, maxValue, step, onValueChange,
        skipRefresh, persistent)
        local addonInstance = self
        parent, yOffset, panelKey, name, defaultValue, minValue, maxValue, step, onValueChange, skipRefresh, persistent =
            callHook(self, "BeforeAddSlider", parent, yOffset, panelKey, name, defaultValue, minValue, maxValue, step,
                onValueChange, skipRefresh, persistent)

        local currentValue = defaultValue

        if persistent == true then
            self.settings[panelKey] = self.settings[panelKey] or {}
            if self.settings[panelKey][name] == nil then
                self.settings[panelKey][name] = defaultValue
            end
            currentValue = self.settings[panelKey][name]
        end

        local slider = CreateFrame("Frame", nil, parent)
        slider:SetHeight(32)
        slider:SetPoint("TOPLEFT", self.config.ui.spacing.controlLeft, yOffset)
        slider:SetPoint("TOPRIGHT", self.config.ui.spacing.controlRight, yOffset)

        slider.Text = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        slider.Text:SetSize(205, 0)
        slider.Text:SetPoint("LEFT", 17, 0)
        slider.Text:SetJustifyH("LEFT")
        slider.Text:SetWordWrap(false)
        slider.Text:SetText(self:L(name))

        slider.Value = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        slider.Value:SetPoint("LEFT", 430, 0)
        slider.Value:SetJustifyH("LEFT")

        slider.Slider = CreateFrame("Slider", nil, slider, "MinimalSliderWithSteppersTemplate")
        slider.Slider:SetSize(205, 22)
        slider.Slider:SetPoint("LEFT", 215, 0)

        local steps = (maxValue - minValue) / step
        slider.Slider:Init(currentValue or defaultValue, minValue, maxValue, steps)
        slider.Slider:SetWidth(self.config.ui.slider.width)

        local function updateValue(value)
            if value == 0 then
                value = 0
            end
            slider.Value:SetText(string.format("%.0f", value))
        end
        updateValue(currentValue or defaultValue)

        if onValueChange then
            onValueChange(addonInstance, currentValue or defaultValue)
        end

        slider.Slider:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, value)
            if persistent == true then
                addonInstance.settings[panelKey][name] = value
            else
                currentValue = value
            end
            updateValue(value)
            if onValueChange then
                onValueChange(addonInstance, value)
            end
        end)

        if not skipRefresh and persistent == true then
            slider.refresh = function()
                addonInstance.settings[panelKey] = addonInstance.settings[panelKey] or {}
                local value = addonInstance.settings[panelKey][name]
                if value == nil then
                    value = defaultValue
                end
                slider.Slider:SetValue(value)
                updateValue(value)
            end
        end

        local tooltipKey = name .. "Tooltip"
        local tooltipText = addonInstance:L(tooltipKey)
        if tooltipText ~= "[" .. tooltipKey .. "]" then
            slider.Slider:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(addonInstance:L(name), 1, 1, 1)
                GameTooltip:AddLine(tooltipText, nil, nil, nil, true)
                GameTooltip:Show()
            end)
            slider.Slider:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
        end

        local newYOffset = yOffset - self.config.ui.spacing.controlHeight
        callHook(self, "AfterAddSlider", slider, newYOffset)
        return slider, newYOffset
    end

    function addon:AddButton(parent, yOffset, panelKey, name, onClick)
        local addonInstance = self
        parent, yOffset, panelKey, name, onClick = callHook(self, "BeforeAddButton", parent, yOffset, panelKey, name, onClick)

        local button = CreateFrame("Frame", nil, parent)
        button:SetHeight(40)
        button:SetPoint("TOPLEFT", self.config.ui.spacing.contentLeft, yOffset)
        button:SetPoint("TOPRIGHT", self.config.ui.spacing.contentRight, yOffset)

        button.Button = CreateFrame("Button", nil, button, "UIPanelButtonTemplate")
        button.Button:SetSize(120, 22)
        button.Button:SetPoint("LEFT", 35, 0)
        button.Button:SetText(self:L(name))

        button.Button:SetScript("OnClick", function(self)
            if onClick then
                onClick(addonInstance)
            end
        end)

        local tooltipKey = name .. "Tooltip"
        local tooltipText = addonInstance:L(tooltipKey)
        if tooltipText ~= "[" .. tooltipKey .. "]" then
            button.Button:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(addonInstance:L(name), 1, 1, 1)
                GameTooltip:AddLine(tooltipText, nil, nil, nil, true)
                GameTooltip:Show()
            end)
            button.Button:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
        end

        local newYOffset = yOffset - self.config.ui.spacing.buttonHeight
        callHook(self, "AfterAddButton", button, newYOffset)
        return button, newYOffset
    end

    function addon:AddColorPicker(parent, yOffset, panelKey, name, defaultValue, onValueChange, skipRefresh, persistent)
        local addonInstance = self
        parent, yOffset, panelKey, name, defaultValue, onValueChange, skipRefresh, persistent = callHook(self,
            "BeforeAddColorPicker", parent, yOffset, panelKey, name, defaultValue, onValueChange, skipRefresh,
            persistent)

        local currentValue = defaultValue

        if persistent == true then
            self.settings[panelKey] = self.settings[panelKey] or {}
            if self.settings[panelKey][name] == nil then
                self.settings[panelKey][name] = defaultValue
            end
            currentValue = self.settings[panelKey][name]
        end

        local colorPicker = CreateFrame("Frame", nil, parent)
        colorPicker:SetHeight(32)
        colorPicker:SetPoint("TOPLEFT", self.config.ui.spacing.controlLeft, yOffset)
        colorPicker:SetPoint("TOPRIGHT", self.config.ui.spacing.controlRight, yOffset)

        colorPicker.Text = colorPicker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        colorPicker.Text:SetSize(205, 0)
        colorPicker.Text:SetPoint("LEFT", 17, 0)
        colorPicker.Text:SetJustifyH("LEFT")
        colorPicker.Text:SetWordWrap(false)
        colorPicker.Text:SetText(self:L(name))

        colorPicker.ColorSwatch = CreateFrame("Button", nil, colorPicker)
        colorPicker.ColorSwatch:SetSize(26, 26)
        colorPicker.ColorSwatch:SetPoint("LEFT", 215, 0)

        colorPicker.ColorSwatch.Background = colorPicker.ColorSwatch:CreateTexture(nil, "BACKGROUND")
        colorPicker.ColorSwatch.Background:SetColorTexture(1, 1, 1, 1)
        colorPicker.ColorSwatch.Background:SetAllPoints()

        colorPicker.ColorSwatch.Color = colorPicker.ColorSwatch:CreateTexture(nil, "BORDER")
        local r, g, b, a = self:hexToRGB(currentValue or defaultValue)
        colorPicker.ColorSwatch.Color:SetColorTexture(r, g, b, a)
        colorPicker.ColorSwatch.Color:SetPoint("TOPLEFT", 2, -2)
        colorPicker.ColorSwatch.Color:SetPoint("BOTTOMRIGHT", -2, 2)

        colorPicker.ColorSwatch.Border = colorPicker.ColorSwatch:CreateTexture(nil, "OVERLAY")
        colorPicker.ColorSwatch.Border:SetColorTexture(0, 0, 0, 1)
        colorPicker.ColorSwatch.Border:SetAllPoints()
        colorPicker.ColorSwatch.Border:SetDrawLayer("OVERLAY", 0)

        local function updateColor(hexColor)
            local r, g, b, a = self:hexToRGB(hexColor)
            colorPicker.ColorSwatch.Color:SetColorTexture(r, g, b, a)
            if persistent == true then
                self.settings[panelKey][name] = hexColor
            else
                currentValue = hexColor
            end
            if onValueChange then
                onValueChange(addonInstance, hexColor)
            end
        end

        if onValueChange then
            onValueChange(addonInstance, currentValue or defaultValue)
        end

        colorPicker.ColorSwatch:SetScript("OnClick", function(self)
            local r, g, b, a = self:hexToRGB(persistent == true and self.settings[panelKey][name] or currentValue or
                                                  defaultValue)

            ColorPickerFrame:SetupColorPickerAndShow({
                swatchFunc = function()
                    local newR, newG, newB = ColorPickerFrame:GetColorRGB()
                    local newA = ColorPickerFrame:GetColorAlpha()
                    local hexColor = self:rgbToHex(newR, newG, newB, newA)
                    updateColor(hexColor)
                end,
                cancelFunc = function()
                    updateColor(self:rgbToHex(r, g, b, a))
                end,
                opacityFunc = function()
                    local newR, newG, newB = ColorPickerFrame:GetColorRGB()
                    local newA = ColorPickerFrame:GetColorAlpha()
                    local hexColor = self:rgbToHex(newR, newG, newB, newA)
                    updateColor(hexColor)
                end,
                r = r,
                g = g,
                b = b,
                opacity = a,
                hasOpacity = true
            })
        end)

        if not skipRefresh and persistent == true then
            colorPicker.refresh = function()
                self.settings[panelKey] = self.settings[panelKey] or {}
                local value = self.settings[panelKey][name]
                if value == nil then
                    value = defaultValue
                end
                local r, g, b, a = self:hexToRGB(value)
                colorPicker.ColorSwatch.Color:SetColorTexture(r, g, b, a)
            end
        end

        local tooltipKey = name .. "Tooltip"
        local tooltipText = self:L(tooltipKey)
        if tooltipText ~= "[" .. tooltipKey .. "]" then
            colorPicker.ColorSwatch:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self:L(name), 1, 1, 1)
                GameTooltip:AddLine(tooltipText, nil, nil, nil, true)
                GameTooltip:Show()
            end)
            colorPicker.ColorSwatch:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
        end

        local newYOffset = yOffset - self.config.ui.spacing.controlHeight
        callHook(self, "AfterAddColorPicker", colorPicker, newYOffset)
        return colorPicker, newYOffset
    end

    function addon:AddDescription(parent, yOffset, panelKey, name, onClick)
        local addonInstance = self
        parent, yOffset, panelKey, name, onClick = callHook(self, "BeforeAddDescription", parent, yOffset, panelKey, name,
            onClick)

        local frame = CreateFrame("Frame", nil, parent)
        frame:SetPoint("TOPLEFT", self.config.ui.spacing.controlLeft, yOffset)
        frame:SetPoint("TOPRIGHT", self.config.ui.spacing.controlRight, yOffset)
        frame:SetHeight(32)

        local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fontString:SetPoint("LEFT", self.config.ui.spacing.textInset, 0)
        fontString:SetPoint("RIGHT", -self.config.ui.spacing.textInset, 0)
        fontString:SetJustifyH("LEFT")
        fontString:SetJustifyV("TOP")
        fontString:SetWordWrap(true)
        fontString:SetText(self:L(name))

        local stringHeight = fontString:GetStringHeight()
        frame:SetHeight(math.max(32, stringHeight))

        if onClick then
            frame:EnableMouse(true)
            frame:SetScript("OnMouseDown", function(self)
                onClick(addonInstance)
            end)
            frame:SetScript("OnEnter", function(self)
                fontString:SetTextColor(1, 0.82, 0, 1)
            end)
            frame:SetScript("OnLeave", function(self)
                fontString:SetTextColor(1.0, 0.82, 0, 1)
            end)
        end

        local newYOffset = yOffset - math.max(32, stringHeight) - self.config.ui.spacing.descriptionPadding
        callHook(self, "AfterAddDescription", frame, newYOffset)
        return frame, newYOffset
    end

    function addon:AddInputBox(parent, yOffset, panelKey, name, default, highlightText, buttonText, onClick,
        onValueChange, persistent)
        local addonInstance = self
        parent, yOffset, panelKey, name, default, highlightText, buttonText, onClick, onValueChange, persistent =
            callHook(self, "BeforeAddInputBox", parent, yOffset, panelKey, name, default, highlightText, buttonText, onClick,
                onValueChange, persistent)

        local control = CreateFrame("Frame", nil, parent)
        control:SetHeight(32)
        control:SetPoint("TOPLEFT", self.config.ui.spacing.controlLeft, yOffset)
        control:SetPoint("TOPRIGHT", self.config.ui.spacing.controlRight, yOffset)

        control.Text = control:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        control.Text:SetSize(205, 0)
        control.Text:SetPoint("LEFT", 17, 0)
        control.Text:SetJustifyH("LEFT")
        control.Text:SetWordWrap(false)
        control.Text:SetText(self:L(name))

        control.EditBox = CreateFrame("EditBox", nil, control)
        control.EditBox:SetSize(220, 22)
        control.EditBox:SetPoint("LEFT", 218, 0)
        control.EditBox:SetAutoFocus(false)
        control.EditBox:SetFontObject("ChatFontNormal")

        control.EditBox.Background = control.EditBox:CreateTexture(nil, "BACKGROUND")
        control.EditBox.Background:SetAllPoints(control.EditBox)
        control.EditBox.Background:SetColorTexture(0, 0, 0, 0.5)

        control.Button = CreateFrame("Button", nil, control, "UIPanelButtonTemplate")
        control.Button:SetSize(60, 22)
        control.Button:SetPoint("LEFT", control.EditBox, "RIGHT", 8, 0)

        local shouldPersist = persistent == true

        if shouldPersist then
            self.settings[panelKey] = self.settings[panelKey] or {}
            if self.settings[panelKey][name] == nil then
                self.settings[panelKey][name] = default
            end

            control.EditBox:SetScript("OnTextChanged", function(self, userInput)
                if userInput then
                    local newValue = self:GetText()
                    addonInstance.settings[panelKey][name] = newValue
                    if onValueChange then
                        onValueChange(addonInstance, newValue)
                    end
                end
            end)
        else
            control.EditBox:SetScript("OnTextChanged", function(self, userInput)
                if userInput then
                    local newValue = self:GetText()
                    if onValueChange then
                        onValueChange(addonInstance, newValue)
                    end
                end
            end)
        end

        if buttonText then
            control.Button:SetText(buttonText)

            if onClick then
                control.Button:SetScript("OnClick", function(self)
                    local inputText = control.EditBox:GetText()
                    onClick(addonInstance, inputText, control.EditBox)
                end)
            end

            local tooltipKey = name .. "Tooltip"
            local tooltipText = addonInstance:L(tooltipKey)
            if tooltipText ~= "[" .. tooltipKey .. "]" then
                control.Button:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(buttonText, 1, 1, 1)
                    GameTooltip:AddLine(tooltipText, nil, nil, nil, true)
                    GameTooltip:Show()
                end)
                control.Button:SetScript("OnLeave", function(self)
                    GameTooltip:Hide()
                end)
            end
        else
            control.Button:Hide()
        end

        control.EditBox.Background:SetAllPoints(control.EditBox)
        control.EditBox:SetFontObject(GameFontHighlight)
        control.EditBox:SetTextColor(1, 1, 1, 1)
        control.EditBox:SetTextInsets(5, 5, 0, 0)
        control.EditBox:SetMultiLine(false)
        control.EditBox:SetAutoFocus(false)
        control.EditBox:Show()
        control.EditBox:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
        end)
        control.EditBox:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
        end)

        control.EditBox:SetScript("OnShow", function(self)
            if shouldPersist then
                local savedValue = addonInstance.settings[panelKey][name]
                if savedValue and self:GetText() == "" then
                    self:SetText(savedValue)
                    self:SetCursorPosition(0)
                end
            end
            if highlightText then
                self:HighlightText()
            end
        end)

        if shouldPersist then
            local initialValue = self.settings[panelKey][name] or default
            if initialValue then
                control.EditBox:SetText(initialValue)
                control.EditBox:SetCursorPosition(0)
            end

            if onValueChange then
                onValueChange(addonInstance, initialValue)
            end

            control.refresh = function()
                local value = addonInstance.settings[panelKey][name] or default
                if value then
                    control.EditBox:SetText(value)
                    control.EditBox:SetCursorPosition(0)
                end
            end
        else
            if default then
                control.EditBox:SetText(default)
                control.EditBox:SetCursorPosition(0)
            end
        end

        local newYOffset = yOffset - self.config.ui.spacing.controlHeight
        callHook(self, "AfterAddInputBox", control, newYOffset)
        return control, newYOffset
    end

    function addon:ShowDialog(dialogOptions)
        local addonInstance = self
        dialogOptions = callHook(self, "BeforeShowDialog", dialogOptions)

        self:debug("ShowDialog called")
        local dialog = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")

        local uiCfg = self.config.ui
        local width = dialogOptions.width or uiCfg.dialog.defaultWidth
        dialog:SetWidth(width)
        dialog:SetPoint("CENTER")
        dialog:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            tile = false,
            edgeSize = uiCfg.backdrop.edgeSize,
            insets = uiCfg.backdrop.insets
        })
        dialog:SetBackdropColor(0, 0, 0, 1)
        dialog:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        dialog:SetFrameStrata("DIALOG")
        dialog:EnableMouse(true)

        local title = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOP", 0, uiCfg.dialog.titleOffset)
        title:SetText(self:L(dialogOptions.title))

        local content = CreateFrame("Frame", nil, dialog)
        content:SetPoint("TOPLEFT", uiCfg.spacing.contentLeft, uiCfg.dialog.contentTop)
        content:SetPoint("BOTTOMRIGHT", uiCfg.spacing.contentRight, uiCfg.dialog.contentBottom)

        local yOffset = uiCfg.dialog.initialYOffset
        local inputBoxControls = {}
        if dialogOptions.controls then
            for _, controlConfig in ipairs(dialogOptions.controls) do
                local control, newYOffset = self:AddControl(content, yOffset, "dialog", controlConfig)
                if controlConfig.type == "inputBox" and controlConfig.highlightText and control then
                    table.insert(inputBoxControls, control)
                end
                yOffset = newYOffset
            end
        end

        local contentHeight = math.abs(yOffset) + uiCfg.dialog.contentPadding
        local calculatedHeight = uiCfg.dialog.titleHeight + contentHeight + uiCfg.dialog.buttonHeight

        local height = dialogOptions.height or calculatedHeight
        dialog:SetHeight(height)

        local closeButton = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
        closeButton:SetSize(uiCfg.dialog.buttonSize.width, uiCfg.dialog.buttonSize.height)
        closeButton:SetPoint("BOTTOM", 0, uiCfg.dialog.buttonOffset)
        closeButton:SetText(self:L("close"))
        closeButton:SetScript("OnClick", function()
            dialog:Hide()
            if dialogOptions.onClose then
                dialogOptions.onClose()
            end
        end)

        dialog:SetScript("OnKeyDown", function(self, key)
            if key == "ESCAPE" then
                closeButton:Click()
            end
        end)

        dialog:Show()

        if #inputBoxControls > 0 then
            local firstControl = inputBoxControls[1]
            if firstControl.EditBox then
                C_Timer.After(0, function()
                    firstControl.EditBox:SetFocus()
                    firstControl.EditBox:HighlightText()
                end)
            end
        end

        callHook(self, "AfterShowDialog", dialog)
        return dialog
    end

    function addon:AddControl(parent, yOffset, panelKey, controlConfig)
        parent, yOffset, panelKey, controlConfig =
            callHook(self, "BeforeAddControl", parent, yOffset, panelKey, controlConfig)

        local controlType = controlConfig.type

        if controlType == "header" then
            local control, newYOffset = self:AddHeader(parent, yOffset, panelKey, controlConfig.name)
            callHook(self, "AfterAddControl", control, newYOffset)
            return control, newYOffset

        elseif controlType == "checkbox" then
            local control, newYOffset = self:AddCheckbox(parent, yOffset, panelKey, controlConfig.name,
                controlConfig.default, controlConfig.onValueChange, controlConfig.skipRefresh, controlConfig.persistent)
            callHook(self, "AfterAddControl", control, newYOffset)
            return control, newYOffset

        elseif controlType == "dropdown" then
            local control, newYOffset = self:AddDropdown(parent, yOffset, panelKey, controlConfig.name,
                controlConfig.default, controlConfig.options, controlConfig.onValueChange, controlConfig.skipRefresh,
                controlConfig.persistent)
            callHook(self, "AfterAddControl", control, newYOffset)
            return control, newYOffset

        elseif controlType == "slider" then
            local control, newYOffset = self:AddSlider(parent, yOffset, panelKey, controlConfig.name,
                controlConfig.default, controlConfig.min, controlConfig.max, controlConfig.step,
                controlConfig.onValueChange, controlConfig.skipRefresh, controlConfig.persistent)
            callHook(self, "AfterAddControl", control, newYOffset)
            return control, newYOffset

        elseif controlType == "button" then
            local control, newYOffset = self:AddButton(parent, yOffset, panelKey, controlConfig.name,
                controlConfig.onClick)
            callHook(self, "AfterAddControl", control, newYOffset)
            return control, newYOffset

        elseif controlType == "description" then
            local control, newYOffset = self:AddDescription(parent, yOffset, panelKey, controlConfig.name,
                controlConfig.onClick)
            callHook(self, "AfterAddControl", control, newYOffset)
            return control, newYOffset

        elseif controlType == "inputBox" then
            local buttonText = controlConfig.buttonText and self:L(controlConfig.buttonText) or nil
            local control, newYOffset = self:AddInputBox(parent, yOffset, panelKey, controlConfig.name,
                controlConfig.default, controlConfig.highlightText, buttonText, controlConfig.onClick,
                controlConfig.onValueChange, controlConfig.persistent)
            callHook(self, "AfterAddControl", control, newYOffset)
            return control, newYOffset

        elseif controlType == "colorPicker" then
            local control, newYOffset = self:AddColorPicker(parent, yOffset, panelKey, controlConfig.name,
                controlConfig.default, controlConfig.onValueChange, controlConfig.skipRefresh, controlConfig.persistent)
            callHook(self, "AfterAddControl", control, newYOffset)
            return control, newYOffset

        else
            self:debug("Unknown control type: " .. tostring(controlType))
            callHook(self, "AfterAddControl", false, yOffset)
            return false, yOffset
        end
    end
end

do -- Utility Functions

    function addon:InspectCommand(frameName)
        frameName = callHook(self, "BeforeInspectCommand", frameName)

        if not frameName or frameName == "" then
            self:info("Usage: /" .. self.addonName:lower() .. " inspect <frameName>")
            local returnValue = false
            callHook(self, "AfterInspectCommand", returnValue)
            return returnValue
        end

        local inspectionResult = self:InspectFrame(frameName)

        if inspectionResult then
            self:ShowDialog({
                title = frameName,
                controls = {{
                    type = "inputBox",
                    name = "inspectResult",
                    default = inspectionResult,
                    highlightText = true
                }}
            })
            local returnValue = true
            callHook(self, "AfterInspectCommand", returnValue)
            return returnValue
        else
            self:error("Frame not found: " .. frameName)
            local returnValue = false
            callHook(self, "AfterInspectCommand", returnValue)
            return returnValue
        end
    end

    function addon:InspectFrame(frameName)
        frameName = callHook(self, "BeforeInspectFrame", frameName)

        local frame = _G[frameName]
        if not frame then
            callHook(self, "AfterInspectFrame", false)
            return false
        end

        local output = {}
        local indent = 0

        local function addLine(text)
            table.insert(output, string.rep("  ", indent) .. text)
        end

        local function safeCall(func, ...)
            local success, result = pcall(func, ...)
            if success then
                return result
            end
            return nil
        end

        local function getFrameAttributes(frame, suggestedName)
            local attrs = {}

            local name = safeCall(frame.GetName, frame) or suggestedName or "Anonymous"
            table.insert(attrs, 'name="' .. name .. '"')

            local frameType = safeCall(frame.GetObjectType, frame) or "Frame"
            table.insert(attrs, 'type="' .. frameType .. '"')

            if frame.IsVisible then
                local visible = safeCall(frame.IsVisible, frame)
                if visible ~= nil then
                    table.insert(attrs, 'visible="' .. tostring(visible) .. '"')
                end
            end

            if frame.GetAlpha then
                local alpha = safeCall(frame.GetAlpha, frame)
                if alpha and alpha < 1.0 then
                    table.insert(attrs, string.format('alpha="%.2f"', alpha))
                end
            end

            if frame.GetWidth and frame.GetHeight then
                local width = safeCall(frame.GetWidth, frame)
                local height = safeCall(frame.GetHeight, frame)
                if width and width > 0 then
                    table.insert(attrs, string.format('width="%.0f"', width))
                end
                if height and height > 0 then
                    table.insert(attrs, string.format('height="%.0f"', height))
                end
            end

            if frameType == "StatusBar" and frame.GetStatusBarTexture then
                local texture = safeCall(frame.GetStatusBarTexture, frame)
                if texture then
                    table.insert(attrs, 'statusBarTexture="' .. tostring(texture) .. '"')
                end
                if frame.GetNumRegions then
                    local numRegions = safeCall(frame.GetNumRegions, frame)
                    if numRegions then
                        table.insert(attrs, 'numRegions="' .. numRegions .. '"')
                    end
                end
            end

            if frameType == "FontString" and frame.GetText then
                local text = safeCall(frame.GetText, frame)
                if text and text ~= "" then
                    text = text:gsub('"', '\\"')
                    if #text > 50 then
                        text = text:sub(1, 50) .. "..."
                    end
                    table.insert(attrs, 'text="' .. text .. '"')
                end
            end

            if frameType == "Texture" then
                if frame.GetTexture then
                    local texture = safeCall(frame.GetTexture, frame)
                    if texture then
                        table.insert(attrs, 'texture="' .. tostring(texture) .. '"')
                    end
                end
                if frame.GetAtlas then
                    local atlas = safeCall(frame.GetAtlas, frame)
                    if atlas then
                        table.insert(attrs, 'atlas="' .. atlas .. '"')
                    end
                end
            end

            return table.concat(attrs, " ")
        end

        local function inspectFrameRecursive(frame, frameName, parentFrame)
            local success, attrs = pcall(getFrameAttributes, frame, frameName)
            if not success then
                addLine("<!-- Protected/Forbidden Frame: " .. tostring(frameName) .. " -->")
                return
            end

            addLine("<" .. frameName .. " " .. attrs .. ">")
            indent = indent + 1

            if frame.GetNumRegions then
                local numRegions = safeCall(frame.GetNumRegions, frame) or 0
                if numRegions > 0 then
                    addLine("<!-- Regions -->")
                    local regions = {frame:GetRegions()}
                    for i = 1, numRegions do
                        local region = regions[i]
                        if region then
                            local regionName = safeCall(region.GetName, region)
                            if not regionName and parentFrame then
                                for key, value in pairs(parentFrame) do
                                    if value == region and type(key) == "string" then
                                        regionName = key
                                        break
                                    end
                                end
                            end
                            regionName = regionName or ("Region" .. i)

                            local regionSuccess, regionAttrs = pcall(getFrameAttributes, region, regionName)
                            if regionSuccess then
                                addLine("<" .. regionName .. " " .. regionAttrs .. " />")
                            else
                                addLine("<!-- Protected Region" .. i .. " -->")
                            end
                        end
                    end
                end
            end

            if frame.GetChildren then
                local numChildren = safeCall(frame.GetNumChildren, frame) or 0
                if numChildren > 0 then
                    addLine("<!-- Children -->")
                    local children = {frame:GetChildren()}
                    for i = 1, numChildren do
                        local child = children[i]
                        if child then
                            local childName = safeCall(child.GetName, child)
                            if not childName and frame then
                                for key, value in pairs(frame) do
                                    if value == child and type(key) == "string" then
                                        childName = key
                                        break
                                    end
                                end
                            end
                            childName = childName or "Anonymous"
                            inspectFrameRecursive(child, childName, frame)
                        end
                    end
                end
            end

            indent = indent - 1
            addLine("</" .. frameName .. ">")
        end

        addLine("-- " .. string.rep("=", 80))
        addLine("-- FRAME INSPECTION: " .. frameName)
        addLine("-- " .. string.rep("=", 80))
        inspectFrameRecursive(frame, frameName, nil)
        addLine("-- " .. string.rep("=", 80))

        local result = table.concat(output, "\n")
        callHook(self, "AfterInspectFrame", result)
        return result
    end

    function addon:hexToRGB(hex)
        hex = hex:gsub("#", "")
        local r = tonumber(hex:sub(1, 2), 16) / 255
        local g = tonumber(hex:sub(3, 4), 16) / 255
        local b = tonumber(hex:sub(5, 6), 16) / 255
        local a = 1
        if #hex == 8 then
            a = tonumber(hex:sub(7, 8), 16) / 255
        end
        return r, g, b, a
    end

    function addon:rgbToHex(r, g, b, a)
        r = math.floor(r * 255 + 0.5)
        g = math.floor(g * 255 + 0.5)
        b = math.floor(b * 255 + 0.5)
        if a then
            a = math.floor(a * 255 + 0.5)
            return string.format("#%02X%02X%02X%02X", r, g, b, a)
        end
        return string.format("#%02X%02X%02X", r, g, b)
    end

    function addon:OpenSettings()
        callHook(self, "BeforeOpenSettings")

        if type(Settings) == "table" and type(Settings.OpenToCategory) == "function" then
            if self.settingsCategory and self.settingsCategory.ID then
                Settings.OpenToCategory(self.settingsCategory.ID)
            end
        end

        local returnValue = true
        callHook(self, "AfterOpenSettings", returnValue)
        return returnValue
    end

    function addon:L(key)
        key = callHook(self, "BeforeL", key)

        if not key then
            callHook(self, "AfterL", "")
            return ""
        end

        key = key:gsub(" ", "_")
        key = key:gsub("[^%w_]", "")

        if key == "author" then
            callHook(self, "AfterL", self.author)
            return self.author
        end
        if not self.localization then
            local returnValue = "[" .. key .. "]"
            callHook(self, "AfterL", returnValue)
            return returnValue
        end
        local result = self.localization[key] or ("[" .. key .. "]")
        callHook(self, "AfterL", result)
        return result
    end

    function addon:coreInfo(text)
        print("\124cffDB09FE" .. "SAdCore" .. ": " .. "\124cffBAFF1A" .. tostring(text))
    end

    function addon:coreDebug(text)
        if self.settings and self.settings.main and self.settings.main.enableDebugging then
            print("\124cffDB09FE" .. "SAdCore" .. " Debug: " .. "\124cffBAFF1A" .. tostring(text))
        end
    end

    function addon:info(text)
        text = callHook(self, "BeforeInfo", text)

        print("\124cffDB09FE" .. self.addonName .. ": " .. "\124cffBAFF1A" .. tostring(text))

        local returnValue = true
        callHook(self, "AfterInfo", returnValue)
        return returnValue
    end

    function addon:error(text)
        text = callHook(self, "BeforeError", text)

        print("\124cffDB09FE" .. self.addonName .. ": " .. "\124cffBAFF1A" .. tostring(text))

        local returnValue = true
        callHook(self, "AfterError", returnValue)
        return returnValue
    end

    function addon:debug(text)
        text = callHook(self, "BeforeDebug", text)

        if self.settings and self.settings.main and self.settings.main.enableDebugging then
            print("\124cffDB09FE" .. self.addonName .. " Debug: " .. "\124cffBAFF1A" .. tostring(text))
        end

        local returnValue = true
        callHook(self, "AfterDebug", returnValue)
        return returnValue
    end

    function addon:RefreshSettingsPanels()
        callHook(self, "BeforeRefreshSettingsPanels")

        if self.settingsPanels then
            for panelKey, panel in pairs(self.settingsPanels) do
                if panel and panel.controlRefreshers then
                    for _, refreshFunc in ipairs(panel.controlRefreshers) do
                        refreshFunc()
                    end
                end
            end
        end

        local returnValue = true
        callHook(self, "AfterRefreshSettingsPanels", returnValue)
        return returnValue
    end

    function addon:UpdateActiveSettings(useCharacter)
        useCharacter = callHook(self, "BeforeUpdateActiveSettings", useCharacter)
        self.settings = useCharacter and self.settingsChar or self.settingsGlobal
        local profileType = useCharacter and "Character" or "Global"
        self:debug("Profile switched to: " .. profileType)
        self:RefreshSettingsPanels()

        local returnValue = true
        callHook(self, "AfterUpdateActiveSettings", returnValue)
        return returnValue
    end

    function addon:ExportSettings()
        callHook(self, "BeforeExportSettings")

        local exportData = {
            addon = self.addonName,
            version = tostring(self.config.version),
            sadCoreVersion = tostring(self.sadCore.version),
            settings = self.settings
        }

        local LibSerialize = self.LibSerialize
        local LibCompress = self.LibCompress
        local success, serialized = pcall(function()
            return LibSerialize:Serialize(exportData)
        end)
        if not success or not serialized then
            self:debug("Serialize failed.")
            callHook(self, "AfterExportSettings", false)
            return false
        end
        local encoded = LibCompress:Encode(serialized)
        if not encoded then
            self:debug("Encode failed.")
            callHook(self, "AfterExportSettings", false)
            return false
        end

        self:debug(encoded)

        self:ShowDialog({
            title = "shareSettingsTitle",
            controls = {{
                type = "inputBox",
                name = "shareSettingsLabel",
                default = encoded,
                highlightText = true
            }}
        })

        callHook(self, "AfterExportSettings", encoded)
        return encoded
    end

    function addon:ImportSettings(serializedString)
        serializedString = callHook(self, "BeforeImportSettings", serializedString)

        if not serializedString or serializedString == "" then
            callHook(self, "AfterImportSettings", false)
            return false
        end

        local LibSerialize = self.LibSerialize
        local LibCompress = self.LibCompress

        self:debug("Decoding import string...")
        local decoded = LibCompress:Decode(serializedString)
        if not decoded then
            self:error(self:L("importDecodeFailed"))
            callHook(self, "AfterImportSettings", false)
            return false
        end
        self:debug("Decode successful. Deserializing...")

        local success, data = LibSerialize:Deserialize(decoded)
        if not success then
            self:error(self:L("importDeserializeFailed") .. ": " .. tostring(data))
            callHook(self, "AfterImportSettings", false)
            return false
        end

        self:debug("Deserialized data type: " .. type(data))
        if type(data) == "table" then
            self:debug("Deserialized table contents:")
            for key, value in pairs(data) do
                self:debug("  " .. tostring(key) .. " = " .. tostring(value))
            end
        else
            self:debug("Deserialized data: " .. tostring(data))
        end

        if not data or type(data) ~= "table" then
            self:error(self:L("importInvalidData"))
            callHook(self, "AfterImportSettings", false)
            return false
        end

        if data.addon ~= self.addonName then
            self:error(self:L("importWrongAddon") .. ": " .. tostring(data.addon))
            callHook(self, "AfterImportSettings", false)
            return false
        end

        if tostring(data.version) ~= tostring(self.config.version) then
            self:error(
                self:L("importVersionMismatch") .. " " .. self:L("imported") .. ": " .. tostring(data.version) .. ", " ..
                    self:L("current") .. ": " .. tostring(self.config.version))
            callHook(self, "AfterImportSettings", false)
            return false
        end

        if tostring(data.sadCoreVersion) ~= tostring(self.sadCore.version) then
            self:error("SAdCore version mismatch. " .. self:L("imported") .. ": " .. tostring(data.sadCoreVersion) ..
                            ", " .. self:L("current") .. ": " .. tostring(self.sadCore.version))
            callHook(self, "AfterImportSettings", false)
            return false
        end

        local importedSettings = data.settings

        for key in pairs(self.settings) do
            self.settings[key] = nil
        end

        for key, value in pairs(importedSettings) do
            self.settings[key] = value
        end

        self:info(self:L("importSuccess"))
        self:RefreshSettingsPanels()

        callHook(self, "AfterImportSettings", true)
        return true
    end

end

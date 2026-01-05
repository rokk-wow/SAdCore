local addonName, addon = ...

--[[
    CRITICAL CODING CONSTRAINTS FOR THIS FILE:
    
    SCOPE: These constraints apply ONLY to addon.* functions (functions on the addon table).
    Local (private) functions are NOT subject to these requirements as they cannot be
    hooked by external addons.
    
    1. HOOK REQUIREMENT - Every addon.* function MUST include:
       - callHook("BeforeFunctionName", ...) as the first line
       - callHook("AfterFunctionName", returnValue) before EVERY return statement
       
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
               callHook("AfterFunctionName", false)
               return false
           end
    
    4. STANDARD FUNCTION PATTERN:
       function addon.FunctionName(params)
           callHook("BeforeFunctionName", params)
           
           -- Early return example
           if errorCondition then
               callHook("AfterFunctionName", false)
               return false
           end
           
           -- Function logic here
           
           local returnValue = true
           callHook("AfterFunctionName", returnValue)
           return returnValue
       end
    
    These constraints enable external addons to hook into ANY addon.* function's execution
    for monitoring, modification, or extension purposes. Failure to follow these
    patterns breaks the extensibility contract of the framework.
]]

local function callHook(hookName, ...)
    local hook = addon[hookName]
    if hook then 
        return hook(...)
    end
    return ...
end

do  -- Initialization

    function addon.initialize()        
        callHook("BeforeInitialize")

        addon.config = addon.config or {}
        addon.config.toc = addon.config.toc or {}
        addon.config.settings = addon.config.settings or {}
        addon.sadCore = addon.sadCore or {}
        addon.sadCore.version = "1.1"
        addon.author = string.char(82,195,180,107,107,45,87,121,114,109,114,101,115,116,32,65,99,99,111,114,100)
        
        local clientLocale = GetLocale()
        addon.localization = addon.locale[clientLocale] or addon.locale.enEN

        addon.config.ui = addon.config.ui or {
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
                buttonSize = { width = 100, height = 25 },
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
                insets = { left = 2, right = 2, top = 2, bottom = 2 }
            }
        }

        callHook("LoadConfig")

        addon.InitializeCompartmentFunc(addon.config.toc.AddonCompartmentFunc)
        addon.InitializeSavedVariables(addon.config.toc.SavedVariables, addon.config.toc.SavedVariablesPerCharacter)

        addon.LibSerialize = LibStub("LibSerialize")
        addon.LibCompress = LibStub("LibCompress")
       
        addon.CreateSlashCommand()
        addon.InitializeSettingsPanel()
        
        if addon.RegisterFunctions then
            addon.RegisterFunctions()
        end
        
        if addon.settings.main.logVersion then
            addon.info(addon.L("versionPrefix") .. addon.config.version)
        end

        local returnValue = true
        callHook("AfterInitialize", returnValue)
        
        addon.initialized = true

        return returnValue
    end

    function addon.InitializeCompartmentFunc(compartmentFunc)
        compartmentFunc = callHook("BeforeInitializeCompartmentFunc", compartmentFunc)
        
        if compartmentFunc then
            _G[compartmentFunc] = function()
                addon.OpenSettings()
            end
        end
        
        local returnValue = true
        callHook("AfterInitializeCompartmentFunc", returnValue)
        return returnValue
    end

    function addon.InitializeSavedVariables(savedVars, savedVarsPerChar)
        savedVars, savedVarsPerChar = callHook("BeforeInitializeSavedVariables", savedVars, savedVarsPerChar)
        
        if savedVars then
            _G[savedVars] = _G[savedVars] or {}
            addon.settingsGlobal = _G[savedVars]
            addon.settingsGlobal.main = addon.settingsGlobal.main or {}
        else
            addon.settingsGlobal = {}
            addon.settingsGlobal.main = {}
        end

        if savedVarsPerChar then
            _G[savedVarsPerChar] = _G[savedVarsPerChar] or {}
            addon.settingsChar = _G[savedVarsPerChar]
            addon.settingsChar.main = addon.settingsChar.main or {}
        else
            addon.settingsChar = {}
            addon.settingsChar.main = {}
        end
        
        addon.settings = (addon.settingsChar.useCharacterSettings) and addon.settingsChar or addon.settingsGlobal
        
        local returnValue = true
        callHook("AfterInitializeSavedVariables", returnValue)
        return returnValue
    end
end

do  -- Registration functions

    function addon.RegisterEvent(eventName, callback)
        eventName, callback = callHook("BeforeRegisterEvent", eventName, callback)
        
        if addon.eventFrame == nil then
            addon.eventFrame = CreateFrame("Frame", nil, UIParent)
            addon.eventCallbacks = {}
            addon.eventFrame:SetScript("OnEvent", function(self, event, ...)
                local eventCallback = addon.eventCallbacks[event]
                if eventCallback then
                    eventCallback(event, ...)
                end
            end)
        end
        
        addon.eventFrame:RegisterEvent(eventName)
        addon.eventCallbacks[eventName] = callback
        
        local returnValue = true
        callHook("AfterRegisterEvent", returnValue)
        return returnValue
    end

    function addon.RegisterSlashCommand(command, callback)
        command, callback = callHook("BeforeRegisterSlashCommand", command, callback)
        
        if not addon.slashCommands then
            addon.slashCommands = {}
        end
        
        addon.slashCommands[command:lower()] = callback
        
        local returnValue = true
        callHook("AfterRegisterSlashCommand", returnValue)
        return returnValue
    end

    function addon.CreateSlashCommand()
        callHook("BeforeCreateSlashCommand")
        
        addon.slashCommands = {}
        
        local slashCommandName = addonName:upper()
        _G["SLASH_" .. slashCommandName .. "1"] = "/" .. addonName:lower()
        SlashCmdList[slashCommandName] = function(message)
            local command, rest = message:match("^(%S*)%s*(.-)$")
            command = command and command:lower() or ""
            
            if command ~= "" and addon.slashCommands[command] then
                local params = {}
                if rest and rest ~= "" then
                    for param in rest:gmatch("%S+") do
                        table.insert(params, param)
                    end
                end
                addon.slashCommands[command](unpack(params))
            else
                addon.OpenSettings()
            end
        end
        
        local returnValue = true
        callHook("AfterCreateSlashCommand", returnValue)
        return returnValue
    end
end


do  -- User Settings UI

    function addon.ConfigureMainSettings()
        callHook("BeforeConfigureMainSettings")
        
        local headerControls = {}
        local footerControls = {
            {
                type = "header",
                name = "loggingHeader"
            },
            {
                type = "checkbox",
                name = "logVersion",
                default = false,
                persistent = true
            },
            {
                type = "checkbox",
                name = "enableDebugging",
                default = false,
                persistent = true
            },
            {
                type = "header",
                name = "profile"
            },
            {
                type = "checkbox",
                name = "useCharacterSettings",
                default = false,
                onValueChange = addon.UpdateActiveSettings,
                skipRefresh = true
            },
            {
                type = "inputBox",
                name = "loadSettings",
                buttonText = "loadSettingsButton",
                onClick = function(inputText, editBox)
                    addon.ImportSettings(inputText)
                    editBox:SetText("")
                end
            },
            {
                type = "button",
                name = "shareSettings",
                onClick = addon.ExportSettings
            },
            {
                type = "description",
                name = "tagline",
            },
            {
                type = "description",
                name = "author",
                onClick = function()
                    addon.ShowDialog({
                        title = "authorTitle",
                        controls = {
                            {
                                type = "inputBox",
                                name = "authorName",
                                default = addon.author,
                                highlightText = true
                            }
                        }
                    })
                end
            }
        }

        local main = {}
        main.title = (addon.config.settings.main and addon.config.settings.main.title) or addonName
        main.controls = {}
        
        for _, control in ipairs(headerControls) do
            table.insert(main.controls, control)
        end
        
        if addon.config.settings.main and addon.config.settings.main.controls then
            for _, control in ipairs(addon.config.settings.main.controls) do
                table.insert(main.controls, control)
            end
        end
        
        for _, control in ipairs(footerControls) do
            table.insert(main.controls, control)
        end
        
        addon.config.settings.main = main
        
        local returnValue = true
        callHook("AfterConfigureMainSettings", returnValue)
        return returnValue
    end

    function addon.InitializeSettingsPanel()
        callHook("BeforeInitializeSettingsPanel")
        
        addon.ConfigureMainSettings()

        addon.settingsPanels = {}
        addon.mainSettingsPanel = addon.BuildMainSettingsPanel()
        addon.settingsCategory = Settings.RegisterCanvasLayoutCategory(addon.mainSettingsPanel, addonName)
        Settings.RegisterAddOnCategory(addon.settingsCategory)
        addon.settingsPanels["main"] = addon.mainSettingsPanel

        local sortedPanelKeys = {}
        for panelKey in pairs(addon.config.settings) do
            if panelKey ~= "main" then
                table.insert(sortedPanelKeys, panelKey)
            end
        end
        table.sort(sortedPanelKeys)
        
        for _, panelKey in ipairs(sortedPanelKeys) do
            local panelConfig = addon.config.settings[panelKey]
            local childPanel = addon.BuildChildSettingsPanel(panelKey)
            if childPanel then
                local categoryName = addon.L(panelConfig.title or panelKey)
                Settings.RegisterCanvasLayoutSubcategory(addon.settingsCategory, childPanel, categoryName)
                addon.settingsPanels[panelKey] = childPanel
            end
        end
        
        local returnValue = true
        callHook("AfterInitializeSettingsPanel", returnValue)
        return returnValue
    end

    function addon.BuildSettingsPanelHelper(panelKey, config)
        panelKey, config = callHook("BeforeBuildSettingsPanelHelper", panelKey, config)
        
        if not config then
            callHook("AfterBuildSettingsPanelHelper", false)
            return false
        end
        
        local panel = addon.CreateSettingsPanel(panelKey)
        local titleText = panelKey == "main" and (addon.L(config.title) or addon.L(addonName)) or addon.L(config.title)
        panel.Title:SetText(titleText)
        panel.controlRefreshers = {}
        
        local content = panel.ScrollFrame.Content
        local yOffset = addon.config.ui.spacing.panelTop
        
        if config.controls then
            for _, controlConfig in ipairs(config.controls) do
                local control, newYOffset = addon.AddControl(content, yOffset, panelKey, controlConfig)
                if control and control.refresh then
                    table.insert(panel.controlRefreshers, control.refresh)
                end
                yOffset = newYOffset
            end
        end
        
        content:SetHeight(math.abs(yOffset) + addon.config.ui.spacing.panelBottom)
        
        callHook("AfterBuildSettingsPanelHelper", panel)
        return panel
    end

    function addon.BuildMainSettingsPanel()
        callHook("BeforeBuildMainSettingsPanel")
        
        local panel = addon.BuildSettingsPanelHelper("main", addon.config.settings.main)
        
        callHook("AfterBuildMainSettingsPanel", panel)
        return panel
    end

    function addon.BuildChildSettingsPanel(panelKey)
        panelKey = callHook("BeforeBuildChildSettingsPanel", panelKey)
        
        local panel = addon.BuildSettingsPanelHelper(panelKey, addon.config.settings[panelKey])
        
        callHook("AfterBuildChildSettingsPanel", panel)
        return panel
    end

    function addon.CreateSettingsPanel(panelKey)
        panelKey = callHook("BeforeCreateSettingsPanel", panelKey)
        
        local panel = CreateFrame("Frame", addonName .. "_" .. panelKey .. "_Panel")
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
        
        callHook("AfterCreateSettingsPanel", panel)
        return panel
    end

    function addon.AddHeader(parent, yOffset, panelKey, name)
        parent, yOffset, panelKey, name = callHook("BeforeAddHeader", parent, yOffset, panelKey, name)
        
        local header = CreateFrame("Frame", nil, parent)
        header:SetHeight(50)
        header:SetPoint("TOPLEFT", addon.config.ui.spacing.contentLeft, yOffset)
        header:SetPoint("TOPRIGHT", addon.config.ui.spacing.contentRight, yOffset)
        
        header.Title = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        header.Title:SetPoint("BOTTOMLEFT", 7, 4)
        header.Title:SetJustifyH("LEFT")
        header.Title:SetJustifyV("BOTTOM")
        header.Title:SetText(addon.L(name))
        
        local newYOffset = yOffset - addon.config.ui.spacing.headerHeight
        callHook("AfterAddHeader", header, newYOffset)
        return header, newYOffset
    end

    function addon.AddCheckbox(parent, yOffset, panelKey, name, defaultValue, onValueChange, skipRefresh, persistent, onLoad)
        parent, yOffset, panelKey, name, defaultValue, onValueChange, skipRefresh, persistent, onLoad = callHook("BeforeAddCheckbox", parent, yOffset, panelKey, name, defaultValue, onValueChange, skipRefresh, persistent, onLoad)
        
        local getValue, setValue
        
        if persistent ~= true then
            local tempValue = defaultValue
            getValue = function()
                return tempValue
            end
            setValue = function(value)
                tempValue = value
                if onValueChange then onValueChange(value) end
            end
        elseif name == "useCharacterSettings" then
            getValue = function()
                return addon.settingsChar.useCharacterSettings
            end
            setValue = function(value)
                addon.settingsChar.useCharacterSettings = value
                if onValueChange then onValueChange(value) end
            end
            if getValue() == nil then
                addon.settingsChar.useCharacterSettings = defaultValue
            end
        else
            addon.settings[panelKey] = addon.settings[panelKey] or {}
            if addon.settings[panelKey][name] == nil then
                addon.settings[panelKey][name] = defaultValue
            end
            
            getValue = function()
                addon.settings[panelKey] = addon.settings[panelKey] or {}
                return addon.settings[panelKey][name]
            end
            
            setValue = function(value)
                addon.settings[panelKey] = addon.settings[panelKey] or {}
                addon.settings[panelKey][name] = value
                if onValueChange then onValueChange(value) end
            end
        end
        
        local checkbox = CreateFrame("Frame", nil, parent)
        checkbox:SetHeight(32)
        checkbox:SetPoint("TOPLEFT", addon.config.ui.spacing.controlLeft, yOffset)
        checkbox:SetPoint("TOPRIGHT", addon.config.ui.spacing.controlRight, yOffset)
        
        checkbox.Text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        checkbox.Text:SetSize(205, 0)
        checkbox.Text:SetPoint("LEFT", 17, 0)
        checkbox.Text:SetJustifyH("LEFT")
        checkbox.Text:SetWordWrap(false)
        checkbox.Text:SetText(addon.L(name))
        
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
        
        if onLoad then
            onLoad(currentValue)
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
        local tooltipText = addon.L(tooltipKey)
        if tooltipText ~= "[" .. tooltipKey .. "]" then
            checkbox.CheckBox:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(addon.L(name), 1, 1, 1)
                GameTooltip:AddLine(tooltipText, nil, nil, nil, true)
                GameTooltip:Show()
            end)
            checkbox.CheckBox:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
        end
        
        local newYOffset = yOffset - addon.config.ui.spacing.controlHeight
        callHook("AfterAddCheckbox", checkbox, newYOffset)
        return checkbox, newYOffset
    end

    function addon.AddDropdown(parent, yOffset, panelKey, name, defaultValue, options, onValueChange, skipRefresh, persistent, onLoad)
        parent, yOffset, panelKey, name, defaultValue, options, onValueChange, skipRefresh, persistent, onLoad = callHook("BeforeAddDropdown", parent, yOffset, panelKey, name, defaultValue, options, onValueChange, skipRefresh, persistent, onLoad)
        
        local currentValue = defaultValue
        
        if persistent == true then
            addon.settings[panelKey] = addon.settings[panelKey] or {}
            if addon.settings[panelKey][name] == nil then
                addon.settings[panelKey][name] = defaultValue
            end
            currentValue = addon.settings[panelKey][name]
        end
        
        local dropdown = CreateFrame("Frame", nil, parent)
        dropdown:SetHeight(32)
        dropdown:SetPoint("TOPLEFT", addon.config.ui.spacing.controlLeft, yOffset)
        dropdown:SetPoint("TOPRIGHT", addon.config.ui.spacing.controlRight, yOffset)
        
        dropdown.Text = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        dropdown.Text:SetSize(205, 0)
        dropdown.Text:SetPoint("LEFT", 17, 0)
        dropdown.Text:SetJustifyH("LEFT")
        dropdown.Text:SetWordWrap(false)
        dropdown.Text:SetText(addon.L(name))
        
        dropdown.Dropdown = CreateFrame("Frame", nil, dropdown, "UIDropDownMenuTemplate")
        dropdown.Dropdown:SetPoint("LEFT", 200, 3)
        UIDropDownMenu_SetWidth(dropdown.Dropdown, addon.config.ui.dropdown.width)
        UIDropDownMenu_Initialize(dropdown.Dropdown, function(dropdownFrame, level)
            for _, option in ipairs(options) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = addon.L(option.label)
                info.value = option.value
                info.func = function(self)
                    if persistent == true then
                        addon.settings[panelKey][name] = self.value
                    else
                        currentValue = self.value
                    end
                    UIDropDownMenu_SetSelectedValue(dropdown.Dropdown, self.value)
                    if onValueChange then onValueChange(self.value) end
                end
                info.checked = (currentValue == option.value)
                UIDropDownMenu_AddButton(info, level)
            end
        end)
        UIDropDownMenu_SetSelectedValue(dropdown.Dropdown, currentValue or defaultValue)
        
        if onLoad then
            onLoad(currentValue or defaultValue)
        end
        
        if not skipRefresh and persistent == true then
            dropdown.refresh = function()
                addon.settings[panelKey] = addon.settings[panelKey] or {}
                local value = addon.settings[panelKey][name]
                if value == nil then
                    value = defaultValue
                end
                UIDropDownMenu_SetSelectedValue(dropdown.Dropdown, value)
            end
        end
        
        local newYOffset = yOffset - addon.config.ui.spacing.controlHeight
        callHook("AfterAddDropdown", dropdown, newYOffset)
        return dropdown, newYOffset
    end

    function addon.AddSlider(parent, yOffset, panelKey, name, defaultValue, minValue, maxValue, step, onValueChange, skipRefresh, persistent, onLoad)
        parent, yOffset, panelKey, name, defaultValue, minValue, maxValue, step, onValueChange, skipRefresh, persistent, onLoad = callHook("BeforeAddSlider", parent, yOffset, panelKey, name, defaultValue, minValue, maxValue, step, onValueChange, skipRefresh, persistent, onLoad)
        
        local currentValue = defaultValue
        
        if persistent == true then
            addon.settings[panelKey] = addon.settings[panelKey] or {}
            if addon.settings[panelKey][name] == nil then
                addon.settings[panelKey][name] = defaultValue
            end
            currentValue = addon.settings[panelKey][name]
        end
        
        local slider = CreateFrame("Frame", nil, parent)
        slider:SetHeight(32)
        slider:SetPoint("TOPLEFT", addon.config.ui.spacing.controlLeft, yOffset)
        slider:SetPoint("TOPRIGHT", addon.config.ui.spacing.controlRight, yOffset)
        
        slider.Text = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        slider.Text:SetSize(205, 0)
        slider.Text:SetPoint("LEFT", 17, 0)
        slider.Text:SetJustifyH("LEFT")
        slider.Text:SetWordWrap(false)
        slider.Text:SetText(addon.L(name))
        
        slider.Value = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        slider.Value:SetPoint("LEFT", 430, 0)
        slider.Value:SetJustifyH("LEFT")
        
        slider.Slider = CreateFrame("Slider", nil, slider, "MinimalSliderWithSteppersTemplate")
        slider.Slider:SetSize(205, 22)
        slider.Slider:SetPoint("LEFT", 215, 0)
        
        local steps = (maxValue - minValue) / step
        slider.Slider:Init(currentValue or defaultValue, minValue, maxValue, steps)
        slider.Slider:SetWidth(addon.config.ui.slider.width)
        
        local function updateValue(value)
            slider.Value:SetText(string.format("%.0f", value))
        end
        updateValue(currentValue or defaultValue)
        
        if onLoad then
            onLoad(currentValue or defaultValue)
        end
        
        slider.Slider:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, value)
            if persistent == true then
                addon.settings[panelKey][name] = value
            else
                currentValue = value
            end
            updateValue(value)
            if onValueChange then onValueChange(value) end
        end)
        
        if not skipRefresh and persistent == true then
            slider.refresh = function()
                addon.settings[panelKey] = addon.settings[panelKey] or {}
                local value = addon.settings[panelKey][name]
                if value == nil then
                    value = defaultValue
                end
                slider.Slider:SetValue(value)
                updateValue(value)
            end
        end
        
        local tooltipKey = name .. "Tooltip"
        local tooltipText = addon.L(tooltipKey)
        if tooltipText ~= "[" .. tooltipKey .. "]" then
            slider.Slider:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(addon.L(name), 1, 1, 1)
                GameTooltip:AddLine(tooltipText, nil, nil, nil, true)
                GameTooltip:Show()
            end)
            slider.Slider:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
        end
        
        local newYOffset = yOffset - addon.config.ui.spacing.controlHeight
        callHook("AfterAddSlider", slider, newYOffset)
        return slider, newYOffset
    end

    function addon.AddButton(parent, yOffset, panelKey, name, onClick)
        parent, yOffset, panelKey, name, onClick = callHook("BeforeAddButton", parent, yOffset, panelKey, name, onClick)
        
        local button = CreateFrame("Frame", nil, parent)
        button:SetHeight(40)
        button:SetPoint("TOPLEFT", addon.config.ui.spacing.contentLeft, yOffset)
        button:SetPoint("TOPRIGHT", addon.config.ui.spacing.contentRight, yOffset)
        
        button.Button = CreateFrame("Button", nil, button, "UIPanelButtonTemplate")
        button.Button:SetSize(120, 22)
        button.Button:SetPoint("LEFT", 35, 0)
        button.Button:SetText(addon.L(name))
        
        button.Button:SetScript("OnClick", function(self)
            if onClick then
                onClick()
            end
        end)
        
        local tooltipKey = name .. "Tooltip"
        local tooltipText = addon.L(tooltipKey)
        if tooltipText ~= "[" .. tooltipKey .. "]" then
            button.Button:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(addon.L(name), 1, 1, 1)
                GameTooltip:AddLine(tooltipText, nil, nil, nil, true)
                GameTooltip:Show()
            end)
            button.Button:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
        end
        
        local newYOffset = yOffset - addon.config.ui.spacing.buttonHeight
        callHook("AfterAddButton", button, newYOffset)
        return button, newYOffset
    end

    function addon.AddDescription(parent, yOffset, panelKey, name, onClick)
        parent, yOffset, panelKey, name, onClick = callHook("BeforeAddDescription", parent, yOffset, panelKey, name, onClick)
        
        local frame = CreateFrame("Frame", nil, parent)
        frame:SetPoint("TOPLEFT", addon.config.ui.spacing.controlLeft, yOffset)
        frame:SetPoint("TOPRIGHT", addon.config.ui.spacing.controlRight, yOffset)
        frame:SetHeight(32)
        
        local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fontString:SetPoint("LEFT", addon.config.ui.spacing.textInset, 0)
        fontString:SetPoint("RIGHT", -addon.config.ui.spacing.textInset, 0)
        fontString:SetJustifyH("LEFT")
        fontString:SetJustifyV("TOP")
        fontString:SetWordWrap(true)
        fontString:SetText(addon.L(name))
        
        local stringHeight = fontString:GetStringHeight()
        frame:SetHeight(math.max(32, stringHeight))
        
        if onClick then
            frame:EnableMouse(true)
            frame:SetScript("OnMouseDown", function(self)
                onClick()
            end)
            frame:SetScript("OnEnter", function(self)
                fontString:SetTextColor(1, 0.82, 0, 1)
            end)
            frame:SetScript("OnLeave", function(self)
                fontString:SetTextColor(1.0, 0.82, 0, 1)
            end)
        end
        
        local newYOffset = yOffset - math.max(32, stringHeight) - addon.config.ui.spacing.descriptionPadding
        callHook("AfterAddDescription", frame, newYOffset)
        return frame, newYOffset
    end

    function addon.AddInputBox(parent, yOffset, panelKey, name, default, highlightText, buttonText, onClick, onValueChange, persistent, onLoad)
        parent, yOffset, panelKey, name, default, highlightText, buttonText, onClick, onValueChange, persistent, onLoad = callHook("BeforeAddInputBox", parent, yOffset, panelKey, name, default, highlightText, buttonText, onClick, onValueChange, persistent, onLoad)
        
        local control = CreateFrame("Frame", nil, parent)
        control:SetHeight(32)
        control:SetPoint("TOPLEFT", addon.config.ui.spacing.controlLeft, yOffset)
        control:SetPoint("TOPRIGHT", addon.config.ui.spacing.controlRight, yOffset)
        
        control.Text = control:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        control.Text:SetSize(205, 0)
        control.Text:SetPoint("LEFT", 17, 0)
        control.Text:SetJustifyH("LEFT")
        control.Text:SetWordWrap(false)
        control.Text:SetText(addon.L(name))
        
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
            addon.settings[panelKey] = addon.settings[panelKey] or {}
            if addon.settings[panelKey][name] == nil then
                addon.settings[panelKey][name] = default
            end
            
            control.EditBox:SetScript("OnTextChanged", function(self, userInput)
                if userInput then
                    local newValue = self:GetText()
                    addon.settings[panelKey][name] = newValue
                    if onValueChange then
                        onValueChange(newValue)
                    end
                end
            end)
        else
            control.EditBox:SetScript("OnTextChanged", function(self, userInput)
                if userInput then
                    local newValue = self:GetText()
                    if onValueChange then
                        onValueChange(newValue)
                    end
                end
            end)
        end
        
        if buttonText then
            control.Button:SetText(buttonText)
            
            if onClick then
                control.Button:SetScript("OnClick", function(self)
                    local inputText = control.EditBox:GetText()
                    onClick(inputText, control.EditBox)
                end)
            end
            
            local tooltipKey = name .. "Tooltip"
            local tooltipText = addon.L(tooltipKey)
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
                local savedValue = addon.settings[panelKey][name]
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
            local initialValue = addon.settings[panelKey][name] or default
            if initialValue then
                control.EditBox:SetText(initialValue)
                control.EditBox:SetCursorPosition(0)
            end
            
            if onLoad then
                onLoad(initialValue)
            end
            
            control.refresh = function()
                local value = addon.settings[panelKey][name] or default
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
        
        local newYOffset = yOffset - addon.config.ui.spacing.controlHeight
        callHook("AfterAddInputBox", control, newYOffset)
        return control, newYOffset
    end

    function addon.ShowDialog(dialogOptions)
        dialogOptions = callHook("BeforeShowDialog", dialogOptions)
        
        addon.debug("ShowDialog called")
        local dialog = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        
        local uiCfg = addon.config.ui
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
        title:SetText(addon.L(dialogOptions.title))
        
        local content = CreateFrame("Frame", nil, dialog)
        content:SetPoint("TOPLEFT", uiCfg.spacing.contentLeft, uiCfg.dialog.contentTop)
        content:SetPoint("BOTTOMRIGHT", uiCfg.spacing.contentRight, uiCfg.dialog.contentBottom)
        
        local yOffset = uiCfg.dialog.initialYOffset
        local inputBoxControls = {}
        if dialogOptions.controls then
            for _, controlConfig in ipairs(dialogOptions.controls) do
                local control, newYOffset = addon.AddControl(content, yOffset, "dialog", controlConfig)
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
        closeButton:SetText(addon.L("close"))
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
        
        callHook("AfterShowDialog", dialog)
        return dialog
    end

    function addon.AddControl(parent, yOffset, panelKey, controlConfig)
        parent, yOffset, panelKey, controlConfig = callHook("BeforeAddControl", parent, yOffset, panelKey, controlConfig)
        
        local controlType = controlConfig.type
        
        if controlType == "header" then
            local control, newYOffset = addon.AddHeader(parent, yOffset, panelKey, controlConfig.name)
            callHook("AfterAddControl", control, newYOffset)
            return control, newYOffset
            
        elseif controlType == "checkbox" then
            local control, newYOffset = addon.AddCheckbox(
                parent, 
                yOffset, 
                panelKey, 
                controlConfig.name,
                controlConfig.default, 
                controlConfig.onValueChange,
                controlConfig.skipRefresh,
                controlConfig.persistent,
                controlConfig.onLoad
            )
            callHook("AfterAddControl", control, newYOffset)
            return control, newYOffset
            
        elseif controlType == "dropdown" then
            local control, newYOffset = addon.AddDropdown(
                parent, 
                yOffset, 
                panelKey, 
                controlConfig.name,
                controlConfig.default, 
                controlConfig.options,
                controlConfig.onValueChange,
                controlConfig.skipRefresh,
                controlConfig.persistent,
                controlConfig.onLoad
            )
            callHook("AfterAddControl", control, newYOffset)
            return control, newYOffset
            
        elseif controlType == "slider" then
            local control, newYOffset = addon.AddSlider(
                parent, 
                yOffset, 
                panelKey, 
                controlConfig.name,
                controlConfig.default, 
                controlConfig.min, 
                controlConfig.max, 
                controlConfig.step,
                controlConfig.onValueChange,
                controlConfig.skipRefresh,
                controlConfig.persistent,
                controlConfig.onLoad
            )
            callHook("AfterAddControl", control, newYOffset)
            return control, newYOffset
            
        elseif controlType == "button" then
            local control, newYOffset = addon.AddButton(
                parent, 
                yOffset, 
                panelKey, 
                controlConfig.name,
                controlConfig.onClick
            )
            callHook("AfterAddControl", control, newYOffset)
            return control, newYOffset
            
        elseif controlType == "description" then
            local control, newYOffset = addon.AddDescription(
                parent, 
                yOffset, 
                panelKey, 
                controlConfig.name,
                controlConfig.onClick
            )
            callHook("AfterAddControl", control, newYOffset)
            return control, newYOffset
            
        elseif controlType == "inputBox" then
            local buttonText = controlConfig.buttonText and addon.L(controlConfig.buttonText) or nil
            local control, newYOffset = addon.AddInputBox(
                parent, 
                yOffset, 
                panelKey, 
                controlConfig.name,
                controlConfig.default,
                controlConfig.highlightText,
                buttonText,
                controlConfig.onClick,
                controlConfig.onValueChange,
                controlConfig.persistent,
                controlConfig.onLoad
            )
            callHook("AfterAddControl", control, newYOffset)
            return control, newYOffset
            
        else
            addon.debug("Unknown control type: " .. tostring(controlType))
            callHook("AfterAddControl", false, yOffset)
            return false, yOffset
        end
    end
end


do  -- Utility Functions

    function addon.OpenSettings()
        callHook("BeforeOpenSettings")
        
        if type(Settings) == "table" and type(Settings.OpenToCategory) == "function" then
            Settings.OpenToCategory(addon.settingsCategory)
            if addon.settingsCategory and addon.settingsCategory.ID then
                Settings.OpenToCategory(addon.settingsCategory.ID)
            end
        end
        
        local returnValue = true
        callHook("AfterOpenSettings", returnValue)
        return returnValue
    end

    function addon.L(key)
        key = callHook("BeforeL", key)
        
        if not key then 
            callHook("AfterL", "")
            return ""
        end
        if key == "author" then 
            callHook("AfterL", addon.author)
            return addon.author
        end
        if not addon.localization then 
            local returnValue = "[" .. key .. "]"
            callHook("AfterL", returnValue)
            return returnValue
        end
        local result = addon.localization[key] or ("[" .. key .. "]")
        callHook("AfterL", result)
        return result
    end

    function addon.info(text)
        text = callHook("BeforeInfo", text)
        
        print("\124cffDB09FE" .. addonName .. ": " .. "\124cffBAFF1A" .. tostring(text))
        
        local returnValue = true
        callHook("AfterInfo", returnValue)
        return returnValue
    end

    function addon.error(text)
        text = callHook("BeforeError", text)
        
        print("\124cffDB09FE" .. addonName .. ": " .. "\124cffBAFF1A" .. tostring(text))
        
        local returnValue = true
        callHook("AfterError", returnValue)
        return returnValue
    end

    function addon.debug(text)
        text = callHook("BeforeDebug", text)
        
        if addon.settings and addon.settings.main and addon.settings.main.enableDebugging then
            print("\124cffDB09FE" .. addonName .. " Debug: " .. "\124cffBAFF1A" .. tostring(text))
        end
        
        local returnValue = true
        callHook("AfterDebug", returnValue)
        return returnValue
    end

    function addon.RefreshSettingsPanels()
        callHook("BeforeRefreshSettingsPanels")
        
        if addon.settingsPanels then
            for panelKey, panel in pairs(addon.settingsPanels) do
                if panel and panel.controlRefreshers then
                    for _, refreshFunc in ipairs(panel.controlRefreshers) do
                        refreshFunc()
                    end
                end
            end
        end
        
        local returnValue = true
        callHook("AfterRefreshSettingsPanels", returnValue)
        return returnValue
    end

    function addon.UpdateActiveSettings(useCharacter)
        useCharacter = callHook("BeforeUpdateActiveSettings", useCharacter)
        addon.settings = useCharacter and addon.settingsChar or addon.settingsGlobal
        local profileType = useCharacter and "Character" or "Global"
        addon.debug("Profile switched to: " .. profileType)
        addon.RefreshSettingsPanels()
        
        local returnValue = true
        callHook("AfterUpdateActiveSettings", returnValue)
        return returnValue
    end

    function addon.ExportSettings()
        callHook("BeforeExportSettings")
        
        local exportData = {
            addon = addonName,
            version = tostring(addon.config.version),
            sadCoreVersion = tostring(addon.sadCore.version),
            settings = addon.settings
        }

        local LibSerialize = addon.LibSerialize
        local LibCompress = addon.LibCompress
        local success, serialized = pcall(function() return LibSerialize:Serialize(exportData) end)
        if not success or not serialized then
            addon.debug("Serialize failed.")
            callHook("AfterExportSettings", false)
            return false
        end
        local encoded = LibCompress:Encode(serialized)
        if not encoded then
            addon.debug("Encode failed.")
            callHook("AfterExportSettings", false)
            return false
        end
        
        addon.debug(encoded)
        
        addon.ShowDialog({
            title = "shareSettingsTitle",
            controls = {
                {
                    type = "inputBox",
                    name = "shareSettingsLabel",
                    default = encoded,
                    highlightText = true
                }
            }
        })
        
        callHook("AfterExportSettings", encoded)
        return encoded
    end

    function addon.ImportSettings(serializedString)
        serializedString = callHook("BeforeImportSettings", serializedString)
        
        if not serializedString or serializedString == "" then
            callHook("AfterImportSettings", false)
            return false
        end
        
        local LibSerialize = addon.LibSerialize
        local LibCompress = addon.LibCompress
        
        addon.debug("Decoding import string...")
        local decoded = LibCompress:Decode(serializedString)
        if not decoded then
            addon.error(addon.L("importDecodeFailed"))
            callHook("AfterImportSettings", false)
            return false
        end
        addon.debug("Decode successful. Deserializing...")
        
        local success, data = LibSerialize:Deserialize(decoded)
        if not success then
            addon.error(addon.L("importDeserializeFailed") .. ": " .. tostring(data))
            callHook("AfterImportSettings", false)
            return false
        end
        
        addon.debug("Deserialized data type: " .. type(data))
        if type(data) == "table" then
            addon.debug("Deserialized table contents:")
            for key, value in pairs(data) do
                addon.debug("  " .. tostring(key) .. " = " .. tostring(value))
            end
        else
            addon.debug("Deserialized data: " .. tostring(data))
        end
        
        if not data or type(data) ~= "table" then
            addon.error(addon.L("importInvalidData"))
            callHook("AfterImportSettings", false)
            return false
        end
        
        if data.addon ~= addonName then
            addon.error(addon.L("importWrongAddon") .. ": " .. tostring(data.addon))
            callHook("AfterImportSettings", false)
            return false
        end
        
        if tostring(data.version) ~= tostring(addon.config.version) then
            addon.error(addon.L("importVersionMismatch") .. " " .. addon.L("imported") .. ": " .. tostring(data.version) .. ", " .. addon.L("current") .. ": " .. tostring(addon.config.version))
            callHook("AfterImportSettings", false)
            return false
        end
        
        if tostring(data.sadCoreVersion) ~= tostring(addon.sadCore.version) then
            addon.error("SAdCore version mismatch. " .. addon.L("imported") .. ": " .. tostring(data.sadCoreVersion) .. ", " .. addon.L("current") .. ": " .. tostring(addon.sadCore.version))
            callHook("AfterImportSettings", false)
            return false
        end

        local importedSettings = data.settings
        
        for key in pairs(addon.settings) do
            addon.settings[key] = nil
        end
        
        for key, value in pairs(importedSettings) do
            addon.settings[key] = value
        end
        
        addon.info(addon.L("importSuccess"))
        addon.RefreshSettingsPanels()
        
        callHook("AfterImportSettings", true)        
        return true
    end

end


-- Entry Point: Register ADDON_LOADED
addon.RegisterEvent("ADDON_LOADED", function(event, loadedAddon)
    if loadedAddon == addonName then
        addon.initialize()
        addon.eventFrame:UnregisterEvent("ADDON_LOADED")
    end
end)

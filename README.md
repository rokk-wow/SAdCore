# SAd - Simple Addons

Simple Addons are about consistency. They do one thing, and they do it well.

SAdCore is a framework for rapidly building simple addons with consistent options and controls. Define your checkboxes, dropdowns, sliders, and buttons, and the settings UI is automatically generated with values persisted to SavedVariables. Built-in features include settings import/export and the ability to switch between global and character-specific profiles.

## The SAd Creed

- **Easy.** If a configuration setting is more complicated than a checkbox, it's probably wrong
- **Simple.** If a user doesn't understand your configuration without additional instructions, it's probably wrong
- **Intuitive.** If a user can't remember where they saw a particular configuration setting, it's probably wrong
- **Relevant.** If a configuration setting doesn't directly relate to the name of the addon, it's probably wrong
- **Respectful.** If a users game setting is changed just by installing the addon, it's probably wrong
- **Clear.** Checkboxes should enable, not disable ("Show Map", not "Hide Map")
- **Robust.** All code exists inside addon functions. The only global code is registering the ADDON_LOADED event

## Getting Started

To create a new addon using SAdCore as your framework:

1. **Rename the folder** from `SAdCore` to your addon name (e.g., `MyAddon`)

2. **Rename the SAdCore.toc file** to match your addon name (e.g., `MyAddon.toc`)

3. **Update your TOC file** and set three key values:
   ```
   ## AddonCompartmentFunc: MyAddon_Compartment_Func
   ## SavedVariables: MyAddon_Settings_Global
   ## SavedVariablesPerCharacter: MyAddon_Settings_Char
   ```

4. **Update SAdConfig.lua** with the same three values:
   ```lua
   addon.config.toc = {
       AddonCompartmentFunc = "MyAddon_Compartment_Func",
       SavedVariables = "MyAddon_Settings_Global",
       SavedVariablesPerCharacter = "MyAddon_Settings_Char"
   }
   ```

5. **Update Addon.lua - Configure your settings panels** by adding controls to `addon.config.settings`:
   ```lua
   addon.config.settings.main = {
       title = "My Addon Settings",
       controls = {
           -- Add your controls here
       }
   }
   ```

6. **Add localization strings** to `Localization.lua` for all text that appears in your UI

## Control Properties

### Common Properties

All controls support these common properties:

- **`type`** (required) - The control type: `"header"`, `"description"`, `"checkbox"`, `"dropdown"`, `"slider"`, `"inputBox"`, or `"button"`
- **`name`** (required) - Localization key used for both display text and variable storage. If the key is not found in localization, it displays as `[keyName]` to alert the developer
- **`tooltip`** (optional) - Localization key for tooltip text shown on hover
- **`persistent`** (optional) - When `true`, the control's value is saved to SavedVariables (either global or per-character). When absent or `false`, the control is session-only and not persisted. Applies to: `checkbox`, `dropdown`, `slider`, `inputBox`

### Control-Specific Properties

**Dropdown:**
- **`options`** (required) - Array of option objects, each with:
  - `value` - The internal value stored when selected
  - `label` - Localization key for the displayed text

**Note:** All user-facing text (control names, tooltips, dropdown labels, button text) must use localization keys. The framework passes these through `addon.L()` to display the localized text.

### Persistent vs Session-Only Controls

By default, controls are session-only and their values are **not** saved to SavedVariables. To persist a control's value, you must explicitly set `persistent = true`.

**Use cases for session-only controls (no persistent flag):**
- Import/export string input fields
- Temporary configuration wizards
- Preview/test settings that shouldn't be saved
- UI elements that trigger actions but don't store state

**Use cases for persistent controls (persistent = true):**
- User preferences that should be remembered
- Configuration settings that affect addon behavior
- Options that should survive /reload or logout

**Example (session-only):**
```lua
{
    type = "inputBox",
    name = "loadSettings",
    buttonText = "loadSettingsButton",
    tooltip = "loadSettingsTooltip",
    -- No persistent flag = session-only, value won't be saved
    onClick = function(inputText, editBox)
        addon.ImportSettings(inputText)
        editBox:SetText("")  -- Clear after import
    end
}
```

**Example (persistent):**
```lua
{
    type = "checkbox",
    name = "enableNotifications",
    tooltip = "enableNotificationsTooltip",
    default = true,
    persistent = true  -- Explicitly persist this setting
}
```

## Example Controls

```lua
addon.config.settings.example = {
    title = "exampleTitle",
    controls = {
        -- Header
        {
            type = "header",
            name = "exampleHeader"
        },
        
        -- Description
        {
            type = "description",
            name = "exampleDescription",
            color = "#CCCCCC"
        },
        
        -- Checkbox (persisted to database)
        {
            type = "checkbox",
            name = "exampleCheckbox",
            tooltip = "exampleCheckboxTooltip",
            default = true,
            persistent = true
        },
        -- Checkbox (session-only - not saved)
        {
            type = "checkbox",
            name = "tempCheckbox",
            tooltip = "tempCheckboxTooltip",
            default = false
        },
        
        -- Dropdown (persisted to database)
        {
            type = "dropdown",
            name = "exampleDropdown",
            tooltip = "exampleDropdownTooltip",
            default = "option2",
            persistent = true,
            options = {
                {value = "option1", label = "dropdownOption1"},
                {value = "option2", label = "dropdownOption2"},
                {value = "option3", label = "dropdownOption3"}
            }
        },
        
        -- Slider (persisted to database)
        {
            type = "slider",
            name = "exampleSlider",
            tooltip = "exampleSliderTooltip",
            default = 50,
            min = 0,
            max = 100,
            step = 5,
            persistent = true
        },
        
        -- Input Box (session-only)
        {
            type = "inputBox",
            name = "exampleInput",
            tooltip = "exampleInputTooltip",
            default = "Enter text here",
            buttonText = "applyButton",
            onClick = function(inputText, editBox)
                addon.info("Input value: " .. inputText)
            end
        },
        
        -- Button
        {
            type = "button",
            name = "exampleButton",
            tooltip = "exampleButtonTooltip",
            onClick = function()
                addon.info("Example button clicked!")
            end
        }
    }
}
```

## Accessing Saved Settings

Settings are saved to `addon.settings` organized by panel key. Access control values using `addon.settings.panelKey.controlName`.

**Example:**
```lua
function addon.PrintDebuggingStatus()
    if addon.settings.main.enableDebugging then
        addon.info("Debugging is currently ENABLED")
    else
        addon.info("Debugging is currently DISABLED")
    end
end
```

## Logging Functions

- **`addon.debug(text)`** - Only displays when "Enable Debugging" is enabled in settings
- **`addon.info(text)`** - Always displays (informational messages)
- **`addon.error(text)`** - Always displays (error messages)

## Hooks

SAdCore provides Before and After hooks for every function, allowing you to extend functionality without modifying core code.

**Before Hooks** receive the function's input parameters and MUST return them (potentially modified). This allows you to intercept and transform parameters before the function executes.

**After Hooks** receive the function's return value(s) for observation. They do not need to return anything.

### Initialization Hooks
- `BeforeInitialize()` → must return nothing / `AfterInitialize(returnValue)`
- `BeforeLoadConfig()` → must return nothing / `AfterLoadConfig()`
- `BeforeInitializeCompartmentFunc(compartmentFunc)` → must return compartmentFunc / `AfterInitializeCompartmentFunc(returnValue)`
- `BeforeInitializeSavedVariables(savedVars, savedVarsPerChar)` → must return savedVars, savedVarsPerChar / `AfterInitializeSavedVariables(returnValue)`

### Registration Hooks
- `BeforeRegisterEvent(eventName, callback)` → must return eventName, callback / `AfterRegisterEvent(returnValue)`
- `BeforeRegisterSlashCommand(command, callback)` → must return command, callback / `AfterRegisterSlashCommand(returnValue)`
- `BeforeCreateSlashCommand()` → must return nothing / `AfterCreateSlashCommand(returnValue)`

### Settings Panel Hooks
- `BeforeConfigureMainSettings()` → must return nothing / `AfterConfigureMainSettings(returnValue)`
- `BeforeInitializeSettingsPanel()` → must return nothing / `AfterInitializeSettingsPanel(returnValue)`
- `BeforeBuildMainSettingsPanel()` → must return nothing / `AfterBuildMainSettingsPanel(panel)`
- `BeforeBuildChildSettingsPanel(panelKey)` → must return panelKey / `AfterBuildChildSettingsPanel(panel)`
- `BeforeCreateSettingsPanel(panelKey)` → must return panelKey / `AfterCreateSettingsPanel(panel)`
- `BeforeRefreshSettingsPanels()` → must return nothing / `AfterRefreshSettingsPanels(returnValue)`

### UI Control Hooks
- `BeforeAddHeader(parent, yOffset, panelKey, name)` → must return parent, yOffset, panelKey, name / `AfterAddHeader(header, newYOffset)`
- `BeforeAddCheckbox(parent, yOffset, panelKey, name, tooltip, defaultValue, onValueChange, skipRefresh, persistent)` → must return all 9 params / `AfterAddCheckbox(checkbox, newYOffset)`
- `BeforeAddDropdown(parent, yOffset, panelKey, name, tooltip, defaultValue, options, onValueChange, skipRefresh, persistent)` → must return all 10 params / `AfterAddDropdown(dropdown, newYOffset)`
- `BeforeAddSlider(parent, yOffset, panelKey, name, tooltip, defaultValue, minValue, maxValue, step, onValueChange, skipRefresh, persistent)` → must return all 12 params / `AfterAddSlider(slider, newYOffset)`
- `BeforeAddButton(parent, yOffset, panelKey, name, tooltip, onClick)` → must return parent, yOffset, panelKey, name, tooltip, onClick / `AfterAddButton(button, newYOffset)`
- `BeforeAddDescription(parent, yOffset, panelKey, name, onClick, color)` → must return parent, yOffset, panelKey, name, onClick, color / `AfterAddDescription(frame, newYOffset)`
- `BeforeAddInputBox(parent, yOffset, panelKey, name, default, tooltip, highlightText, buttonText, onClick, persistent)` → must return all 10 params / `AfterAddInputBox(control, newYOffset)`
- `BeforeShowDialog(dialogOptions)` → must return dialogOptions / `AfterShowDialog(dialog)`
- `BeforeAddControl(parent, yOffset, panelKey, controlConfig)` → must return parent, yOffset, panelKey, controlConfig / `AfterAddControl(control, newYOffset)`

### Utility Function Hooks
- `BeforeHexToRGB(hex)` → must return hex / `AfterHexToRGB(red, green, blue)`
- `BeforeOpenSettings()` → must return nothing / `AfterOpenSettings(returnValue)`
- `BeforeL(key)` → must return key / `AfterL(result)`
- `BeforeInfo(text)` → must return text / `AfterInfo(returnValue)`
- `BeforeError(text)` → must return text / `AfterError(returnValue)`
- `BeforeDebug(text)` → must return text / `AfterDebug(returnValue)`
- `BeforePrintParams(...)` → must return varargs / `AfterPrintParams(returnValue)`
- `BeforeDecodeExportString(exportString)` → must return exportString / `AfterDecodeExportString(data)`
- `BeforeCountTableEntries(tbl)` → must return tbl / `AfterCountTableEntries(count)`
- `BeforeSerializableCopy(original, exclusions)` → must return original, exclusions / `AfterSerializableCopy(copy)`
- `BeforeDeepMerge(target, source, exclusions)` → must return target, source, exclusions / `AfterDeepMerge(target)`
- `BeforeUpdateActiveSettings(useCharacter)` → must return useCharacter / `AfterUpdateActiveSettings(returnValue)`
- `BeforeRefreshSettingsPanels()` → must return nothing / `AfterRefreshSettingsPanels(returnValue)`

### Import/Export Hooks
- `BeforeExportSettings()` → must return nothing / `AfterExportSettings(encoded)`
- `BeforeImportSettings(serializedString)` → must return serializedString / `AfterImportSettings(success)`

### Hook Usage Examples

**Before Hook - Modifying Parameters:**
```lua
-- Make all localization keys uppercase
function addon.BeforeL(key)
    return key:upper()  -- Return the modified parameter
end
```

**Before Hook - Pass-through (no modification):**
```lua
-- Log but don't modify
function addon.BeforeInfo(text)
    -- Do something with the text
    return text  -- Must still return it unchanged
end
```

**After Hook - Observation Only:**
```lua
-- Log when initialization completes
function addon.AfterInitialize(success)
    if success then
        addon.info("Addon initialized successfully!")
    end
    -- After hooks don't need to return anything
end

-- Customize all checkboxes after creation
function addon.AfterAddCheckbox(checkbox, newYOffset)
    checkbox:SetAlpha(0.9)
end
```

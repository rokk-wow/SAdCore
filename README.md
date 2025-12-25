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

3. **Update your TOC file** and change MyAddon to the unique name of your addon:
   ```
   ## Title: MyAddon
   ## AddonCompartmentFunc: MyAddon_Compartment_Func
   ## SavedVariables: MyAddon_Settings_Global
   ## SavedVariablesPerCharacter: MyAddon_Settings_Char
   ```

4. **Update Addon.lua** update these values to match the TOC:
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

## Slash Commands

SAdCore automatically creates a slash command for your addon based on your addon name. For example, if your addon is named `MyAddon`, the slash command will be `/myaddon`.

### Default Behavior

When you type the slash command with no arguments (e.g., `/myaddon`), it opens your addon's settings panel.

### Registering Custom Slash Commands

Register custom slash commands using `addon.RegisterSlashCommand(command, callback)`:

**Parameters:**
- **`command`** - The subcommand name (case-insensitive)
- **`callback`** - Function to execute when the command is used

**Example:**
```lua
function addon.RegisterFunctions()
    -- Register /myaddon hello
    addon.RegisterSlashCommand("hello", function()
        addon.info("Hello, World!")
    end)
    
    -- Register /myaddon reset
    addon.RegisterSlashCommand("reset", function()
        addon.info("Resetting settings...")
        -- Your reset logic here
    end)
    
    -- Command with parameters
    addon.RegisterSlashCommand("debug", function(enabled)
        if enabled == "on" then
            addon.settings.main.enableDebugging = true
            addon.info("Debugging enabled")
        elseif enabled == "off" then
            addon.settings.main.enableDebugging = false
            addon.info("Debugging disabled")
        else
            addon.info("Usage: /myaddon debug on|off")
        end
    end)
end
```

### Using Slash Commands In-Game

**Basic usage:**
```
/myaddon                    -- Opens settings panel
/myaddon hello              -- Runs the "hello" command
/myaddon debug on           -- Runs "debug" with parameter "on"
```

**Built-in commands:**
- `/myaddon import` - Opens import dialog for settings
- `/myaddon decode <string>` - Decodes an export string (for debugging)

### Multiple Parameters

When users type multiple parameters, they are split by spaces and passed to your callback function:

```lua
addon.RegisterSlashCommand("teleport", function(zone, x, y)
    addon.info(string.format("Teleporting to %s at (%s, %s)", zone or "?", x or "?", y or "?"))
end)

-- Usage: /myaddon teleport Orgrimmar 50 75
```

## Event Registration

SAdCore provides a simple event registration system that handles frame creation and callback management automatically.

### Registering Events

Register game events using `addon.RegisterEvent(eventName, callback)`:

**Parameters:**
- **`eventName`** - The WoW event name (e.g., "PLAYER_ENTERING_WORLD", "COMBAT_LOG_EVENT_UNFILTERED")
- **`callback`** - Function to execute when the event fires. Receives `(event, ...)` where `...` are event-specific parameters

**Example:**
```lua
function addon.RegisterFunctions()
    -- Register a simple event
    addon.RegisterEvent("PLAYER_ENTERING_WORLD", function(event)
        addon.info("Player has entered the world!")
    end)
    
    -- Register event with parameters
    addon.RegisterEvent("PLAYER_REGEN_DISABLED", function(event)
        addon.info("Entering combat!")
    end)
    
    addon.RegisterEvent("PLAYER_REGEN_ENABLED", function(event)
        addon.info("Leaving combat!")
    end)
    
    -- Event with additional parameters
    addon.RegisterEvent("UNIT_HEALTH", function(event, unitID)
        if unitID == "player" then
            local health = UnitHealth("player")
            local maxHealth = UnitHealthMax("player")
            addon.debug(string.format("Health: %d/%d", health, maxHealth))
        end
    end)
    
    -- Chat message event
    addon.RegisterEvent("CHAT_MSG_SYSTEM", function(event, message)
        addon.debug("System message: " .. message)
    end)
end
```

### Event Frame Management

SAdCore automatically creates and manages an event frame for you:
- The first call to `addon.RegisterEvent()` creates the frame
- All subsequent events are registered on the same frame
- Each event has its own callback function
- No need to manually create frames or manage OnEvent scripts

### Unregistering Events

To unregister an event, access the event frame directly:

```lua
addon.eventFrame:UnregisterEvent("UNIT_HEALTH")
```

### Common WoW Events

Here are some frequently used events:

- **`ADDON_LOADED`** - Fires when an addon loads (already used by SAdCore for initialization)
- **`PLAYER_ENTERING_WORLD`** - Player enters world or reloads UI
- **`PLAYER_LOGIN`** - Player logs in (fires once per session)
- **`PLAYER_REGEN_DISABLED`** - Player enters combat
- **`PLAYER_REGEN_ENABLED`** - Player leaves combat
- **`UNIT_HEALTH`** - Unit's health changes
- **`CHAT_MSG_*`** - Various chat events (SYSTEM, SAY, WHISPER, etc.)
- **`COMBAT_LOG_EVENT_UNFILTERED`** - Combat log events

For a complete list of events, see the [WoW API documentation](https://wowpedia.fandom.com/wiki/Events).

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

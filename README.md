# SAd - Simple Addons

Simple Addons are about consistency. They do one thing, and they do it well.

SAdCore is a framework for rapidly building simple addons with consistent options and controls. Define your checkboxes, dropdowns, sliders, and buttons, and the settings UI is automatically generated with values persisted to SavedVariables. Built-in features include settings import/export and the ability to switch between global and character-specific profiles.

## The SAd Creed

- **Easy.** If a configuration setting is more complicated than a checkbox, it's probably wrong
- **Simple.** If a user doesn't understand your configuration without additional instructions, it's probably wrong
- **Intuitive.** If a user can't remember where they saw a particular configuration setting, it's probably wrong
- **Relevant.** If a configuration setting doesn't directly relate to the name of the addon, it's probably wrong
- **Respectful.** If a users game setting is changed just by installing the addon, it's probably wrong
- **Affirmative.** Logic should always enable, not disable ("Show Map", not "Hide Map")
- **Robust.** All code exists inside addon functions. The only global code is registering the ADDON_LOADED event

## Getting Started

1. Rename the folder and `.toc` file to your addon name
2. Update the TOC file with your addon name in Title, AddonCompartmentFunc, SavedVariables, and SavedVariablesPerCharacter
3. Update the same values in `Addon.lua` under `addon.config.toc`
4. Add your controls to `addon.config.settings.main` in `Addon.lua`
5. Add localization strings to `Localization.lua`

## Localization

All user-facing text uses localization keys. If you see `[keyName]` in your UI, add that key to `Localization.lua`:

```lua
addon.locale.enEN = {
    keyName = "Your Text Here"
}
```

The framework automatically replaces keys with localized text.

## Control Properties

### Common Properties

All controls support these common properties:

- **`type`** (required) - The control type: `"header"`, `"description"`, `"checkbox"`, `"dropdown"`, `"slider"`, `"inputBox"`, or `"button"`
- **`name`** (required) - Localization key used for both display text and variable storage. If the key is not found in localization, it displays as `[keyName]` to alert the developer
- **`persistent`** (optional) - When `true`, the control's value is saved to SavedVariables (either global or per-character). When absent or `false`, the control is session-only and not persisted. Applies to: `checkbox`, `dropdown`, `slider`, `inputBox`
- **`onValueChange`** (optional) - Callback function that fires immediately when the user changes the control's value. Receives the new value as a parameter. Perfect for applying settings in real-time without requiring a UI reload. Applies to: `checkbox`, `dropdown`, `slider`, `inputBox`
- **`onLoad`** (optional) - Callback function that fires when the game starts or the addon loads. Receives the saved value as a parameter. Applies to: `checkbox`, `dropdown`, `slider`, `inputBox`

### Automatic Tooltips

To add a tooltip, define a localization key with the control's name + `"Tooltip"` (e.g., `"exampleCheckboxTooltip"` for `name = "exampleCheckbox"`).

### Control-Specific Properties

**Dropdown:**
- **`options`** (required) - Array of option objects, each with:
  - `value` - The internal value stored when selected
  - `label` - Localization key for the displayed text

**Note:** All user-facing text (control names, tooltips, dropdown labels, button text) must use localization keys. The framework passes these through `addon.L()` to display the localized text.

### Persistent vs Session-Only Controls

Set `persistent = true` to save settings permanently (survives logout/exit). Controls default to session-only.

**Example (persistent):**
```lua
function addon.EnableNotificationSystem(isEnabled)
    -- Your code here
end

{
    type = "checkbox",
    name = "enableNotifications",
    default = true,
    persistent = true,
    onValueChange = addon.EnableNotificationSystem,
    onLoad = addon.EnableNotificationSystem
}
```

**Note:** A tooltip will automatically appear if you add `"enableNotificationsTooltip"` to your localization file.

Use **onValueChange** when the user changes a setting. Use **onLoad** when the addon loads. Often you'll use both.

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
            default = true,
            persistent = true,
            onValueChange = addon.exampleCheckboxChanged,
            onLoad = addon.exampleCheckboxChanged
        },
        -- Checkbox (session-only - not saved)
        {
            type = "checkbox",
            name = "tempCheckbox",
            default = false
        },
        
        -- Dropdown (persisted to database)
        {
            type = "dropdown",
            name = "exampleDropdown",
            default = "option2",
            persistent = true,
            options = {
                {value = "option1", label = "dropdownOption1"},
                {value = "option2", label = "dropdownOption2"},
                {value = "option3", label = "dropdownOption3"}
            },
            onValueChange = addon.exampleDropdownChanged,
            onLoad = addon.exampleDropdownChanged
        },
        
        -- Slider (persisted to database)
        {
            type = "slider",
            name = "exampleSlider",
            default = 50,
            min = 0,
            max = 100,
            step = 5,
            persistent = true,
            onValueChange = addon.exampleSliderChanged,
            onLoad = addon.exampleSliderChanged
        },
        
        -- Input Box (session-only)
        {
            type = "inputBox",
            name = "exampleInput",
            default = "Enter text here",
            buttonText = "applyButton",
            onClick = addon.exampleInputClicked
        },
        
        -- Button
        {
            type = "button",
            name = "exampleButton",
            onClick = addon.exampleButtonClicked
        }
    }
}

function addon.exampleCheckboxChanged(isChecked)
    addon.info("Checkbox changed to: " .. tostring(isChecked))
end

function addon.exampleDropdownChanged(selectedValue)
    addon.info("Dropdown changed to: " .. selectedValue)
end

function addon.exampleSliderChanged(value)
    addon.info("Slider changed to: " .. value)
end

function addon.exampleInputClicked(inputText, editBox)
    addon.info("Input value: " .. inputText)
end

function addon.exampleButtonClicked()
    addon.info("Example button clicked!")
end
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

Your addon automatically gets a slash command: `/youraddonname`

Typing it alone opens settings. Register custom commands with `addon.RegisterSlashCommand(command, callback)`:

```lua
function addon.RegisterFunctions()
    addon.RegisterSlashCommand("hello", addon.HelloCommand)
    addon.RegisterSlashCommand("debug", addon.DebugCommand)
end

function addon.HelloCommand()
    addon.info("Hello, World!")
end

function addon.DebugCommand(enabled)
    if enabled == "on" then
        addon.settings.main.enableDebugging = true
        addon.info("Debugging enabled")
    end
end
```

**Built-in:** `/addon import` for importing settings

## Event Registration

Register WoW events with `addon.RegisterEvent(eventName, callback)`:

```lua
function addon.RegisterFunctions()
    addon.RegisterEvent("PLAYER_ENTERING_WORLD", addon.OnPlayerEnteringWorld)
    addon.RegisterEvent("PLAYER_REGEN_DISABLED", addon.OnEnterCombat)
    addon.RegisterEvent("UNIT_HEALTH", addon.OnUnitHealth)
end

function addon.OnPlayerEnteringWorld(event)
    addon.info("Player entered world")
end

function addon.OnEnterCombat(event)
    addon.info("Entering combat")
end

function addon.OnUnitHealth(event, unitID)
    if unitID == "player" then
        local health = UnitHealth("player")
        addon.debug("Health: " .. health)
    end
end
```

Unregister: `addon.eventFrame:UnregisterEvent("UNIT_HEALTH")`

## Logging Functions

- **`addon.debug(text)`** - Only displays when "Enable Debugging" is enabled in settings
- **`addon.info(text)`** - Always displays (informational messages)
- **`addon.error(text)`** - Always displays (error messages)

## Hooks

Every framework function has Before/After hooks for extending functionality.

**Before hooks** receive and must return parameters (can modify them):
```lua
function addon.BeforeL(key)
    return key:upper()  -- Modify parameter
end
```

**After hooks** receive return values (observation only):
```lua
function addon.AfterAddCheckbox(checkbox, newYOffset)
    checkbox:SetAlpha(0.9)  -- Customize the checkbox
end
```

All available hooks follow the pattern: `Before[FunctionName]` and `After[FunctionName]`. See `SAdCore.lua` for the complete list.

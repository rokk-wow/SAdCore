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

## Installation

### Embedding SAdCore in Your Addon

1. **Clone or download SAdCore** into your addon's `Libs` folder:
   ```bash
   cd YourAddon/Libs
   git clone https://github.com/yourusername/SAdCore.git
   # or add as a submodule
   git submodule add https://github.com/yourusername/SAdCore.git
   ```

   Your addon structure should look like:
   ```
   YourAddon/
   ├── Libs/
   │   └── SAdCore/
   │       ├── Libs/
   │       │   ├── LibSerialize/
   │       │   ├── LibCompress/
   │       │   └── ...
   │       ├── SAdCore.lua
   │       ├── SAdCore.toc
   │       ├── Addon_Example.lua
   │       └── README.md
   ├── YourAddon.lua
   └── YourAddon.toc
   ```

2. **Update your `.toc` file** to load SAdCore:
   ```toc
   ## Interface: 110207, 120000
   ## Title: YourAddon
   ## Author: Your Name
   ## Version: 1.0
   ## SavedVariables: YourAddon_Settings_Global
   ## SavedVariablesPerCharacter: YourAddon_Settings_Char
   ## AddonCompartmentFunc: YourAddon_Compartment_Func

   # Load SAdCore library (includes all dependencies)
   Libs\SAdCore\SAdCore.toc

   # Your addon files
   YourAddon.lua
   ```

3. **Initialize your addon** in `YourAddon.lua`:
   ```lua
   local addonName = ...
   local SAdCore = LibStub("SAdCore-1")
   local addon = SAdCore:GetAddon(addonName)
   
   -- Configure your addon
   function addon.LoadConfig()
       addon.config.version = "1.0"
       addon.config.settings.main = {
           title = "settingsTitle",
           controls = {
               {
                   type = "checkbox",
                   name = "enableFeature",
                   default = true,
                   persistent = true
               }
           }
       }
   end
   
   -- Handle addon loading
   local frame = CreateFrame("Frame")
   frame:RegisterEvent("ADDON_LOADED")
   frame:SetScript("OnEvent", function(self, event, loadedAddon)
       if loadedAddon == addonName then
           -- Initialize with your SavedVariables
           addon:Initialize(YourAddon_Settings_Global, YourAddon_Settings_Char)
           
           -- Optional: Register compartment function
           YourAddon_Compartment_Func = function()
               addon.OpenSettings()
           end
           
           self:UnregisterEvent("ADDON_LOADED")
       end
   end)
   
   -- Localization
   addon.locale = {}
   addon.locale.enEN = {
       settingsTitle = "My Addon Settings",
       enableFeature = "Enable Feature"
   }
   ```

**Important**: The SavedVariable names passed to `Initialize()` must match exactly what's declared in your `.toc` file.

## Quick Start: Creating a New Addon

Starting from scratch? Here's the complete process:

1. **Create your addon folder** in `World of Warcraft\_retail_\Interface\AddOns\`:
   ```
   MyNewAddon/
   ```

2. **Create `MyNewAddon.toc`** with these required fields:
   ```toc
   ## Interface: 110207, 120000
   ## Title: My New Addon
   ## Author: Your Name
   ## Version: 1.0
   ## SavedVariables: MyNewAddon_Settings_Global
   ## SavedVariablesPerCharacter: MyNewAddon_Settings_Char
   ## AddonCompartmentFunc: MyNewAddon_Compartment_Func
   
   Libs\SAdCore\SAdCore.toc
   MyNewAddon.lua
   ```

3. **Clone SAdCore** into your addon's Libs folder:
   ```bash
   cd MyNewAddon
   mkdir Libs
   cd Libs
   git clone https://github.com/yourusername/SAdCore.git
   ```

4. **Copy `Addon_Example.lua`** to your addon root and rename it:
   ```bash
   copy Libs\SAdCore\Addon_Example.lua MyNewAddon.lua
   ```

5. **Update `MyNewAddon.lua`**:
   - Find/replace `MyAddon` with `MyNewAddon` (matches your SavedVariables names)
   - Customize settings in `addon.LoadConfig()`
   - Update localization strings in `addon.locale.enEN`

6. **Load WoW and test** - your addon will appear in the AddOns list and Interface Options

That's it! You now have a working addon with a settings panel, SavedVariables persistence, and import/export functionality.

## How It Works

**LibStub Singleton Pattern**: When multiple addons embed SAdCore, LibStub ensures only one shared instance runs. If Addon A has SAdCore v1.2 and Addon B has v1.5, both will use v1.5 (the highest version). This means:
- ✅ Core logging appears only once
- ✅ Shared event management
- ✅ Efficient memory usage
- ✅ Addons can communicate through the shared core

**Addon Independence**: Each addon manages its own:
- Lifecycle (ADDON_LOADED event)
- SavedVariables declaration in .toc
- Compartment function registration
- Settings panels and UI
- Configuration and callbacks

SAdCore provides the framework functions while respecting each addon's autonomy.

## Localization

All user-facing text uses localization keys. This allows you to easily translate into other languages.

By default, localization is defined in `Addon.lua` at the bottom of the file. You can optionally move it to a separate `Localization.lua` file.

**Adding localized text:**

```lua
addon.locale.enEN = {
    keyName = "Your Text Here",
    exampleHeader = "My Settings",
    exampleCheckbox = "Enable Feature"
}
```

When you use `name = "exampleHeader"` in your control config, SAdCore automatically displays "My Settings". If a key is missing, it displays as `[keyName]` to alert you during development.

## Control Properties

### Common Properties

All controls support these common properties:

- **`type`** (required) - The control type: `"header"`, `"description"`, `"checkbox"`, `"dropdown"`, `"slider"`, `"colorPicker"`, `"inputBox"`, or `"button"`
- **`name`** (required) - Localization key used for both display text and variable storage. If the key is not found in localization, it displays as `[keyName]` to alert the developer
- **`persistent`** (optional) - When `true`, the control's value is saved to SavedVariables (either global or per-character). When absent or `false`, the control is session-only and not persisted. Applies to: `checkbox`, `dropdown`, `slider`, `inputBox`
- **`onValueChange`** (optional) - Callback function that fires immediately when the user changes the control's value. Receives the new value as a parameter. Perfect for applying settings in real-time without requiring a UI reload. Applies to: `checkbox`, `dropdown`, `slider`, `colorPicker`, `inputBox`
- **`onLoad`** (optional) - Callback function that fires when the game starts or the addon loads. Receives the saved value as a parameter. Applies to: `checkbox`, `dropdown`, `slider`, `colorPicker`, `inputBox`

### Automatic Tooltips

To add a tooltip, define a localization key with the control's name + `"Tooltip"` (e.g., `"exampleCheckboxTooltip"` for `name = "exampleCheckbox"`).

### Control-Specific Properties

**Dropdown:**
- **`options`** (required) - Array of option objects, each with:
  - `value` - The internal value stored when selected
  - `label` - Localization key for the displayed text

**Color Picker:**
- **`default`** (required) - Hex color code in one of two formats:
  - 6-character format: `"#RRGGBB"` (e.g., `"#FFFFFF"` for white, `"#FF0000"` for red)
  - 8-character format with alpha: `"#RRGGBBAA"` (e.g., `"#FFFFFF80"` for 50% transparent white, `"#FF0000FF"` for fully opaque red)
  - Alpha values range from `00` (fully transparent) to `FF` (fully opaque)
- The color picker UI includes an opacity slider that automatically updates the alpha channel

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
        
        -- Color Picker (persisted to database)
        -- Supports 6-character hex (#RRGGBB) or 8-character hex with alpha (#RRGGBBAA)
        -- Alpha values: #FFFFFF (fully opaque) or #FFFFFF80 (50% transparent)
        {
            type = "colorPicker",
            name = "exampleColor",
            default = "#FFFFFF",
            persistent = true,
            onValueChange = addon.exampleColorChanged,
            onLoad = addon.exampleColorChanged
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

function addon.exampleColorChanged(hexColor)
    addon.info("Color changed to: " .. hexColor)
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

## Zone Management

SAdCore provides automatic zone detection and callbacks. Register functions to execute when entering specific zones.

### Supported Zones

Use the predefined `addon.zones` list:
```lua
-- Available zones: "arena", "battleground", "dungeon", "raid", "world"
for _, zoneName in ipairs(addon.zones) do
    -- Your code here
end
```

### Registering Zone Callbacks

Register a callback for when the player enters a zone:

```lua
function addon.RegisterFunctions()
    addon.RegisterZone("ARENA", addon.enteringArena)
    addon.RegisterZone("BATTLEGROUND", addon.enteringBattleground)
    addon.RegisterZone("WORLD", addon.enteringWorld)
end

function addon.enteringArena()
    addon.info("Entered arena - applying arena settings")
    -- Apply your arena-specific settings
end

function addon.enteringWorld()
    addon.info("Entered world - restoring default settings")
    -- Restore default settings
end
```

### Zone Detection Events

Zone changes are automatically detected from these events:
- `PLAYER_ENTERING_WORLD`
- `ZONE_CHANGED_NEW_AREA`
- `PVP_MATCH_ACTIVE`
- `PVP_MATCH_INACTIVE`
- `ARENA_PREP_OPPONENT_SPECIALIZATIONS`
- `ARENA_OPPONENT_UPDATE`
- `PLAYER_ROLES_ASSIGNED`

### Getting Current Zone

```lua
local currentZone = addon.GetCurrentZone()
-- Returns: "ARENA", "BATTLEGROUND", "DUNGEON", "RAID", or "WORLD"
```

### Zone Leave Events

To execute code when leaving a zone, use hooks:

```lua
function addon.BeforeHandleZoneChange()
    if addon.previousZone == "ARENA" then
        addon.info("Leaving arena")
        -- Your cleanup code
    end
end
```

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

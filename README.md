# SAd - Simple Addons

Simple Addons are about consistency. They do one thing, and they do it well.

SAdCore is a lightweight, embeddable framework for rapidly building simple addons with consistent options and controls. Define your checkboxes, dropdowns, sliders, and buttons, and the settings UI is automatically generated with values persisted to SavedVariables. Built-in features include settings import/export, profile management, and optional zone detection for addons that need zone-based behavior.

**Note:** SAdCore is a library, not a standalone addon. It's embedded within other addons (similar to Ace3, LibStub, etc.).

## The SAd Creed
SAddons are:
- **Easy.** If a configuration setting is more complicated than a single control, it's probably wrong
- **Simple.** If a user doesn't understand your configuration without additional instructions, it's probably wrong
- **Intuitive.** If a user can't remember where they saw a particular configuration setting, it's probably wrong
- **Relevant.** If a configuration setting doesn't directly relate to the name of the addon, it's probably wrong
- **Respectful.** If a users game setting is changed just by installing the addon, it's probably wrong
- **Affirmative.** Logic should always enable, not disable (a checkbox should "Show Map", not "Hide Map")
- **Robust.** All code exists inside scoped functions. No global code exists
- **On Time.** All code should run based on proper events

## Installation

### Embedding SAdCore in Your Addon

1. **Clone or download SAdCore** into your addon's `Libs` folder:
   ```bash
   cd YourAddon/Libs
   git clone https://github.com/rokk-wow/SAdCore.git
   # or add as a submodule
   git submodule add https://github.com/rokk-wow/SAdCore.git
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
   ## Interface: 120000
   ## Title: YourAddon
   ## Author: Your Name
   ## Version: 1.0
   ## SavedVariables: YourAddon_Settings_Global
   ## SavedVariablesPerCharacter: YourAddon_Settings_Char
   ## AddonCompartmentFunc: YourAddon_Compartment_Func

   Libs\SAdCore\Libs\LibSerialize\LibStub\LibStub.lua
   Libs\SAdCore\Libs\LibSerialize\LibSerialize.lua
   Libs\SAdCore\Libs\LibCompress\LibCompress.lua
   Libs\SAdCore\SAdCore.lua

   YourAddon.lua
   ```
   
   **Note:** You must load the individual library files in this specific order. Loading the nested `SAdCore.toc` doesn't work reliably.

3. **Initialize your addon** in `YourAddon.lua`:
   ```lua
   local addonName = ...
   local SAdCore = LibStub("SAdCore-1")
   local addon = SAdCore:GetAddon(addonName)
   
   -- Configure SavedVariables (must match your .toc declarations)
   addon.savedVarsGlobal = YourAddon_Settings_Global
   addon.savedVarsPerChar = YourAddon_Settings_Char
   addon.compartmentFuncName = "YourAddon_Compartment_Func"
   
   -- Configure your addon and settings panels
   function addon:LoadConfig()
       self.config.version = "1.0"
       self.config.settings.main = {
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
   
   -- Localization
   addon.locale = {}
   addon.locale.enEN = {
       settingsTitle = "My Addon Settings",
       enableFeature = "Enable Feature"
   }
   ```

**Important**: 
- SavedVariable names must match exactly what's declared in your `.toc` file
- Use **colon syntax** (`function addon:MethodName()`) for all functions
- Inside functions, use **`self`** to reference the addon instance
- Initialization happens automatically when your addon loads

## Quick Start: Creating a New Addon

1. **Create your addon folder** in `World of Warcraft\_retail_\Interface\AddOns\`:
   ```
   MyAddon/
   ```

2. **Create `MyAddon.toc`** with these required fields:
   ```toc
   ## Interface: 110207, 120000
   ## Title: My Addon
   ## Author: Your Name
   ## Version: 1.0
   ## SavedVariables: MyAddon_Settings_Global
   ## SavedVariablesPerCharacter: MyAddon_Settings_Char
   ## AddonCompartmentFunc: MyAddon_Compartment_Func
   
   Libs\SAdCore\Libs\LibSerialize\LibStub\LibStub.lua
   Libs\SAdCore\Libs\LibSerialize\LibSerialize.lua
   Libs\SAdCore\Libs\LibCompress\LibCompress.lua
   Libs\SAdCore\SAdCore.lua
   MyAddon.lua
   ```

3. **Clone SAdCore** into your addon's Libs folder:
   ```bash
   cd MyAddon
   mkdir Libs
   cd Libs
   git clone https://github.com/rokk-wow/SAdCore.git
   ```

4. **Copy `Addon_Example.lua`** to your addon root and rename it:
   ```bash
   copy Libs\SAdCore\Addon_Example.lua MyAddon.lua
   ```

5. **Update `MyAddon.lua`**:
   - No need to change SavedVariables names (they already use `MyAddon`)
   - Customize settings in `addon.LoadConfig()`
   - Update localization strings in `addon.locale.enEN`

6. **Load WoW and test** - your addon will appear in the AddOns list and Interface Options

That's it! You now have a working addon with a settings panel, SavedVariables persistence, and import/export functionality.

## Adding New Lua Files

To add a new Lua file to your addon: add it to your `.toc` file, then include these three lines at the top:

```lua
local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)
```

All files share the same `addon` instance and can define functions using colon syntax.

## How It Works

**LibStub Singleton Pattern**: When multiple addons embed SAdCore, LibStub ensures only one shared instance runs. If Addon A has SAdCore v1.2 and Addon B has v1.5, both will use v1.5 (the highest version). This means:
- ✅ Core logging appears only once
- ✅ Shared event management
- ✅ Efficient memory usage
- ✅ Addons can communicate through the shared core

**Addon Independence**: Each addon manages its own:
- Lifecycle (automatic initialization via `GetAddon()`)
- SavedVariables declaration in .toc
- Compartment function registration
- Settings panels and UI
- Configuration and callbacks

SAdCore provides the framework functions while respecting each addon's autonomy.

## Initialization

SAdCore uses **automatic initialization** - you don't need to call any setup functions. Just set your SavedVariables properties and define your functions:

```lua
local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

-- Saved Variable definitions and Addon Compartment Function must match what's in your .toc
addon.savedVarsGlobal = YourAddon_Settings_Global
addon.savedVarsPerChar = YourAddon_Settings_Char
addon.compartmentFuncName = "YourAddon_Compartment_Func"

-- Define your configuration
function addon:LoadConfig()
    self.config.version = "1.0"
    -- Your settings here
end
```

**What happens automatically:**
1. `GetAddon()` creates your addon instance and registers for `ADDON_LOADED`
2. When your addon loads, SAdCore reads `savedVarsGlobal` and `savedVarsPerChar` from your addon instance
3. `Initialize()` is called automatically with your SavedVariables
4. Your `LoadConfig()` function is called
5. Compartment function is registered


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
- **`onValueChange`** (optional) - Callback function that fires when the control's value changes (either from user interaction or when the addon loads with saved values). Receives the new value as a parameter. Perfect for applying settings in real-time. Applies to: `checkbox`, `dropdown`, `slider`, `colorPicker`, `inputBox`

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
function addon:EnableNotificationSystem(isEnabled)
    -- Your code here
end

{
    type = "checkbox",
    name = "enableNotifications",
    default = true,
    persistent = true,
    onValueChange = self.EnableNotificationSystem
}
```

**Note:** A tooltip will automatically appear if you add `"enableNotificationsTooltip"` to your localization file.

The `onValueChange` function is called both when the user changes the setting AND when the addon loads with the saved value.

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
            onValueChange = self.exampleCheckboxChanged
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
            onValueChange = self.exampleDropdownChanged
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
            onValueChange = self.exampleSliderChanged
        },
        
        -- Color Picker (persisted to database)
        -- Supports 6-character hex (#RRGGBB) or 8-character hex with alpha (#RRGGBBAA)
        -- Alpha values: #FFFFFF (fully opaque) or #FFFFFF80 (50% transparent)
        {
            type = "colorPicker",
            name = "exampleColor",
            default = "#FFFFFF",
            persistent = true,
            onValueChange = self.exampleColorChanged
        },
        
        -- Input Box (session-only)
        {
            type = "inputBox",
            name = "exampleInput",
            default = "Enter text here",
            buttonText = "applyButton",
            onClick = self.exampleInputClicked
        },
        
        -- Button
        {
            type = "button",
            name = "exampleButton",
            onClick = self.exampleButtonClicked
        }
    }
}

function addon:exampleCheckboxChanged(isChecked)
    self:info("Checkbox changed to: " .. tostring(isChecked))
end

function addon:exampleDropdownChanged(selectedValue)
    self:info("Dropdown changed to: " .. selectedValue)
end

function addon:exampleSliderChanged(value)
    self:info("Slider changed to: " .. value)
end

function addon:exampleColorChanged(hexColor)
    self:info("Color changed to: " .. hexColor)
end

function addon:exampleInputClicked(inputText, editBox)
    self:info("Input value: " .. inputText)
end

function addon:exampleButtonClicked()
    self:info("Example button clicked!")
end
```

## Accessing Saved Settings

Settings are saved to `self.settings` organized by panel key. Access control values using `self.settings.panelKey.controlName`.

**Example:**
```lua
function addon:PrintDebuggingStatus()
    if self.settings.main.enableDebugging then
        self:info("Debugging is currently ENABLED")
    else
        self:info("Debugging is currently DISABLED")
    end
end
```

## Common API Functions

These are the most commonly used functions available on the `self` object within your addon methods:

### Logging
- **`self:debug(text)`** - Only displays when "Enable Debugging" is enabled in settings
- **`self:info(text)`** - Always displays (informational messages)
- **`self:error(text)`** - Always displays (error messages)

### Localization
- **`self:L(key)`** - Returns the localized string for the given key based on client language

### Events & Commands
- **`self:RegisterEvent(eventName, callback)`** - Register a WoW event with a callback function
- **`self:RegisterSlashCommand(command, callback)`** - Register a custom slash command
- **`self:RegisterZone(zoneName, callback)`** - Register a callback when player enters a zone

### Zone Detection
- **`self:GetCurrentZone()`** - Returns current zone: "ARENA", "BATTLEGROUND", "DUNGEON", "RAID", or "WORLD"

### Settings
- **`self:OpenSettings()`** - Opens the addon settings panel

### Utilities
- **`self:ShowDialog(title, message, onAccept, onCancel)`** - Display a confirmation dialog
- **`self:Inspect(table)`** - Debug utility to inspect UI frame structures

## Slash Commands

Your addon automatically gets a slash command: `/youraddonname`

Typing it alone opens settings. Register custom commands with `self:RegisterSlashCommand(command, callback)`:

```lua
function addon:RegisterFunctions()
    self:RegisterSlashCommand("hello", self.HelloCommand)
    self:RegisterSlashCommand("debug", self.DebugCommand)
end

function addon:HelloCommand()
    self:info("Hello, World!")
end

function addon:DebugCommand(enabled)
    if enabled == "on" then
        self.settings.main.enableDebugging = true
        self:info("Debugging enabled")
    end
end
```

**Built-in:** `/addon import` for importing settings

## Event Registration

Register WoW events with `self:RegisterEvent(eventName, callback)`:

```lua
function addon:RegisterFunctions()
    self:RegisterEvent("PLAYER_ENTERING_WORLD", self.OnPlayerEnteringWorld)
    self:RegisterEvent("PLAYER_REGEN_DISABLED", self.OnEnterCombat)
    self:RegisterEvent("UNIT_HEALTH", self.OnUnitHealth)
end

function addon:OnPlayerEnteringWorld(event)
    self:info("Player entered world")
end

function addon:OnEnterCombat(event)
    self:info("Entering combat")
end

function addon:OnUnitHealth(event, unitID)
    if unitID == "player" then
        local health = UnitHealth("player")
        self:debug("Health: " .. health)
    end
end
```

Unregister: `self.eventFrame:UnregisterEvent("UNIT_HEALTH")`

## Zone Management (Optional)

SAdCore provides **optional** automatic zone detection and callbacks. This feature is designed for addons that need zone-based behavior (like chat filters or UI visibility in different zones). If your addon doesn't need zone-specific functionality, simply don't use these functions.

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
function addon:RegisterFunctions()
    self:RegisterZone("ARENA", self.enteringArena)
    self:RegisterZone("BATTLEGROUND", self.enteringBattleground)
    self:RegisterZone("WORLD", self.enteringWorld)
end

function addon:enteringArena()
    self:info("Entered arena - applying arena settings")
    -- Apply your arena-specific settings
end

function addon:enteringWorld()
    self:info("Entered world - restoring default settings")
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
local currentZone = self:GetCurrentZone()
-- Returns: "ARENA", "BATTLEGROUND", "DUNGEON", "RAID", or "WORLD"
```

### Zone Leave Events

To execute code when leaving a zone, use hooks:

```lua
function addon:BeforeHandleZoneChange()
    if self.previousZone == "ARENA" then
        self:info("Leaving arena")
        -- Your cleanup code
    end
end
```

## Hooks

Every framework function has Before/After hooks for extending functionality.

**Before hooks** receive and must return parameters (can modify them):
```lua
function addon:BeforeL(key)
    return key:upper()  -- Modify parameter
end
```

**After hooks** receive return values (observation only):
```lua
function addon:AfterAddCheckbox(checkbox, newYOffset)
    checkbox:SetAlpha(0.9)  -- Customize the checkbox
end
```

All available hooks follow the pattern: `Before[FunctionName]` and `After[FunctionName]`. See `SAdCore.lua` for the complete list.

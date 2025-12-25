local addonName, addon = ...

-- SAdCore is a free and open source quick start template for rapidly developing addons.
--
-- The goal is for this framework to handle all settings, saved variables, config UI and other
-- basic functionality so that you can get straight to coding the actual addon.
--
-- Just by adding a simple configuration, you get:
--   • Fully functional settings panel that matches Blizzards UI with your custom settings
--   • Addon compartment support
--   • Access to all user configurations
--   • Quick and easy slash commands
--   • Event hooks
--   • Settings import/export
--
-- You are free to use this for your own addon. My only request is if you choose to use the SAd prefix for your,
-- addon name then you will try your best to follow the SAd Creed.
--
-- ## The SAd Creed
--   Easy        - If a configuration setting is more complicated than a checkbox, it's probably wrong
--   Simple      - If a user doesn't understand your configuration without additional instructions, it's probably wrong
--   Intuitive   - If a user can't remember where they saw a particular configuration setting, it's probably wrong
--   Relevant    - If a configuration setting doesn't directly relate to the name of the addon, it's probably wrong
--   Respectful  - If a users game setting is changed just by installing the addon, it's probably wrong
--   Clear       - Checkboxes should enable, not disable ("Show Map", not "Hide Map")
--   Robust      - All code exists inside addon functions. The only global code is registering the ADDON_LOADED event

function addon.LoadConfig()
    addon.config.version = "1.1"

    addon.config.toc = {
        -- Values in .toc file must match these values exactly. They must be unique from any other addon.
        AddonCompartmentFunc = "MyAddon_Compartment_Func",
        SavedVariables = "MyAddon_Settings_Global",
        SavedVariablesPerCharacter = "MyAddon_Settings_Char",
    }

    -- Example - Add Settings to Main Settings Panel
    addon.config.settings.main = {
        title = "My Addon Settings",
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
                tooltip = "exampleCheckboxTooltip",
                default = true,
                persistent = true
            },
        }
    }

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
                name = "exampleCheckbox",
                tooltip = "exampleCheckboxTooltip",
                default = true,
                persistent = true
            },
        }
    }
end

-- Example Registration Functions
function addon.RegisterFunctions()

    -- Register /myaddon hello (change myaddon to the name of your addon)
    addon.RegisterSlashCommand("hello", function()
        addon.info("Hello, World!")
    end)
    
    -- Register a simple event
    addon.RegisterEvent("PLAYER_ENTERING_WORLD", function(event)
        addon.info("Player has entered the world!")
    end)
    
end

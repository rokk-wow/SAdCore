local addonName, addon = ...

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

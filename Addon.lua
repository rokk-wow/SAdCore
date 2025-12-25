local addonName, addon = ...

function addon.LoadConfig()
    addon.config.version = "1.1"

    addon.config.toc = {
        -- Values in .toc file must match these values exactly. They must be unique from any other addon.
        AddonCompartmentFunc = "MyAddon_Compartment_Func",
        SavedVariables = "MyAddon_Settings_Global",
        SavedVariablesPerCharacter = "MyAddon_Settings_Char",
    }
end

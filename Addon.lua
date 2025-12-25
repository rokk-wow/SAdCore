local addonName, addon = ...

function addon.LoadConfig()
    addon.config.version = "1.1"

    addon.config.toc = {
        -- Values in .toc file must match these values exactly. They must be unique from any other addon.
        AddonCompartmentFunc = "CHANGE_TO_UNIQUE_COMPARTMENT_FUNCTION_NAME",
        SavedVariables = "CHANGE_TO_UNIQUE_SAVED_VARIABLE_NAME",
        SavedVariablesPerCharacter = "CHANGE_TO_UNIQUE_SAVED_VARIABLE_PER_CHARACTER_NAME",
    }
end

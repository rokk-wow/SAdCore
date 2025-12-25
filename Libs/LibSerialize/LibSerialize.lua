-- LibSerialize: Simple table serialization library
local MAJOR, MINOR = "LibSerialize", 1
local LibSerialize = LibStub:NewLibrary(MAJOR, MINOR)
if not LibSerialize then return end

local serialize_simple

local function serialize_value(v)
    local tv = type(v)
    if tv == "string" then
        return string.format("%q", v)
    elseif tv == "number" or tv == "boolean" then
        return tostring(v)
    elseif tv == "table" then
        return serialize_simple(v)
    else
        return "nil"
    end
end

serialize_simple = function(tbl)
    local result = {}
    result[1] = "{"
    local first = true
    
    for k, v in pairs(tbl) do
        if not first then
            table.insert(result, ",")
        end
        first = false
        
        if type(k) == "string" then
            table.insert(result, "[")
            table.insert(result, string.format("%q", k))
            table.insert(result, "]=")
        elseif type(k) == "number" then
            table.insert(result, "[")
            table.insert(result, tostring(k))
            table.insert(result, "]=")
        else
            -- Skip unsupported key types
            first = true
            table.remove(result) -- Remove the comma we just added
        end
        
        if type(k) == "string" or type(k) == "number" then
            table.insert(result, serialize_value(v))
        end
    end
    
    table.insert(result, "}")
    return table.concat(result)
end

function LibSerialize:Serialize(data)
    if type(data) ~= "table" then
        return nil, "Data must be a table"
    end
    
    local success, result = pcall(serialize_simple, data)
    if not success then
        return nil, result
    end
    
    return result
end

function LibSerialize:Deserialize(str)
    if not str or str == "" then
        return nil, "Empty string"
    end

    -- Remove line breaks and extra whitespace
    local sanitized = str:gsub("\r", ""):gsub("\n", ""):gsub("%s+", " ")
    print("LibSerialize Debug: sanitized string:", sanitized)
    local func, err = loadstring("return " .. sanitized)
    if not func then
        print("LibSerialize Debug: loadstring error:", tostring(err))
        return nil, "Parse error: " .. tostring(err) .. "\nSanitized string: " .. sanitized
    end

    local success, result = pcall(func)
    if not success then
        print("LibSerialize Debug: pcall error:", tostring(result))
        return nil, "Execution error: " .. tostring(result) .. "\nSanitized string: " .. sanitized
    end

    return result
end

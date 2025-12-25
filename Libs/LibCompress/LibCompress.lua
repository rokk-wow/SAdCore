-- LibCompress: Simple base64 encoding for data transmission
local MAJOR, MINOR = "LibCompress", 1
local LibCompress = LibStub:NewLibrary(MAJOR, MINOR)
if not LibCompress then return end

-- Base64 encoding table
local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local b64lookup = {}
for i = 1, #b64chars do
    b64lookup[b64chars:sub(i, i)] = i - 1
end

-- Encode string to base64
function LibCompress:Encode(data)
    if type(data) ~= "string" then
        return nil, "Data must be a string"
    end
    
    return ((data:gsub('.', function(x) 
        local r, b = '', x:byte()
        for i = 8, 1, -1 do
            r = r .. (b % 2^i - b % 2^(i-1) > 0 and '1' or '0')
        end
        return r
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if #x < 6 then return '' end
        local c = 0
        for i = 1, 6 do
            c = c + (x:sub(i, i) == '1' and 2^(6-i) or 0)
        end
        return b64chars:sub(c + 1, c + 1)
    end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

-- Decode base64 to string
function LibCompress:Decode(data)
    if type(data) ~= "string" then
        return nil, "Data must be a string"
    end
    
    data = string.gsub(data, '[^'..b64chars..'=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r, f = '', b64lookup[x]
        for i = 6, 1, -1 do
            r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0')
        end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c = 0
        for i = 1, 8 do
            c = c + (x:sub(i, i) == '1' and 2^(8-i) or 0)
        end
        return string.char(c)
    end))
end

-- For compatibility with full LibCompress API
function LibCompress:Compress(data)
    return self:Encode(data)
end

function LibCompress:Decompress(data)
    return self:Decode(data)
end

-- Get encode table for addon channel (removes \000)
function LibCompress:GetAddonEncodeTable()
    local tbl = {}
    function tbl:Encode(str)
        return (str:gsub("%z", "\001\001"))
    end
    function tbl:Decode(str)
        return (str:gsub("\001\001", "\000"))
    end
    return tbl
end

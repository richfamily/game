--[[
    Utilities.lua
    Contains general utility functions used throughout the game
]]

local Utilities = {}

-- Random number generation with seed for consistent results
function Utilities.SeededRandom(seed, min, max)
    local rng = Random.new(seed)
    return rng:NextNumber(min, max)
end

-- Format large numbers to be more readable with specific abbreviations
function Utilities.FormatNumber(number)
    if number >= 1000000000000000000 then -- Quintillions (qi)
        return string.format("%.1fqi", number / 1000000000000000000)
    elseif number >= 1000000000000000 then -- Quadrillions (qa)
        return string.format("%.1fqa", number / 1000000000000000)
    elseif number >= 1000000000000 then -- Trillions (t)
        return string.format("%.1ft", number / 1000000000000)
    elseif number >= 1000000000 then -- Billions (b)
        return string.format("%.1fb", number / 1000000000)
    elseif number >= 1000000 then -- Millions (m)
        return string.format("%.1fm", number / 1000000)
    elseif number >= 1000 then -- Thousands with comma
        return string.format("%s", Utilities.AddCommas(math.floor(number)))
    else -- Small numbers
        return tostring(math.floor(number))
    end
end

-- Add commas to a number (e.g., 1234567 -> 1,234,567)
function Utilities.AddCommas(number)
    local formatted = tostring(number)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Format time in seconds to a readable format (e.g., 3665 -> 1h 1m 5s)
function Utilities.FormatTime(seconds)
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    
    if days > 0 then
        return string.format("%dd %dh %dm %ds", days, hours, minutes, seconds)
    elseif hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes, seconds)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, seconds)
    else
        return string.format("%ds", seconds)
    end
end

-- Deep copy a table (to avoid reference issues)
function Utilities.DeepCopy(original)
    local copy
    if type(original) == "table" then
        copy = {}
        for key, value in pairs(original) do
            copy[Utilities.DeepCopy(key)] = Utilities.DeepCopy(value)
        end
        setmetatable(copy, Utilities.DeepCopy(getmetatable(original)))
    else
        copy = original
    end
    return copy
end

-- Merge two tables (useful for updating configurations)
function Utilities.MergeTables(t1, t2)
    for key, value in pairs(t2) do
        if type(value) == "table" and type(t1[key]) == "table" then
            Utilities.MergeTables(t1[key], value)
        else
            t1[key] = value
        end
    end
    return t1
end

-- Calculate the chance of an event occurring based on a percentage
function Utilities.CalculateChance(percentage)
    return math.random() <= percentage
end

-- Get a random element from a table
function Utilities.GetRandomElement(tbl)
    if #tbl == 0 then return nil end
    return tbl[math.random(1, #tbl)]
end

-- Get a weighted random element from a table
-- Each element should have a 'weight' property
function Utilities.GetWeightedRandomElement(tbl)
    if #tbl == 0 then return nil end
    
    local totalWeight = 0
    for _, item in ipairs(tbl) do
        totalWeight = totalWeight + (item.weight or 1)
    end
    
    local randomWeight = math.random() * totalWeight
    local currentWeight = 0
    
    for _, item in ipairs(tbl) do
        currentWeight = currentWeight + (item.weight or 1)
        if randomWeight <= currentWeight then
            return item
        end
    end
    
    return tbl[#tbl] -- Fallback
end

-- Lerp between two values
function Utilities.Lerp(a, b, t)
    return a + (b - a) * t
end

-- Clamp a value between min and max
function Utilities.Clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

-- Round a number to a specific decimal place
function Utilities.Round(number, decimals)
    local power = 10 ^ (decimals or 0)
    return math.floor(number * power + 0.5) / power
end

-- Check if a table contains a specific value
function Utilities.TableContains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- Find an item in a table by a specific property value
function Utilities.FindItemByProperty(tbl, property, value)
    for _, item in pairs(tbl) do
        if item[property] == value then
            return item
        end
    end
    return nil
end

-- Calculate the distance between two Vector3 positions
function Utilities.CalculateDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- Create a unique ID for various game elements
function Utilities.CreateUniqueID(prefix)
    prefix = prefix or "ITEM"
    local timestamp = os.time()
    local random = math.random(1000, 9999)
    return string.format("%s_%d_%d", prefix, timestamp, random)
end

-- Convert a color from RGB to HSV
function Utilities.RGBtoHSV(r, g, b)
    r, g, b = r / 255, g / 255, b / 255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    v = max
    
    local d = max - min
    if max == 0 then
        s = 0
    else
        s = d / max
    end
    
    if max == min then
        h = 0
    else
        if max == r then
            h = (g - b) / d
            if g < b then h = h + 6 end
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    
    return h, s, v
end

-- Convert a color from HSV to RGB
function Utilities.HSVtoRGB(h, s, v)
    local r, g, b
    
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    i = i % 6
    
    if i == 0 then
        r, g, b = v, t, p
    elseif i == 1 then
        r, g, b = q, v, p
    elseif i == 2 then
        r, g, b = p, v, t
    elseif i == 3 then
        r, g, b = p, q, v
    elseif i == 4 then
        r, g, b = t, p, v
    elseif i == 5 then
        r, g, b = v, p, q
    end
    
    return r * 255, g * 255, b * 255
end

-- Get a color based on rarity (common to mythical)
function Utilities.GetRarityColor(rarity)
    local colors = {
        Common = Color3.fromRGB(255, 255, 255), -- White
        Uncommon = Color3.fromRGB(0, 255, 0), -- Green
        Rare = Color3.fromRGB(0, 112, 221), -- Blue
        Epic = Color3.fromRGB(163, 53, 238), -- Purple
        Legendary = Color3.fromRGB(255, 215, 0), -- Gold
        Mythical = Color3.fromRGB(255, 0, 0) -- Red
    }
    
    return colors[rarity] or colors.Common
end

-- Create a tween for smooth animations
function Utilities.CreateTween(instance, tweenInfo, properties)
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, properties)
    return tween
end

-- Wait for a child to be added to an instance
function Utilities.WaitForChild(parent, childName, timeout)
    timeout = timeout or 5
    local startTime = os.clock()
    
    while os.clock() - startTime < timeout do
        local child = parent:FindFirstChild(childName)
        if child then
            return child
        end
        wait(0.1)
    end
    
    warn("WaitForChild timed out: " .. childName)
    return nil
end

return Utilities

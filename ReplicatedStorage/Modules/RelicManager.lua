--[[
    RelicManager.lua
    Handles relic-related functionality such as creating relics, calculating relic effects, and managing relic interactions
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import modules
local Utilities = require(ReplicatedStorage.Modules.Utilities)

-- Import configurations
local RelicConfig = require(ReplicatedStorage.Config.RelicConfig)
local GameConfig = require(ReplicatedStorage.Config.GameConfig)

local RelicManager = {}
RelicManager.__index = RelicManager

-- Create a new RelicManager instance
function RelicManager.new()
    local self = setmetatable({}, RelicManager)
    
    -- Initialize properties
    self.ActiveRelics = {} -- Table to track active relics in the game
    
    return self
end

-- Get a relic definition from the config
function RelicManager:GetRelicDefinition(relicID)
    for _, relic in ipairs(RelicConfig.Relics) do
        if relic.ID == relicID then
            return relic
        end
    end
    return nil
end

-- Get a rarity definition from the config
function RelicManager:GetRarityDefinition(rarityName)
    for _, rarity in ipairs(RelicConfig.Rarities) do
        if rarity.Name == rarityName then
            return rarity
        end
    end
    return nil
end

-- Calculate relic effect based on level and rarity
function RelicManager:CalculateRelicEffect(relicData)
    -- Get the base relic definition
    local relicDefinition = self:GetRelicDefinition(relicData.ID)
    if not relicDefinition then
        warn("Relic definition not found for ID: " .. relicData.ID)
        return nil
    end
    
    -- Get the rarity multiplier
    local rarityDefinition = self:GetRarityDefinition(relicData.Rarity)
    local rarityMultiplier = rarityDefinition and rarityDefinition.EffectMultiplier or 1.0
    
    -- Calculate level multiplier
    local levelMultiplier = 1 + ((relicData.Level - 1) * RelicConfig.LevelingSystem.EffectIncrease)
    
    -- Calculate the effect
    local effect = {
        Type = relicDefinition.Effect.Type,
        Value = relicDefinition.Effect.Value * rarityMultiplier * levelMultiplier
    }
    
    -- Round the effect value for cleaner display
    effect.Value = Utilities.Round(effect.Value, 3)
    
    return effect
end

-- Create a new relic instance
function RelicManager:CreateRelic(relicID, rarity, level, experience)
    -- Get the relic definition
    local relicDefinition = self:GetRelicDefinition(relicID)
    if not relicDefinition then
        warn("Relic definition not found for ID: " .. relicID)
        return nil
    end
    
    -- Create the relic data
    local relicData = {
        ID = relicID,
        UUID = Utilities.CreateUniqueID("RELIC"),
        Rarity = rarity or "Common",
        Level = level or 1,
        Experience = experience or 0,
        Equipped = false,
        Effect = {} -- Will be calculated below
    }
    
    -- Calculate the relic's effect
    relicData.Effect = self:CalculateRelicEffect(relicData)
    
    return relicData
end

-- Calculate experience needed for next level
function RelicManager:GetExperienceForNextLevel(currentLevel)
    return RelicConfig.LevelingSystem.ExperiencePerLevel(currentLevel)
end

-- Add experience to a relic
function RelicManager:AddRelicExperience(relicData, experienceAmount)
    if not relicData then return false end
    
    -- Add experience
    relicData.Experience = relicData.Experience + experienceAmount
    
    -- Check if relic should level up
    local maxLevel = RelicConfig.LevelingSystem.MaxLevel
    while relicData.Level < maxLevel do
        local expForNextLevel = self:GetExperienceForNextLevel(relicData.Level)
        if relicData.Experience >= expForNextLevel then
            relicData.Level = relicData.Level + 1
            relicData.Experience = relicData.Experience - expForNextLevel
            
            -- Recalculate effect after leveling up
            relicData.Effect = self:CalculateRelicEffect(relicData)
        else
            break
        end
    end
    
    -- Cap experience at max level
    if relicData.Level >= maxLevel then
        relicData.Experience = 0
    end
    
    return true
end

-- Equip a relic
function RelicManager:EquipRelic(playerData, relicUUID)
    if not playerData or not playerData.Relics then return false end
    
    -- Find the relic in the player's inventory
    local relicToEquip = nil
    for _, relic in ipairs(playerData.Relics) do
        if relic.UUID == relicUUID then
            relicToEquip = relic
            break
        end
    end
    
    if not relicToEquip then
        warn("Relic not found in player's inventory: " .. relicUUID)
        return false
    end
    
    -- Count currently equipped relics
    local equippedCount = 0
    for _, relic in ipairs(playerData.Relics) do
        if relic.Equipped then
            equippedCount = equippedCount + 1
        end
    end
    
    -- Check if player has reached the equip limit
    if equippedCount >= RelicConfig.CombinationSystem.MaxEquippedRelics and not relicToEquip.Equipped then
        warn("Player has reached the relic equip limit")
        return false
    end
    
    -- Equip the relic
    relicToEquip.Equipped = true
    
    -- Update player multipliers based on equipped relics
    self:UpdatePlayerMultipliers(playerData)
    
    return true
end

-- Unequip a relic
function RelicManager:UnequipRelic(playerData, relicUUID)
    if not playerData or not playerData.Relics then return false end
    
    -- Find the relic in the player's inventory
    local relicToUnequip = nil
    for _, relic in ipairs(playerData.Relics) do
        if relic.UUID == relicUUID then
            relicToUnequip = relic
            break
        end
    end
    
    if not relicToUnequip then
        warn("Relic not found in player's inventory: " .. relicUUID)
        return false
    end
    
    -- Unequip the relic
    relicToUnequip.Equipped = false
    
    -- Update player multipliers based on equipped relics
    self:UpdatePlayerMultipliers(playerData)
    
    return true
end

-- Update player multipliers based on equipped relics
function RelicManager:UpdatePlayerMultipliers(playerData)
    if not playerData or not playerData.Relics then return false end
    
    -- Reset multipliers to base values
    playerData.Multipliers = {
        Coins = 1,
        Damage = 1,
        Speed = 1
    }
    
    -- Get all equipped relics
    local equippedRelics = {}
    for _, relic in ipairs(playerData.Relics) do
        if relic.Equipped then
            table.insert(equippedRelics, relic)
        end
    end
    
    -- Apply individual relic effects
    for _, relic in ipairs(equippedRelics) do
        local relicDefinition = self:GetRelicDefinition(relic.ID)
        if not relicDefinition then continue end
        
        if relic.Effect.Type == "GlobalMultiplier" then
            -- Apply to all multipliers
            playerData.Multipliers.Coins = playerData.Multipliers.Coins * (1 + relic.Effect.Value)
            playerData.Multipliers.Damage = playerData.Multipliers.Damage * (1 + relic.Effect.Value)
            playerData.Multipliers.Speed = playerData.Multipliers.Speed * (1 + relic.Effect.Value)
        elseif relic.Effect.Type == "CoinMultiplier" then
            -- Apply to coin multiplier only
            playerData.Multipliers.Coins = playerData.Multipliers.Coins * (1 + relic.Effect.Value)
        elseif relic.Effect.Type == "DamageMultiplier" then
            -- Apply to damage multiplier only
            playerData.Multipliers.Damage = playerData.Multipliers.Damage * (1 + relic.Effect.Value)
        elseif relic.Effect.Type == "SpeedMultiplier" then
            -- Apply to speed multiplier only
            playerData.Multipliers.Speed = playerData.Multipliers.Speed * (1 + relic.Effect.Value)
        end
    end
    
    -- Check for relic combinations
    for _, combination in ipairs(RelicConfig.CombinationSystem.Combinations) do
        -- Check if all required relics are equipped
        local hasAllRelics = true
        for _, requiredRelicID in ipairs(combination.RequiredRelics) do
            local found = false
            for _, relic in ipairs(equippedRelics) do
                if relic.ID == requiredRelicID then
                    found = true
                    break
                end
            end
            if not found then
                hasAllRelics = false
                break
            end
        end
        
        -- Apply combination bonus if all required relics are equipped
        if hasAllRelics then
            if combination.Bonus.Type == "GlobalMultiplier" then
                -- Apply to all multipliers
                playerData.Multipliers.Coins = playerData.Multipliers.Coins * (1 + combination.Bonus.Value)
                playerData.Multipliers.Damage = playerData.Multipliers.Damage * (1 + combination.Bonus.Value)
                playerData.Multipliers.Speed = playerData.Multipliers.Speed * (1 + combination.Bonus.Value)
            elseif combination.Bonus.Type == "CoinMultiplier" then
                -- Apply to coin multiplier only
                playerData.Multipliers.Coins = playerData.Multipliers.Coins * (1 + combination.Bonus.Value)
            elseif combination.Bonus.Type == "DamageMultiplier" then
                -- Apply to damage multiplier only
                playerData.Multipliers.Damage = playerData.Multipliers.Damage * (1 + combination.Bonus.Value)
            elseif combination.Bonus.Type == "SpeedMultiplier" then
                -- Apply to speed multiplier only
                playerData.Multipliers.Speed = playerData.Multipliers.Speed * (1 + combination.Bonus.Value)
            end
        end
    end
    
    -- Round the multipliers for cleaner display
    playerData.Multipliers.Coins = Utilities.Round(playerData.Multipliers.Coins, 2)
    playerData.Multipliers.Damage = Utilities.Round(playerData.Multipliers.Damage, 2)
    playerData.Multipliers.Speed = Utilities.Round(playerData.Multipliers.Speed, 2)
    
    return true
end

-- Get relics available for a specific zone
function RelicManager:GetRelicsForZone(zoneNumber)
    local availableRelics = {}
    
    for _, relic in ipairs(RelicConfig.Relics) do
        if relic.UnlockZone <= zoneNumber then
            table.insert(availableRelics, relic)
        end
    end
    
    return availableRelics
end

-- Generate a random relic for a specific zone
function RelicManager:GenerateRandomRelic(zoneNumber)
    -- Get relics available for this zone
    local availableRelics = self:GetRelicsForZone(zoneNumber)
    
    if #availableRelics == 0 then
        warn("No relics available for zone: " .. zoneNumber)
        return nil
    end
    
    -- Select a random relic
    local selectedRelic = Utilities.GetRandomElement(availableRelics)
    
    -- Determine rarity based on chances
    local rarities = {}
    for _, rarity in ipairs(RelicConfig.Rarities) do
        if Utilities.TableContains(selectedRelic.AvailableRarities, rarity.Name) then
            table.insert(rarities, {name = rarity.Name, chance = rarity.Chance})
        end
    end
    
    -- Sort rarities by chance (ascending)
    table.sort(rarities, function(a, b) return a.chance < b.chance end)
    
    -- Roll for rarity
    local selectedRarity = rarities[1].name -- Default to lowest rarity
    local random = math.random()
    local cumulativeChance = 0
    
    for _, rarity in ipairs(rarities) do
        cumulativeChance = cumulativeChance + rarity.chance
        if random <= cumulativeChance then
            selectedRarity = rarity.name
            break
        end
    end
    
    -- Create the relic
    return self:CreateRelic(
        selectedRelic.ID,
        selectedRarity,
        1, -- Level
        0 -- Experience
    )
end

-- Get active relic combinations for a player
function RelicManager:GetActiveRelicCombinations(playerData)
    if not playerData or not playerData.Relics then return {} end
    
    local activeCombinations = {}
    
    -- Get all equipped relics
    local equippedRelics = {}
    for _, relic in ipairs(playerData.Relics) do
        if relic.Equipped then
            table.insert(equippedRelics, relic)
        end
    end
    
    -- Check for relic combinations
    for _, combination in ipairs(RelicConfig.CombinationSystem.Combinations) do
        -- Check if all required relics are equipped
        local hasAllRelics = true
        for _, requiredRelicID in ipairs(combination.RequiredRelics) do
            local found = false
            for _, relic in ipairs(equippedRelics) do
                if relic.ID == requiredRelicID then
                    found = true
                    break
                end
            end
            if not found then
                hasAllRelics = false
                break
            end
        end
        
        -- Add to active combinations if all required relics are equipped
        if hasAllRelics then
            table.insert(activeCombinations, combination)
        end
    end
    
    return activeCombinations
end

-- Get the total effect of all equipped relics for a player
function RelicManager:GetTotalRelicEffect(playerData)
    if not playerData or not playerData.Relics then return {} end
    
    local totalEffect = {
        GlobalMultiplier = 0,
        CoinMultiplier = 0,
        DamageMultiplier = 0,
        SpeedMultiplier = 0
    }
    
    -- Get all equipped relics
    local equippedRelics = {}
    for _, relic in ipairs(playerData.Relics) do
        if relic.Equipped then
            table.insert(equippedRelics, relic)
        end
    end
    
    -- Apply individual relic effects
    for _, relic in ipairs(equippedRelics) do
        local relicDefinition = self:GetRelicDefinition(relic.ID)
        if not relicDefinition then continue end
        
        if relic.Effect.Type == "GlobalMultiplier" then
            totalEffect.GlobalMultiplier = totalEffect.GlobalMultiplier + relic.Effect.Value
        elseif relic.Effect.Type == "CoinMultiplier" then
            totalEffect.CoinMultiplier = totalEffect.CoinMultiplier + relic.Effect.Value
        elseif relic.Effect.Type == "DamageMultiplier" then
            totalEffect.DamageMultiplier = totalEffect.DamageMultiplier + relic.Effect.Value
        elseif relic.Effect.Type == "SpeedMultiplier" then
            totalEffect.SpeedMultiplier = totalEffect.SpeedMultiplier + relic.Effect.Value
        end
    end
    
    -- Apply combination bonuses
    local activeCombinations = self:GetActiveRelicCombinations(playerData)
    for _, combination in ipairs(activeCombinations) do
        if combination.Bonus.Type == "GlobalMultiplier" then
            totalEffect.GlobalMultiplier = totalEffect.GlobalMultiplier + combination.Bonus.Value
        elseif combination.Bonus.Type == "CoinMultiplier" then
            totalEffect.CoinMultiplier = totalEffect.CoinMultiplier + combination.Bonus.Value
        elseif combination.Bonus.Type == "DamageMultiplier" then
            totalEffect.DamageMultiplier = totalEffect.DamageMultiplier + combination.Bonus.Value
        elseif combination.Bonus.Type == "SpeedMultiplier" then
            totalEffect.SpeedMultiplier = totalEffect.SpeedMultiplier + combination.Bonus.Value
        end
    end
    
    -- Round the effects for cleaner display
    totalEffect.GlobalMultiplier = Utilities.Round(totalEffect.GlobalMultiplier, 3)
    totalEffect.CoinMultiplier = Utilities.Round(totalEffect.CoinMultiplier, 3)
    totalEffect.DamageMultiplier = Utilities.Round(totalEffect.DamageMultiplier, 3)
    totalEffect.SpeedMultiplier = Utilities.Round(totalEffect.SpeedMultiplier, 3)
    
    return totalEffect
end

-- Format relic effect for display
function RelicManager:FormatRelicEffect(effect)
    if not effect then return "" end
    
    if effect.Type == "GlobalMultiplier" then
        return string.format("+%.1f%% to All Stats", effect.Value * 100)
    elseif effect.Type == "CoinMultiplier" then
        return string.format("+%.1f%% to Coins", effect.Value * 100)
    elseif effect.Type == "DamageMultiplier" then
        return string.format("+%.1f%% to Damage", effect.Value * 100)
    elseif effect.Type == "SpeedMultiplier" then
        return string.format("+%.1f%% to Speed", effect.Value * 100)
    else
        return ""
    end
end

return RelicManager

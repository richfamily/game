--[[
    DrawManager.lua
    Handles the draw system for pets, auras, and relics
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import modules
local Utilities = require(ReplicatedStorage.Modules.Utilities)

-- Import configurations
local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local AvatarConfig = require(ReplicatedStorage.Config.AvatarConfig)
local AuraConfig = require(ReplicatedStorage.Config.AuraConfig)
local RelicConfig = require(ReplicatedStorage.Config.RelicConfig)

local DrawManager = {}
DrawManager.__index = DrawManager

-- Create a new DrawManager instance
function DrawManager.new()
    local self = setmetatable({}, DrawManager)
    
    -- Initialize properties
    self.DrawTiers = {
        "Basic",
        "Premium",
        "Ultimate"
    }
    
    return self
end

-- Get the draw tier information
function DrawManager:GetDrawTierInfo(drawType, tier)
    if drawType == "Avatars" then
        local costs = GameConfig.DrawSettings.Coins
        if tier == "Basic" then
            return {
                Cost = costs.BasicDraw,
                CurrencyType = "Coins",
                RarityBoost = 0 -- No boost for basic
            }
        elseif tier == "Premium" then
            return {
                Cost = costs.PremiumDraw,
                CurrencyType = "Coins",
                RarityBoost = 0.1 -- 10% boost for premium
            }
        elseif tier == "Ultimate" then
            return {
                Cost = costs.UltimateDraw,
                CurrencyType = "Coins",
                RarityBoost = 0.25 -- 25% boost for ultimate
            }
        end
    elseif drawType == "Auras" then
        local costs = GameConfig.DrawSettings.Diamonds
        if tier == "Basic" then
            return {
                Cost = costs.BasicDraw,
                CurrencyType = "Diamonds",
                RarityBoost = 0 -- No boost for basic
            }
        elseif tier == "Premium" then
            return {
                Cost = costs.PremiumDraw,
                CurrencyType = "Diamonds",
                RarityBoost = 0.1 -- 10% boost for premium
            }
        elseif tier == "Ultimate" then
            return {
                Cost = costs.UltimateDraw,
                CurrencyType = "Diamonds",
                RarityBoost = 0.25 -- 25% boost for ultimate
            }
        end
    elseif drawType == "Relics" then
        local costs = GameConfig.DrawSettings.Rubies
        if tier == "Basic" then
            return {
                Cost = costs.BasicDraw,
                CurrencyType = "Rubies",
                RarityBoost = 0 -- No boost for basic
            }
        elseif tier == "Premium" then
            return {
                Cost = costs.PremiumDraw,
                CurrencyType = "Rubies",
                RarityBoost = 0.1 -- 10% boost for premium
            }
        elseif tier == "Ultimate" then
            return {
                Cost = costs.UltimateDraw,
                CurrencyType = "Rubies",
                RarityBoost = 0.25 -- 25% boost for ultimate
            }
        end
    end
    
    -- Default to basic pet draw if invalid
    return {
        Cost = GameConfig.DrawSettings.Coins.BasicDraw,
        CurrencyType = "Coins",
        RarityBoost = 0
    }
end

-- Perform an avatar draw
function DrawManager:PerformAvatarDraw(playerData, tier, zoneNumber, dataManager, player, avatarManager, currencyManager)
    if not playerData or not dataManager or not player or not avatarManager or not currencyManager then return false end
    
    -- Get draw tier info
    local tierInfo = self:GetDrawTierInfo("Avatars", tier)
    
    -- Check if the player has enough currency
    if not currencyManager:HasEnoughCurrency(playerData, tierInfo.CurrencyType, tierInfo.Cost) then
        return false, "Not enough " .. tierInfo.CurrencyType
    end
    
    -- Remove the currency
    if not currencyManager:RemoveCurrency(playerData, tierInfo.CurrencyType, tierInfo.Cost, dataManager, player) then
        return false, "Failed to remove currency"
    end
    
    -- Generate a random avatar with rarity boost
    local avatar = self:GenerateRandomAvatar(zoneNumber, tierInfo.RarityBoost, avatarManager)
    if not avatar then
        -- Refund the currency if avatar generation fails
        currencyManager:AddCurrency(playerData, tierInfo.CurrencyType, tierInfo.Cost, dataManager, player)
        return false, "Failed to generate avatar"
    end
    
    -- Add the avatar to the player's inventory
    dataManager:AddAvatar(player, avatar)
    
    return true, avatar
end

-- Perform an aura draw
function DrawManager:PerformAuraDraw(playerData, tier, zoneNumber, dataManager, player, petManager, currencyManager)
    if not playerData or not dataManager or not player or not petManager or not currencyManager then return false end
    
    -- Get draw tier info
    local tierInfo = self:GetDrawTierInfo("Auras", tier)
    
    -- Check if the player has enough currency
    if not currencyManager:HasEnoughCurrency(playerData, tierInfo.CurrencyType, tierInfo.Cost) then
        return false, "Not enough " .. tierInfo.CurrencyType
    end
    
    -- Remove the currency
    if not currencyManager:RemoveCurrency(playerData, tierInfo.CurrencyType, tierInfo.Cost, dataManager, player) then
        return false, "Failed to remove currency"
    end
    
    -- Generate a random aura with rarity boost
    local aura = self:GenerateRandomAura(zoneNumber, tierInfo.RarityBoost, petManager)
    if not aura then
        -- Refund the currency if aura generation fails
        currencyManager:AddCurrency(playerData, tierInfo.CurrencyType, tierInfo.Cost, dataManager, player)
        return false, "Failed to generate aura"
    end
    
    -- Add the aura to the player's inventory
    dataManager:AddAura(player, aura)
    
    return true, aura
end

-- Perform a relic draw
function DrawManager:PerformRelicDraw(playerData, tier, zoneNumber, dataManager, player, relicManager, currencyManager)
    if not playerData or not dataManager or not player or not relicManager or not currencyManager then return false end
    
    -- Get draw tier info
    local tierInfo = self:GetDrawTierInfo("Relics", tier)
    
    -- Check if the player has enough currency
    if not currencyManager:HasEnoughCurrency(playerData, tierInfo.CurrencyType, tierInfo.Cost) then
        return false, "Not enough " .. tierInfo.CurrencyType
    end
    
    -- Remove the currency
    if not currencyManager:RemoveCurrency(playerData, tierInfo.CurrencyType, tierInfo.Cost, dataManager, player) then
        return false, "Failed to remove currency"
    end
    
    -- Generate a random relic with rarity boost
    local relic = self:GenerateRandomRelic(zoneNumber, tierInfo.RarityBoost, relicManager)
    if not relic then
        -- Refund the currency if relic generation fails
        currencyManager:AddCurrency(playerData, tierInfo.CurrencyType, tierInfo.Cost, dataManager, player)
        return false, "Failed to generate relic"
    end
    
    -- Add the relic to the player's inventory
    dataManager:AddRelic(player, relic)
    
    return true, relic
end

-- Generate a random avatar with rarity boost
function DrawManager:GenerateRandomAvatar(zoneNumber, rarityBoost, avatarManager)
    -- Get avatars available for this zone
    local availableAvatars = avatarManager:GetAvatarsForZone(zoneNumber)
    
    if #availableAvatars == 0 then
        warn("No avatars available for zone: " .. zoneNumber)
        return nil
    end
    
    -- Select a random avatar
    local selectedAvatar = Utilities.GetRandomElement(availableAvatars)
    
    -- Determine rarity based on chances with boost
    local rarities = {}
    for _, rarity in ipairs(AvatarConfig.Rarities) do
        if Utilities.TableContains(selectedAvatar.AvailableRarities, rarity.Name) then
            -- Apply rarity boost
            local boostedChance = rarity.Chance * (1 + rarityBoost)
            table.insert(rarities, {name = rarity.Name, chance = boostedChance})
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
    
    -- Create the avatar
    return avatarManager:CreateAvatar(
        selectedAvatar.ID,
        selectedRarity,
        1, -- Level
        0, -- Experience
        false, -- Equipped
        false, -- Locked
        nil, -- EquippedAura
        "Normal" -- Variant
    )
end

-- Generate a random aura with rarity boost
function DrawManager:GenerateRandomAura(zoneNumber, rarityBoost, petManager)
    -- Get auras available for this zone
    local availableAuras = petManager:GetAurasForZone(zoneNumber)
    
    if #availableAuras == 0 then
        warn("No auras available for zone: " .. zoneNumber)
        return nil
    end
    
    -- Select a random aura
    local selectedAura = Utilities.GetRandomElement(availableAuras)
    
    -- Determine rarity based on chances with boost
    local rarities = {}
    for _, rarity in ipairs(AuraConfig.Rarities) do
        if Utilities.TableContains(selectedAura.AvailableRarities, rarity.Name) then
            -- Apply rarity boost
            local boostedChance = rarity.Chance * (1 + rarityBoost)
            table.insert(rarities, {name = rarity.Name, chance = boostedChance})
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
    
    -- Create the aura
    return petManager:CreateAura(
        selectedAura.ID,
        selectedRarity,
        1, -- Level
        0 -- Experience
    )
end

-- Generate a random relic with rarity boost
function DrawManager:GenerateRandomRelic(zoneNumber, rarityBoost, relicManager)
    -- Get relics available for this zone
    local availableRelics = relicManager:GetRelicsForZone(zoneNumber)
    
    if #availableRelics == 0 then
        warn("No relics available for zone: " .. zoneNumber)
        return nil
    end
    
    -- Select a random relic
    local selectedRelic = Utilities.GetRandomElement(availableRelics)
    
    -- Determine rarity based on chances with boost
    local rarities = {}
    for _, rarity in ipairs(RelicConfig.Rarities) do
        if Utilities.TableContains(selectedRelic.AvailableRarities, rarity.Name) then
            -- Apply rarity boost
            local boostedChance = rarity.Chance * (1 + rarityBoost)
            table.insert(rarities, {name = rarity.Name, chance = boostedChance})
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
    return relicManager:CreateRelic(
        selectedRelic.ID,
        selectedRarity,
        1, -- Level
        0 -- Experience
    )
end

-- Perform a multi-draw (draw multiple items at once)
function DrawManager:PerformMultiDraw(playerData, drawType, tier, count, zoneNumber, dataManager, player, petManager, relicManager, currencyManager)
    if not playerData or not dataManager or not player or not currencyManager then return false end
    
    -- Get draw tier info
    local tierInfo = self:GetDrawTierInfo(drawType, tier)
    
    -- Calculate total cost
    local totalCost = tierInfo.Cost * count
    
    -- Check if the player has enough currency
    if not currencyManager:HasEnoughCurrency(playerData, tierInfo.CurrencyType, totalCost) then
        return false, "Not enough " .. tierInfo.CurrencyType
    end
    
    -- Remove the currency
    if not currencyManager:RemoveCurrency(playerData, tierInfo.CurrencyType, totalCost, dataManager, player) then
        return false, "Failed to remove currency"
    end
    
    -- Perform the draws
    local results = {}
    local success = true
    
    for i = 1, count do
        local drawSuccess, result
        
        if drawType == "Avatars" then
            drawSuccess, result = self:PerformAvatarDraw(playerData, tier, zoneNumber, dataManager, player, petManager, currencyManager)
        elseif drawType == "Auras" then
            drawSuccess, result = self:PerformAuraDraw(playerData, tier, zoneNumber, dataManager, player, petManager, currencyManager)
        elseif drawType == "Relics" then
            drawSuccess, result = self:PerformRelicDraw(playerData, tier, zoneNumber, dataManager, player, relicManager, currencyManager)
        end
        
        if drawSuccess then
            table.insert(results, result)
        else
            success = false
            break
        end
    end
    
    -- If any draw failed, refund the remaining draws
    if not success then
        local refundAmount = tierInfo.Cost * (count - #results)
        currencyManager:AddCurrency(playerData, tierInfo.CurrencyType, refundAmount, dataManager, player)
    end
    
    return success, results
end

-- Get the draw animation information
function DrawManager:GetDrawAnimation(drawType, tier)
    local animations = {
        Avatars = {
            Basic = {
                Duration = 2,
                ParticleEffect = "BASIC_AVATAR_PARTICLES",
                Sound = "BASIC_AVATAR_SOUND"
            },
            Premium = {
                Duration = 3,
                ParticleEffect = "PREMIUM_AVATAR_PARTICLES",
                Sound = "PREMIUM_AVATAR_SOUND"
            },
            Ultimate = {
                Duration = 4,
                ParticleEffect = "ULTIMATE_AVATAR_PARTICLES",
                Sound = "ULTIMATE_AVATAR_SOUND"
            }
        },
        Auras = {
            Basic = {
                Duration = 2,
                ParticleEffect = "BASIC_AURA_PARTICLES",
                Sound = "BASIC_AURA_SOUND"
            },
            Premium = {
                Duration = 3,
                ParticleEffect = "PREMIUM_AURA_PARTICLES",
                Sound = "PREMIUM_AURA_SOUND"
            },
            Ultimate = {
                Duration = 4,
                ParticleEffect = "ULTIMATE_AURA_PARTICLES",
                Sound = "ULTIMATE_AURA_SOUND"
            }
        },
        Relics = {
            Basic = {
                Duration = 2,
                ParticleEffect = "BASIC_RELIC_PARTICLES",
                Sound = "BASIC_RELIC_SOUND"
            },
            Premium = {
                Duration = 3,
                ParticleEffect = "PREMIUM_RELIC_PARTICLES",
                Sound = "PREMIUM_RELIC_SOUND"
            },
            Ultimate = {
                Duration = 4,
                ParticleEffect = "ULTIMATE_RELIC_PARTICLES",
                Sound = "ULTIMATE_RELIC_SOUND"
            }
        }
    }
    
    return animations[drawType] and animations[drawType][tier] or animations.Avatars.Basic
end

-- Get the draw chances display information
function DrawManager:GetDrawChancesDisplay(drawType, tier, zoneNumber)
    local chances = {
        Common = 0,
        Uncommon = 0,
        Rare = 0,
        Epic = 0,
        Legendary = 0,
        Mythical = 0
    }
    
    -- Get the rarity boost for the tier
    local tierInfo = self:GetDrawTierInfo(drawType, tier)
    local rarityBoost = tierInfo.RarityBoost
    
    -- Calculate the chances based on the draw type
    if drawType == "Avatars" then
        for _, rarity in ipairs(AvatarConfig.Rarities) do
            chances[rarity.Name] = rarity.Chance * (1 + rarityBoost)
        end
    elseif drawType == "Auras" then
        for _, rarity in ipairs(AuraConfig.Rarities) do
            chances[rarity.Name] = rarity.Chance * (1 + rarityBoost)
        end
    elseif drawType == "Relics" then
        for _, rarity in ipairs(RelicConfig.Rarities) do
            chances[rarity.Name] = rarity.Chance * (1 + rarityBoost)
        end
    end
    
    -- Format the chances for display
    local display = {}
    for rarity, chance in pairs(chances) do
        if chance > 0 then
            table.insert(display, {
                Rarity = rarity,
                Chance = chance,
                DisplayChance = string.format("%.2f%%", chance * 100),
                Color = Utilities.GetRarityColor(rarity)
            })
        end
    end
    
    -- Sort by chance (descending)
    table.sort(display, function(a, b) return a.Chance > b.Chance end)
    
    return display
end

return DrawManager

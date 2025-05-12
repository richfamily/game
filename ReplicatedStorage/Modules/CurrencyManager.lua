--[[
    CurrencyManager.lua
    Handles currency-related functionality such as earning, spending, and managing different types of currencies
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import modules
local Utilities = require(ReplicatedStorage.Modules.Utilities)

-- Import configurations
local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local AvatarConfig = require(ReplicatedStorage.Config.AvatarConfig)

local CurrencyManager = {}
CurrencyManager.__index = CurrencyManager

-- Create a new CurrencyManager instance
function CurrencyManager.new()
    local self = setmetatable({}, CurrencyManager)
    
    -- Initialize properties
    self.CurrencyTypes = GameConfig.CurrencyTypes
    
    return self
end

-- Get the current amount of a currency for a player
function CurrencyManager:GetCurrency(playerData, currencyType)
    if not playerData then return 0 end
    
    -- Validate currency type
    if not Utilities.TableContains(self.CurrencyTypes, currencyType) then
        warn("Invalid currency type: " .. currencyType)
        return 0
    end
    
    return playerData[currencyType] or 0
end

-- Add currency to a player
function CurrencyManager:AddCurrency(playerData, currencyType, amount, dataManager, player)
    if not playerData or not dataManager or not player then return false end
    
    -- Validate currency type
    if not Utilities.TableContains(self.CurrencyTypes, currencyType) then
        warn("Invalid currency type: " .. currencyType)
        return false
    end
    
    -- Get current amount
    local currentAmount = self:GetCurrency(playerData, currencyType)
    
    -- Add the currency
    local newAmount = currentAmount + amount
    dataManager:UpdateData(player, currencyType, newAmount)
    
    -- Update stats
    if currencyType == "Coins" then
        dataManager:IncrementData(player, "Stats.TotalCoinsEarned", amount)
    elseif currencyType == "Diamonds" then
        dataManager:IncrementData(player, "Stats.TotalDiamondsEarned", amount)
    elseif currencyType == "Rubies" then
        dataManager:IncrementData(player, "Stats.TotalRubiesEarned", amount)
    end
    
    return true
end

-- Remove currency from a player
function CurrencyManager:RemoveCurrency(playerData, currencyType, amount, dataManager, player)
    if not playerData or not dataManager or not player then return false end
    
    -- Validate currency type
    if not Utilities.TableContains(self.CurrencyTypes, currencyType) then
        warn("Invalid currency type: " .. currencyType)
        return false
    end
    
    -- Get current amount
    local currentAmount = self:GetCurrency(playerData, currencyType)
    
    -- Check if the player has enough currency
    if currentAmount < amount then
        return false
    end
    
    -- Remove the currency
    local newAmount = currentAmount - amount
    dataManager:UpdateData(player, currencyType, newAmount)
    
    return true
end

-- Check if a player has enough currency
function CurrencyManager:HasEnoughCurrency(playerData, currencyType, amount)
    if not playerData then return false end
    
    -- Validate currency type
    if not Utilities.TableContains(self.CurrencyTypes, currencyType) then
        warn("Invalid currency type: " .. currencyType)
        return false
    end
    
    -- Get current amount
    local currentAmount = self:GetCurrency(playerData, currencyType)
    
    -- Check if the player has enough currency
    return currentAmount >= amount
end

-- Award currency for defeating an enemy
function CurrencyManager:AwardEnemyDefeatCurrency(playerData, enemyStats, dataManager, player)
    if not playerData or not enemyStats or not dataManager or not player then return false end
    
    -- Get the coin reward
    local coinReward = enemyStats.Coins
    
    -- Apply player multipliers
    local coinMultiplier = playerData.Multipliers.Coins or 1
    coinReward = coinReward * coinMultiplier
    
    -- Add the coins
    self:AddCurrency(playerData, "Coins", coinReward, dataManager, player)
    
    -- Add diamonds (10% of coins earned)
    local diamondReward = math.floor(coinReward * 0.1)
    if diamondReward > 0 then
        self:AddCurrency(playerData, "Diamonds", diamondReward, dataManager, player)
    end
    
    -- Update stats
    dataManager:IncrementData(player, "Stats.EnemiesDefeated", 1)
    
    return true
end

-- Award currency for defeating a boss
function CurrencyManager:AwardBossDefeatCurrency(playerData, bossStats, dataManager, player)
    if not playerData or not bossStats or not dataManager or not player then return false end
    
    -- Get the coin reward
    local coinReward = bossStats.Coins
    
    -- Apply player multipliers
    local coinMultiplier = playerData.Multipliers.Coins or 1
    coinReward = coinReward * coinMultiplier
    
    -- Add the coins
    self:AddCurrency(playerData, "Coins", coinReward, dataManager, player)
    
    -- Add diamonds (10% of coins earned)
    local diamondReward = math.floor(coinReward * 0.1)
    if diamondReward > 0 then
        self:AddCurrency(playerData, "Diamonds", diamondReward, dataManager, player)
    end
    
    -- Add rubies (10% of diamonds earned, only from bosses)
    local rubyReward = math.floor(diamondReward * 0.1)
    if rubyReward > 0 then
        self:AddCurrency(playerData, "Rubies", rubyReward, dataManager, player)
    end
    
    -- Update stats
    dataManager:IncrementData(player, "Stats.BossesDefeated", 1)
    
    return true
end

-- Calculate the cost of a gear draw
function CurrencyManager:CalculateGearDrawCost(drawType, tier)
    local costs = GameConfig.DrawSettings.Coins
    
    if tier == "Basic" then
        return costs.BasicDraw
    elseif tier == "Premium" then
        return costs.PremiumDraw
    elseif tier == "Ultimate" then
        return costs.UltimateDraw
    else
        return costs.BasicDraw -- Default to basic
    end
end

-- Calculate the cost of an aura draw
function CurrencyManager:CalculateAuraDrawCost(tier)
    local costs = GameConfig.DrawSettings.Diamonds
    
    if tier == "Basic" then
        return costs.BasicDraw
    elseif tier == "Premium" then
        return costs.PremiumDraw
    elseif tier == "Ultimate" then
        return costs.UltimateDraw
    else
        return costs.BasicDraw -- Default to basic
    end
end

-- Calculate the cost of a relic draw
function CurrencyManager:CalculateRelicDrawCost(tier)
    local costs = GameConfig.DrawSettings.Rubies
    
    if tier == "Basic" then
        return costs.BasicDraw
    elseif tier == "Premium" then
        return costs.PremiumDraw
    elseif tier == "Ultimate" then
        return costs.UltimateDraw
    else
        return costs.BasicDraw -- Default to basic
    end
end

-- Perform a gear draw
function CurrencyManager:PerformGearDraw(playerData, tier, zoneNumber, dataManager, player, gearManager)
    if not playerData or not dataManager or not player or not gearManager then return false end
    
    -- Calculate the cost
    local cost = self:CalculateGearDrawCost("Coins", tier)
    
    -- Check if the player has enough currency
    if not self:HasEnoughCurrency(playerData, "Coins", cost) then
        return false
    end
    
    -- Remove the currency
    if not self:RemoveCurrency(playerData, "Coins", cost, dataManager, player) then
        return false
    end
    
    -- Get gear available for this zone
    local availableGear = gearManager:GetGearForZone(zoneNumber)
    if #availableGear == 0 then
        -- Refund the currency if no gear is available
        self:AddCurrency(playerData, "Coins", cost, dataManager, player)
        return false
    end
    
    -- Select a random gear
    local selectedGear = Utilities.GetRandomElement(availableGear)
    
    -- Determine rarity based on tier
    local rarityBoost = 0
    if tier == "Premium" then
        rarityBoost = 0.1 -- 10% boost for premium
    elseif tier == "Ultimate" then
        rarityBoost = 0.25 -- 25% boost for ultimate
    end
    
    -- Apply draw luck boost from rebirth rewards
    if playerData.Boosts and playerData.Boosts.DrawLuck then
        rarityBoost = rarityBoost + playerData.Boosts.DrawLuck
    end
    
    -- Determine rarity
    local rarities = {}
    for _, rarity in ipairs(selectedGear.AvailableRarities) do
        for _, rarityDef in ipairs(GearConfig.Rarities) do
            if rarityDef.Name == rarity then
                -- Apply rarity boost
                local boostedChance = rarityDef.Chance * (1 + rarityBoost)
                table.insert(rarities, {name = rarity, chance = boostedChance})
                break
            end
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
    
    -- Create the gear
    local gear = gearManager:CreateGear(
        selectedGear.ID,
        selectedRarity,
        0, -- Enhancement level
        false, -- Not equipped
        nil -- Not equipped on any avatar
    )
    
    if not gear then
        -- Refund the currency if gear creation fails
        self:AddCurrency(playerData, "Coins", cost, dataManager, player)
        return false
    end
    
    -- Add the gear to the player's inventory
    if not playerData.Gear then
        playerData.Gear = {}
    end
    table.insert(playerData.Gear, gear)
    
    -- Save the player's data
    dataManager:SaveData(player)
    
    return gear
end

-- Perform an aura draw
function CurrencyManager:PerformAuraDraw(playerData, tier, zoneNumber, dataManager, player, avatarManager)
    if not playerData or not dataManager or not player or not avatarManager then return false end
    
    -- Calculate the cost
    local cost = self:CalculateAuraDrawCost(tier)
    
    -- Check if the player has enough currency
    if not self:HasEnoughCurrency(playerData, "Diamonds", cost) then
        return false
    end
    
    -- Remove the currency
    if not self:RemoveCurrency(playerData, "Diamonds", cost, dataManager, player) then
        return false
    end
    
    -- Generate a random aura
    local aura = avatarManager:GenerateRandomAura(zoneNumber)
    if not aura then
        -- Refund the currency if aura generation fails
        self:AddCurrency(playerData, "Diamonds", cost, dataManager, player)
        return false
    end
    
    -- Add the aura to the player's inventory
    dataManager:AddAura(player, aura)
    
    return aura
end

-- Perform a relic draw
function CurrencyManager:PerformRelicDraw(playerData, tier, zoneNumber, dataManager, player, relicManager)
    if not playerData or not dataManager or not player or not relicManager then return false end
    
    -- Calculate the cost
    local cost = self:CalculateRelicDrawCost(tier)
    
    -- Check if the player has enough currency
    if not self:HasEnoughCurrency(playerData, "Rubies", cost) then
        return false
    end
    
    -- Remove the currency
    if not self:RemoveCurrency(playerData, "Rubies", cost, dataManager, player) then
        return false
    end
    
    -- Generate a random relic
    local relic = relicManager:GenerateRandomRelic(zoneNumber)
    if not relic then
        -- Refund the currency if relic generation fails
        self:AddCurrency(playerData, "Rubies", cost, dataManager, player)
        return false
    end
    
    -- Add the relic to the player's inventory
    dataManager:AddRelic(player, relic)
    
    return relic
end

-- Calculate the cost to unlock a zone
function CurrencyManager:CalculateZoneUnlockCost(zoneNumber, zoneManager)
    if not zoneManager then return 0 end
    
    return zoneManager:CalculateUnlockCost(zoneNumber)
end

-- Unlock a zone for a player
function CurrencyManager:UnlockZone(playerData, zoneNumber, dataManager, player, zoneManager)
    if not playerData or not dataManager or not player or not zoneManager then return false end
    
    -- Calculate the cost
    local cost = self:CalculateZoneUnlockCost(zoneNumber, zoneManager)
    
    -- Check if the player has enough currency
    if not self:HasEnoughCurrency(playerData, "Coins", cost) then
        return false
    end
    
    -- Unlock the zone (this will also deduct the cost)
    return zoneManager:UnlockZone(playerData, zoneNumber, dataManager, player)
end

-- Calculate the cost to perform a rebirth
function CurrencyManager:CalculateRebirthCost(playerData, zoneManager)
    if not playerData or not zoneManager then return 0 end
    
    return zoneManager:CalculateRebirthCost(playerData.RebirthLevel or 0)
end

-- Get the next rebirth reward based on the player's rebirth level
function CurrencyManager:GetNextRebirthReward(rebirthLevel)
    -- Get the reward cycle
    local rewardCycle = AvatarConfig.RebirthRewards.RewardCycle
    
    -- Calculate the index in the cycle
    local cycleIndex = (rebirthLevel % #rewardCycle) + 1
    
    -- Get the reward
    local reward = rewardCycle[cycleIndex]
    
    -- If the reward is a new avatar, determine which avatar based on the rebirth level
    if reward.Type == "NewAvatar" then
        -- Find the appropriate rebirth avatar
        local rebirthAvatars = AvatarConfig.RebirthRewards.RebirthAvatars
        local selectedAvatar = nil
        
        -- Sort avatars by unlock level (descending)
        table.sort(rebirthAvatars, function(a, b) 
            return a.UnlockRebirthLevel > b.UnlockRebirthLevel 
        end)
        
        -- Find the highest avatar the player can unlock
        for _, avatar in ipairs(rebirthAvatars) do
            if rebirthLevel >= avatar.UnlockRebirthLevel then
                selectedAvatar = avatar
                break
            end
        end
        
        -- If no avatar is found, use the first one
        if not selectedAvatar and #rebirthAvatars > 0 then
            selectedAvatar = rebirthAvatars[#rebirthAvatars]
        end
        
        if selectedAvatar then
            return {
                Type = "NewAvatar",
                AvatarID = selectedAvatar.ID,
                Description = "New Avatar: " .. selectedAvatar.Name
            }
        end
    end
    
    return reward
end

-- Apply rebirth reward to player
function CurrencyManager:ApplyRebirthReward(playerData, reward, dataManager, player, avatarManager)
    if not playerData or not reward or not dataManager or not player then return false end
    
    if reward.Type == "AttackBoost" then
        -- Apply attack boost
        if not playerData.Boosts then
            playerData.Boosts = {}
        end
        
        if not playerData.Boosts.Attack then
            playerData.Boosts.Attack = 0
        end
        
        playerData.Boosts.Attack = playerData.Boosts.Attack + reward.Value
        dataManager:UpdateData(player, "Boosts.Attack", playerData.Boosts.Attack)
        
        return true, "Attack boost increased by " .. (reward.Value * 100) .. "%"
    elseif reward.Type == "DrawLuckBoost" then
        -- Apply draw luck boost
        if not playerData.Boosts then
            playerData.Boosts = {}
        end
        
        if not playerData.Boosts.DrawLuck then
            playerData.Boosts.DrawLuck = 0
        end
        
        playerData.Boosts.DrawLuck = playerData.Boosts.DrawLuck + reward.Value
        dataManager:UpdateData(player, "Boosts.DrawLuck", playerData.Boosts.DrawLuck)
        
        return true, "Draw luck increased by " .. (reward.Value * 100) .. "%"
    elseif reward.Type == "NewAvatar" and reward.AvatarID and avatarManager then
        -- Add new avatar to player
        local avatarDef = nil
        
        -- Find the avatar definition
        for _, avatar in ipairs(AvatarConfig.RebirthRewards.RebirthAvatars) do
            if avatar.ID == reward.AvatarID then
                avatarDef = avatar
                break
            end
        end
        
        if not avatarDef then
            return false, "Avatar definition not found"
        end
        
        -- Check if player already has this avatar
        local hasAvatar = false
        if playerData.Avatars then
            for _, avatar in ipairs(playerData.Avatars) do
                if avatar.ID == reward.AvatarID then
                    hasAvatar = true
                    break
                end
            end
        end
        
        if hasAvatar then
            -- If player already has this avatar, give them a different reward
            return self:ApplyRebirthReward(playerData, {
                Type = "AttackBoost",
                Value = 0.1, -- 10% attack boost as compensation
                Description = "10% Attack Boost (Avatar already owned)"
            }, dataManager, player)
        end
        
        -- Create the avatar
        local avatar = avatarManager:CreateAvatar(
            avatarDef.ID,
            avatarDef.AvailableRarities[1], -- Use the first available rarity
            1, -- Level
            0, -- Experience
            false, -- Not equipped
            false, -- Not locked
            nil, -- No aura equipped
            "Normal" -- Normal variant
        )
        
        if not avatar then
            return false, "Failed to create avatar"
        end
        
        -- Add the avatar to the player's inventory
        dataManager:AddAvatar(player, avatar)
        
        return true, "Unlocked new avatar: " .. avatarDef.Name
    end
    
    return false, "Invalid reward type"
end

-- Perform a rebirth for a player
function CurrencyManager:PerformRebirth(playerData, zoneNumber, dataManager, player, zoneManager, avatarManager)
    if not playerData or not dataManager or not player or not zoneManager then return false end
    
    -- Check if the player is at the rebirth statue
    local isAtRebirthStatue = zoneManager:IsPlayerAtRebirthStatue(player, zoneNumber)
    if not isAtRebirthStatue then
        return false, "Player is not at the rebirth statue"
    end
    
    -- Calculate rebirth rewards
    local rebirthLevel = playerData.RebirthLevel or 0
    local newRebirthLevel = rebirthLevel + 1
    
    -- Get the next rebirth reward
    local reward = self:GetNextRebirthReward(newRebirthLevel)
    
    -- Reset player's progress
    playerData.Coins = GameConfig.StartingValues.Coins
    playerData.Diamonds = GameConfig.StartingValues.Diamonds
    playerData.Rubies = GameConfig.StartingValues.Rubies
    
    -- Keep only the first zone unlocked
    playerData.UnlockedZones = {1}
    
    -- Apply rebirth bonuses
    playerData.RebirthLevel = newRebirthLevel
    playerData.Multipliers.Coins = playerData.Multipliers.Coins + 0.1 -- 10% increase per rebirth
    playerData.Multipliers.Damage = playerData.Multipliers.Damage + 0.1 -- 10% increase per rebirth
    playerData.Multipliers.Speed = playerData.Multipliers.Speed + 0.05 -- 5% increase per rebirth
    
    -- Apply the specific rebirth reward
    local rewardSuccess, rewardMessage = self:ApplyRebirthReward(playerData, reward, dataManager, player, avatarManager)
    
    -- Save the player's data
    dataManager:SaveData(player)
    
    return true, {
        RebirthLevel = newRebirthLevel,
        Reward = reward,
        RewardMessage = rewardMessage
    }
end

-- Format currency for display
function CurrencyManager:FormatCurrency(amount)
    return Utilities.FormatNumber(amount)
end

-- Get the currency icon for a currency type
function CurrencyManager:GetCurrencyIcon(currencyType)
    if currencyType == "Coins" then
        return "rbxassetid://0" -- Replace with actual coin icon asset ID
    elseif currencyType == "Diamonds" then
        return "rbxassetid://0" -- Replace with actual diamond icon asset ID
    elseif currencyType == "Rubies" then
        return "rbxassetid://0" -- Replace with actual ruby icon asset ID
    else
        return ""
    end
end

-- Get the currency color for a currency type
function CurrencyManager:GetCurrencyColor(currencyType)
    if currencyType == "Coins" then
        return Color3.fromRGB(255, 215, 0) -- Gold
    elseif currencyType == "Diamonds" then
        return Color3.fromRGB(0, 191, 255) -- Light blue
    elseif currencyType == "Rubies" then
        return Color3.fromRGB(220, 20, 60) -- Crimson
    else
        return Color3.fromRGB(255, 255, 255) -- White
    end
end

return CurrencyManager

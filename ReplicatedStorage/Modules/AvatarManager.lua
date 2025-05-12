--[[
    AvatarManager.lua
    Handles avatar-related functionality such as creating avatars, calculating avatar stats, and managing avatar interactions
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import modules
local Utilities = require(ReplicatedStorage.Modules.Utilities)

-- Import configurations
local AvatarConfig = require(ReplicatedStorage.Config.AvatarConfig)
local AuraConfig = require(ReplicatedStorage.Config.AuraConfig)
local GameConfig = require(ReplicatedStorage.Config.GameConfig)

local AvatarManager = {}
AvatarManager.__index = AvatarManager

-- Create a new AvatarManager instance
function AvatarManager.new()
    local self = setmetatable({}, AvatarManager)
    
    -- Initialize properties
    self.ActiveAvatars = {} -- Table to track active avatars in the game
    
    -- Create folder structure for avatar animations if it doesn't exist
    self:InitializeAnimationFolders()
    
    return self
end

-- Initialize folder structure for avatar animations and models
function AvatarManager:InitializeAnimationFolders()
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    if not assets then
        assets = Instance.new("Folder")
        assets.Name = "Assets"
        assets.Parent = ReplicatedStorage
    end
    
    -- Initialize animations folder structure
    local animations = assets:FindFirstChild("Animations")
    if not animations then
        animations = Instance.new("Folder")
        animations.Name = "Animations"
        animations.Parent = assets
    end
    
    local avatarAnimations = animations:FindFirstChild("AvatarAnimations")
    if not avatarAnimations then
        avatarAnimations = Instance.new("Folder")
        avatarAnimations.Name = "AvatarAnimations"
        avatarAnimations.Parent = animations
    end
    
    -- Create a default animation template if it doesn't exist
    local avatarAnimation = avatarAnimations:FindFirstChild("AvatarAnimation")
    if not avatarAnimation then
        avatarAnimation = Instance.new("Folder")
        avatarAnimation.Name = "AvatarAnimation"
        avatarAnimation.Parent = avatarAnimations
        
        -- Create animation controller
        local animController = Instance.new("AnimationController")
        animController.Name = "AnimationController"
        animController.Parent = avatarAnimation
        
        local animator = Instance.new("Animator")
        animator.Parent = animController
        
        -- Create avatar animation folder
        local avatarAnim = Instance.new("Folder")
        avatarAnim.Name = "Avatar"
        avatarAnim.Parent = avatarAnimation
        
        local avatarAnimFolder = Instance.new("Folder")
        avatarAnimFolder.Name = "Avatar Animation"
        avatarAnimFolder.Parent = avatarAnim
        
        -- Create idle animation
        local idleAnim = Instance.new("Animation")
        idleAnim.Name = "IdleAnimation"
        idleAnim.AnimationId = "rbxassetid://507766666" -- Default idle animation
        idleAnim.Parent = avatarAnimFolder
        
        -- Create action animation
        local actionAnim = Instance.new("Animation")
        actionAnim.Name = "ActionAnimation"
        actionAnim.AnimationId = "rbxassetid://507766951" -- Default action animation
        actionAnim.Parent = avatarAnimFolder
    end
    
    -- Initialize avatars folder structure
    local avatars = assets:FindFirstChild("Avatars")
    if not avatars then
        avatars = Instance.new("Folder")
        avatars.Name = "Avatars"
        avatars.Parent = assets
    end
    
    -- Create Normal variant folder
    local normalVariant = avatars:FindFirstChild("Normal")
    if not normalVariant then
        normalVariant = Instance.new("Folder")
        normalVariant.Name = "Normal"
        normalVariant.Parent = avatars
    end
    
    -- Create Golden variant folder
    local goldenVariant = avatars:FindFirstChild("Golden")
    if not goldenVariant then
        goldenVariant = Instance.new("Folder")
        goldenVariant.Name = "Golden"
        goldenVariant.Parent = avatars
    end
    
    print("Avatar folder structure initialized")
end

-- Get an avatar definition from the config
function AvatarManager:GetAvatarDefinition(avatarID)
    for _, avatar in ipairs(AvatarConfig.Avatars) do
        if avatar.ID == avatarID then
            return avatar
        end
    end
    return nil
end

-- Get a rarity definition from the config
function AvatarManager:GetRarityDefinition(rarityName)
    for _, rarity in ipairs(AvatarConfig.Rarities) do
        if rarity.Name == rarityName then
            return rarity
        end
    end
    return nil
end

-- Get an aura definition from the config
function AvatarManager:GetAuraDefinition(auraID)
    for _, aura in ipairs(AuraConfig.Auras) do
        if aura.ID == auraID then
            return aura
        end
    end
    return nil
end

-- Calculate avatar stats based on level, rarity, variant, and equipped aura
function AvatarManager:CalculateAvatarStats(avatarData)
    -- Get the base avatar definition
    local avatarDefinition = self:GetAvatarDefinition(avatarData.ID)
    if not avatarDefinition then
        warn("Avatar definition not found for ID: " .. avatarData.ID)
        return avatarData.Stats
    end
    
    -- Get the rarity multiplier
    local rarityDefinition = self:GetRarityDefinition(avatarData.Rarity)
    local rarityMultiplier = rarityDefinition and rarityDefinition.StatMultiplier or 1.0
    
    -- Get the variant multiplier (Normal or Golden)
    local variantName = avatarData.Variant or "Normal"
    local variantDefinition = AvatarConfig.Variants[variantName]
    local variantMultiplier = variantDefinition and variantDefinition.StatMultiplier or 1.0
    
    -- Calculate level multiplier
    local levelMultiplier = 1 + ((avatarData.Level - 1) * AvatarConfig.LevelingSystem.StatIncrease.Damage)
    local speedLevelMultiplier = 1 + ((avatarData.Level - 1) * AvatarConfig.LevelingSystem.StatIncrease.Speed)
    local coinsLevelMultiplier = 1 + ((avatarData.Level - 1) * AvatarConfig.LevelingSystem.StatIncrease.CoinsMultiplier)
    
    -- Calculate base stats with rarity, variant, and level
    local stats = {
        Damage = avatarDefinition.BaseDamage * rarityMultiplier * variantMultiplier * levelMultiplier,
        Speed = avatarDefinition.BaseSpeed * rarityMultiplier * variantMultiplier * speedLevelMultiplier,
        CoinsMultiplier = avatarDefinition.BaseCoinsMultiplier * rarityMultiplier * variantMultiplier * coinsLevelMultiplier
    }
    
    -- Apply aura effects if equipped
    if avatarData.EquippedAura then
        local auraDefinition = self:GetAuraDefinition(avatarData.EquippedAura.ID)
        if auraDefinition then
            local auraRarityDefinition = self:GetAuraRarityDefinition(avatarData.EquippedAura.Rarity)
            local auraEffectMultiplier = auraRarityDefinition and auraRarityDefinition.EffectMultiplier or 1.0
            local auraLevelMultiplier = 1 + ((avatarData.EquippedAura.Level - 1) * AuraConfig.LevelingSystem.EffectIncrease)
            
            if auraDefinition.Effect.Type == "Damage" then
                stats.Damage = stats.Damage * (1 + (auraDefinition.Effect.Value * auraEffectMultiplier * auraLevelMultiplier))
            elseif auraDefinition.Effect.Type == "Speed" then
                stats.Speed = stats.Speed * (1 + (auraDefinition.Effect.Value * auraEffectMultiplier * auraLevelMultiplier))
            elseif auraDefinition.Effect.Type == "Coins" then
                stats.CoinsMultiplier = stats.CoinsMultiplier * (1 + (auraDefinition.Effect.Value * auraEffectMultiplier * auraLevelMultiplier))
            elseif auraDefinition.Effect.Type == "Multi" then
                if auraDefinition.Effect.Values.Damage then
                    stats.Damage = stats.Damage * (1 + (auraDefinition.Effect.Values.Damage * auraEffectMultiplier * auraLevelMultiplier))
                end
                if auraDefinition.Effect.Values.Speed then
                    stats.Speed = stats.Speed * (1 + (auraDefinition.Effect.Values.Speed * auraEffectMultiplier * auraLevelMultiplier))
                end
                if auraDefinition.Effect.Values.Coins then
                    stats.CoinsMultiplier = stats.CoinsMultiplier * (1 + (auraDefinition.Effect.Values.Coins * auraEffectMultiplier * auraLevelMultiplier))
                end
            end
        end
    end
    
    -- Round the stats for cleaner display
    stats.Damage = Utilities.Round(stats.Damage, 1)
    stats.Speed = Utilities.Round(stats.Speed, 1)
    stats.CoinsMultiplier = Utilities.Round(stats.CoinsMultiplier, 2)
    
    return stats
end

-- Get an aura rarity definition from the config
function AvatarManager:GetAuraRarityDefinition(rarityName)
    for _, rarity in ipairs(AuraConfig.Rarities) do
        if rarity.Name == rarityName then
            return rarity
        end
    end
    return nil
end

-- Create a new avatar instance
function AvatarManager:CreateAvatar(avatarID, rarity, level, experience, equipped, locked, equippedAura, variant)
    -- Get the avatar definition
    local avatarDefinition = self:GetAvatarDefinition(avatarID)
    if not avatarDefinition then
        warn("Avatar definition not found for ID: " .. avatarID)
        return nil
    end
    
    -- Create the avatar data
    local avatarData = {
        ID = avatarID,
        UUID = Utilities.CreateUniqueID("AVATAR"),
        Rarity = rarity or "Common",
        Level = level or 1,
        Experience = experience or 0,
        Equipped = equipped or false,
        Locked = locked or false,
        EquippedAura = equippedAura or nil,
        Variant = variant or "Normal", -- Default to Normal variant
        Stats = {} -- Will be calculated below
    }
    
    -- Calculate the avatar's stats
    avatarData.Stats = self:CalculateAvatarStats(avatarData)
    
    return avatarData
end

-- Create the starter avatar for a new player
function AvatarManager:CreateStarterAvatar()
    return self:CreateAvatar(
        "STARTER_AVATAR", -- ID
        "Common", -- Rarity
        1, -- Level
        0, -- Experience
        true, -- Equipped (automatically equipped for new players)
        false, -- Locked
        nil, -- EquippedAura
        "Normal" -- Variant
    )
end

-- Upgrade an avatar to golden variant
function AvatarManager:UpgradeAvatarToGolden(playerData, avatarUUID, dataManager, player, currencyManager)
    if not playerData or not playerData.Avatars then return false, "Invalid player data" end
    
    -- Find the avatar in the player's inventory
    local avatarToUpgrade = nil
    local avatarIndex = nil
    for i, avatar in ipairs(playerData.Avatars) do
        if avatar.UUID == avatarUUID then
            avatarToUpgrade = avatar
            avatarIndex = i
            break
        end
    end
    
    if not avatarToUpgrade then
        return false, "Avatar not found in player's inventory"
    end
    
    -- Check if avatar is already golden
    if avatarToUpgrade.Variant == "Golden" then
        return false, "Avatar is already golden"
    end
    
    -- Check if player has reached the required zone to unlock golden upgrades
    local highestZoneReached = playerData.Stats.HighestZoneReached or 0
    if highestZoneReached < AvatarConfig.GoldenUpgradeSystem.UnlockZone then
        return false, "Golden upgrades unlock at zone " .. AvatarConfig.GoldenUpgradeSystem.UnlockZone
    end
    
    -- Get the avatar definition
    local avatarDefinition = self:GetAvatarDefinition(avatarToUpgrade.ID)
    if not avatarDefinition then
        return false, "Avatar definition not found"
    end
    
    -- Calculate the upgrade cost based on the avatar's draw type and the golden upgrade cost multiplier
    local drawType = avatarDefinition.DrawType
    local drawTierInfo = nil
    
    if drawType == "Coins" then
        drawTierInfo = {
            Cost = GameConfig.DrawSettings.Coins.BasicDraw,
            CurrencyType = "Coins"
        }
    elseif drawType == "Diamonds" then
        drawTierInfo = {
            Cost = GameConfig.DrawSettings.Diamonds.BasicDraw,
            CurrencyType = "Diamonds"
        }
    elseif drawType == "Rubies" then
        drawTierInfo = {
            Cost = GameConfig.DrawSettings.Rubies.BasicDraw,
            CurrencyType = "Rubies"
        }
    else
        -- For avatars with no draw type (like starter avatar), use a default cost
        drawTierInfo = {
            Cost = 1000,
            CurrencyType = "Rubies"
        }
    end
    
    -- Override currency type to use Rubies as specified
    local upgradeCost = drawTierInfo.Cost * AvatarConfig.GoldenUpgradeSystem.CostMultiplier
    local currencyType = AvatarConfig.GoldenUpgradeSystem.CurrencyType
    
    -- Check if the player has enough currency
    if not currencyManager:HasEnoughCurrency(playerData, currencyType, upgradeCost) then
        return false, "Not enough " .. currencyType .. ". Need " .. upgradeCost
    end
    
    -- Remove the currency
    if not currencyManager:RemoveCurrency(playerData, currencyType, upgradeCost, dataManager, player) then
        return false, "Failed to remove currency"
    end
    
    -- Create a new golden avatar with the same properties as the original
    local goldenAvatar = self:CreateAvatar(
        avatarToUpgrade.ID,
        avatarToUpgrade.Rarity,
        avatarToUpgrade.Level,
        avatarToUpgrade.Experience,
        avatarToUpgrade.Equipped,
        avatarToUpgrade.Locked,
        avatarToUpgrade.EquippedAura,
        "Golden" -- Set variant to Golden
    )
    
    if not goldenAvatar then
        -- Refund the currency if avatar creation fails
        currencyManager:AddCurrency(playerData, currencyType, upgradeCost, dataManager, player)
        return false, "Failed to create golden avatar"
    end
    
    -- Replace the original avatar with the golden version
    playerData.Avatars[avatarIndex] = goldenAvatar
    
    return true, goldenAvatar
end

-- Calculate experience needed for next level
function AvatarManager:GetExperienceForNextLevel(currentLevel)
    return AvatarConfig.LevelingSystem.ExperiencePerLevel(currentLevel)
end

-- Add experience to an avatar
function AvatarManager:AddAvatarExperience(avatarData, experienceAmount)
    if not avatarData then return false end
    
    -- Add experience
    avatarData.Experience = avatarData.Experience + experienceAmount
    
    -- Check if avatar should level up
    local maxLevel = AvatarConfig.LevelingSystem.MaxLevel
    while avatarData.Level < maxLevel do
        local expForNextLevel = self:GetExperienceForNextLevel(avatarData.Level)
        if avatarData.Experience >= expForNextLevel then
            avatarData.Level = avatarData.Level + 1
            avatarData.Experience = avatarData.Experience - expForNextLevel
            
            -- Recalculate stats after leveling up
            avatarData.Stats = self:CalculateAvatarStats(avatarData)
        else
            break
        end
    end
    
    -- Cap experience at max level
    if avatarData.Level >= maxLevel then
        avatarData.Experience = 0
    end
    
    return true
end

-- Equip an avatar
function AvatarManager:EquipAvatar(playerData, avatarUUID)
    if not playerData or not playerData.Avatars then return false end
    
    -- Find the avatar in the player's inventory
    local avatarToEquip = nil
    for _, avatar in ipairs(playerData.Avatars) do
        if avatar.UUID == avatarUUID then
            avatarToEquip = avatar
            break
        end
    end
    
    if not avatarToEquip then
        warn("Avatar not found in player's inventory: " .. avatarUUID)
        return false
    end
    
    -- Count currently equipped avatars
    local equippedCount = 0
    for _, avatar in ipairs(playerData.Avatars) do
        if avatar.Equipped then
            equippedCount = equippedCount + 1
        end
    end
    
    -- Check if player has reached the equip limit
    if equippedCount >= AvatarConfig.EquipLimit and not avatarToEquip.Equipped then
        -- Unequip the first equipped avatar to make room for the new one
        for _, avatar in ipairs(playerData.Avatars) do
            if avatar.Equipped and avatar.UUID ~= avatarUUID then
                avatar.Equipped = false
                break
            end
        end
    end
    
    -- Equip the avatar
    avatarToEquip.Equipped = true
    
    return true
end

-- Unequip an avatar
function AvatarManager:UnequipAvatar(playerData, avatarUUID)
    if not playerData or not playerData.Avatars then return false end
    
    -- Find the avatar in the player's inventory
    local avatarToUnequip = nil
    for _, avatar in ipairs(playerData.Avatars) do
        if avatar.UUID == avatarUUID then
            avatarToUnequip = avatar
            break
        end
    end
    
    if not avatarToUnequip then
        warn("Avatar not found in player's inventory: " .. avatarUUID)
        return false
    end
    
    -- Count equipped avatars to ensure at least one remains equipped
    local equippedCount = 0
    for _, avatar in ipairs(playerData.Avatars) do
        if avatar.Equipped then
            equippedCount = equippedCount + 1
        end
    end
    
    -- Don't allow unequipping if this is the only equipped avatar
    if equippedCount <= 1 and avatarToUnequip.Equipped then
        warn("Cannot unequip the only equipped avatar")
        return false
    end
    
    -- Unequip the avatar
    avatarToUnequip.Equipped = false
    
    return true
end

-- Equip an aura on an avatar
function AvatarManager:EquipAura(playerData, avatarUUID, auraUUID)
    if not playerData or not playerData.Avatars or not playerData.Auras then return false end
    
    -- Find the avatar in the player's inventory
    local avatarToEquip = nil
    for _, avatar in ipairs(playerData.Avatars) do
        if avatar.UUID == avatarUUID then
            avatarToEquip = avatar
            break
        end
    end
    
    if not avatarToEquip then
        warn("Avatar not found in player's inventory: " .. avatarUUID)
        return false
    end
    
    -- Find the aura in the player's inventory
    local auraToEquip = nil
    for _, aura in ipairs(playerData.Auras) do
        if aura.UUID == auraUUID then
            auraToEquip = aura
            break
        end
    end
    
    if not auraToEquip then
        warn("Aura not found in player's inventory: " .. auraUUID)
        return false
    end
    
    -- Check if the aura is already equipped on another avatar
    for _, avatar in ipairs(playerData.Avatars) do
        if avatar.EquippedAura and avatar.EquippedAura.UUID == auraUUID and avatar.UUID ~= avatarUUID then
            warn("Aura is already equipped on another avatar")
            return false
        end
    end
    
    -- Equip the aura on the avatar
    avatarToEquip.EquippedAura = auraToEquip
    
    -- Recalculate avatar stats with the new aura
    avatarToEquip.Stats = self:CalculateAvatarStats(avatarToEquip)
    
    return true
end

-- Unequip an aura from an avatar
function AvatarManager:UnequipAura(playerData, avatarUUID)
    if not playerData or not playerData.Avatars then return false end
    
    -- Find the avatar in the player's inventory
    local avatarToUnequip = nil
    for _, avatar in ipairs(playerData.Avatars) do
        if avatar.UUID == avatarUUID then
            avatarToUnequip = avatar
            break
        end
    end
    
    if not avatarToUnequip then
        warn("Avatar not found in player's inventory: " .. avatarUUID)
        return false
    end
    
    -- Unequip the aura
    avatarToUnequip.EquippedAura = nil
    
    -- Recalculate avatar stats without the aura
    avatarToUnequip.Stats = self:CalculateAvatarStats(avatarToUnequip)
    
    return true
end

-- Fuse avatars to create a stronger avatar
function AvatarManager:FuseAvatars(playerData, avatarUUIDs)
    if not playerData or not playerData.Avatars then return false end
    
    -- Check if we have enough avatars to fuse
    if #avatarUUIDs < AvatarConfig.FusionSystem.RequiredAvatarsForFusion then
        warn("Not enough avatars to fuse. Required: " .. AvatarConfig.FusionSystem.RequiredAvatarsForFusion)
        return false
    end
    
    -- Find the avatars in the player's inventory
    local avatarsToFuse = {}
    for _, uuid in ipairs(avatarUUIDs) do
        for i, avatar in ipairs(playerData.Avatars) do
            if avatar.UUID == uuid then
                if avatar.Locked then
                    warn("Cannot fuse locked avatar: " .. uuid)
                    return false
                end
                table.insert(avatarsToFuse, {avatar = avatar, index = i})
                break
            end
        end
    end
    
    -- Check if we found all the avatars
    if #avatarsToFuse ~= #avatarUUIDs then
        warn("Not all avatars were found in player's inventory")
        return false
    end
    
    -- Determine the base avatar (first in the list)
    local baseAvatar = avatarsToFuse[1].avatar
    local baseAvatarDefinition = self:GetAvatarDefinition(baseAvatar.ID)
    
    -- Calculate the new avatar's properties
    local newLevel = math.min(baseAvatar.Level + 1, AvatarConfig.LevelingSystem.MaxLevel)
    local newExperience = 0
    
    -- Check if all avatars are the same type for bonus
    local allSameType = true
    for i = 2, #avatarsToFuse do
        if avatarsToFuse[i].avatar.ID ~= baseAvatar.ID then
            allSameType = false
            break
        end
    end
    
    -- Apply same type bonus if applicable
    local sameTypeBonus = allSameType and AvatarConfig.FusionSystem.SameTypeBonus or 0
    
    -- Determine if rarity should be upgraded
    local newRarity = baseAvatar.Rarity
    local rarityUpgradeChance = AvatarConfig.FusionSystem.RarityUpgradeChance[baseAvatar.Rarity] or 0
    
    -- Apply same type bonus to rarity upgrade chance
    rarityUpgradeChance = rarityUpgradeChance * (1 + sameTypeBonus)
    
    -- Roll for rarity upgrade
    if Utilities.CalculateChance(rarityUpgradeChance) then
        -- Find the next rarity level
        local rarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
        for i, rarity in ipairs(rarities) do
            if rarity == baseAvatar.Rarity and i < #rarities then
                newRarity = rarities[i + 1]
                break
            end
        end
    end
    
    -- Create the new fused avatar
    local fusedAvatar = self:CreateAvatar(
        baseAvatar.ID,
        newRarity,
        newLevel,
        newExperience,
        baseAvatar.Equipped,
        baseAvatar.Locked,
        baseAvatar.EquippedAura
    )
    
    -- Remove the avatars that were fused (in reverse order to avoid index issues)
    table.sort(avatarsToFuse, function(a, b) return a.index > b.index end)
    for _, avatarInfo in ipairs(avatarsToFuse) do
        table.remove(playerData.Avatars, avatarInfo.index)
    end
    
    -- Add the new fused avatar to the player's inventory
    table.insert(playerData.Avatars, fusedAvatar)
    
    return fusedAvatar
end

-- Get avatars available for a specific zone
function AvatarManager:GetAvatarsForZone(zoneNumber)
    local availableAvatars = {}
    
    for _, avatar in ipairs(AvatarConfig.Avatars) do
        if avatar.UnlockZone <= zoneNumber then
            table.insert(availableAvatars, avatar)
        end
    end
    
    return availableAvatars
end

-- Generate a random avatar for a specific zone
function AvatarManager:GenerateRandomAvatar(zoneNumber, drawType)
    -- Get avatars available for this zone
    local availableAvatars = self:GetAvatarsForZone(zoneNumber)
    
    -- Filter by draw type if specified
    if drawType then
        local filteredAvatars = {}
        for _, avatar in ipairs(availableAvatars) do
            if avatar.DrawType == drawType then
                table.insert(filteredAvatars, avatar)
            end
        end
        availableAvatars = filteredAvatars
    end
    
    if #availableAvatars == 0 then
        warn("No avatars available for zone: " .. zoneNumber)
        return nil
    end
    
    -- Select a random avatar
    local selectedAvatar = Utilities.GetRandomElement(availableAvatars)
    
    -- Determine rarity based on chances
    local rarities = {}
    for _, rarity in ipairs(AvatarConfig.Rarities) do
        if Utilities.TableContains(selectedAvatar.AvailableRarities, rarity.Name) then
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
    
    -- Create the avatar
    return self:CreateAvatar(
        selectedAvatar.ID,
        selectedRarity,
        1, -- Level
        0, -- Experience
        false, -- Equipped
        false, -- Locked
        nil -- EquippedAura
    )
end

-- Spawn an avatar in the game world
function AvatarManager:SpawnAvatarInWorld(avatarData, position, player)
    if not avatarData then return nil end
    
    -- Get the avatar definition
    local avatarDefinition = self:GetAvatarDefinition(avatarData.ID)
    if not avatarDefinition then
        warn("Avatar definition not found for ID: " .. avatarData.ID)
        return nil
    end
    
    -- Determine the model ID based on variant
    local variantName = avatarData.Variant or "Normal"
    local variantDefinition = AvatarConfig.Variants[variantName]
    local modelSuffix = variantDefinition and variantDefinition.ModelSuffix or "_MODEL"
    
    -- Get the base model ID without suffix
    local baseModelId = avatarDefinition.ModelID:gsub("_MODEL$", "")
    local fullModelId = baseModelId .. modelSuffix
    
    -- Find the model in ReplicatedStorage
    local avatarModel = ReplicatedStorage.Assets.Avatars[variantName]:FindFirstChild(fullModelId)
    if not avatarModel then
        warn("Avatar model not found: " .. fullModelId)
        return nil
    end
    
    -- Clone the model
    local model = avatarModel:Clone()
    model.Name = avatarData.ID .. "_" .. avatarData.UUID
    
    -- Set position
    if position then
        local primaryPart = model.PrimaryPart or model:FindFirstChild("RootPart")
        if primaryPart then
            model:SetPrimaryPartCFrame(CFrame.new(position))
        else
            model:MoveTo(position)
        end
    end
    
    -- Apply animations
    self:ApplyAnimationsToModel(model)
    
    -- Store reference to the avatar data
    model:SetAttribute("AvatarUUID", avatarData.UUID)
    
    -- Create a folder for avatars if it doesn't exist
    local avatarsFolder = workspace:FindFirstChild("Avatars")
    if not avatarsFolder then
        avatarsFolder = Instance.new("Folder")
        avatarsFolder.Name = "Avatars"
        avatarsFolder.Parent = workspace
    end
    
    -- Create a folder for the player's avatars if it doesn't exist
    local playerAvatarsFolder = nil
    if player then
        playerAvatarsFolder = avatarsFolder:FindFirstChild(player.Name)
        if not playerAvatarsFolder then
            playerAvatarsFolder = Instance.new("Folder")
            playerAvatarsFolder.Name = player.Name
            playerAvatarsFolder.Parent = avatarsFolder
        end
    end
    
    -- Parent the model
    model.Parent = playerAvatarsFolder or avatarsFolder
    
    -- Store in ActiveAvatars table
    self.ActiveAvatars[avatarData.UUID] = {
        Model = model,
        Data = avatarData,
        Player = player
    }
    
    -- Play idle animation by default
    self:PlayAvatarIdleAnimation(model)
    
    return model
end

-- Apply animations to an avatar model
function AvatarManager:ApplyAnimationsToModel(avatarModel)
    -- Get the animation template
    local animTemplate = ReplicatedStorage.Assets.Animations.AvatarAnimations.AvatarAnimation
    if not animTemplate then
        warn("Avatar animation template not found")
        return
    end
    
    -- Check if the avatar already has an AnimationController
    local existingController = avatarModel:FindFirstChildOfClass("AnimationController")
    if existingController then
        existingController:Destroy() -- Remove existing controller if present
    end
    
    -- Clone the AnimationController from the template
    local animController = animTemplate.AnimationController:Clone()
    animController.Parent = avatarModel
    
    -- Clone the animations
    local avatarAnim = animTemplate.Avatar["Avatar Animation"]
    local idleAnim = avatarAnim.IdleAnimation:Clone()
    local actionAnim = avatarAnim.ActionAnimation:Clone()
    
    -- Create an Animations folder in the avatar if it doesn't exist
    local animFolder = avatarModel:FindFirstChild("Animations")
    if not animFolder then
        animFolder = Instance.new("Folder")
        animFolder.Name = "Animations"
        animFolder.Parent = avatarModel
    end
    
    -- Add the animations to the avatar
    idleAnim.Parent = animFolder
    actionAnim.Parent = animFolder
end

-- Play the idle animation for an avatar
function AvatarManager:PlayAvatarIdleAnimation(avatarModel)
    local animator = avatarModel:FindFirstChild("AnimationController"):FindFirstChild("Animator")
    local animFolder = avatarModel:FindFirstChild("Animations")
    
    if animator and animFolder and animFolder:FindFirstChild("IdleAnimation") then
        -- Stop action animation if playing
        local actionTrack = avatarModel:GetAttribute("ActionAnimTrack")
        if actionTrack then
            actionTrack:Stop()
        end
        
        -- Play idle animation
        local idleTrack = avatarModel:GetAttribute("IdleAnimTrack")
        if not idleTrack then
            idleTrack = animator:LoadAnimation(animFolder.IdleAnimation)
            avatarModel:SetAttribute("IdleAnimTrack", idleTrack)
        end
        
        idleTrack:Play()
    end
end

-- Play the action animation for an avatar
function AvatarManager:PlayAvatarActionAnimation(avatarModel)
    local animator = avatarModel:FindFirstChild("AnimationController"):FindFirstChild("Animator")
    local animFolder = avatarModel:FindFirstChild("Animations")
    
    if animator and animFolder and animFolder:FindFirstChild("ActionAnimation") then
        -- Stop idle animation if playing
        local idleTrack = avatarModel:GetAttribute("IdleAnimTrack")
        if idleTrack then
            idleTrack:Stop()
        end
        
        -- Load and play action animation if not already loaded
        local actionTrack = avatarModel:GetAttribute("ActionAnimTrack")
        if not actionTrack then
            actionTrack = animator:LoadAnimation(animFolder.ActionAnimation)
            avatarModel:SetAttribute("ActionAnimTrack", actionTrack)
        end
        
        actionTrack:Play()
        
        -- Return to idle after animation completes
        task.delay(actionTrack.Length, function()
            self:PlayAvatarIdleAnimation(avatarModel)
        end)
    end
end

-- Despawn an avatar from the game world
function AvatarManager:DespawnAvatar(avatarUUID)
    local activeAvatar = self.ActiveAvatars[avatarUUID]
    if not activeAvatar then
        warn("Avatar not found in active avatars: " .. avatarUUID)
        return false
    end
    
    -- Remove the model
    if activeAvatar.Model and activeAvatar.Model.Parent then
        activeAvatar.Model:Destroy()
    end
    
    -- Remove from ActiveAvatars table
    self.ActiveAvatars[avatarUUID] = nil
    
    return true
end

-- Update avatar position
function AvatarManager:UpdateAvatarPosition(avatarUUID, position)
    local activeAvatar = self.ActiveAvatars[avatarUUID]
    if not activeAvatar or not activeAvatar.Model then
        return false
    end
    
    local primaryPart = activeAvatar.Model.PrimaryPart or activeAvatar.Model:FindFirstChild("RootPart")
    if primaryPart then
        activeAvatar.Model:SetPrimaryPartCFrame(CFrame.new(position))
    else
        activeAvatar.Model:MoveTo(position)
    end
    
    return true
end

-- Get all active avatars for a player
function AvatarManager:GetPlayerActiveAvatars(player)
    local playerAvatars = {}
    
    for uuid, avatarInfo in pairs(self.ActiveAvatars) do
        if avatarInfo.Player and avatarInfo.Player == player then
            table.insert(playerAvatars, {
                UUID = uuid,
                Model = avatarInfo.Model,
                Data = avatarInfo.Data
            })
        end
    end
    
    return playerAvatars
end

return AvatarManager

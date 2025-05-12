--[[
    PetManager.lua
    Handles pet-related functionality such as creating pets, calculating pet stats, and managing pet interactions
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import modules
local Utilities = require(ReplicatedStorage.Modules.Utilities)

-- Import configurations
local PetConfig = require(ReplicatedStorage.Config.PetConfig)
local AuraConfig = require(ReplicatedStorage.Config.AuraConfig)
local GameConfig = require(ReplicatedStorage.Config.GameConfig)

local PetManager = {}
PetManager.__index = PetManager

-- Create a new PetManager instance
function PetManager.new()
    local self = setmetatable({}, PetManager)
    
    -- Initialize properties
    self.ActivePets = {} -- Table to track active pets in the game
    
    -- Create folder structure for pet animations if it doesn't exist
    self:InitializeAnimationFolders()
    
    return self
end

-- Initialize folder structure for pet animations
function PetManager:InitializeAnimationFolders()
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    if not assets then
        assets = Instance.new("Folder")
        assets.Name = "Assets"
        assets.Parent = ReplicatedStorage
    end
    
    local animations = assets:FindFirstChild("Animations")
    if not animations then
        animations = Instance.new("Folder")
        animations.Name = "Animations"
        animations.Parent = assets
    end
    
    local petAnimations = animations:FindFirstChild("PetAnimations")
    if not petAnimations then
        petAnimations = Instance.new("Folder")
        petAnimations.Name = "PetAnimations"
        petAnimations.Parent = animations
    end
end

-- Get a pet definition from the config
function PetManager:GetPetDefinition(petID)
    for _, pet in ipairs(PetConfig.Pets) do
        if pet.ID == petID then
            return pet
        end
    end
    return nil
end

-- Get a rarity definition from the config
function PetManager:GetRarityDefinition(rarityName)
    for _, rarity in ipairs(PetConfig.Rarities) do
        if rarity.Name == rarityName then
            return rarity
        end
    end
    return nil
end

-- Get an aura definition from the config
function PetManager:GetAuraDefinition(auraID)
    for _, aura in ipairs(AuraConfig.Auras) do
        if aura.ID == auraID then
            return aura
        end
    end
    return nil
end

-- Calculate pet stats based on level, rarity, variant, and equipped aura
function PetManager:CalculatePetStats(petData)
    -- Get the base pet definition
    local petDefinition = self:GetPetDefinition(petData.ID)
    if not petDefinition then
        warn("Pet definition not found for ID: " .. petData.ID)
        return petData.Stats
    end
    
    -- Get the rarity multiplier
    local rarityDefinition = self:GetRarityDefinition(petData.Rarity)
    local rarityMultiplier = rarityDefinition and rarityDefinition.StatMultiplier or 1.0
    
    -- Get the variant multiplier (Normal or Golden)
    local variantName = petData.Variant or "Normal"
    local variantDefinition = PetConfig.Variants[variantName]
    local variantMultiplier = variantDefinition and variantDefinition.StatMultiplier or 1.0
    
    -- Calculate level multiplier
    local levelMultiplier = 1 + ((petData.Level - 1) * PetConfig.LevelingSystem.StatIncrease.Damage)
    local speedLevelMultiplier = 1 + ((petData.Level - 1) * PetConfig.LevelingSystem.StatIncrease.Speed)
    local coinsLevelMultiplier = 1 + ((petData.Level - 1) * PetConfig.LevelingSystem.StatIncrease.CoinsMultiplier)
    
    -- Calculate base stats with rarity, variant, and level
    local stats = {
        Damage = petDefinition.BaseDamage * rarityMultiplier * variantMultiplier * levelMultiplier,
        Speed = petDefinition.BaseSpeed * rarityMultiplier * variantMultiplier * speedLevelMultiplier,
        CoinsMultiplier = petDefinition.BaseCoinsMultiplier * rarityMultiplier * variantMultiplier * coinsLevelMultiplier
    }
    
    -- Apply aura effects if equipped
    if petData.EquippedAura then
        local auraDefinition = self:GetAuraDefinition(petData.EquippedAura.ID)
        if auraDefinition then
            local auraRarityDefinition = self:GetAuraRarityDefinition(petData.EquippedAura.Rarity)
            local auraEffectMultiplier = auraRarityDefinition and auraRarityDefinition.EffectMultiplier or 1.0
            local auraLevelMultiplier = 1 + ((petData.EquippedAura.Level - 1) * AuraConfig.LevelingSystem.EffectIncrease)
            
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
function PetManager:GetAuraRarityDefinition(rarityName)
    for _, rarity in ipairs(AuraConfig.Rarities) do
        if rarity.Name == rarityName then
            return rarity
        end
    end
    return nil
end

-- Create a new pet instance
function PetManager:CreatePet(petID, rarity, level, experience, equipped, locked, equippedAura, variant)
    -- Get the pet definition
    local petDefinition = self:GetPetDefinition(petID)
    if not petDefinition then
        warn("Pet definition not found for ID: " .. petID)
        return nil
    end
    
    -- Create the pet data
    local petData = {
        ID = petID,
        UUID = Utilities.CreateUniqueID("PET"),
        Rarity = rarity or "Common",
        Level = level or 1,
        Experience = experience or 0,
        Equipped = equipped or false,
        Locked = locked or false,
        EquippedAura = equippedAura or nil,
        Variant = variant or "Normal", -- Default to Normal variant
        Stats = {} -- Will be calculated below
    }
    
    -- Calculate the pet's stats
    petData.Stats = self:CalculatePetStats(petData)
    
    return petData
end

-- Upgrade a pet to golden variant
function PetManager:UpgradePetToGolden(playerData, petUUID, dataManager, player, currencyManager)
    if not playerData or not playerData.Pets then return false, "Invalid player data" end
    
    -- Find the pet in the player's inventory
    local petToUpgrade = nil
    local petIndex = nil
    for i, pet in ipairs(playerData.Pets) do
        if pet.UUID == petUUID then
            petToUpgrade = pet
            petIndex = i
            break
        end
    end
    
    if not petToUpgrade then
        return false, "Pet not found in player's inventory"
    end
    
    -- Check if pet is already golden
    if petToUpgrade.Variant == "Golden" then
        return false, "Pet is already golden"
    end
    
    -- Check if player has reached the required zone to unlock golden upgrades
    local highestZoneReached = playerData.Stats.HighestZoneReached or 0
    if highestZoneReached < PetConfig.GoldenUpgradeSystem.UnlockZone then
        return false, "Golden upgrades unlock at zone " .. PetConfig.GoldenUpgradeSystem.UnlockZone
    end
    
    -- Get the pet definition
    local petDefinition = self:GetPetDefinition(petToUpgrade.ID)
    if not petDefinition then
        return false, "Pet definition not found"
    end
    
    -- Calculate the upgrade cost based on the pet's draw type and the golden upgrade cost multiplier
    local drawType = petDefinition.DrawType
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
        return false, "Invalid draw type"
    end
    
    -- Override currency type to use Rubies as specified
    local upgradeCost = drawTierInfo.Cost * PetConfig.GoldenUpgradeSystem.CostMultiplier
    local currencyType = PetConfig.GoldenUpgradeSystem.CurrencyType
    
    -- Check if the player has enough currency
    if not currencyManager:HasEnoughCurrency(playerData, currencyType, upgradeCost) then
        return false, "Not enough " .. currencyType .. ". Need " .. upgradeCost
    end
    
    -- Remove the currency
    if not currencyManager:RemoveCurrency(playerData, currencyType, upgradeCost, dataManager, player) then
        return false, "Failed to remove currency"
    end
    
    -- Create a new golden pet with the same properties as the original
    local goldenPet = self:CreatePet(
        petToUpgrade.ID,
        petToUpgrade.Rarity,
        petToUpgrade.Level,
        petToUpgrade.Experience,
        petToUpgrade.Equipped,
        petToUpgrade.Locked,
        petToUpgrade.EquippedAura,
        "Golden" -- Set variant to Golden
    )
    
    if not goldenPet then
        -- Refund the currency if pet creation fails
        currencyManager:AddCurrency(playerData, currencyType, upgradeCost, dataManager, player)
        return false, "Failed to create golden pet"
    end
    
    -- Replace the original pet with the golden version
    playerData.Pets[petIndex] = goldenPet
    
    return true, goldenPet
end

-- Create a new aura instance
function PetManager:CreateAura(auraID, rarity, level, experience)
    -- Get the aura definition
    local auraDefinition = self:GetAuraDefinition(auraID)
    if not auraDefinition then
        warn("Aura definition not found for ID: " .. auraID)
        return nil
    end
    
    -- Create the aura data
    local auraData = {
        ID = auraID,
        UUID = Utilities.CreateUniqueID("AURA"),
        Rarity = rarity or "Common",
        Level = level or 1,
        Experience = experience or 0
    }
    
    return auraData
end

-- Calculate experience needed for next level
function PetManager:GetExperienceForNextLevel(currentLevel, isAura)
    if isAura then
        return AuraConfig.LevelingSystem.ExperiencePerLevel(currentLevel)
    else
        return PetConfig.LevelingSystem.ExperiencePerLevel(currentLevel)
    end
end

-- Add experience to a pet
function PetManager:AddPetExperience(petData, experienceAmount)
    if not petData then return false end
    
    -- Add experience
    petData.Experience = petData.Experience + experienceAmount
    
    -- Check if pet should level up
    local maxLevel = PetConfig.LevelingSystem.MaxLevel
    while petData.Level < maxLevel do
        local expForNextLevel = self:GetExperienceForNextLevel(petData.Level, false)
        if petData.Experience >= expForNextLevel then
            petData.Level = petData.Level + 1
            petData.Experience = petData.Experience - expForNextLevel
            
            -- Recalculate stats after leveling up
            petData.Stats = self:CalculatePetStats(petData)
        else
            break
        end
    end
    
    -- Cap experience at max level
    if petData.Level >= maxLevel then
        petData.Experience = 0
    end
    
    return true
end

-- Add experience to an aura
function PetManager:AddAuraExperience(auraData, experienceAmount)
    if not auraData then return false end
    
    -- Add experience
    auraData.Experience = auraData.Experience + experienceAmount
    
    -- Check if aura should level up
    local maxLevel = AuraConfig.LevelingSystem.MaxLevel
    while auraData.Level < maxLevel do
        local expForNextLevel = self:GetExperienceForNextLevel(auraData.Level, true)
        if auraData.Experience >= expForNextLevel then
            auraData.Level = auraData.Level + 1
            auraData.Experience = auraData.Experience - expForNextLevel
        else
            break
        end
    end
    
    -- Cap experience at max level
    if auraData.Level >= maxLevel then
        auraData.Experience = 0
    end
    
    return true
end

-- Equip a pet
function PetManager:EquipPet(playerData, petUUID)
    if not playerData or not playerData.Pets then return false end
    
    -- Find the pet in the player's inventory
    local petToEquip = nil
    for _, pet in ipairs(playerData.Pets) do
        if pet.UUID == petUUID then
            petToEquip = pet
            break
        end
    end
    
    if not petToEquip then
        warn("Pet not found in player's inventory: " .. petUUID)
        return false
    end
    
    -- Count currently equipped pets
    local equippedCount = 0
    for _, pet in ipairs(playerData.Pets) do
        if pet.Equipped then
            equippedCount = equippedCount + 1
        end
    end
    
    -- Check if player has reached the equip limit
    if equippedCount >= GameConfig.Mechanics.PetEquipLimit and not petToEquip.Equipped then
        warn("Player has reached the pet equip limit")
        return false
    end
    
    -- Equip the pet
    petToEquip.Equipped = true
    
    return true
end

-- Unequip a pet
function PetManager:UnequipPet(playerData, petUUID)
    if not playerData or not playerData.Pets then return false end
    
    -- Find the pet in the player's inventory
    local petToUnequip = nil
    for _, pet in ipairs(playerData.Pets) do
        if pet.UUID == petUUID then
            petToUnequip = pet
            break
        end
    end
    
    if not petToUnequip then
        warn("Pet not found in player's inventory: " .. petUUID)
        return false
    end
    
    -- Unequip the pet
    petToUnequip.Equipped = false
    
    return true
end

-- Equip an aura on a pet
function PetManager:EquipAura(playerData, petUUID, auraUUID)
    if not playerData or not playerData.Pets or not playerData.Auras then return false end
    
    -- Find the pet in the player's inventory
    local petToEquip = nil
    for _, pet in ipairs(playerData.Pets) do
        if pet.UUID == petUUID then
            petToEquip = pet
            break
        end
    end
    
    if not petToEquip then
        warn("Pet not found in player's inventory: " .. petUUID)
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
    
    -- Check if the aura is already equipped on another pet
    for _, pet in ipairs(playerData.Pets) do
        if pet.EquippedAura and pet.EquippedAura.UUID == auraUUID and pet.UUID ~= petUUID then
            warn("Aura is already equipped on another pet")
            return false
        end
    end
    
    -- Equip the aura on the pet
    petToEquip.EquippedAura = auraToEquip
    
    -- Recalculate pet stats with the new aura
    petToEquip.Stats = self:CalculatePetStats(petToEquip)
    
    return true
end

-- Unequip an aura from a pet
function PetManager:UnequipAura(playerData, petUUID)
    if not playerData or not playerData.Pets then return false end
    
    -- Find the pet in the player's inventory
    local petToUnequip = nil
    for _, pet in ipairs(playerData.Pets) do
        if pet.UUID == petUUID then
            petToUnequip = pet
            break
        end
    end
    
    if not petToUnequip then
        warn("Pet not found in player's inventory: " .. petUUID)
        return false
    end
    
    -- Unequip the aura
    petToUnequip.EquippedAura = nil
    
    -- Recalculate pet stats without the aura
    petToUnequip.Stats = self:CalculatePetStats(petToUnequip)
    
    return true
end

-- Fuse pets to create a stronger pet
function PetManager:FusePets(playerData, petUUIDs)
    if not playerData or not playerData.Pets then return false end
    
    -- Check if we have enough pets to fuse
    if #petUUIDs < PetConfig.FusionSystem.RequiredPetsForFusion then
        warn("Not enough pets to fuse. Required: " .. PetConfig.FusionSystem.RequiredPetsForFusion)
        return false
    end
    
    -- Find the pets in the player's inventory
    local petsToFuse = {}
    for _, uuid in ipairs(petUUIDs) do
        for i, pet in ipairs(playerData.Pets) do
            if pet.UUID == uuid then
                if pet.Locked then
                    warn("Cannot fuse locked pet: " .. uuid)
                    return false
                end
                table.insert(petsToFuse, {pet = pet, index = i})
                break
            end
        end
    end
    
    -- Check if we found all the pets
    if #petsToFuse ~= #petUUIDs then
        warn("Not all pets were found in player's inventory")
        return false
    end
    
    -- Determine the base pet (first in the list)
    local basePet = petsToFuse[1].pet
    local basePetDefinition = self:GetPetDefinition(basePet.ID)
    
    -- Calculate the new pet's properties
    local newLevel = math.min(basePet.Level + 1, PetConfig.LevelingSystem.MaxLevel)
    local newExperience = 0
    
    -- Check if all pets are the same type for bonus
    local allSameType = true
    for i = 2, #petsToFuse do
        if petsToFuse[i].pet.ID ~= basePet.ID then
            allSameType = false
            break
        end
    end
    
    -- Apply same type bonus if applicable
    local sameTypeBonus = allSameType and PetConfig.FusionSystem.SameTypeBonus or 0
    
    -- Determine if rarity should be upgraded
    local newRarity = basePet.Rarity
    local rarityUpgradeChance = PetConfig.FusionSystem.RarityUpgradeChance[basePet.Rarity] or 0
    
    -- Apply same type bonus to rarity upgrade chance
    rarityUpgradeChance = rarityUpgradeChance * (1 + sameTypeBonus)
    
    -- Roll for rarity upgrade
    if Utilities.CalculateChance(rarityUpgradeChance) then
        -- Find the next rarity level
        local rarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
        for i, rarity in ipairs(rarities) do
            if rarity == basePet.Rarity and i < #rarities then
                newRarity = rarities[i + 1]
                break
            end
        end
    end
    
    -- Create the new fused pet
    local fusedPet = self:CreatePet(
        basePet.ID,
        newRarity,
        newLevel,
        newExperience,
        basePet.Equipped,
        basePet.Locked,
        basePet.EquippedAura
    )
    
    -- Remove the pets that were fused (in reverse order to avoid index issues)
    table.sort(petsToFuse, function(a, b) return a.index > b.index end)
    for _, petInfo in ipairs(petsToFuse) do
        table.remove(playerData.Pets, petInfo.index)
    end
    
    -- Add the new fused pet to the player's inventory
    table.insert(playerData.Pets, fusedPet)
    
    return fusedPet
end

-- Fuse auras to create a stronger aura
function PetManager:FuseAuras(playerData, auraUUIDs)
    if not playerData or not playerData.Auras then return false end
    
    -- Check if we have enough auras to fuse
    if #auraUUIDs < AuraConfig.FusionSystem.RequiredAurasForFusion then
        warn("Not enough auras to fuse. Required: " .. AuraConfig.FusionSystem.RequiredAurasForFusion)
        return false
    end
    
    -- Find the auras in the player's inventory
    local aurasToFuse = {}
    for _, uuid in ipairs(auraUUIDs) do
        for i, aura in ipairs(playerData.Auras) do
            if aura.UUID == uuid then
                -- Check if aura is equipped on any pet
                local isEquipped = false
                for _, pet in ipairs(playerData.Pets) do
                    if pet.EquippedAura and pet.EquippedAura.UUID == uuid then
                        isEquipped = true
                        break
                    end
                end
                
                if isEquipped then
                    warn("Cannot fuse equipped aura: " .. uuid)
                    return false
                end
                
                table.insert(aurasToFuse, {aura = aura, index = i})
                break
            end
        end
    end
    
    -- Check if we found all the auras
    if #aurasToFuse ~= #auraUUIDs then
        warn("Not all auras were found in player's inventory")
        return false
    end
    
    -- Determine the base aura (first in the list)
    local baseAura = aurasToFuse[1].aura
    local baseAuraDefinition = self:GetAuraDefinition(baseAura.ID)
    
    -- Calculate the new aura's properties
    local newLevel = math.min(baseAura.Level + 1, AuraConfig.LevelingSystem.MaxLevel)
    local newExperience = 0
    
    -- Check if all auras are the same type for bonus
    local allSameType = true
    for i = 2, #aurasToFuse do
        if aurasToFuse[i].aura.ID ~= baseAura.ID then
            allSameType = false
            break
        end
    end
    
    -- Apply same type bonus if applicable
    local sameTypeBonus = allSameType and AuraConfig.FusionSystem.SameTypeBonus or 0
    
    -- Determine if rarity should be upgraded
    local newRarity = baseAura.Rarity
    local rarityUpgradeChance = AuraConfig.FusionSystem.RarityUpgradeChance[baseAura.Rarity] or 0
    
    -- Apply same type bonus to rarity upgrade chance
    rarityUpgradeChance = rarityUpgradeChance * (1 + sameTypeBonus)
    
    -- Roll for rarity upgrade
    if Utilities.CalculateChance(rarityUpgradeChance) then
        -- Find the next rarity level
        local rarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
        for i, rarity in ipairs(rarities) do
            if rarity == baseAura.Rarity and i < #rarities then
                newRarity = rarities[i + 1]
                break
            end
        end
    end
    
    -- Create the new fused aura
    local fusedAura = self:CreateAura(
        baseAura.ID,
        newRarity,
        newLevel,
        newExperience
    )
    
    -- Remove the auras that were fused (in reverse order to avoid index issues)
    table.sort(aurasToFuse, function(a, b) return a.index > b.index end)
    for _, auraInfo in ipairs(aurasToFuse) do
        table.remove(playerData.Auras, auraInfo.index)
    end
    
    -- Add the new fused aura to the player's inventory
    table.insert(playerData.Auras, fusedAura)
    
    return fusedAura
end

-- Get pets available for a specific zone
function PetManager:GetPetsForZone(zoneNumber)
    local availablePets = {}
    
    for _, pet in ipairs(PetConfig.Pets) do
        if pet.UnlockZone <= zoneNumber then
            table.insert(availablePets, pet)
        end
    end
    
    return availablePets
end

-- Get auras available for a specific zone
function PetManager:GetAurasForZone(zoneNumber)
    local availableAuras = {}
    
    for _, aura in ipairs(AuraConfig.Auras) do
        if aura.UnlockZone <= zoneNumber then
            table.insert(availableAuras, aura)
        end
    end
    
    return availableAuras
end

-- Generate a random pet for a specific zone
function PetManager:GenerateRandomPet(zoneNumber, drawType)
    -- Get pets available for this zone
    local availablePets = self:GetPetsForZone(zoneNumber)
    
    -- Filter by draw type if specified
    if drawType then
        local filteredPets = {}
        for _, pet in ipairs(availablePets) do
            if pet.DrawType == drawType then
                table.insert(filteredPets, pet)
            end
        end
        availablePets = filteredPets
    end
    
    if #availablePets == 0 then
        warn("No pets available for zone: " .. zoneNumber)
        return nil
    end
    
    -- Select a random pet
    local selectedPet = Utilities.GetRandomElement(availablePets)
    
    -- Determine rarity based on chances
    local rarities = {}
    for _, rarity in ipairs(PetConfig.Rarities) do
        if Utilities.TableContains(selectedPet.AvailableRarities, rarity.Name) then
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
    
    -- Create the pet
    return self:CreatePet(
        selectedPet.ID,
        selectedRarity,
        1, -- Level
        0, -- Experience
        false, -- Equipped
        false, -- Locked
        nil -- EquippedAura
    )
end

-- Generate a random aura for a specific zone
function PetManager:GenerateRandomAura(zoneNumber)
    -- Get auras available for this zone
    local availableAuras = self:GetAurasForZone(zoneNumber)
    
    if #availableAuras == 0 then
        warn("No auras available for zone: " .. zoneNumber)
        return nil
    end
    
    -- Select a random aura
    local selectedAura = Utilities.GetRandomElement(availableAuras)
    
    -- Determine rarity based on chances
    local rarities = {}
    for _, rarity in ipairs(AuraConfig.Rarities) do
        if Utilities.TableContains(selectedAura.AvailableRarities, rarity.Name) then
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
    
    -- Create the aura
    return self:CreateAura(
        selectedAura.ID,
        selectedRarity,
        1, -- Level
        0 -- Experience
    )
end

-- Spawn a pet in the game world
function PetManager:SpawnPetInWorld(petData, position, player)
    if not petData then return nil end
    
    -- Get the pet definition
    local petDefinition = self:GetPetDefinition(petData.ID)
    if not petDefinition then
        warn("Pet definition not found for ID: " .. petData.ID)
        return nil
    end
    
    -- Determine the model ID based on variant
    local variantName = petData.Variant or "Normal"
    local variantDefinition = PetConfig.Variants[variantName]
    local modelSuffix = variantDefinition and variantDefinition.ModelSuffix or "_MODEL"
    
    -- Get the base model ID without suffix
    local baseModelId = petDefinition.ModelID:gsub("_MODEL$", "")
    local fullModelId = baseModelId .. modelSuffix
    
    -- Find the model in ReplicatedStorage
    local petModel = ReplicatedStorage.Assets.Pets[variantName]:FindFirstChild(fullModelId)
    if not petModel then
        warn("Pet model not found: " .. fullModelId)
        return nil
    end
    
    -- Clone the model
    local model = petModel:Clone()
    model.Name = petData.ID .. "_" .. petData.UUID
    
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
    
    -- Store reference to the pet data
    model:SetAttribute("PetUUID", petData.UUID)
    
    -- Create a folder for pets if it doesn't exist
    local petsFolder = workspace:FindFirstChild("Pets")
    if not petsFolder then
        petsFolder = Instance.new("Folder")
        petsFolder.Name = "Pets"
        petsFolder.Parent = workspace
    end
    
    -- Create a folder for the player's pets if it doesn't exist
    local playerPetsFolder = nil
    if player then
        playerPetsFolder = petsFolder:FindFirstChild(player.Name)
        if not playerPetsFolder then
            playerPetsFolder = Instance.new("Folder")
            playerPetsFolder.Name = player.Name
            playerPetsFolder.Parent = petsFolder
        end
    end
    
    -- Parent the model
    model.Parent = playerPetsFolder or petsFolder
    
    -- Store in ActivePets table
    self.ActivePets[petData.UUID] = {
        Model = model,
        Data = petData,
        Player = player
    }
    
    -- Play idle animation by default
    self:PlayPetIdleAnimation(model)
    
    return model
end

-- Apply animations to a pet model
function PetManager:ApplyAnimationsToModel(petModel)
    -- Get the animation template
    local animTemplate = ReplicatedStorage.Assets.Animations.PetAnimations.PetAnimation
    if not animTemplate then
        warn("Pet animation template not found")
        return
    end
    
    -- Check if the pet already has an AnimationController
    local existingController = petModel:FindFirstChildOfClass("AnimationController")
    if existingController then
        existingController:Destroy() -- Remove existing controller if present
    end
    
    -- Clone the AnimationController from the template
    local animController = animTemplate.AnimationController:Clone()
    animController.Parent = petModel
    
    -- Clone the animations
    local petAnim = animTemplate.Pet["Pet Animation"]
    local idleAnim = petAnim.IdleAnimation:Clone()
    local actionAnim = petAnim.ActionAnimation:Clone()
    
    -- Create an Animations folder in the pet if it doesn't exist
    local animFolder = petModel:FindFirstChild("Animations")
    if not animFolder then
        animFolder = Instance.new("Folder")
        animFolder.Name = "Animations"
        animFolder.Parent = petModel
    end
    
    -- Add the animations to the pet
    idleAnim.Parent = animFolder
    actionAnim.Parent = animFolder
end

-- Play the idle animation for a pet
function PetManager:PlayPetIdleAnimation(petModel)
    local animator = petModel:FindFirstChild("AnimationController"):FindFirstChild("Animator")
    local animFolder = petModel:FindFirstChild("Animations")
    
    if animator and animFolder and animFolder:FindFirstChild("IdleAnimation") then
        -- Stop action animation if playing
        local actionTrack = petModel:GetAttribute("ActionAnimTrack")
        if actionTrack then
            actionTrack:Stop()
        end
        
        -- Play idle animation
        local idleTrack = petModel:GetAttribute("IdleAnimTrack")
        if not idleTrack then
            idleTrack = animator:LoadAnimation(animFolder.IdleAnimation)
            petModel:SetAttribute("IdleAnimTrack", idleTrack)
        end
        
        idleTrack:Play()
    end
end

-- Play the action animation for a pet
function PetManager:PlayPetActionAnimation(petModel)
    local animator = petModel:FindFirstChild("AnimationController"):FindFirstChild("Animator")
    local animFolder = petModel:FindFirstChild("Animations")
    
    if animator and animFolder and animFolder:FindFirstChild("ActionAnimation") then
        -- Stop idle animation if playing
        local idleTrack = petModel:GetAttribute("IdleAnimTrack")
        if idleTrack then
            idleTrack:Stop()
        end
        
        -- Load and play action animation if not already loaded
        local actionTrack = petModel:GetAttribute("ActionAnimTrack")
        if not actionTrack then
            actionTrack = animator:LoadAnimation(animFolder.ActionAnimation)
            petModel:SetAttribute("ActionAnimTrack", actionTrack)
        end
        
        actionTrack:Play()
        
        -- Return to idle after animation completes
        task.delay(actionTrack.Length, function()
            self:PlayPetIdleAnimation(petModel)
        end)
    end
end

-- Despawn a pet from the game world
function PetManager:DespawnPet(petUUID)
    local activePet = self.ActivePets[petUUID]
    if not activePet then
        warn("Pet not found in active pets: " .. petUUID)
        return false
    end
    
    -- Remove the model
    if activePet.Model and activePet.Model.Parent then
        activePet.Model:Destroy()
    end
    
    -- Remove from ActivePets table
    self.ActivePets[petUUID] = nil
    
    return true
end

-- Update pet position
function PetManager:UpdatePetPosition(petUUID, position)
    local activePet = self.ActivePets[petUUID]
    if not activePet or not activePet.Model then
        return false
    end
    
    local primaryPart = activePet.Model.PrimaryPart or activePet.Model:FindFirstChild("RootPart")
    if primaryPart then
        activePet.Model:SetPrimaryPartCFrame(CFrame.new(position))
    else
        activePet.Model:MoveTo(position)
    end
    
    return true
end

-- Get all active pets for a player
function PetManager:GetPlayerActivePets(player)
    local playerPets = {}
    
    for uuid, petInfo in pairs(self.ActivePets) do
        if petInfo.Player and petInfo.Player == player then
            table.insert(playerPets, {
                UUID = uuid,
                Model = petInfo.Model,
                Data = petInfo.Data
            })
        end
    end
    
    return playerPets
end

return PetManager

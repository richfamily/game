--[[
    GearManager.lua
    Handles the gear system for avatars
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import modules
local Utilities = require(ReplicatedStorage.Modules.Utilities)

-- Import configurations
local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local GearConfig = require(ReplicatedStorage.Config.GearConfig)

local GearManager = {}
GearManager.__index = GearManager

-- Create a new GearManager instance
function GearManager.new()
    local self = setmetatable({}, GearManager)
    
    -- Initialize properties
    self.GearDefinitions = GearConfig.Definitions
    
    return self
end

-- Get a gear definition by ID
function GearManager:GetGearDefinition(gearID)
    return self.GearDefinitions[gearID]
end

-- Create a new gear item
function GearManager:CreateGear(gearID, rarity, enhancementLevel, equipped, equippedOn)
    local gearDefinition = self:GetGearDefinition(gearID)
    if not gearDefinition then
        warn("Invalid gear ID: " .. gearID)
        return nil
    end
    
    -- Validate rarity
    local isValidRarity = false
    for _, validRarity in ipairs(gearDefinition.AvailableRarities) do
        if validRarity == rarity then
            isValidRarity = true
            break
        end
    end
    
    if not isValidRarity then
        warn("Invalid rarity for gear: " .. gearID .. ", rarity: " .. rarity)
        return nil
    end
    
    -- Get rarity multiplier
    local rarityMultiplier = 1.0
    for _, rarityDef in ipairs(GearConfig.Rarities) do
        if rarityDef.Name == rarity then
            rarityMultiplier = rarityDef.StatMultiplier
            break
        end
    end
    
    -- Calculate enhancement multiplier
    local enhancementMultiplier = 1.0
    if enhancementLevel and enhancementLevel > 0 then
        enhancementMultiplier = 1.0 + (enhancementLevel * GearConfig.EnhancementSystem.StatIncreasePerLevel)
    end
    
    -- Create the gear
    local gear = {
        ID = gearID,
        UUID = Utilities.CreateUniqueID("GEAR"),
        Name = gearDefinition.Name,
        Type = gearDefinition.Type,
        Description = gearDefinition.Description,
        Rarity = rarity,
        EnhancementLevel = enhancementLevel or 0,
        Equipped = equipped or false,
        EquippedOn = equippedOn or nil, -- UUID of the avatar it's equipped on
        Stats = {
            Damage = gearDefinition.BaseDamage * rarityMultiplier * enhancementMultiplier,
            Speed = gearDefinition.BaseSpeed * rarityMultiplier * enhancementMultiplier
        },
        ModelID = gearDefinition.ModelID
    }
    
    return gear
end

-- Get gear for a specific zone
function GearManager:GetGearForZone(zoneNumber)
    local availableGear = {}
    
    for id, gear in pairs(self.GearDefinitions) do
        if zoneNumber >= gear.MinZone and zoneNumber <= gear.MaxZone then
            table.insert(availableGear, {
                ID = id,
                AvailableRarities = gear.AvailableRarities
            })
        end
    end
    
    return availableGear
end

-- Equip gear on an avatar
function GearManager:EquipGear(playerData, gearUUID, avatarUUID)
    if not playerData or not playerData.Gear or not playerData.Avatars then
        return false, "Invalid player data"
    end
    
    -- Find the gear in the player's inventory
    local gearToEquip = nil
    for _, gear in ipairs(playerData.Gear) do
        if gear.UUID == gearUUID then
            gearToEquip = gear
            break
        end
    end
    
    if not gearToEquip then
        return false, "Gear not found in player's inventory"
    end
    
    -- Find the avatar
    local avatar = nil
    for _, av in ipairs(playerData.Avatars) do
        if av.UUID == avatarUUID then
            avatar = av
            break
        end
    end
    
    if not avatar then
        return false, "Avatar not found in player's inventory"
    end
    
    -- Check if the avatar already has gear of this type equipped
    if avatar.EquippedGear then
        for existingGearUUID, _ in pairs(avatar.EquippedGear) do
            local existingGear = nil
            for _, gear in ipairs(playerData.Gear) do
                if gear.UUID == existingGearUUID then
                    existingGear = gear
                    break
                end
            end
            
            if existingGear and existingGear.Type == gearToEquip.Type then
                -- Unequip the existing gear of the same type
                existingGear.Equipped = false
                existingGear.EquippedOn = nil
                avatar.EquippedGear[existingGearUUID] = nil
                break
            end
        end
    else
        avatar.EquippedGear = {}
    end
    
    -- Equip the new gear
    gearToEquip.Equipped = true
    gearToEquip.EquippedOn = avatarUUID
    avatar.EquippedGear[gearUUID] = true
    
    -- Update avatar stats
    self:UpdateAvatarStats(playerData, avatarUUID)
    
    return true
end

-- Unequip gear from an avatar
function GearManager:UnequipGear(playerData, gearUUID)
    if not playerData or not playerData.Gear or not playerData.Avatars then
        return false, "Invalid player data"
    end
    
    -- Find the gear in the player's inventory
    local gearToUnequip = nil
    for _, gear in ipairs(playerData.Gear) do
        if gear.UUID == gearUUID then
            gearToUnequip = gear
            break
        end
    end
    
    if not gearToUnequip then
        return false, "Gear not found in player's inventory"
    end
    
    if not gearToUnequip.Equipped or not gearToUnequip.EquippedOn then
        return false, "Gear is not equipped"
    end
    
    -- Find the avatar
    local avatarUUID = gearToUnequip.EquippedOn
    local avatar = nil
    for _, av in ipairs(playerData.Avatars) do
        if av.UUID == avatarUUID then
            avatar = av
            break
        end
    end
    
    if not avatar then
        -- If avatar not found, still unequip the gear
        gearToUnequip.Equipped = false
        gearToUnequip.EquippedOn = nil
        return true
    end
    
    -- Unequip the gear
    gearToUnequip.Equipped = false
    gearToUnequip.EquippedOn = nil
    
    if avatar.EquippedGear then
        avatar.EquippedGear[gearUUID] = nil
    end
    
    -- Update avatar stats
    self:UpdateAvatarStats(playerData, avatarUUID)
    
    return true
end

-- Update avatar stats based on equipped gear
function GearManager:UpdateAvatarStats(playerData, avatarUUID)
    if not playerData or not playerData.Avatars then
        return false, "Invalid player data"
    end
    
    -- Find the avatar
    local avatar = nil
    for _, av in ipairs(playerData.Avatars) do
        if av.UUID == avatarUUID then
            avatar = av
            break
        end
    end
    
    if not avatar then
        return false, "Avatar not found in player's inventory"
    end
    
    -- Reset gear-based stats
    avatar.GearStats = {
        Damage = 0,
        Speed = 0
    }
    
    -- If no gear is equipped, return
    if not avatar.EquippedGear then
        return true
    end
    
    -- Calculate stats from equipped gear
    for gearUUID, _ in pairs(avatar.EquippedGear) do
        local gear = nil
        for _, g in ipairs(playerData.Gear) do
            if g.UUID == gearUUID then
                gear = g
                break
            end
        end
        
        if gear then
            avatar.GearStats.Damage = avatar.GearStats.Damage + gear.Stats.Damage
            avatar.GearStats.Speed = avatar.GearStats.Speed + gear.Stats.Speed
        end
    end
    
    return true
end

-- Enhance gear
function GearManager:EnhanceGear(playerData, gearUUID, dataManager, player, currencyManager)
    if not playerData or not playerData.Gear then
        return false, "Invalid player data"
    end
    
    -- Find the gear in the player's inventory
    local gearToEnhance = nil
    local gearIndex = nil
    for i, gear in ipairs(playerData.Gear) do
        if gear.UUID == gearUUID then
            gearToEnhance = gear
            gearIndex = i
            break
        end
    end
    
    if not gearToEnhance then
        return false, "Gear not found in player's inventory"
    end
    
    -- Check if gear is already at max enhancement level
    if gearToEnhance.EnhancementLevel >= GearConfig.EnhancementSystem.MaxLevel then
        return false, "Gear is already at maximum enhancement level"
    end
    
    -- Calculate enhancement cost
    local gearDefinition = self:GetGearDefinition(gearToEnhance.ID)
    if not gearDefinition then
        return false, "Invalid gear definition"
    end
    
    local baseCost = 100 -- Base cost for enhancement
    local costMultiplier = GearConfig.EnhancementSystem.CostMultiplier
    local nextLevel = gearToEnhance.EnhancementLevel + 1
    local enhancementCost = math.floor(baseCost * nextLevel * costMultiplier)
    
    -- Check if player has enough currency
    if not currencyManager:HasEnoughCurrency(playerData, "Coins", enhancementCost) then
        return false, "Not enough Coins"
    end
    
    -- Remove currency
    if not currencyManager:RemoveCurrency(playerData, "Coins", enhancementCost, dataManager, player) then
        return false, "Failed to remove currency"
    end
    
    -- Calculate success chance
    local failChance = GearConfig.EnhancementSystem.FailChance[nextLevel] or 0
    local success = math.random() > failChance
    
    if success then
        -- Enhancement succeeded
        gearToEnhance.EnhancementLevel = nextLevel
        
        -- Recalculate stats
        local rarityMultiplier = 1.0
        for _, rarityDef in ipairs(GearConfig.Rarities) do
            if rarityDef.Name == gearToEnhance.Rarity then
                rarityMultiplier = rarityDef.StatMultiplier
                break
            end
        end
        
        local enhancementMultiplier = 1.0 + (nextLevel * GearConfig.EnhancementSystem.StatIncreasePerLevel)
        
        gearToEnhance.Stats.Damage = gearDefinition.BaseDamage * rarityMultiplier * enhancementMultiplier
        gearToEnhance.Stats.Speed = gearDefinition.BaseSpeed * rarityMultiplier * enhancementMultiplier
        
        -- If gear is equipped, update avatar stats
        if gearToEnhance.Equipped and gearToEnhance.EquippedOn then
            self:UpdateAvatarStats(playerData, gearToEnhance.EquippedOn)
        end
        
        return true, {
            Success = true,
            NewLevel = nextLevel,
            Gear = gearToEnhance
        }
    else
        -- Enhancement failed
        local levelDecrease = GearConfig.EnhancementSystem.FailLevelDecrease
        gearToEnhance.EnhancementLevel = math.max(0, gearToEnhance.EnhancementLevel - levelDecrease)
        
        -- Recalculate stats
        local rarityMultiplier = 1.0
        for _, rarityDef in ipairs(GearConfig.Rarities) do
            if rarityDef.Name == gearToEnhance.Rarity then
                rarityMultiplier = rarityDef.StatMultiplier
                break
            end
        end
        
        local enhancementMultiplier = 1.0 + (gearToEnhance.EnhancementLevel * GearConfig.EnhancementSystem.StatIncreasePerLevel)
        
        gearToEnhance.Stats.Damage = gearDefinition.BaseDamage * rarityMultiplier * enhancementMultiplier
        gearToEnhance.Stats.Speed = gearDefinition.BaseSpeed * rarityMultiplier * enhancementMultiplier
        
        -- If gear is equipped, update avatar stats
        if gearToEnhance.Equipped and gearToEnhance.EquippedOn then
            self:UpdateAvatarStats(playerData, gearToEnhance.EquippedOn)
        end
        
        return true, {
            Success = false,
            NewLevel = gearToEnhance.EnhancementLevel,
            Gear = gearToEnhance
        }
    end
end

-- Fuse gear (combine multiple gear of the same type to create a stronger one)
function GearManager:FuseGear(playerData, gearUUIDs)
    if not playerData or not playerData.Gear then
        return false, "Invalid player data"
    end
    
    -- Check if we have enough gear to fuse
    if #gearUUIDs < GearConfig.FusionSystem.RequiredCount then
        return false, "Not enough gear to fuse"
    end
    
    -- Find all gear in the player's inventory
    local gearToFuse = {}
    local gearIndices = {}
    
    for i, gear in ipairs(playerData.Gear) do
        for _, uuid in ipairs(gearUUIDs) do
            if gear.UUID == uuid then
                table.insert(gearToFuse, gear)
                table.insert(gearIndices, i)
                break
            end
        end
    end
    
    if #gearToFuse ~= #gearUUIDs then
        return false, "Some gear not found in player's inventory"
    end
    
    -- Check if all gear is of the same type
    local firstType = gearToFuse[1].Type
    local firstID = gearToFuse[1].ID
    
    for i = 2, #gearToFuse do
        if gearToFuse[i].Type ~= firstType then
            return false, "All gear must be of the same type"
        end
    end
    
    -- Check if any gear is equipped
    for _, gear in ipairs(gearToFuse) do
        if gear.Equipped then
            return false, "Cannot fuse equipped gear"
        end
    end
    
    -- Get the base gear definition
    local gearDefinition = self:GetGearDefinition(firstID)
    if not gearDefinition then
        return false, "Invalid gear definition"
    end
    
    -- Determine the rarity of the result
    local highestRarity = gearToFuse[1].Rarity
    local highestRarityIndex = 1
    
    for i, rarityDef in ipairs(GearConfig.Rarities) do
        if rarityDef.Name == highestRarity then
            highestRarityIndex = i
            break
        end
    end
    
    -- Check if we can upgrade the rarity
    local newRarityIndex = highestRarityIndex
    local upgradeChance = GearConfig.FusionSystem.UpgradeChance
    
    if math.random() < upgradeChance and highestRarityIndex < #GearConfig.Rarities then
        newRarityIndex = highestRarityIndex + 1
    end
    
    local newRarity = GearConfig.Rarities[newRarityIndex].Name
    
    -- Create the fused gear
    local fusedGear = self:CreateGear(
        firstID,
        newRarity,
        0, -- Enhancement level starts at 0
        false, -- Not equipped
        nil -- Not equipped on any avatar
    )
    
    if not fusedGear then
        return false, "Failed to create fused gear"
    end
    
    -- Apply fusion boost
    local fusionBoost = GearConfig.FusionSystem.FusionBoost
    fusedGear.Stats.Damage = fusedGear.Stats.Damage * fusionBoost
    fusedGear.Stats.Speed = fusedGear.Stats.Speed * fusionBoost
    
    -- Remove the gear used for fusion
    -- Sort indices in descending order to avoid index shifting when removing
    table.sort(gearIndices, function(a, b) return a > b end)
    
    for _, index in ipairs(gearIndices) do
        table.remove(playerData.Gear, index)
    end
    
    -- Add the fused gear to the player's inventory
    table.insert(playerData.Gear, fusedGear)
    
    return true, fusedGear
end

return GearManager

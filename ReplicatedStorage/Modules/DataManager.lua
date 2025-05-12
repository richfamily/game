--[[
    DataManager.lua
    Handles player data saving and loading
    This module is used by both server and client
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Import modules
local Utilities = require(ReplicatedStorage.Modules.Utilities)

-- Import configurations
local GameConfig = require(ReplicatedStorage.Config.GameConfig)

local DataManager = {}
DataManager.__index = DataManager

-- Create a new DataManager instance
function DataManager.new()
    local self = setmetatable({}, DataManager)
    
    -- Initialize properties
    self.PlayerData = {}
    self.DataStoreService = game:GetService("DataStoreService")
    self.DataStore = self.DataStoreService:GetDataStore("PetSimulatorData")
    self.SessionLocked = {}
    self.AutoSaveInterval = 300 -- 5 minutes
    
    -- Set up auto-save
    spawn(function()
        while wait(self.AutoSaveInterval) do
            self:SaveAllData()
        end
    end)
    
    return self
end

-- Create default data for a new player
function DataManager:CreateDefaultData()
    local defaultData = Utilities.DeepCopy(GameConfig.StartingValues)
    
    -- Add additional default data not in GameConfig
    defaultData.LastSave = os.time()
    defaultData.PlayTime = 0
    defaultData.JoinDate = os.time()
    defaultData.Stats = {
        TotalCoinsEarned = 0,
        TotalDiamondsEarned = 0,
        TotalRubiesEarned = 0,
        EnemiesDefeated = 0,
        BossesDefeated = 0,
        AvatarsObtained = 0,
        AurasObtained = 0,
        RelicsDiscovered = 0,
        GearObtained = 0,
        ZonesUnlocked = 1,
        HighestZoneReached = 1,
        RebirthCount = 0,
        TotalAvatarLevels = 0
    }
    
    -- Initialize arrays if they don't exist
    if not defaultData.Avatars then
        defaultData.Avatars = {}
    end
    
    if not defaultData.Gear then
        defaultData.Gear = {}
    end
    
    -- Create and add starter avatar
    local AvatarManager = require(ReplicatedStorage.Modules.AvatarManager)
    local avatarManager = AvatarManager.new()
    local starterAvatar = avatarManager:CreateStarterAvatar()
    
    table.insert(defaultData.Avatars, starterAvatar)
    
    -- Create and add starter gear
    local GearManager = require(ReplicatedStorage.Modules.GearManager)
    local gearManager = GearManager.new()
    
    -- Add starter weapon
    local starterWeapon = gearManager:CreateGear(
        "WEAPON_BASIC_SWORD",
        "Common",
        0, -- Enhancement level
        false, -- Not equipped
        nil -- Not equipped on any avatar
    )
    
    if starterWeapon then
        table.insert(defaultData.Gear, starterWeapon)
    end
    
    return defaultData
end

-- Load player data
function DataManager:LoadData(player)
    if not player then return nil end
    
    local userId = player.UserId
    if self.SessionLocked[userId] then
        warn("Session is locked for player: " .. player.Name)
        return nil
    end
    
    self.SessionLocked[userId] = true
    
    local success, data = pcall(function()
        return self.DataStore:GetAsync("Player_" .. userId)
    end)
    
    if not success then
        warn("Failed to load data for player: " .. player.Name .. " - " .. tostring(data))
        self.SessionLocked[userId] = false
        return self:CreateDefaultData()
    end
    
    if not data then
        -- New player, create default data
        data = self:CreateDefaultData()
    else
        -- Update any missing fields with default values
        local defaultData = self:CreateDefaultData()
        for key, value in pairs(defaultData) do
            if data[key] == nil then
                data[key] = value
            elseif type(value) == "table" and type(data[key]) == "table" then
                -- Recursively update nested tables
                data[key] = Utilities.MergeTables(Utilities.DeepCopy(value), data[key])
            end
        end
    end
    
    -- Update last login time
    data.LastLogin = os.time()
    
    -- Store data in memory
    self.PlayerData[userId] = data
    
    -- Unlock session
    self.SessionLocked[userId] = false
    
    return data
end

-- Save player data
function DataManager:SaveData(player)
    if not player then return false end
    
    local userId = player.UserId
    local data = self.PlayerData[userId]
    
    if not data then
        warn("No data to save for player: " .. player.Name)
        return false
    end
    
    if self.SessionLocked[userId] then
        warn("Session is locked for player: " .. player.Name)
        return false
    end
    
    self.SessionLocked[userId] = true
    
    -- Update last save time
    data.LastSave = os.time()
    
    -- Calculate play time
    if data.LastLogin then
        data.PlayTime = (data.PlayTime or 0) + (os.time() - data.LastLogin)
        data.LastLogin = os.time()
    end
    
    local success, result = pcall(function()
        return self.DataStore:SetAsync("Player_" .. userId, data)
    end)
    
    self.SessionLocked[userId] = false
    
    if not success then
        warn("Failed to save data for player: " .. player.Name .. " - " .. tostring(result))
        return false
    end
    
    return true
end

-- Save all player data
function DataManager:SaveAllData()
    for _, player in pairs(Players:GetPlayers()) do
        self:SaveData(player)
    end
end

-- Get player data
function DataManager:GetData(player)
    if not player then return nil end
    
    local userId = player.UserId
    return self.PlayerData[userId]
end

-- Update player data
function DataManager:UpdateData(player, dataPath, value)
    if not player then return false end
    
    local userId = player.UserId
    local data = self.PlayerData[userId]
    
    if not data then
        warn("No data to update for player: " .. player.Name)
        return false
    end
    
    -- Parse the data path (e.g., "Stats.TotalCoinsEarned")
    local pathParts = string.split(dataPath, ".")
    local currentTable = data
    
    -- Navigate to the correct nested table
    for i = 1, #pathParts - 1 do
        local part = pathParts[i]
        if not currentTable[part] then
            currentTable[part] = {}
        end
        currentTable = currentTable[part]
    end
    
    -- Update the value
    currentTable[pathParts[#pathParts]] = value
    
    return true
end

-- Increment player data
function DataManager:IncrementData(player, dataPath, amount)
    if not player then return false end
    
    local userId = player.UserId
    local data = self.PlayerData[userId]
    
    if not data then
        warn("No data to increment for player: " .. player.Name)
        return false
    end
    
    -- Parse the data path (e.g., "Stats.TotalCoinsEarned")
    local pathParts = string.split(dataPath, ".")
    local currentTable = data
    
    -- Navigate to the correct nested table
    for i = 1, #pathParts - 1 do
        local part = pathParts[i]
        if not currentTable[part] then
            currentTable[part] = {}
        end
        currentTable = currentTable[part]
    end
    
    -- Get the current value
    local key = pathParts[#pathParts]
    local currentValue = currentTable[key] or 0
    
    -- Increment the value
    currentTable[key] = currentValue + amount
    
    return true
end

-- Add an avatar to player data
function DataManager:AddAvatar(player, avatarData)
    if not player then return false end
    
    local userId = player.UserId
    local data = self.PlayerData[userId]
    
    if not data then
        warn("No data to update for player: " .. player.Name)
        return false
    end
    
    -- Initialize Avatars array if it doesn't exist
    if not data.Avatars then
        data.Avatars = {}
    end
    
    -- Generate a unique ID for the avatar
    avatarData.UUID = avatarData.UUID or Utilities.CreateUniqueID("AVATAR")
    
    -- Add the avatar to the player's inventory
    table.insert(data.Avatars, avatarData)
    
    -- Increment stats
    self:IncrementData(player, "Stats.AvatarsObtained", 1)
    
    return true
end

-- Add an aura to player data
function DataManager:AddAura(player, auraData)
    if not player then return false end
    
    local userId = player.UserId
    local data = self.PlayerData[userId]
    
    if not data then
        warn("No data to update for player: " .. player.Name)
        return false
    end
    
    -- Generate a unique ID for the aura
    auraData.UUID = auraData.UUID or Utilities.CreateUniqueID("AURA")
    
    -- Add the aura to the player's inventory
    table.insert(data.Auras, auraData)
    
    -- Increment stats
    self:IncrementData(player, "Stats.AurasObtained", 1)
    
    return true
end

-- Add a relic to player data
function DataManager:AddRelic(player, relicData)
    if not player then return false end
    
    local userId = player.UserId
    local data = self.PlayerData[userId]
    
    if not data then
        warn("No data to update for player: " .. player.Name)
        return false
    end
    
    -- Generate a unique ID for the relic
    relicData.UUID = relicData.UUID or Utilities.CreateUniqueID("RELIC")
    
    -- Add the relic to the player's inventory
    table.insert(data.Relics, relicData)
    
    -- Increment stats
    self:IncrementData(player, "Stats.RelicsDiscovered", 1)
    
    return true
end

-- Add gear to player data
function DataManager:AddGear(player, gearData)
    if not player then return false end
    
    local userId = player.UserId
    local data = self.PlayerData[userId]
    
    if not data then
        warn("No data to update for player: " .. player.Name)
        return false
    end
    
    -- Initialize Gear array if it doesn't exist
    if not data.Gear then
        data.Gear = {}
    end
    
    -- Generate a unique ID for the gear if it doesn't have one
    gearData.UUID = gearData.UUID or Utilities.CreateUniqueID("GEAR")
    
    -- Add the gear to the player's inventory
    table.insert(data.Gear, gearData)
    
    -- Increment stats
    self:IncrementData(player, "Stats.GearObtained", 1)
    
    return true
end

-- Unlock a zone for a player
function DataManager:UnlockZone(player, zoneNumber)
    if not player then return false end
    
    local userId = player.UserId
    local data = self.PlayerData[userId]
    
    if not data then
        warn("No data to update for player: " .. player.Name)
        return false
    end
    
    -- Check if the zone is already unlocked
    if Utilities.TableContains(data.UnlockedZones, zoneNumber) then
        return true
    end
    
    -- Add the zone to the player's unlocked zones
    table.insert(data.UnlockedZones, zoneNumber)
    
    -- Update highest zone reached if necessary
    if zoneNumber > data.Stats.HighestZoneReached then
        self:UpdateData(player, "Stats.HighestZoneReached", zoneNumber)
    end
    
    -- Increment stats
    self:IncrementData(player, "Stats.ZonesUnlocked", 1)
    
    return true
end

-- Perform a rebirth for a player
function DataManager:PerformRebirth(player, zoneNumber)
    if not player then return false end
    
    local userId = player.UserId
    local data = self.PlayerData[userId]
    
    if not data then
        warn("No data to update for player: " .. player.Name)
        return false
    end
    
    -- Increment rebirth level
    local currentRebirthLevel = data.RebirthLevel or 0
    local newRebirthLevel = currentRebirthLevel + 1
    
    -- Calculate rebirth rewards
    local ZoneConfig = require(ReplicatedStorage.Config.ZoneConfig)
    local rebirthReward = ZoneConfig.RebirthSystem.CalculateRebirthReward(zoneNumber, currentRebirthLevel)
    
    -- Update player data
    self:UpdateData(player, "RebirthLevel", newRebirthLevel)
    
    -- Apply rebirth multipliers
    local multipliers = data.Multipliers
    for stat, value in pairs(multipliers) do
        multipliers[stat] = value * (1 + rebirthReward)
    end
    
    -- Reset certain progress
    self:UpdateData(player, "UnlockedZones", {1}) -- Reset to only first zone
    self:UpdateData(player, "Coins", GameConfig.StartingValues.Coins) -- Reset coins
    
    -- Keep pets, auras, relics, and diamonds
    
    -- Increment stats
    self:IncrementData(player, "Stats.RebirthCount", 1)
    
    return true
end

-- Clean up when a player leaves
function DataManager:PlayerRemoving(player)
    if not player then return end
    
    -- Save player data
    self:SaveData(player)
    
    -- Clear memory
    local userId = player.UserId
    self.PlayerData[userId] = nil
    self.SessionLocked[userId] = nil
end

return DataManager

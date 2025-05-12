--[[
    ZoneManager.lua
    Handles zone-related functionality such as creating zones, managing zone progression, and handling rebirth statues
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import modules
local Utilities = require(ReplicatedStorage.Modules.Utilities)

-- Import configurations
local ZoneConfig = require(ReplicatedStorage.Config.ZoneConfig)
local GameConfig = require(ReplicatedStorage.Config.GameConfig)

local ZoneManager = {}
ZoneManager.__index = ZoneManager

-- Create a new ZoneManager instance
function ZoneManager.new()
    local self = setmetatable({}, ZoneManager)
    
    -- Initialize properties
    self.ActiveZones = {} -- Table to track active zones in the game
    self.ActiveEnemies = {} -- Table to track active enemies in the game
    self.ActiveBosses = {} -- Table to track active bosses in the game
    self.ActiveRebirthStatues = {} -- Table to track active rebirth statues in the game
    self.ActivePortals = {} -- Table to track active portals in the game
    self.OpenBarriers = {} -- Table to track which barriers have been opened
    
    -- Initialize barriers to be visible and solid
    task.spawn(function()
        self:InitializeBarriers()
    end)
    
    return self
end

-- Initialize all barriers to be visible and solid
function ZoneManager:InitializeBarriers()
    -- Wait a short time to ensure the workspace is loaded
    task.wait(1)
    
    -- Find all barriers in the workspace
    local barriers = {}
    
    -- Check the main location: Workspace.Worlds.Spawn.MAP.Gates
    local gatesFolder = workspace:FindFirstChild("Worlds")
    if gatesFolder then
        gatesFolder = gatesFolder:FindFirstChild("Spawn")
        if gatesFolder then
            gatesFolder = gatesFolder:FindFirstChild("MAP")
            if gatesFolder then
                gatesFolder = gatesFolder:FindFirstChild("Gates")
                if gatesFolder then
                    for _, barrier in ipairs(gatesFolder:GetChildren()) do
                        if barrier.Name:match("^ZoneBarrier_%d+_%d+$") or barrier.Name:match("^Barrier_%d+_%d+$") then
                            table.insert(barriers, barrier)
                        end
                    end
                end
            end
        end
    end
    
    -- Also check the old location for backward compatibility
    local oldGatesFolder = workspace:FindFirstChild("World")
    if oldGatesFolder then
        oldGatesFolder = oldGatesFolder:FindFirstChild("Spawn")
        if oldGatesFolder then
            oldGatesFolder = oldGatesFolder:FindFirstChild("Map")
            if oldGatesFolder then
                oldGatesFolder = oldGatesFolder:FindFirstChild("Gates")
                if oldGatesFolder then
                    oldGatesFolder = oldGatesFolder:FindFirstChild("Model")
                    if oldGatesFolder then
                        for _, barrier in ipairs(oldGatesFolder:GetChildren()) do
                            if barrier.Name:match("^ZoneBarrier_%d+_%d+$") or barrier.Name:match("^Barrier_%d+_%d+$") then
                                table.insert(barriers, barrier)
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- As a last resort, search the entire workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:match("^ZoneBarrier_%d+_%d+$") or obj.Name:match("^Barrier_%d+_%d+$") then
            table.insert(barriers, obj)
        end
    end
    
    -- Make all barriers visible and solid
    for _, barrier in ipairs(barriers) do
        -- Extract world and zone numbers from the barrier name
        local worldNum, zoneNum = barrier.Name:match("ZoneBarrier_(%d+)_(%d+)")
        if not worldNum or not zoneNum then
            worldNum, zoneNum = barrier.Name:match("Barrier_(%d+)_(%d+)")
        end
        
        if worldNum and zoneNum then
            worldNum = tonumber(worldNum)
            zoneNum = tonumber(zoneNum)
            
            -- Make the barrier visible and solid
            for _, part in ipairs(barrier:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                    part.Transparency = 0
                end
            end
            
            print("Initialized barrier: " .. barrier.Name .. " to be visible and solid")
        end
    end
    
    print("All barriers initialized")
end

-- Get a zone definition from the config
function ZoneManager:GetZoneDefinition(zoneID)
    for _, zone in ipairs(ZoneConfig.Zones) do
        if zone.ID == zoneID then
            return zone
        end
    end
    return nil
end

-- Get a zone definition by zone number
function ZoneManager:GetZoneDefinitionByNumber(worldID, zoneNumber)
    for _, zone in ipairs(ZoneConfig.Zones) do
        if zone.WorldID == worldID and zone.ZoneNumber == zoneNumber then
            return zone
        end
    end
    return nil
end

-- Get a world definition from the config
function ZoneManager:GetWorldDefinition(worldID)
    for _, world in ipairs(ZoneConfig.Worlds) do
        if world.ID == worldID then
            return world
        end
    end
    return nil
end

-- Get an enemy definition from the config
function ZoneManager:GetEnemyDefinition(enemyID)
    for _, enemy in ipairs(ZoneConfig.EnemyTypes) do
        if enemy.ID == enemyID then
            return enemy
        end
    end
    return nil
end

-- Get a boss definition from the config
function ZoneManager:GetBossDefinition(bossID)
    for _, boss in ipairs(ZoneConfig.BossTypes) do
        if boss.ID == bossID then
            return boss
        end
    end
    return nil
end

-- Get enemies for a specific zone
function ZoneManager:GetEnemiesForZone(zoneNumber)
    local enemies = {}
    
    for _, enemy in ipairs(ZoneConfig.EnemyTypes) do
        if enemy.ZoneRange and zoneNumber >= enemy.ZoneRange[1] and zoneNumber <= enemy.ZoneRange[2] then
            table.insert(enemies, enemy)
        end
    end
    
    return enemies
end

-- Calculate the cost to unlock a zone
function ZoneManager:CalculateUnlockCost(zoneNumber)
    return ZoneConfig.UnlockRequirements.CalculateUnlockCost(zoneNumber)
end

-- Check if a player can unlock a zone
function ZoneManager:CanUnlockZone(playerData, zoneNumber)
    if not playerData then return false end
    
    -- Check if the zone is already unlocked
    if Utilities.TableContains(playerData.UnlockedZones, zoneNumber) then
        return true
    end
    
    -- Check if the previous zone is unlocked
    if not Utilities.TableContains(playerData.UnlockedZones, zoneNumber - 1) then
        return false
    end
    
    -- Check if the player has enough coins
    local unlockCost = self:CalculateUnlockCost(zoneNumber)
    return playerData.Coins >= unlockCost
end

-- Get a barrier model by world and zone number
function ZoneManager:GetBarrier(worldNumber, zoneNumber)
    -- Check if the barrier exists in the workspace
    local barrierName = "ZoneBarrier_" .. worldNumber .. "_" .. zoneNumber
    
    -- Try the new path first: Workspace.Worlds.Spawn.MAP.Gates
    local gatesFolder = workspace:FindFirstChild("Worlds")
    if gatesFolder then
        gatesFolder = gatesFolder:FindFirstChild("Spawn")
        if gatesFolder then
            gatesFolder = gatesFolder:FindFirstChild("MAP")
            if gatesFolder then
                gatesFolder = gatesFolder:FindFirstChild("Gates")
                if gatesFolder then
                    local barrier = gatesFolder:FindFirstChild(barrierName)
                    if barrier then
                        return barrier
                    end
                end
            end
        end
    end
    
    -- Try the old path: World>Spawn>Map>Gates>Model
    gatesFolder = workspace:FindFirstChild("World")
    if gatesFolder then
        gatesFolder = gatesFolder:FindFirstChild("Spawn")
        if gatesFolder then
            gatesFolder = gatesFolder:FindFirstChild("Map")
            if gatesFolder then
                gatesFolder = gatesFolder:FindFirstChild("Gates")
                if gatesFolder then
                    gatesFolder = gatesFolder:FindFirstChild("Model")
                    if gatesFolder then
                        local barrier = gatesFolder:FindFirstChild(barrierName)
                        if barrier then
                            return barrier
                        end
                        
                        -- Also try with the new naming pattern
                        barrier = gatesFolder:FindFirstChild("Barrier_" .. worldNumber .. "_" .. zoneNumber)
                        if barrier then
                            return barrier
                        end
                    end
                end
            end
        end
    end
    
    -- As a last resort, search the entire workspace
    return workspace:FindFirstChild(barrierName, true)
end

-- Open a barrier
function ZoneManager:OpenBarrier(worldNumber, zoneNumber)
    local barrier = self:GetBarrier(worldNumber, zoneNumber)
    if not barrier then
        warn("Barrier not found: Barrier_" .. worldNumber .. "_" .. zoneNumber)
        return false
    end
    
    -- Check if this barrier is already open
    local barrierKey = worldNumber .. "_" .. zoneNumber
    if self.OpenBarriers[barrierKey] then
        return true -- Barrier is already open
    end
    
    -- Make the barrier invisible and non-collidable
    for _, part in ipairs(barrier:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Transparency = 1
        end
    end
    
    -- You could also play an animation here if the barrier has an AnimationController
    local animController = barrier:FindFirstChildOfClass("AnimationController")
    if animController then
        local animator = animController:FindFirstChildOfClass("Animator")
        if animator then
            local openAnim = barrier:FindFirstChild("OpenAnimation")
            if openAnim and openAnim:IsA("Animation") then
                local track = animator:LoadAnimation(openAnim)
                track:Play()
            end
        end
    end
    
    -- Mark this barrier as open
    self.OpenBarriers[barrierKey] = true
    
    return true
end

-- Close a barrier
function ZoneManager:CloseBarrier(worldNumber, zoneNumber)
    local barrier = self:GetBarrier(worldNumber, zoneNumber)
    if not barrier then
        warn("Barrier not found: Barrier_" .. worldNumber .. "_" .. zoneNumber)
        return false
    end
    
    -- Make the barrier visible and collidable
    for _, part in ipairs(barrier:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
            part.Transparency = 0
        end
    end
    
    -- You could also play an animation here if the barrier has an AnimationController
    local animController = barrier:FindFirstChildOfClass("AnimationController")
    if animController then
        local animator = animController:FindFirstChildOfClass("Animator")
        if animator then
            local closeAnim = barrier:FindFirstChild("CloseAnimation")
            if closeAnim and closeAnim:IsA("Animation") then
                local track = animator:LoadAnimation(closeAnim)
                track:Play()
            end
        end
    end
    
    return true
end

-- Unlock a zone for a player
function ZoneManager:UnlockZone(playerData, zoneNumber, dataManager, player)
    if not playerData or not dataManager or not player then return false end
    
    -- Check if the player can unlock the zone
    if not self:CanUnlockZone(playerData, zoneNumber) then
        return false
    end
    
    -- If the zone is already unlocked, return true
    if Utilities.TableContains(playerData.UnlockedZones, zoneNumber) then
        return true
    end
    
    -- Deduct the cost from the player's coins
    local unlockCost = self:CalculateUnlockCost(zoneNumber)
    dataManager:UpdateData(player, "Coins", playerData.Coins - unlockCost)
    
    -- Add the zone to the player's unlocked zones
    dataManager:UnlockZone(player, zoneNumber)
    
    -- Open the barrier for this zone (assuming world 1 for now)
    self:OpenBarrier(1, zoneNumber)
    
    return true
end

-- Calculate enemy stats for a specific zone
function ZoneManager:CalculateEnemyStats(enemyDefinition, zoneNumber)
    if not enemyDefinition then return nil end
    
    local zoneDefinition = self:GetZoneDefinitionByNumber("WORLD_1", zoneNumber)
    if not zoneDefinition then return nil end
    
    -- Calculate health based on zone progression
    local healthMultiplier = ZoneConfig.DifficultyScaling.ZoneHealthMultiplier ^ (zoneNumber - 1)
    local health = enemyDefinition.BaseHealth * healthMultiplier
    
    -- Calculate damage based on zone progression
    local damageMultiplier = math.sqrt(healthMultiplier) -- Damage scales slower than health
    local damage = enemyDefinition.BaseDamage * damageMultiplier
    
    -- Calculate coin reward based on zone progression
    local coinMultiplier = zoneDefinition.CoinMultiplier
    local coins = enemyDefinition.BaseCoins * coinMultiplier
    
    return {
        Health = math.floor(health),
        Damage = math.floor(damage),
        Coins = math.floor(coins)
    }
end

-- Calculate boss stats for a specific zone
function ZoneManager:CalculateBossStats(bossDefinition, zoneNumber)
    if not bossDefinition then return nil end
    
    local zoneDefinition = self:GetZoneDefinitionByNumber("WORLD_1", zoneNumber)
    if not zoneDefinition then return nil end
    
    -- Calculate health based on zone progression
    local healthMultiplier = ZoneConfig.DifficultyScaling.ZoneHealthMultiplier ^ (zoneNumber - 1)
    local health = bossDefinition.BaseHealth * healthMultiplier * ZoneConfig.DifficultyScaling.BossHealthMultiplier
    
    -- Calculate damage based on zone progression
    local damageMultiplier = math.sqrt(healthMultiplier) -- Damage scales slower than health
    local damage = bossDefinition.BaseDamage * damageMultiplier * math.sqrt(ZoneConfig.DifficultyScaling.BossHealthMultiplier)
    
    -- Calculate coin reward based on zone progression
    local coinMultiplier = zoneDefinition.CoinMultiplier * ZoneConfig.DifficultyScaling.BossRewardMultiplier
    local coins = bossDefinition.BaseCoins * coinMultiplier
    
    return {
        Health = math.floor(health),
        Damage = math.floor(damage),
        Coins = math.floor(coins)
    }
end

-- Create a new enemy instance
function ZoneManager:CreateEnemy(enemyID, zoneNumber, position)
    -- Get the enemy definition
    local enemyDefinition = self:GetEnemyDefinition(enemyID)
    if not enemyDefinition then
        warn("Enemy definition not found for ID: " .. enemyID)
        return nil
    end
    
    -- Calculate the enemy's stats
    local stats = self:CalculateEnemyStats(enemyDefinition, zoneNumber)
    if not stats then
        warn("Failed to calculate stats for enemy: " .. enemyID)
        return nil
    end
    
    -- Create the enemy data
    local enemyData = {
        ID = enemyID,
        UUID = Utilities.CreateUniqueID("ENEMY"),
        ZoneNumber = zoneNumber,
        Position = position or Vector3.new(0, 0, 0),
        Stats = stats,
        CurrentHealth = stats.Health,
        IsDead = false
    }
    
    -- Add the enemy to the active enemies table
    self.ActiveEnemies[enemyData.UUID] = enemyData
    
    return enemyData
end

-- Create a new boss instance
function ZoneManager:CreateBoss(bossID, zoneNumber, position)
    -- Get the boss definition
    local bossDefinition = self:GetBossDefinition(bossID)
    if not bossDefinition then
        warn("Boss definition not found for ID: " .. bossID)
        return nil
    end
    
    -- Calculate the boss's stats
    local stats = self:CalculateBossStats(bossDefinition, zoneNumber)
    if not stats then
        warn("Failed to calculate stats for boss: " .. bossID)
        return nil
    end
    
    -- Create the boss data
    local bossData = {
        ID = bossID,
        UUID = Utilities.CreateUniqueID("BOSS"),
        ZoneNumber = zoneNumber,
        Position = position or Vector3.new(0, 0, 0),
        Stats = stats,
        CurrentHealth = stats.Health,
        IsDead = false
    }
    
    -- Add the boss to the active bosses table
    self.ActiveBosses[bossData.UUID] = bossData
    
    return bossData
end

-- Create a new zone instance
function ZoneManager:CreateZone(zoneID, position)
    -- Get the zone definition
    local zoneDefinition = self:GetZoneDefinition(zoneID)
    if not zoneDefinition then
        warn("Zone definition not found for ID: " .. zoneID)
        return nil
    end
    
    -- Create the zone data
    local zoneData = {
        ID = zoneID,
        UUID = Utilities.CreateUniqueID("ZONE"),
        WorldID = zoneDefinition.WorldID,
        ZoneNumber = zoneDefinition.ZoneNumber,
        Position = position or Vector3.new(0, 0, 0),
        Enemies = {},
        Boss = nil,
        RebirthStatue = nil,
        Portal = nil
    }
    
    -- Add the zone to the active zones table
    self.ActiveZones[zoneData.UUID] = zoneData
    
    -- Create enemies for the zone
    for _, enemyType in ipairs(zoneDefinition.EnemyTypes) do
        -- Create multiple enemies of each type
        for i = 1, 5 do -- 5 enemies of each type
            local enemyPosition = position + Vector3.new(math.random(-50, 50), 0, math.random(-50, 50))
            local enemy = self:CreateEnemy(enemyType, zoneDefinition.ZoneNumber, enemyPosition)
            if enemy then
                table.insert(zoneData.Enemies, enemy.UUID)
            end
        end
    end
    
    -- Create a boss for the zone
    local bossPosition = position + Vector3.new(0, 0, 100) -- Boss is at the end of the zone
    local boss = self:CreateBoss(zoneDefinition.BossType, zoneDefinition.ZoneNumber, bossPosition)
    if boss then
        zoneData.Boss = boss.UUID
    end
    
    -- Create a rebirth statue if the zone should have one
    if zoneDefinition.HasRebirthStatue then
        local statuePosition = position + Vector3.new(50, 0, 0) -- Statue is to the right of the zone
        local statue = self:CreateRebirthStatue(zoneDefinition.ZoneNumber, statuePosition)
        if statue then
            zoneData.RebirthStatue = statue.UUID
        end
    end
    
    -- Create a portal if the zone should have one
    if zoneDefinition.HasPortal then
        local portalPosition = position + Vector3.new(0, 0, 150) -- Portal is beyond the boss
        local portal = self:CreatePortal(zoneDefinition.PortalDestination, portalPosition)
        if portal then
            zoneData.Portal = portal.UUID
        end
    end
    
    return zoneData
end

-- Create a new rebirth statue instance
function ZoneManager:CreateRebirthStatue(zoneNumber, position)
    -- Create the rebirth statue data
    local statueData = {
        UUID = Utilities.CreateUniqueID("STATUE"),
        ZoneNumber = zoneNumber,
        Position = position or Vector3.new(0, 0, 0)
    }
    
    -- Add the statue to the active rebirth statues table
    self.ActiveRebirthStatues[statueData.UUID] = statueData
    
    return statueData
end

-- Create a new portal instance
function ZoneManager:CreatePortal(destinationWorldID, position)
    -- Create the portal data
    local portalData = {
        UUID = Utilities.CreateUniqueID("PORTAL"),
        DestinationWorldID = destinationWorldID,
        Position = position or Vector3.new(0, 0, 0)
    }
    
    -- Add the portal to the active portals table
    self.ActivePortals[portalData.UUID] = portalData
    
    return portalData
end

-- Damage an enemy
function ZoneManager:DamageEnemy(enemyUUID, damage)
    local enemy = self.ActiveEnemies[enemyUUID]
    if not enemy or enemy.IsDead then return 0 end
    
    -- Apply damage
    local actualDamage = math.min(enemy.CurrentHealth, damage)
    enemy.CurrentHealth = enemy.CurrentHealth - actualDamage
    
    -- Check if the enemy is dead
    if enemy.CurrentHealth <= 0 then
        enemy.IsDead = true
    end
    
    return actualDamage
end

-- Damage a boss
function ZoneManager:DamageBoss(bossUUID, damage)
    local boss = self.ActiveBosses[bossUUID]
    if not boss or boss.IsDead then return 0 end
    
    -- Apply damage
    local actualDamage = math.min(boss.CurrentHealth, damage)
    boss.CurrentHealth = boss.CurrentHealth - actualDamage
    
    -- Check if the boss is dead
    if boss.CurrentHealth <= 0 then
        boss.IsDead = true
    end
    
    return actualDamage
end

-- Respawn an enemy
function ZoneManager:RespawnEnemy(enemyUUID)
    local enemy = self.ActiveEnemies[enemyUUID]
    if not enemy then return false end
    
    -- Get the enemy definition
    local enemyDefinition = self:GetEnemyDefinition(enemy.ID)
    if not enemyDefinition then return false end
    
    -- Calculate the enemy's stats
    local stats = self:CalculateEnemyStats(enemyDefinition, enemy.ZoneNumber)
    if not stats then return false end
    
    -- Reset the enemy's health and state
    enemy.Stats = stats
    enemy.CurrentHealth = stats.Health
    enemy.IsDead = false
    
    return true
end

-- Respawn a boss
function ZoneManager:RespawnBoss(bossUUID)
    local boss = self.ActiveBosses[bossUUID]
    if not boss then return false end
    
    -- Get the boss definition
    local bossDefinition = self:GetBossDefinition(boss.ID)
    if not bossDefinition then return false end
    
    -- Calculate the boss's stats
    local stats = self:CalculateBossStats(bossDefinition, boss.ZoneNumber)
    if not stats then return false end
    
    -- Reset the boss's health and state
    boss.Stats = stats
    boss.CurrentHealth = stats.Health
    boss.IsDead = false
    
    return true
end

-- Calculate rebirth rewards
function ZoneManager:CalculateRebirthReward(zoneNumber, currentRebirthLevel)
    return ZoneConfig.RebirthSystem.CalculateRebirthReward(zoneNumber, currentRebirthLevel)
end

-- Calculate rebirth cost
function ZoneManager:CalculateRebirthCost(currentRebirthLevel)
    return ZoneConfig.RebirthSystem.CalculateRebirthCost(currentRebirthLevel)
end

-- Perform a rebirth for a player
function ZoneManager:PerformRebirth(playerData, zoneNumber, dataManager, player)
    if not playerData or not dataManager or not player then return false end
    
    -- Calculate the rebirth cost
    local rebirthCost = self:CalculateRebirthCost(playerData.RebirthLevel or 0)
    
    -- Check if the player has enough coins
    if playerData.Coins < rebirthCost then
        return false
    end
    
    -- Perform the rebirth
    return dataManager:PerformRebirth(player, zoneNumber)
end

-- Get the next zone for a player
function ZoneManager:GetNextZone(playerData)
    if not playerData or not playerData.UnlockedZones then return 1 end
    
    -- Find the highest unlocked zone
    local highestZone = 0
    for _, zoneNumber in ipairs(playerData.UnlockedZones) do
        if zoneNumber > highestZone then
            highestZone = zoneNumber
        end
    end
    
    -- The next zone is the highest unlocked zone + 1
    return highestZone + 1
end

-- Check if a player has completed a world
function ZoneManager:HasCompletedWorld(playerData, worldID)
    if not playerData or not playerData.UnlockedZones then return false end
    
    -- Get the world definition
    local worldDefinition = self:GetWorldDefinition(worldID)
    if not worldDefinition then return false end
    
    -- Check if the player has unlocked the final zone of the world
    local finalZoneNumber = GameConfig.WorldSettings.ZonesPerWorld
    return Utilities.TableContains(playerData.UnlockedZones, finalZoneNumber)
end

-- Get all zones for a world
function ZoneManager:GetZonesForWorld(worldID)
    local zones = {}
    
    for _, zone in ipairs(ZoneConfig.Zones) do
        if zone.WorldID == worldID then
            table.insert(zones, zone)
        end
    end
    
    -- Sort zones by zone number
    table.sort(zones, function(a, b) return a.ZoneNumber < b.ZoneNumber end)
    
    return zones
end

return ZoneManager

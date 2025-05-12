--[[
    GameInit.lua
    Initializes the game and sets up the core systems
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- Import modules
local DataManager = require(ReplicatedStorage.Modules.DataManager)
local AvatarManager = require(ReplicatedStorage.Modules.AvatarManager)
local ZoneManager = require(ReplicatedStorage.Modules.ZoneManager)
local CurrencyManager = require(ReplicatedStorage.Modules.CurrencyManager)
local DrawManager = require(ReplicatedStorage.Modules.DrawManager)
local RelicManager = require(ReplicatedStorage.Modules.RelicManager)
local GearManager = require(ReplicatedStorage.Modules.GearManager)
local AvatarSpawner = require(script.Parent.AvatarSpawner)

-- Initialize modules
local dataManager = DataManager.new()
local avatarManager = AvatarManager.new()
local zoneManager = ZoneManager.new()
local currencyManager = CurrencyManager.new()
local drawManager = DrawManager.new()
local relicManager = RelicManager.new()
local gearManager = GearManager.new()

-- Initialize AvatarSpawner with dependencies
local avatarSpawner = AvatarSpawner.init(dataManager, avatarManager)






-- Create RemoteEvents for client-server communication
local remoteEvents = {
    -- Player Actions
    PlayerReady = Instance.new("RemoteEvent"),
    
    -- Avatar Actions
    EquipAvatar = Instance.new("RemoteEvent"),
    UnequipAvatar = Instance.new("RemoteEvent"),
    EquipAura = Instance.new("RemoteEvent"),
    UnequipAura = Instance.new("RemoteEvent"),
    FuseAvatars = Instance.new("RemoteEvent"),
    FuseAuras = Instance.new("RemoteEvent"),
    UpgradeAvatarToGolden = Instance.new("RemoteEvent"),
    GetStarterAvatar = Instance.new("RemoteEvent"), -- New event for getting the starter avatar
    
    -- Gear Actions
    EquipGear = Instance.new("RemoteEvent"),
    UnequipGear = Instance.new("RemoteEvent"),
    EnhanceGear = Instance.new("RemoteEvent"),
    FuseGear = Instance.new("RemoteEvent"),
    
    -- Zone Actions
    UnlockZone = Instance.new("RemoteEvent"),
    DamageEnemy = Instance.new("RemoteEvent"),
    DamageBoss = Instance.new("RemoteEvent"),
    PerformRebirth = Instance.new("RemoteEvent"),
    
    -- Draw Actions
    PerformAvatarDraw = Instance.new("RemoteEvent"),
    PerformGearDraw = Instance.new("RemoteEvent"),
    PerformAuraDraw = Instance.new("RemoteEvent"),
    PerformRelicDraw = Instance.new("RemoteEvent"),
    PerformMultiDraw = Instance.new("RemoteEvent"),
    
    -- Relic Actions
    EquipRelic = Instance.new("RemoteEvent"),
    UnequipRelic = Instance.new("RemoteEvent"),
    
    -- Data Actions
    RequestPlayerData = Instance.new("RemoteEvent"),
    RequestZoneData = Instance.new("RemoteEvent"),
    
    -- UI Actions
    UpdateUI = Instance.new("RemoteEvent")
}

-- Create RemoteFunctions for client-server communication
local remoteFunctions = {
    -- Data Functions
    GetPlayerData = Instance.new("RemoteFunction"),
    GetAvatarInfo = Instance.new("RemoteFunction"),
    GetAuraInfo = Instance.new("RemoteFunction"),
    GetRelicInfo = Instance.new("RemoteFunction"),
    GetGearInfo = Instance.new("RemoteFunction"),
    GetZoneInfo = Instance.new("RemoteFunction"),
    GetDrawChances = Instance.new("RemoteFunction"),
    GetGoldenUpgradeCost = Instance.new("RemoteFunction"),
    GetEnhancementCost = Instance.new("RemoteFunction")
}

-- Parent RemoteEvents and RemoteFunctions to ReplicatedStorage
local remoteFolder = Instance.new("Folder")
remoteFolder.Name = "Remotes"
remoteFolder.Parent = ReplicatedStorage

for name, event in pairs(remoteEvents) do
    event.Name = name
    event.Parent = remoteFolder
end

for name, func in pairs(remoteFunctions) do
    func.Name = name
    func.Parent = remoteFolder
end





-- We're now using the AvatarSpawner module for avatar spawning functionality

-- Player character added event (handles respawning)
local function onCharacterAdded(character, player)
    -- Wait for the character to be fully loaded
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- We no longer automatically spawn avatars when the character is added
    -- Instead, the player will need to request their first avatar using the GetStarterAvatar event
    
    -- Handle character death
    humanoid.Died:Connect(function()
        -- Despawn avatars when character dies using the AvatarSpawner module
        avatarSpawner.despawnPlayerAvatars(player)
    end)
end

-- Function to open barriers for unlocked zones
local function openBarriersForUnlockedZones(playerData)
    if not playerData or not playerData.UnlockedZones then return end
    
    -- Open barriers for all unlocked zones
    for _, zoneNumber in ipairs(playerData.UnlockedZones) do
        -- Assuming world 1 for now
        zoneManager:OpenBarrier(1, zoneNumber)
    end
    
    -- Make sure barriers for locked zones are closed
    -- First, get the highest unlocked zone
    local highestUnlockedZone = 0
    for _, zoneNumber in ipairs(playerData.UnlockedZones) do
        if zoneNumber > highestUnlockedZone then
            highestUnlockedZone = zoneNumber
        end
    end
    
    -- The next zone is the highest unlocked zone + 1
    local nextZone = highestUnlockedZone + 1
    
    -- Make sure the barrier for the next zone is closed
    -- We don't need to call CloseBarrier explicitly because the InitializeBarriers function
    -- in ZoneManager will make all barriers visible and solid by default
    
    print("Opened barriers for unlocked zones up to zone " .. highestUnlockedZone)
    print("Next zone to unlock: " .. nextZone)
end



-- Player joined event
Players.PlayerAdded:Connect(function(player)
    print("Player joined: " .. player.Name)
    
    -- Load player data
    local playerData = dataManager:LoadData(player)
    if not playerData then
        warn("Failed to load data for player: " .. player.Name)
        return
    end
    
    -- Connect character added event
    player.CharacterAdded:Connect(function(character)
        onCharacterAdded(character, player)
    end)
    
    -- If the player already has a character, handle it
    if player.Character then
        onCharacterAdded(player.Character, player)
    end
    
    print("Player data loaded for: " .. player.Name)
    
    -- Set up player's game state
    -- This would include creating the player's character, setting up their UI, etc.
    
    -- Create player's starting zone
    local startingZoneNumber = 1
    if playerData.UnlockedZones and #playerData.UnlockedZones > 0 then
        startingZoneNumber = math.max(unpack(playerData.UnlockedZones))
    end
    
    local startingZoneID = "ZONE_1_" .. startingZoneNumber
    local zonePosition = Vector3.new(0, 0, 0) -- Adjust as needed
    local zone = zoneManager:CreateZone(startingZoneID, zonePosition)
    
    if not zone then
        warn("Failed to create zone: " .. startingZoneID)
        return
    end
    
    print("Created zone: " .. startingZoneID .. " for player: " .. player.Name)
    
    -- Open barriers for all unlocked zones
    openBarriersForUnlockedZones(playerData)
    
    -- Teleport player to starting zone
    -- This would involve setting the player's character position
    
    -- Update player's relics to ensure multipliers are applied
    relicManager:UpdatePlayerMultipliers(playerData)
    
    -- We no longer automatically spawn avatars when the player joins
    -- Instead, the player will need to request their first avatar using the GetStarterAvatar event
    
    -- Notify client that the player is ready
    remoteEvents.PlayerReady:FireClient(player, {
        ZoneID = startingZoneID,
        PlayerData = playerData
    })
end)


-- Player leaving event
Players.PlayerRemoving:Connect(function(player)
    print("Player leaving: " .. player.Name)
    
    -- Despawn all avatars for this player using the AvatarSpawner module
    avatarSpawner.despawnPlayerAvatars(player)
    
    -- Save player data
    dataManager:PlayerRemoving(player)
    
    print("Player data saved for: " .. player.Name)
end)

-- Handle remote events

-- Avatar Actions
-- Handler for the GetStarterAvatar event
remoteEvents.GetStarterAvatar.OnServerEvent:Connect(function(player)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    -- Check if the player already has avatars
    if #playerData.Avatars > 0 then
        -- Player already has avatars, no need to give them a starter avatar
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "StarterAvatarError",
            ErrorMessage = "You already have avatars!",
            PlayerData = playerData
        })
        return
    end
    
    -- Give the player a starter avatar
    local starterAvatar = {
        ID = "STARTER_AVATAR",
        UUID = avatarManager:GenerateUUID(),
        Level = 1,
        XP = 0,
        Equipped = true,
        Variant = "Normal",
        EquippedGear = nil,
        EquippedAura = nil
    }
    
    -- Add the avatar to the player's data
    table.insert(playerData.Avatars, starterAvatar)
    
    -- Save the player's data
    dataManager:SaveData(player, playerData)
    
    -- Try to spawn the avatar
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local success = avatarSpawner.attemptSpawnAvatar(starterAvatar, player)
        if not success then
            warn("Failed to spawn starter avatar for player: " .. player.Name)
        end
    end
    
    -- Notify the client
    remoteEvents.UpdateUI:FireClient(player, {
        Type = "StarterAvatarReceived",
        Avatar = starterAvatar,
        PlayerData = playerData
    })
end)

remoteEvents.EquipAvatar.OnServerEvent:Connect(function(player, avatarUUID)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local success = avatarManager:EquipAvatar(playerData, avatarUUID)
    if success then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "AvatarEquipped",
            AvatarUUID = avatarUUID,
            PlayerData = playerData
        })
    end
end)

remoteEvents.UnequipAvatar.OnServerEvent:Connect(function(player, avatarUUID)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local success = avatarManager:UnequipAvatar(playerData, avatarUUID)
    if success then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "AvatarUnequipped",
            AvatarUUID = avatarUUID,
            PlayerData = playerData
        })
    end
end)

remoteEvents.EquipAura.OnServerEvent:Connect(function(player, avatarUUID, auraUUID)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local success = avatarManager:EquipAura(playerData, avatarUUID, auraUUID)
    if success then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "AuraEquipped",
            AvatarUUID = avatarUUID,
            AuraUUID = auraUUID,
            PlayerData = playerData
        })
    end
end)

remoteEvents.UnequipAura.OnServerEvent:Connect(function(player, avatarUUID)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local success = avatarManager:UnequipAura(playerData, avatarUUID)
    if success then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "AuraUnequipped",
            AvatarUUID = avatarUUID,
            PlayerData = playerData
        })
    end
end)

remoteEvents.FuseAvatars.OnServerEvent:Connect(function(player, avatarUUIDs)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local fusedAvatar = avatarManager:FuseAvatars(playerData, avatarUUIDs)
    if fusedAvatar then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "AvatarsFused",
            FusedAvatar = fusedAvatar,
            PlayerData = playerData
        })
    end
end)

remoteEvents.FuseAuras.OnServerEvent:Connect(function(player, auraUUIDs)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local fusedAura = avatarManager:FuseAuras(playerData, auraUUIDs)
    if fusedAura then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "AurasFused",
            FusedAura = fusedAura,
            PlayerData = playerData
        })
    end
end)

remoteEvents.UpgradeAvatarToGolden.OnServerEvent:Connect(function(player, avatarUUID)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local success, result = avatarManager:UpgradeAvatarToGolden(playerData, avatarUUID, dataManager, player, currencyManager)
    if success then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "AvatarUpgradedToGolden",
            AvatarUUID = avatarUUID,
            GoldenAvatar = result,
            PlayerData = playerData
        })
    else
        -- Send error message to client
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "AvatarUpgradeError",
            ErrorMessage = result, -- In case of failure, result contains the error message
            AvatarUUID = avatarUUID
        })
    end
end)

-- Zone Actions
remoteEvents.UnlockZone.OnServerEvent:Connect(function(player, zoneNumber)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local success = currencyManager:UnlockZone(playerData, zoneNumber, dataManager, player, zoneManager)
    if success then
        -- Create the new zone
        local zoneID = "ZONE_1_" .. zoneNumber
        local zonePosition = Vector3.new(0, 0, zoneNumber * 100) -- Adjust as needed
        local zone = zoneManager:CreateZone(zoneID, zonePosition)
        
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "ZoneUnlocked",
            ZoneNumber = zoneNumber,
            ZoneID = zoneID,
            PlayerData = playerData
        })
    end
end)

remoteEvents.DamageEnemy.OnServerEvent:Connect(function(player, enemyUUID, damage)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local actualDamage = zoneManager:DamageEnemy(enemyUUID, damage)
    local enemy = zoneManager.ActiveEnemies[enemyUUID]
    
    if enemy and enemy.IsDead then
        -- Award currency for defeating the enemy
        currencyManager:AwardEnemyDefeatCurrency(playerData, enemy.Stats, dataManager, player)
        
        -- Respawn the enemy after a delay
        spawn(function()
            wait(5) -- 5 second respawn time
            zoneManager:RespawnEnemy(enemyUUID)
            
            remoteEvents.UpdateUI:FireClient(player, {
                Type = "EnemyRespawned",
                EnemyUUID = enemyUUID,
                Enemy = zoneManager.ActiveEnemies[enemyUUID]
            })
        end)
    end
    
    remoteEvents.UpdateUI:FireClient(player, {
        Type = "EnemyDamaged",
        EnemyUUID = enemyUUID,
        Damage = actualDamage,
        IsDead = enemy and enemy.IsDead or false,
        PlayerData = playerData
    })
end)

remoteEvents.DamageBoss.OnServerEvent:Connect(function(player, bossUUID, damage)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local actualDamage = zoneManager:DamageBoss(bossUUID, damage)
    local boss = zoneManager.ActiveBosses[bossUUID]
    
    if boss and boss.IsDead then
        -- Award currency for defeating the boss
        currencyManager:AwardBossDefeatCurrency(playerData, boss.Stats, dataManager, player)
        
        -- Respawn the boss after a delay
        spawn(function()
            wait(10) -- 10 second respawn time
            zoneManager:RespawnBoss(bossUUID)
            
            remoteEvents.UpdateUI:FireClient(player, {
                Type = "BossRespawned",
                BossUUID = bossUUID,
                Boss = zoneManager.ActiveBosses[bossUUID]
            })
        end)
    end
    
    remoteEvents.UpdateUI:FireClient(player, {
        Type = "BossDamaged",
        BossUUID = bossUUID,
        Damage = actualDamage,
        IsDead = boss and boss.IsDead or false,
        PlayerData = playerData
    })
end)

remoteEvents.PerformRebirth.OnServerEvent:Connect(function(player, zoneNumber)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local success, result = currencyManager:PerformRebirth(playerData, zoneNumber, dataManager, player, zoneManager, avatarManager)
    if success then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "RebirthPerformed",
            ZoneNumber = zoneNumber,
            RebirthLevel = result.RebirthLevel,
            Reward = result.Reward,
            RewardMessage = result.RewardMessage,
            PlayerData = playerData
        })
    end
end)

-- Draw Actions
remoteEvents.PerformAvatarDraw.OnServerEvent:Connect(function(player, tier, zoneNumber)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local success, result = drawManager:PerformAvatarDraw(playerData, tier, zoneNumber, dataManager, player, avatarManager, currencyManager)
    if success then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "AvatarDrawPerformed",
            Tier = tier,
            Avatar = result,
            PlayerData = playerData
        })
    end
end)

remoteEvents.PerformAuraDraw.OnServerEvent:Connect(function(player, tier, zoneNumber)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local success, result = drawManager:PerformAuraDraw(playerData, tier, zoneNumber, dataManager, player, avatarManager, currencyManager)
    if success then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "AuraDrawPerformed",
            Tier = tier,
            Aura = result,
            PlayerData = playerData
        })
    end
end)

remoteEvents.PerformRelicDraw.OnServerEvent:Connect(function(player, tier, zoneNumber)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local success, result = drawManager:PerformRelicDraw(playerData, tier, zoneNumber, dataManager, player, relicManager, currencyManager)
    if success then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "RelicDrawPerformed",
            Tier = tier,
            Relic = result,
            PlayerData = playerData
        })
    end
end)

remoteEvents.PerformMultiDraw.OnServerEvent:Connect(function(player, drawType, tier, count, zoneNumber)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local success, results = drawManager:PerformMultiDraw(playerData, drawType, tier, count, zoneNumber, dataManager, player, avatarManager, relicManager, currencyManager)
    if success then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "MultiDrawPerformed",
            DrawType = drawType,
            Tier = tier,
            Count = count,
            Results = results,
            PlayerData = playerData
        })
    end
end)

-- Gear Actions
remoteEvents.EquipGear.OnServerEvent:Connect(function(player, gearUUID, avatarUUID)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local success = gearManager:EquipGear(playerData, gearUUID, avatarUUID)
    if success then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "GearEquipped",
            GearUUID = gearUUID,
            AvatarUUID = avatarUUID,
            PlayerData = playerData
        })
    end
end)

remoteEvents.UnequipGear.OnServerEvent:Connect(function(player, gearUUID)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local success = gearManager:UnequipGear(playerData, gearUUID)
    if success then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "GearUnequipped",
            GearUUID = gearUUID,
            PlayerData = playerData
        })
    end
end)

remoteEvents.EnhanceGear.OnServerEvent:Connect(function(player, gearUUID)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local success, result = gearManager:EnhanceGear(playerData, gearUUID, dataManager, player, currencyManager)
    if success then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "GearEnhanced",
            GearUUID = gearUUID,
            Success = result.Success,
            NewLevel = result.NewLevel,
            Gear = result.Gear,
            PlayerData = playerData
        })
    end
end)

remoteEvents.FuseGear.OnServerEvent:Connect(function(player, gearUUIDs)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local success, fusedGear = gearManager:FuseGear(playerData, gearUUIDs)
    if success then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "GearFused",
            FusedGear = fusedGear,
            PlayerData = playerData
        })
    end
end)

remoteEvents.PerformGearDraw.OnServerEvent:Connect(function(player, tier, zoneNumber)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local gear = currencyManager:PerformGearDraw(playerData, tier, zoneNumber, dataManager, player, gearManager)
    if gear then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "GearDrawPerformed",
            Tier = tier,
            Gear = gear,
            PlayerData = playerData
        })
    end
end)

-- Relic Actions
remoteEvents.EquipRelic.OnServerEvent:Connect(function(player, relicUUID)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local success = relicManager:EquipRelic(playerData, relicUUID)
    if success then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "RelicEquipped",
            RelicUUID = relicUUID,
            PlayerData = playerData
        })
    end
end)

remoteEvents.UnequipRelic.OnServerEvent:Connect(function(player, relicUUID)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    local success = relicManager:UnequipRelic(playerData, relicUUID)
    if success then
        remoteEvents.UpdateUI:FireClient(player, {
            Type = "RelicUnequipped",
            RelicUUID = relicUUID,
            PlayerData = playerData
        })
    end
end)

-- Data Actions
remoteEvents.RequestPlayerData.OnServerEvent:Connect(function(player)
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    remoteEvents.UpdateUI:FireClient(player, {
        Type = "PlayerDataUpdated",
        PlayerData = playerData
    })
end)

remoteEvents.RequestZoneData.OnServerEvent:Connect(function(player, zoneID)
    local zone = nil
    for uuid, zoneData in pairs(zoneManager.ActiveZones) do
        if zoneData.ID == zoneID then
            zone = zoneData
            break
        end
    end
    
    if not zone then return end
    
    -- Collect all the data for the zone
    local zoneData = {
        ID = zone.ID,
        UUID = zone.UUID,
        WorldID = zone.WorldID,
        ZoneNumber = zone.ZoneNumber,
        Position = zone.Position,
        Enemies = {},
        Boss = nil,
        RebirthStatue = nil,
        Portal = nil
    }
    
    -- Add enemy data
    for _, enemyUUID in ipairs(zone.Enemies) do
        local enemy = zoneManager.ActiveEnemies[enemyUUID]
        if enemy then
            table.insert(zoneData.Enemies, enemy)
        end
    end
    
    -- Add boss data
    if zone.Boss then
        zoneData.Boss = zoneManager.ActiveBosses[zone.Boss]
    end
    
    -- Add rebirth statue data
    if zone.RebirthStatue then
        zoneData.RebirthStatue = zoneManager.ActiveRebirthStatues[zone.RebirthStatue]
    end
    
    -- Add portal data
    if zone.Portal then
        zoneData.Portal = zoneManager.ActivePortals[zone.Portal]
    end
    
    remoteEvents.UpdateUI:FireClient(player, {
        Type = "ZoneDataUpdated",
        ZoneData = zoneData
    })
end)

-- Handle remote functions

-- Data Functions
remoteFunctions.GetPlayerData.OnServerInvoke = function(player)
    return dataManager:GetData(player)
end

remoteFunctions.GetAvatarInfo.OnServerInvoke = function(player, avatarID)
    return avatarManager:GetAvatarDefinition(avatarID)
end

remoteFunctions.GetAuraInfo.OnServerInvoke = function(player, auraID)
    return avatarManager:GetAuraDefinition(auraID)
end

remoteFunctions.GetRelicInfo.OnServerInvoke = function(player, relicID)
    return relicManager:GetRelicDefinition(relicID)
end

remoteFunctions.GetGearInfo.OnServerInvoke = function(player, gearID)
    return gearManager:GetGearDefinition(gearID)
end

remoteFunctions.GetZoneInfo.OnServerInvoke = function(player, zoneID)
    return zoneManager:GetZoneDefinition(zoneID)
end

remoteFunctions.GetEnhancementCost.OnServerInvoke = function(player, gearUUID)
    local playerData = dataManager:GetData(player)
    if not playerData then return nil, "Player data not found" end
    
    -- Find the gear in the player's inventory
    local gearToEnhance = nil
    for _, gear in ipairs(playerData.Gear) do
        if gear.UUID == gearUUID then
            gearToEnhance = gear
            break
        end
    end
    
    if not gearToEnhance then
        return nil, "Gear not found in player's inventory"
    end
    
    -- Check if gear is already at max enhancement level
    if gearToEnhance.EnhancementLevel >= GearConfig.EnhancementSystem.MaxLevel then
        return nil, "Gear is already at maximum enhancement level"
    end
    
    -- Calculate enhancement cost
    local gearDefinition = gearManager:GetGearDefinition(gearToEnhance.ID)
    if not gearDefinition then
        return nil, "Invalid gear definition"
    end
    
    local baseCost = 100 -- Base cost for enhancement
    local costMultiplier = GearConfig.EnhancementSystem.CostMultiplier
    local nextLevel = gearToEnhance.EnhancementLevel + 1
    local enhancementCost = math.floor(baseCost * nextLevel * costMultiplier)
    
    -- Get fail chance
    local failChance = GearConfig.EnhancementSystem.FailChance[nextLevel] or 0
    
    return {
        Cost = enhancementCost,
        CurrencyType = "Coins",
        NextLevel = nextLevel,
        FailChance = failChance,
        CanAfford = currencyManager:HasEnoughCurrency(playerData, "Coins", enhancementCost)
    }
end

remoteFunctions.GetDrawChances.OnServerInvoke = function(player, drawType, tier, zoneNumber)
    return drawManager:GetDrawChancesDisplay(drawType, tier, zoneNumber)
end

remoteFunctions.GetGoldenUpgradeCost.OnServerInvoke = function(player, avatarUUID)
    local playerData = dataManager:GetData(player)
    if not playerData then return nil, "Player data not found" end
    
    -- Find the avatar in the player's inventory
    local avatarToUpgrade = nil
    for _, avatar in ipairs(playerData.Avatars) do
        if avatar.UUID == avatarUUID then
            avatarToUpgrade = avatar
            break
        end
    end
    
    if not avatarToUpgrade then
        return nil, "Avatar not found in player's inventory"
    end
    
    -- Check if avatar is already golden
    if avatarToUpgrade.Variant == "Golden" then
        return nil, "Avatar is already golden"
    end
    
    -- Get the avatar definition
    local avatarDefinition = avatarManager:GetAvatarDefinition(avatarToUpgrade.ID)
    if not avatarDefinition then
        return nil, "Avatar definition not found"
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
    
    -- Check if player has reached the required zone to unlock golden upgrades
    local highestZoneReached = playerData.Stats.HighestZoneReached or 0
    local unlockZone = AvatarConfig.GoldenUpgradeSystem.UnlockZone
    local isUnlocked = highestZoneReached >= unlockZone
    
    return {
        Cost = upgradeCost,
        CurrencyType = currencyType,
        IsUnlocked = isUnlocked,
        UnlockZone = unlockZone,
        CanAfford = currencyManager:HasEnoughCurrency(playerData, currencyType, upgradeCost)
    }
end

print("Game initialized successfully!")

--[[
    AvatarSpawner.lua
    Handles spawning and despawning of player avatars
]]

local AvatarSpawner = {}
local RunService = game:GetService("RunService")

-- Initialize with required dependencies
function AvatarSpawner.init(dataManager, avatarManager)
    AvatarSpawner.dataManager = dataManager
    AvatarSpawner.avatarManager = avatarManager
    AvatarSpawner.pendingSpawns = {}
    
    -- Set up a heartbeat connection to check for pending spawns
    RunService.Heartbeat:Connect(function()
        AvatarSpawner.checkPendingSpawns()
    end)
    
    return AvatarSpawner
end

-- Function to check and process pending spawns
function AvatarSpawner.checkPendingSpawns()
    for playerUserId, spawnData in pairs(AvatarSpawner.pendingSpawns) do
        local player = spawnData.Player
        
        -- Skip if player is no longer in game
        if not player or not player:IsDescendantOf(game) then
            AvatarSpawner.pendingSpawns[playerUserId] = nil
            continue
        end
        
        -- Check if character is loaded
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Character is loaded, attempt to spawn avatars
            print("Character loaded for pending spawn, attempting to spawn avatars for: " .. player.Name)
            AvatarSpawner.spawnPlayerAvatars(player)
            
            -- Remove from pending spawns
            AvatarSpawner.pendingSpawns[playerUserId] = nil
        else
            -- Check if we've exceeded the timeout
            if os.time() - spawnData.StartTime > spawnData.Timeout then
                warn("Timed out waiting for character to load for pending spawn: " .. player.Name)
                AvatarSpawner.pendingSpawns[playerUserId] = nil
            end
        end
    end
end

-- Function to schedule avatar spawning for when character is loaded
function AvatarSpawner.scheduleSpawn(player, timeout)
    timeout = timeout or 30 -- Default timeout of 30 seconds
    
    -- Skip if player already has a pending spawn
    if AvatarSpawner.pendingSpawns[player.UserId] then
        return
    end
    
    -- Add to pending spawns
    AvatarSpawner.pendingSpawns[player.UserId] = {
        Player = player,
        StartTime = os.time(),
        Timeout = timeout
    }
    
    print("Scheduled avatar spawn for player: " .. player.Name)
end

-- Function to wait for character to be fully loaded
function AvatarSpawner.waitForCharacter(player, timeout)
    timeout = timeout or 10 -- Default timeout of 10 seconds
    
    -- If character already exists and has HumanoidRootPart, return it
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        return player.Character
    end
    
    -- Wait for character to be added if it doesn't exist
    local startTime = os.time()
    local character = player.Character
    
    while not character or not character:FindFirstChild("HumanoidRootPart") do
        -- Check if we've exceeded the timeout
        if os.time() - startTime > timeout then
            warn("Timed out waiting for character to load for player: " .. player.Name)
            return nil
        end
        
        -- Wait a short time before checking again
        wait(0.1)
        
        -- Update character reference
        character = player.Character
    end
    
    return character
end

-- Function to attempt spawning a single avatar with retries
function AvatarSpawner.attemptSpawnAvatar(avatar, player, maxRetries)
    local avatarManager = AvatarSpawner.avatarManager
    maxRetries = maxRetries or 3
    
    -- Validate avatar data
    if not avatar.ID then
        warn("Avatar missing ID for player: " .. player.Name)
        return false
    end
    
    -- Wait for character to be fully loaded
    local character = AvatarSpawner.waitForCharacter(player)
    if not character then
        warn("Failed to get character for player: " .. player.Name)
        return false
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        warn("HumanoidRootPart not found for player: " .. player.Name)
        return false
    end
    
    -- Calculate spawn position
    local position = rootPart.Position + Vector3.new(0, 0, 5) -- Spawn slightly in front of player
    
    -- Try to spawn the avatar with retries
    for attempt = 1, maxRetries do
        -- Add error handling around the SpawnAvatarInWorld call
        local success, result = pcall(function()
            return avatarManager:SpawnAvatarInWorld(avatar, position, player)
        end)
        
        if success and result then
            print("Spawned avatar: " .. avatar.ID .. " for player: " .. player.Name .. " (attempt " .. attempt .. ")")
            return true
        else
            if not success then
                warn("Error spawning avatar: " .. avatar.ID .. " for player: " .. player.Name .. " - " .. tostring(result) .. " (attempt " .. attempt .. ")")
            else
                warn("Failed to spawn avatar: " .. avatar.ID .. " for player: " .. player.Name .. " (attempt " .. attempt .. ")")
            end
            
            -- Wait a bit before retrying
            if attempt < maxRetries then
                wait(0.5)
            end
        end
    end
    
    warn("Failed to spawn avatar after " .. maxRetries .. " attempts: " .. avatar.ID .. " for player: " .. player.Name)
    return false
end

-- Function to spawn player's avatars
function AvatarSpawner.spawnPlayerAvatars(player)
    local dataManager = AvatarSpawner.dataManager
    local avatarManager = AvatarSpawner.avatarManager
    
    local playerData = dataManager:GetData(player)
    if not playerData then return end
    
    -- Despawn any existing avatars for this player
    for uuid, avatarInfo in pairs(avatarManager.ActiveAvatars) do
        if avatarInfo.Player == player then
            -- Add error handling around the DespawnAvatar call
            local success, result = pcall(function()
                avatarManager:DespawnAvatar(uuid)
            end)
            
            if not success then
                warn("Error despawning avatar: " .. uuid .. " for player: " .. player.Name .. " - " .. tostring(result))
            end
        end
    end
    
    -- Spawn the player's equipped avatars
    local spawnedAny = false
    for _, avatar in ipairs(playerData.Avatars) do
        if avatar.Equipped then
            local success = AvatarSpawner.attemptSpawnAvatar(avatar, player)
            if success then
                spawnedAny = true
            end
        end
    end
    
    -- If no avatars were spawned, try again after a delay
    if not spawnedAny and #playerData.Avatars > 0 then
        print("No avatars spawned for player: " .. player.Name .. ", retrying after delay")
        spawn(function()
            wait(2) -- Wait 2 seconds before retrying
            
            -- Try one more time to spawn avatars
            for _, avatar in ipairs(playerData.Avatars) do
                if avatar.Equipped then
                    AvatarSpawner.attemptSpawnAvatar(avatar, player, 1) -- Just one retry
                end
            end
        end)
    end
end

-- Function to despawn all avatars for a player
function AvatarSpawner.despawnPlayerAvatars(player)
    local avatarManager = AvatarSpawner.avatarManager
    
    for uuid, avatarInfo in pairs(avatarManager.ActiveAvatars) do
        if avatarInfo.Player == player then
            -- Add error handling around the DespawnAvatar call
            local success, result = pcall(function()
                avatarManager:DespawnAvatar(uuid)
            end)
            
            if not success then
                warn("Error despawning avatar: " .. uuid .. " for player: " .. player.Name .. " - " .. tostring(result))
            end
        end
    end
end

return AvatarSpawner

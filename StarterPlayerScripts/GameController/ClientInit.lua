--[[
    ClientInit.lua
    Initializes the client-side game logic and handles UI interactions
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Get the local player
local player = Players.LocalPlayer

-- Get remote events and functions
local remoteFolder = ReplicatedStorage:WaitForChild("Remotes")
local remoteEvents = {
    -- Player Actions
    PlayerReady = remoteFolder:WaitForChild("PlayerReady"),
    
    -- Avatar Actions
    EquipAvatar = remoteFolder:WaitForChild("EquipAvatar"),
    UnequipAvatar = remoteFolder:WaitForChild("UnequipAvatar"),
    EquipAura = remoteFolder:WaitForChild("EquipAura"),
    UnequipAura = remoteFolder:WaitForChild("UnequipAura"),
    FuseAvatars = remoteFolder:WaitForChild("FuseAvatars"),
    FuseAuras = remoteFolder:WaitForChild("FuseAuras"),
    UpgradeAvatarToGolden = remoteFolder:WaitForChild("UpgradeAvatarToGolden"),
    
    -- Gear Actions
    EquipGear = remoteFolder:WaitForChild("EquipGear"),
    UnequipGear = remoteFolder:WaitForChild("UnequipGear"),
    EnhanceGear = remoteFolder:WaitForChild("EnhanceGear"),
    FuseGear = remoteFolder:WaitForChild("FuseGear"),
    
    -- Zone Actions
    UnlockZone = remoteFolder:WaitForChild("UnlockZone"),
    DamageEnemy = remoteFolder:WaitForChild("DamageEnemy"),
    DamageBoss = remoteFolder:WaitForChild("DamageBoss"),
    PerformRebirth = remoteFolder:WaitForChild("PerformRebirth"),
    
    -- Draw Actions
    PerformGearDraw = remoteFolder:WaitForChild("PerformGearDraw"),
    PerformAuraDraw = remoteFolder:WaitForChild("PerformAuraDraw"),
    PerformRelicDraw = remoteFolder:WaitForChild("PerformRelicDraw"),
    PerformMultiDraw = remoteFolder:WaitForChild("PerformMultiDraw"),
    
    -- Relic Actions
    EquipRelic = remoteFolder:WaitForChild("EquipRelic"),
    UnequipRelic = remoteFolder:WaitForChild("UnequipRelic"),
    
    -- Data Actions
    RequestPlayerData = remoteFolder:WaitForChild("RequestPlayerData"),
    RequestZoneData = remoteFolder:WaitForChild("RequestZoneData"),
    
    -- UI Actions
    UpdateUI = remoteFolder:WaitForChild("UpdateUI")
}

local remoteFunctions = {
    -- Data Functions
    GetPlayerData = remoteFolder:WaitForChild("GetPlayerData"),
    GetAvatarInfo = remoteFolder:WaitForChild("GetAvatarInfo"),
    GetAuraInfo = remoteFolder:WaitForChild("GetAuraInfo"),
    GetRelicInfo = remoteFolder:WaitForChild("GetRelicInfo"),
    GetGearInfo = remoteFolder:WaitForChild("GetGearInfo"),
    GetZoneInfo = remoteFolder:WaitForChild("GetZoneInfo"),
    GetDrawChances = remoteFolder:WaitForChild("GetDrawChances"),
    GetGoldenUpgradeCost = remoteFolder:WaitForChild("GetGoldenUpgradeCost"),
    GetEnhancementCost = remoteFolder:WaitForChild("GetEnhancementCost")
}

-- Game state
local gameState = {
    PlayerData = nil,
    CurrentZone = nil,
    EquippedPets = {},
    ActiveEnemies = {},
    ActiveBoss = nil,
    IsAttacking = false,
    TargetEnemy = nil,
    AutoAttackEnabled = false,
    UIState = {
        CurrentTab = "Pets",
        InventoryFilter = "All",
        ShopTab = "Pets",
        DrawTier = "Basic"
    }
}

-- UI References
local playerGui = player:WaitForChild("PlayerGui")
local mainUI = playerGui:WaitForChild("MainUI")
local currencyDisplay = mainUI:WaitForChild("CurrencyDisplay")
local petInventory = mainUI:WaitForChild("PetInventory")
local shopUI = mainUI:WaitForChild("Shop")
-- ZoneUI has been replaced with TeleportFrame in our updated design
local teleportFrame = mainUI:WaitForChild("TeleportFrame")
local statsUI = mainUI:WaitForChild("StatsUI")

-- Initialize UI
local function initializeUI()
    -- This function would set up all the UI elements and connect their events
    -- For brevity, we're not implementing the full UI here
    print("Initializing UI...")
    
    -- Example: Connect tab buttons (now ImageButtons)
    for _, button in ipairs(mainUI.Tabs:GetChildren()) do
        if button:IsA("ImageButton") then
            if button.Name == "AutoAttack" then
                button.MouseButton1Click:Connect(function()
                    toggleAutoAttack()
                end)
            else
                button.MouseButton1Click:Connect(function()
                    toggleFrame(button.Name)
                end)
            end
        end
    end
    
    -- Example: Connect world tab buttons (now ImageButtons)
    for _, worldTab in ipairs(mainUI.TeleportFrame.WorldTabs:GetChildren()) do
        if worldTab:IsA("ImageButton") then
            worldTab.MouseButton1Click:Connect(function()
                switchWorld(worldTab.Name)
            end)
        end
    end
    
    -- Example: Connect inventory filter buttons
    for _, filter in ipairs(petInventory.Filters:GetChildren()) do
        if filter:IsA("TextButton") then
            filter.MouseButton1Click:Connect(function()
                setInventoryFilter(filter.Name)
            end)
        end
    end
    
    -- Example: Connect shop tab buttons
    for _, tab in ipairs(shopUI.Tabs:GetChildren()) do
        if tab:IsA("TextButton") then
            tab.MouseButton1Click:Connect(function()
                setShopTab(tab.Name)
            end)
        end
    end
    
    -- Example: Connect draw tier buttons
    for _, tier in ipairs(shopUI.Tiers:GetChildren()) do
        if tier:IsA("TextButton") then
            tier.MouseButton1Click:Connect(function()
                setDrawTier(tier.Name)
            end)
        end
    end
    
    -- Example: Connect draw buttons
    shopUI.DrawButton.MouseButton1Click:Connect(function()
        performDraw()
    end)
    
    shopUI.MultiDrawButton.MouseButton1Click:Connect(function()
        performMultiDraw(10) -- Draw 10 at once
    end)
    
    -- Zone unlock and rebirth buttons are now handled by the ZoneUnlockHandler script
    -- These connections have been removed as zoneUI no longer exists
    
    print("UI initialized!")
end

-- Toggle UI frame visibility
local function toggleFrame(frameName)
    -- Hide all content frames
    mainUI.PetInventory.Visible = false
    mainUI.Shop.Visible = false
    mainUI.StatsUI.Visible = false
    mainUI.TeleportFrame.Visible = false
    
    -- Show the selected frame
    if frameName == "Pets" then
        mainUI.PetInventory.Visible = true
        updatePetInventory()
    elseif frameName == "Shop" then
        mainUI.Shop.Visible = true
        updateShop()
    elseif frameName == "Stats" then
        mainUI.StatsUI.Visible = true
        updateStatsUI()
    elseif frameName == "Teleport" then
        mainUI.TeleportFrame.Visible = true
        
        -- Find the currently selected world tab
        local selectedWorldTab = nil
        for _, worldTab in ipairs(mainUI.TeleportFrame.WorldTabs:GetChildren()) do
            if worldTab:IsA("ImageButton") and worldTab.Selected.Visible then
                selectedWorldTab = worldTab
                break
            end
        end
        
        -- If no world tab is selected, default to World1
        local worldName = selectedWorldTab and selectedWorldTab.Name or "World1"
        
        -- Update the zone list for the selected world
        updateTeleportZoneList(gameState.PlayerData.UnlockedZones, worldName)
    end
    
    -- Update button appearance
    for _, button in ipairs(mainUI.Tabs:GetChildren()) do
        if button:IsA("ImageButton") then
            button.Selected.Visible = (button.Name == frameName)
        end
    end
end

-- Set inventory filter
local function setInventoryFilter(filterName)
    gameState.UIState.InventoryFilter = filterName
    updatePetInventory()
    
    -- Update filter button appearance using UIStroke
    for _, filter in ipairs(petInventory.Filters:GetChildren()) do
        if filter:IsA("TextButton") then
            local stroke = filter:FindFirstChild("UIStroke")
            if not stroke then
                -- Create UIStroke if it doesn't exist
                stroke = Instance.new("UIStroke")
                stroke.Parent = filter
            end
            
            if filter.Name == filterName then
                -- Selected state
                stroke.Thickness = 2
                stroke.Color = Color3.fromRGB(0, 120, 255) -- Blue border
                filter.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
            else
                -- Unselected state
                stroke.Thickness = 0 -- No border
                filter.TextColor3 = Color3.fromRGB(200, 200, 200) -- Light gray text
            end
        end
    end
end

-- Set shop tab
local function setShopTab(tabName)
    gameState.UIState.ShopTab = tabName
    updateShop()
    
    -- Update shop tab button appearance
    for _, tab in ipairs(shopUI.Tabs:GetChildren()) do
        if tab:IsA("TextButton") then
            tab.Selected.Visible = (tab.Name == tabName)
        end
    end
end

-- Set draw tier
local function setDrawTier(tierName)
    gameState.UIState.DrawTier = tierName
    updateShop()
    
    -- Update tier button appearance
    for _, tier in ipairs(shopUI.Tiers:GetChildren()) do
        if tier:IsA("TextButton") then
            tier.Selected.Visible = (tier.Name == tierName)
        end
    end
end

-- Update currency display
local function updateCurrencyDisplay()
    if not gameState.PlayerData then return end
    
    -- Import Utilities module for number formatting
    local Utilities = require(ReplicatedStorage.Modules.Utilities)
    
    -- Update currency display with formatted values, ensuring 0 is displayed properly
    local coins = gameState.PlayerData.Coins or 0
    local diamonds = gameState.PlayerData.Diamonds or 0
    local rubies = gameState.PlayerData.Rubies or 0
    
    currencyDisplay.Coins.TextLabel.Text = Utilities.FormatNumber(coins)
    currencyDisplay.Diamonds.TextLabel.Text = Utilities.FormatNumber(diamonds)
    currencyDisplay.Rubies.TextLabel.Text = Utilities.FormatNumber(rubies)
    
    -- Debug output to verify values
    print("Currency Display Updated - Coins:", coins, "Diamonds:", diamonds, "Rubies:", rubies)
end

-- Update pet inventory UI
local function updatePetInventory()
    if not gameState.PlayerData then return end
    
    -- Clear existing pet slots
    for _, slot in ipairs(petInventory.PetSlots:GetChildren()) do
        if slot:IsA("Frame") and slot.Name ~= "Template" then
            slot:Destroy()
        end
    end
    
    -- Filter pets based on current filter
    local filteredPets = {}
    for _, pet in ipairs(gameState.PlayerData.Pets) do
        if gameState.UIState.InventoryFilter == "All" or 
           (gameState.UIState.InventoryFilter == "Equipped" and pet.Equipped) or
           (gameState.UIState.InventoryFilter == "Unequipped" and not pet.Equipped) then
            table.insert(filteredPets, pet)
        end
    end
    
    -- Create pet slots for filtered pets
    for i, pet in ipairs(filteredPets) do
        local petInfo = remoteFunctions.GetPetInfo:InvokeServer(pet.ID)
        if not petInfo then continue end
        
        local slot = petInventory.PetSlots.Template:Clone()
        slot.Name = "PetSlot_" .. i
        slot.PetName.Text = petInfo.Name
        slot.PetRarity.Text = pet.Rarity
        slot.PetLevel.Text = "Lvl " .. pet.Level
        
        -- Set pet image
        -- slot.PetImage.Image = getAssetId(petInfo.ModelID)
        
        -- Set rarity color
        local rarityColor = getRarityColor(pet.Rarity)
        slot.RarityColor.BackgroundColor3 = rarityColor
        
        -- Set up equip/unequip button with two states
        -- Assuming EquipButton is a Frame containing two ImageButtons: EquipImage and EquippedImage
        local equipImage = slot.EquipButton:FindFirstChild("EquipImage")
        local equippedImage = slot.EquipButton:FindFirstChild("EquippedImage")
        
        if equipImage and equippedImage then
            -- Set initial visibility based on equipped status
            equipImage.Visible = not pet.Equipped
            equippedImage.Visible = pet.Equipped
            
            -- Connect click events to both images
            equipImage.MouseButton1Click:Connect(function()
                remoteEvents.EquipPet:FireServer(pet.UUID)
                equipImage.Visible = false
                equippedImage.Visible = true
            end)
            
            equippedImage.MouseButton1Click:Connect(function()
                remoteEvents.UnequipPet:FireServer(pet.UUID)
                equippedImage.Visible = false
                equipImage.Visible = true
            end)
        else
            -- Fallback if the images don't exist
            slot.EquipButton.MouseButton1Click:Connect(function()
                if pet.Equipped then
                    remoteEvents.UnequipPet:FireServer(pet.UUID)
                else
                    remoteEvents.EquipPet:FireServer(pet.UUID)
                end
            end)
        end
        
        -- Connect aura button
        slot.AuraButton.MouseButton1Click:Connect(function()
            openAuraSelectionUI(pet)
        end)
        
        -- Connect info button
        slot.InfoButton.MouseButton1Click:Connect(function()
            openPetInfoUI(pet)
        end)
        
        slot.Parent = petInventory.PetSlots
        slot.Visible = true
    end
    
    -- Update pet count
    petInventory.PetCount.Text = #gameState.PlayerData.Pets .. "/" .. 100 -- Assuming max 100 pets
end

-- Update shop UI
local function updateShop()
    if not gameState.PlayerData then return end
    
    -- Update shop based on current tab and tier
    local drawType = gameState.UIState.ShopTab
    local tier = gameState.UIState.DrawTier
    
    -- Get current zone number
    local currentZoneNumber = 1
    if gameState.CurrentZone then
        currentZoneNumber = gameState.CurrentZone.ZoneNumber
    end
    
    -- Get draw chances
    local drawChances = remoteFunctions.GetDrawChances:InvokeServer(drawType, tier, currentZoneNumber)
    
    -- Update draw chances display
    shopUI.ChancesContainer:ClearAllChildren()
    for i, chance in ipairs(drawChances) do
        local chanceLabel = Instance.new("TextLabel")
        chanceLabel.Name = "Chance_" .. i
        chanceLabel.Text = chance.Rarity .. ": " .. chance.DisplayChance
        chanceLabel.TextColor3 = chance.Color
        chanceLabel.Parent = shopUI.ChancesContainer
    end
    
    -- Update draw cost
    local costType = "Coins"
    if drawType == "Auras" then
        costType = "Diamonds"
    elseif drawType == "Relics" then
        costType = "Rubies"
    end
    
    local cost = 0
    if tier == "Basic" then
        if costType == "Coins" then
            cost = gameState.PlayerData.GameConfig.DrawSettings.Coins.BasicDraw
        elseif costType == "Diamonds" then
            cost = gameState.PlayerData.GameConfig.DrawSettings.Diamonds.BasicDraw
        elseif costType == "Rubies" then
            cost = gameState.PlayerData.GameConfig.DrawSettings.Rubies.BasicDraw
        end
    elseif tier == "Premium" then
        if costType == "Coins" then
            cost = gameState.PlayerData.GameConfig.DrawSettings.Coins.PremiumDraw
        elseif costType == "Diamonds" then
            cost = gameState.PlayerData.GameConfig.DrawSettings.Diamonds.PremiumDraw
        elseif costType == "Rubies" then
            cost = gameState.PlayerData.GameConfig.DrawSettings.Rubies.PremiumDraw
        end
    elseif tier == "Ultimate" then
        if costType == "Coins" then
            cost = gameState.PlayerData.GameConfig.DrawSettings.Coins.UltimateDraw
        elseif costType == "Diamonds" then
            cost = gameState.PlayerData.GameConfig.DrawSettings.Diamonds.UltimateDraw
        elseif costType == "Rubies" then
            cost = gameState.PlayerData.GameConfig.DrawSettings.Rubies.UltimateDraw
        end
    end
    
    shopUI.DrawCost.Text = Utilities.FormatNumber(cost) .. " " .. costType
    shopUI.MultiDrawCost.Text = Utilities.FormatNumber(cost * 10) .. " " .. costType -- 10x draw
    
    -- Update draw button state (enabled/disabled)
    local hasEnoughCurrency = gameState.PlayerData[costType] >= cost
    shopUI.DrawButton.Disabled = not hasEnoughCurrency
    
    -- Update multi-draw button state
    local hasEnoughForMulti = gameState.PlayerData[costType] >= (cost * 10)
    shopUI.MultiDrawButton.Disabled = not hasEnoughForMulti
end

-- Update zone UI (replaced with TeleportFrame)
local function updateZoneUI()
    -- This function has been replaced by updateTeleportZoneList
    -- Zone UI is now handled through the TeleportFrame
    -- Enemy and boss information is now displayed in-game rather than in a UI
    
    -- If we need to update anything based on the current zone, we can do it here
    if not gameState.PlayerData or not gameState.CurrentZone then return end
    
    -- Update the teleport zone list to reflect any changes
    local worldName = "World" .. gameState.CurrentZone.WorldNumber
    updateTeleportZoneList(gameState.PlayerData.UnlockedZones, worldName)
end

-- Switch world in teleport UI
local function switchWorld(worldName)
    -- Hide all world frames
    for _, worldFrame in ipairs(mainUI.TeleportFrame.WorldScroll:GetChildren()) do
        if worldFrame:IsA("Frame") and worldFrame.Name:match("^World%d+Frame$") then
            worldFrame.Visible = false
        end
    end
    
    -- Show the selected world frame
    local selectedWorldFrame = mainUI.TeleportFrame.WorldScroll:FindFirstChild(worldName .. "Frame")
    if selectedWorldFrame then
        selectedWorldFrame.Visible = true
    end
    
    -- Update world tab button appearance
    for _, worldTab in ipairs(mainUI.TeleportFrame.WorldTabs:GetChildren()) do
        if worldTab:IsA("ImageButton") then
            worldTab.Selected.Visible = (worldTab.Name == worldName)
        end
    end
    
    -- Update zone list for the selected world
    updateTeleportZoneList(gameState.PlayerData.UnlockedZones, worldName)
end

-- Update teleport zone list
local function updateTeleportZoneList(unlockedZones, worldName)
    if not gameState.PlayerData then return end
    
    -- Default to World1 if not specified
    worldName = worldName or "World1"
    
    -- Get the world frame
    local worldFrame = mainUI.TeleportFrame.WorldScroll:FindFirstChild(worldName .. "Frame")
    if not worldFrame then return end
    
    -- Get the zone scroll for this world
    local zoneScroll = worldFrame:FindFirstChild("ZoneScroll")
    if not zoneScroll then return end
    
    -- Find the template
    local template = zoneScroll:FindFirstChild("ZoneEntryTemplate")
    if not template then
        warn("Zone entry template not found in " .. worldName .. "!")
        return
    end
    
    -- Clear existing zone entries
    for _, entry in ipairs(zoneScroll:GetChildren()) do
        if entry:IsA("Frame") and entry.Name ~= "UIListLayout" and entry.Name ~= "ZoneEntryTemplate" then
            entry:Destroy()
        end
    end
    
    -- Create zone entries for all zones in this world
    for i = 1, 100 do -- Assuming 100 zones per world
        -- Clone the template
        local zoneEntry = template:Clone()
        zoneEntry.Name = "Zone_" .. i
        zoneEntry.LayoutOrder = i
        zoneEntry.Visible = true
        
        -- Check if zone is unlocked
        local worldPrefix = worldName:sub(6) -- Extract number from "World1", "World2", etc.
        local zoneKey = worldPrefix .. "_" .. i
        local isUnlocked = table.find(unlockedZones, zoneKey) ~= nil
        
        -- Update zone name (now a TextButton)
        local zoneName = zoneEntry:FindFirstChild("ZoneName")
        if zoneName then
            -- Get zone info from ZoneConfig
            local zoneInfo = {Name = worldName .. " Zone " .. i} -- Default name if not found
            zoneName.Text = zoneInfo.Name
            
            -- Style based on unlock status
            if isUnlocked then
                zoneName.TextColor3 = Color3.fromRGB(255, 255, 255) -- White for unlocked
                zoneName.MouseButton1Click:Connect(function()
                    teleportToZone(worldName, i)
                    mainUI.TeleportFrame.Visible = false
                end)
            else
                zoneName.TextColor3 = Color3.fromRGB(150, 150, 150) -- Gray for locked
                -- No click event for locked zones
            end
        end
        
        -- Update zone description
        local zoneDesc = zoneEntry:FindFirstChild("ZoneDesc")
        if zoneDesc then
            if isUnlocked then
                zoneDesc.Text = "Click to teleport" -- Could be populated from ZoneConfig
            else
                zoneDesc.Text = "Zone locked" -- Could show unlock requirements
            end
        end
        
        zoneEntry.Parent = zoneScroll
    end
end

-- Teleport to zone
local function teleportToZone(worldName, zoneNumber)
    -- Extract world number from worldName (e.g., "World1" -> "1")
    local worldNumber = worldName:match("%d+")
    if not worldNumber then
        warn("Invalid world name: " .. worldName)
        return
    end
    
    -- Find the zone in workspace
    local zoneID = "ZONE_" .. worldNumber .. "_" .. zoneNumber
    local zoneFolder = workspace.Zones:FindFirstChild(zoneID)
    if not zoneFolder then
        warn("Zone not found: " .. zoneID)
        return
    end
    
    -- Find spawn location
    local spawnLocation = zoneFolder:FindFirstChild("SpawnLocation") or zoneFolder:FindFirstChild("SpawnPoint")
    if not spawnLocation then
        warn("Spawn location not found in zone: " .. zoneID)
        return
    end
    
    -- Teleport player
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
    end
    
    -- Update current zone
    gameState.CurrentZone = {
        WorldNumber = tonumber(worldNumber),
        ZoneNumber = zoneNumber,
        ID = zoneID
    }
    
    -- Request zone data from server
    remoteEvents.RequestZoneData:FireServer(zoneID)
end

-- Update stats UI
local function updateStatsUI()
    if not gameState.PlayerData then return end
    
    -- Update player stats
    statsUI.CoinsEarned.Text = Utilities.FormatNumber(gameState.PlayerData.Stats.TotalCoinsEarned)
    statsUI.DiamondsEarned.Text = Utilities.FormatNumber(gameState.PlayerData.Stats.TotalDiamondsEarned)
    statsUI.RubiesEarned.Text = Utilities.FormatNumber(gameState.PlayerData.Stats.TotalRubiesEarned)
    statsUI.EnemiesDefeated.Text = Utilities.FormatNumber(gameState.PlayerData.Stats.EnemiesDefeated)
    statsUI.BossesDefeated.Text = Utilities.FormatNumber(gameState.PlayerData.Stats.BossesDefeated)
    statsUI.PetsHatched.Text = Utilities.FormatNumber(gameState.PlayerData.Stats.PetsHatched)
    statsUI.AurasObtained.Text = Utilities.FormatNumber(gameState.PlayerData.Stats.AurasObtained)
    statsUI.RelicsDiscovered.Text = Utilities.FormatNumber(gameState.PlayerData.Stats.RelicsDiscovered)
    statsUI.ZonesUnlocked.Text = Utilities.FormatNumber(gameState.PlayerData.Stats.ZonesUnlocked)
    statsUI.HighestZone.Text = Utilities.FormatNumber(gameState.PlayerData.Stats.HighestZoneReached)
    statsUI.RebirthCount.Text = Utilities.FormatNumber(gameState.PlayerData.Stats.RebirthCount)
    statsUI.PlayTime.Text = formatTime(gameState.PlayerData.PlayTime)
    
    -- Update multipliers
    statsUI.CoinMultiplier.Text = Utilities.FormatNumber(gameState.PlayerData.Multipliers.Coins * 100) .. "%"
    statsUI.DamageMultiplier.Text = Utilities.FormatNumber(gameState.PlayerData.Multipliers.Damage * 100) .. "%"
    statsUI.SpeedMultiplier.Text = Utilities.FormatNumber(gameState.PlayerData.Multipliers.Speed * 100) .. "%"
    
    -- Update collection progress
    local petCount = #gameState.PlayerData.Pets
    local auraCount = #gameState.PlayerData.Auras
    local relicCount = #gameState.PlayerData.Relics
    
    statsUI.PetCollection.Text = petCount .. "/200" -- Assuming 200 total pets
    statsUI.AuraCollection.Text = auraCount .. "/50" -- Assuming 50 total auras
    statsUI.RelicCollection.Text = relicCount .. "/20" -- Assuming 20 total relics
end

-- Import Utilities module at the top of the file
local Utilities = require(ReplicatedStorage.Modules.Utilities)


-- Format time for display
local function formatTime(seconds)
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    
    if days > 0 then
        return string.format("%dd %dh %dm", days, hours, minutes)
    elseif hours > 0 then
        return string.format("%dh %dm", hours, minutes)
    else
        return string.format("%dm %ds", minutes, seconds)
    end
end

-- Get rarity color
local function getRarityColor(rarity)
    if rarity == "Common" then
        return Color3.fromRGB(255, 255, 255) -- White
    elseif rarity == "Uncommon" then
        return Color3.fromRGB(0, 255, 0) -- Green
    elseif rarity == "Rare" then
        return Color3.fromRGB(0, 112, 221) -- Blue
    elseif rarity == "Epic" then
        return Color3.fromRGB(163, 53, 238) -- Purple
    elseif rarity == "Legendary" then
        return Color3.fromRGB(255, 215, 0) -- Gold
    elseif rarity == "Mythical" then
        return Color3.fromRGB(255, 0, 0) -- Red
    else
        return Color3.fromRGB(255, 255, 255) -- Default white
    end
end

-- Set target enemy
local function setTargetEnemy(enemy)
    gameState.TargetEnemy = enemy
    gameState.IsAttacking = true
    
    -- Update UI to show attacking state
    -- ...
end

-- Stop attacking
local function stopAttacking()
    gameState.IsAttacking = false
    gameState.TargetEnemy = nil
    
    -- Update UI to show idle state
    -- ...
end

-- Perform attack
local function performAttack()
    if not gameState.IsAttacking or not gameState.TargetEnemy then return end
    
    -- Calculate total damage from equipped pets
    local totalDamage = 0
    for _, pet in ipairs(gameState.PlayerData.Pets) do
        if pet.Equipped then
            totalDamage = totalDamage + pet.Stats.Damage
        end
    end
    
    -- Apply player damage multiplier
    totalDamage = totalDamage * gameState.PlayerData.Multipliers.Damage
    
    -- Send damage to server
    remoteEvents.DamageEnemy:FireServer(gameState.TargetEnemy.UUID, totalDamage)
end

-- Toggle auto-attack
local function toggleAutoAttack()
    -- Toggle the auto-attack state
    gameState.AutoAttackEnabled = not gameState.AutoAttackEnabled
    
    -- Update the AutoAttack button appearance
    local autoAttackButton = mainUI.Tabs:FindFirstChild("AutoAttack")
    if autoAttackButton then
        -- Change background color based on state
        if gameState.AutoAttackEnabled then
            autoAttackButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- Yellow when active
        else
            autoAttackButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Dark gray when inactive
        end
    end
    
    -- If auto-attack is enabled, find a target if we don't have one
    if gameState.AutoAttackEnabled and not gameState.TargetEnemy and #gameState.ActiveEnemies > 0 then
        -- Find the first active enemy
        for _, enemy in pairs(gameState.ActiveEnemies) do
            if not enemy.IsDead then
                setTargetEnemy(enemy)
                break
            end
        end
    end
end

-- Auto-attack logic
local function updateAutoAttack()
    if not gameState.AutoAttackEnabled then return end
    
    -- If we have a target and it's dead or doesn't exist anymore, find a new target
    if gameState.TargetEnemy then
        local targetExists = false
        for _, enemy in pairs(gameState.ActiveEnemies) do
            if enemy.UUID == gameState.TargetEnemy.UUID then
                targetExists = true
                if enemy.IsDead then
                    gameState.TargetEnemy = nil
                    break
                end
            end
        end
        
        if not targetExists then
            gameState.TargetEnemy = nil
        end
    end
    
    -- If we don't have a target, find one
    if not gameState.TargetEnemy and #gameState.ActiveEnemies > 0 then
        for _, enemy in pairs(gameState.ActiveEnemies) do
            if not enemy.IsDead then
                setTargetEnemy(enemy)
                break
            end
        end
    end
    
    -- If we have a target, attack it
    if gameState.TargetEnemy then
        performAttack()
    elseif gameState.ActiveBoss and not gameState.ActiveBoss.IsDead then
        -- If no regular enemies but there's a boss, attack the boss
        performBossAttack()
    end
end

-- Perform boss attack
local function performBossAttack()
    if not gameState.ActiveBoss or gameState.ActiveBoss.IsDead then return end
    
    -- Calculate total damage from equipped pets
    local totalDamage = 0
    for _, pet in ipairs(gameState.PlayerData.Pets) do
        if pet.Equipped then
            totalDamage = totalDamage + pet.Stats.Damage
        end
    end
    
    -- Apply player damage multiplier
    totalDamage = totalDamage * gameState.PlayerData.Multipliers.Damage
    
    -- Send damage to server
    remoteEvents.DamageBoss:FireServer(gameState.ActiveBoss.UUID, totalDamage)
end

-- Unlock next zone
local function unlockNextZone()
    if not gameState.CurrentZone then return end
    
    local nextZoneNumber = gameState.CurrentZone.ZoneNumber + 1
    remoteEvents.UnlockZone:FireServer(nextZoneNumber)
end

-- Perform rebirth
local function performRebirth()
    if not gameState.CurrentZone or not gameState.CurrentZone.HasRebirthStatue then return end
    
    remoteEvents.PerformRebirth:FireServer(gameState.CurrentZone.ZoneNumber)
end

-- Perform draw
local function performDraw()
    local drawType = gameState.UIState.ShopTab
    local tier = gameState.UIState.DrawTier
    local currentZoneNumber = gameState.CurrentZone and gameState.CurrentZone.ZoneNumber or 1
    
    if drawType == "Pets" then
        remoteEvents.PerformPetDraw:FireServer(tier, currentZoneNumber)
    elseif drawType == "Auras" then
        remoteEvents.PerformAuraDraw:FireServer(tier, currentZoneNumber)
    elseif drawType == "Relics" then
        remoteEvents.PerformRelicDraw:FireServer(tier, currentZoneNumber)
    end
end

-- Perform multi-draw
local function performMultiDraw(count)
    local drawType = gameState.UIState.ShopTab
    local tier = gameState.UIState.DrawTier
    local currentZoneNumber = gameState.CurrentZone and gameState.CurrentZone.ZoneNumber or 1
    
    remoteEvents.PerformMultiDraw:FireServer(drawType, tier, count, currentZoneNumber)
end

-- Game loop
local function gameLoop(deltaTime)
    -- Update auto-attack
    updateAutoAttack()
    
    -- Other game loop logic can be added here
    -- ...
end

-- Connect game loop to RunService.Heartbeat
RunService.Heartbeat:Connect(gameLoop)

-- Open aura selection UI
local function openAuraSelectionUI(pet)
    -- This function would open a UI for selecting an aura to equip on a pet
    -- For brevity, we're not implementing the full UI here
    print("Opening aura selection UI for pet: " .. pet.UUID)
    
    -- Example implementation:
    -- Create a frame to display all available auras
    local auraSelectionUI = Instance.new("Frame")
    auraSelectionUI.Name = "AuraSelectionUI"
    auraSelectionUI.Size = UDim2.new(0.8, 0, 0.8, 0)
    auraSelectionUI.Position = UDim2.new(0.1, 0, 0.1, 0)
    auraSelectionUI.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    auraSelectionUI.Parent = playerGui
    
    -- Add a title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = "Select Aura for " .. pet.ID
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.Parent = auraSelectionUI
    
    -- Add a close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0.1, 0, 0.1, 0)
    closeButton.Position = UDim2.new(0.9, 0, 0, 0)
    closeButton.MouseButton1Click:Connect(function()
        auraSelectionUI:Destroy()
    end)
    closeButton.Parent = auraSelectionUI
    
    -- Add a scroll frame for auras
    local auraScroll = Instance.new("ScrollingFrame")
    auraScroll.Name = "AuraScroll"
    auraScroll.Size = UDim2.new(1, 0, 0.9, 0)
    auraScroll.Position = UDim2.new(0, 0, 0.1, 0)
    auraScroll.Parent = auraSelectionUI
    
    -- Add aura slots
    local yPos = 0
    for _, aura in ipairs(gameState.PlayerData.Auras) do
        -- Skip auras that are already equipped on other pets
        local isEquipped = false
        for _, otherPet in ipairs(gameState.PlayerData.Pets) do
            if otherPet.UUID ~= pet.UUID and otherPet.EquippedAura and otherPet.EquippedAura.UUID == aura.UUID then
                isEquipped = true
                break
            end
        end
        
        if not isEquipped then
            local auraInfo = remoteFunctions.GetAuraInfo:InvokeServer(aura.ID)
            if not auraInfo then continue end
            
            local auraSlot = Instance.new("Frame")
            auraSlot.Name = "AuraSlot_" .. aura.UUID
            auraSlot.Size = UDim2.new(1, 0, 0.1, 0)
            auraSlot.Position = UDim2.new(0, 0, yPos, 0)
            
            local auraName = Instance.new("TextLabel")
            auraName.Name = "AuraName"
            auraName.Text = auraInfo.Name
            auraName.Size = UDim2.new(0.7, 0, 1, 0)
            auraName.Parent = auraSlot
            
            local equipButton = Instance.new("TextButton")
            equipButton.Name = "EquipButton"
            equipButton.Text = "Equip"
        end
    end
end

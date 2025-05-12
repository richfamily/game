-- ZoneUnlockHandler.lua
-- Handles the zone unlock functionality using the ScreenGUI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local zoneUnlockGUI = playerGui:WaitForChild("ZoneUnlockGUI")

-- Get remote events and functions
local remoteFolder = ReplicatedStorage:WaitForChild("Remotes")
local remoteEvents = {
    UnlockZone = remoteFolder:WaitForChild("UnlockZone")
}
local remoteFunctions = {
    GetZoneInfo = remoteFolder:WaitForChild("GetZoneInfo"),
    GetPlayerData = remoteFolder:WaitForChild("GetPlayerData")
}

-- Import Utilities module
local Utilities = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utilities"))

-- References to GUI elements (using exact names from the implementation guide)
local background = zoneUnlockGUI:WaitForChild("Background")
local zoneInfoFrame = zoneUnlockGUI:WaitForChild("ZoneInfoFrame")
local zoneNameLabel = zoneInfoFrame:WaitForChild("ZoneNameLabel")
local zoneDescriptionLabel = zoneInfoFrame:WaitForChild("ZoneDescriptionLabel")
local unlockFrame = zoneUnlockGUI:WaitForChild("UnlockFrame")
local costLabel = unlockFrame:WaitForChild("CostLabel")
local unlockButton = unlockFrame:WaitForChild("UnlockButton")
local closeButton = zoneUnlockGUI:WaitForChild("CloseButton")

-- Current barrier reference
local currentBarrier = nil

-- Function to show the unlock GUI
local function showUnlockGUI(barrier)
    print("showUnlockGUI called for barrier:", barrier.Name)
    
    -- Get zone info from barrier name
    local worldNum, zoneNum = barrier.Name:match("ZoneBarrier_(%d+)_(%d+)")
    if not worldNum or not zoneNum then
        -- Try the new naming pattern as a fallback
        worldNum, zoneNum = barrier.Name:match("Barrier_(%d+)_(%d+)")
    end
    
    print("Extracted worldNum:", worldNum, "zoneNum:", zoneNum)
    if not worldNum or not zoneNum then 
        print("Failed to extract world/zone numbers")
        return 
    end
    
    worldNum = tonumber(worldNum)
    zoneNum = tonumber(zoneNum)
    
    -- Get zone info
    local zoneID = "ZONE_" .. worldNum .. "_" .. zoneNum
    print("Requesting zone info for:", zoneID)
    local zoneInfo = remoteFunctions.GetZoneInfo:InvokeServer(zoneID)
    print("Zone info received:", zoneInfo ~= nil)
    if not zoneInfo then 
        print("Failed to get zone info")
        return 
    end
    
    -- Get player data to check if they can afford it
    print("Requesting player data")
    local playerData = remoteFunctions.GetPlayerData:InvokeServer()
    print("Player data received:", playerData ~= nil)
    if not playerData then 
        print("Failed to get player data")
        return 
    end
    
    -- Update GUI with zone info
    zoneNameLabel.Text = zoneInfo.Name or ("Zone " .. zoneNum)
    zoneDescriptionLabel.Text = zoneInfo.Description or "Unlock this zone to continue your adventure!"
    costLabel.Text = Utilities.FormatNumber(zoneInfo.UnlockCost) .. " Coins"
    
    -- Update unlock button state
    local canAfford = playerData.Coins >= zoneInfo.UnlockCost
    unlockButton.BackgroundColor3 = canAfford and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(100, 100, 100)
    -- Check if the button has a Text property (TextButton) or not (ImageButton)
    if unlockButton:IsA("TextButton") then
        unlockButton.Text = canAfford and "UNLOCK" or "NOT ENOUGH COINS"
    elseif unlockButton:FindFirstChild("TextLabel") then
        unlockButton.TextLabel.Text = canAfford and "UNLOCK" or "NOT ENOUGH COINS"
    end
    -- Set AutoButtonColor if available
    if unlockButton:IsA("TextButton") or unlockButton:IsA("ImageButton") then
        unlockButton.AutoButtonColor = canAfford
    end
    
    -- Store current barrier reference
    currentBarrier = barrier
    
    -- Show the GUI
    print("Enabling the GUI")
    zoneUnlockGUI.Enabled = true
    
    -- Optional: Add animation
    zoneInfoFrame.Position = UDim2.new(0.5, 0, 0.4, 0) -- Match the position in the guide
    zoneInfoFrame.AnchorPoint = Vector2.new(0.5, 0.5) -- Centered as specified
    
    -- Make sure the unlock frame is positioned correctly
    unlockFrame.Position = UDim2.new(0.5, 0, 0.7, 0)
    unlockFrame.AnchorPoint = Vector2.new(0.5, 0.5)
end

-- Function to hide the unlock GUI
local function hideUnlockGUI()
    zoneUnlockGUI.Enabled = false
    currentBarrier = nil
end

-- Connect the unlock button
unlockButton.MouseButton1Click:Connect(function()
    if currentBarrier then
        local worldNum, zoneNum = currentBarrier.Name:match("ZoneBarrier_(%d+)_(%d+)")
        if not worldNum or not zoneNum then
            -- Try the new naming pattern as a fallback
            worldNum, zoneNum = currentBarrier.Name:match("Barrier_(%d+)_(%d+)")
        end
        
        if worldNum and zoneNum then
            remoteEvents.UnlockZone:FireServer(tonumber(zoneNum))
            hideUnlockGUI()
        end
    end
end)

-- Connect the close button
closeButton.MouseButton1Click:Connect(hideUnlockGUI)

-- Connect proximity prompts
local function connectPrompt(prompt, barrier)
    print("Connecting prompt for barrier:", barrier.Name)
    
    -- Connect with a more robust approach
    prompt.Triggered:Connect(function(playerWhoTriggered)
        print("Prompt triggered by:", playerWhoTriggered.Name)
        if playerWhoTriggered == player then
            print("Showing unlock GUI for barrier:", barrier.Name)
            -- Use task.spawn to ensure the GUI shows even if there's an error elsewhere
            task.spawn(function()
                showUnlockGUI(barrier)
            end)
        end
    end)
    
    -- Add a ClickDetector as a backup interaction method
    local clickDetector = barrier:FindFirstChild("ClickDetector")
    if not clickDetector then
        clickDetector = Instance.new("ClickDetector")
        clickDetector.MaxActivationDistance = 10
        clickDetector.Parent = barrier
    end
    
    clickDetector.MouseClick:Connect(function(playerWhoClicked)
        print("Barrier clicked by:", playerWhoClicked.Name)
        if playerWhoClicked == player then
            print("Showing unlock GUI from click for barrier:", barrier.Name)
            task.spawn(function()
                showUnlockGUI(barrier)
            end)
        end
    end)
    
    print("Connection established for:", barrier.Name)
end

-- Find and connect all zone barriers
local function setupZoneBarriers()
    print("Setting up zone barriers")
    
    -- Look for barriers in the correct location: Workspace.Worlds.Spawn.MAP.Gates
    local gatesFolder = workspace:FindFirstChild("Worlds")
    if gatesFolder then
        gatesFolder = gatesFolder:FindFirstChild("Spawn")
        if gatesFolder then
            gatesFolder = gatesFolder:FindFirstChild("MAP")
            if gatesFolder then
                gatesFolder = gatesFolder:FindFirstChild("Gates")
                if gatesFolder then
                    -- Found the gates folder, now look for barriers
                    for _, barrier in ipairs(gatesFolder:GetChildren()) do
                        if barrier.Name:match("^ZoneBarrier_%d+_%d+$") then
                            print("Found barrier:", barrier.Name)
                            
                            -- Add a proximity prompt if it doesn't exist
                            local prompt = barrier:FindFirstChild("UnlockPrompt")
                            if not prompt then
                                prompt = Instance.new("ProximityPrompt")
                                prompt.Name = "UnlockPrompt"
                                prompt.ActionText = "View Zone"
                                prompt.ObjectText = "Zone Barrier"
                                prompt.KeyboardKeyCode = Enum.KeyCode.E
                                prompt.HoldDuration = 0
                                prompt.MaxActivationDistance = 10
                                prompt.RequiresLineOfSight = false
                                prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
                                prompt.Enabled = true
                                prompt.Style = Enum.ProximityPromptStyle.Default
                                prompt.ClickablePrompt = true
                                prompt.AutoLocalize = true
                                prompt.Parent = barrier
                            end
                            
                            if prompt and prompt:IsA("ProximityPrompt") then
                                print("Found/created prompt for barrier:", barrier.Name)
                                connectPrompt(prompt, barrier)
                            else
                                print("No prompt found for barrier:", barrier.Name)
                            end
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
                        -- Found the old gates folder, now look for barriers
                        for _, barrier in ipairs(oldGatesFolder:GetChildren()) do
                            if barrier.Name:match("^Barrier_%d+_%d+$") then
                                print("Found old-style barrier:", barrier.Name)
                                local prompt = barrier:FindFirstChild("UnlockPrompt")
                                if prompt and prompt:IsA("ProximityPrompt") then
                                    print("Found prompt for old-style barrier:", barrier.Name)
                                    connectPrompt(prompt, barrier)
                                else
                                    print("No prompt found for old-style barrier:", barrier.Name)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- As a last resort, search the entire workspace for any barriers we might have missed
    for _, barrier in ipairs(workspace:GetDescendants()) do
        if barrier.Name:match("^ZoneBarrier_%d+_%d+$") or barrier.Name:match("^Barrier_%d+_%d+$") then
            print("Found barrier through workspace search:", barrier.Name)
            local prompt = barrier:FindFirstChild("UnlockPrompt")
            if prompt and prompt:IsA("ProximityPrompt") then
                print("Found prompt for barrier:", barrier.Name)
                connectPrompt(prompt, barrier)
            else
                print("No prompt found for barrier:", barrier.Name)
            end
        end
    end
end

-- Setup barriers when the game loads
setupZoneBarriers()

-- Also connect to new barriers that might be added later
workspace.DescendantAdded:Connect(function(descendant)
    -- Check for any barrier naming pattern
    if descendant.Name:match("^ZoneBarrier_%d+_%d+$") or descendant.Name:match("^Barrier_%d+_%d+$") then
        print("New barrier added:", descendant.Name)
        local prompt = descendant:FindFirstChild("UnlockPrompt")
        if prompt and prompt:IsA("ProximityPrompt") then
            connectPrompt(prompt, descendant)
        else
            -- Add a proximity prompt
            prompt = Instance.new("ProximityPrompt")
            prompt.Name = "UnlockPrompt"
            prompt.ActionText = "View Zone"
            prompt.ObjectText = "Zone Barrier"
            prompt.KeyboardKeyCode = Enum.KeyCode.E
            prompt.HoldDuration = 0
            prompt.MaxActivationDistance = 10
            prompt.RequiresLineOfSight = false
            prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
            prompt.Enabled = true
            prompt.Style = Enum.ProximityPromptStyle.Default
            prompt.ClickablePrompt = true
            prompt.AutoLocalize = true
            prompt.Parent = descendant
            
            connectPrompt(prompt, descendant)
            
            -- Also add a ClickDetector for additional interaction
            local clickDetector = descendant:FindFirstChild("ClickDetector")
            if not clickDetector then
                clickDetector = Instance.new("ClickDetector")
                clickDetector.MaxActivationDistance = 10
                clickDetector.Parent = descendant
                
                clickDetector.MouseClick:Connect(function(plr)
                    print("Barrier clicked by:", plr.Name)
                    if plr == player then
                        task.spawn(function()
                            showUnlockGUI(descendant)
                        end)
                    end
                end)
            end
        end
    elseif descendant:IsA("ProximityPrompt") and descendant.Name == "UnlockPrompt" then
        local barrier = descendant.Parent
        if barrier and (barrier.Name:match("^Barrier_%d+_%d+$") or barrier.Name:match("^ZoneBarrier_%d+_%d+$")) then
            print("New prompt added to barrier:", barrier.Name)
            connectPrompt(descendant, barrier)
        end
    end
end)

-- Add a direct test function that you can trigger with a key press
local UserInputService = game:GetService("UserInputService")

-- Test function to directly show the GUI
local function testShowGUI()
    print("Test: Directly showing GUI")
    
    -- Create dummy data
    local dummyBarrier = {
        Name = "Barrier_1_2"
    }
    
    -- Override remote functions for testing
    local originalGetZoneInfo = remoteFunctions.GetZoneInfo
    local originalGetPlayerData = remoteFunctions.GetPlayerData
    
    remoteFunctions.GetZoneInfo = {
        InvokeServer = function()
            return {
                Name = "Test Zone",
                Description = "This is a test zone",
                UnlockCost = 1000
            }
        end
    }
    
    remoteFunctions.GetPlayerData = {
        InvokeServer = function()
            return {
                Coins = 5000
            }
        end
    }
    
    -- Show the GUI
    showUnlockGUI(dummyBarrier)
    
    -- Restore original functions
    remoteFunctions.GetZoneInfo = originalGetZoneInfo
    remoteFunctions.GetPlayerData = originalGetPlayerData
end

-- Connect to T key press for testing
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.T then
        print("T key pressed, testing GUI")
        testShowGUI()
    end
end)

print("ZoneUnlockHandler script loaded successfully!")

-- Add direct testing code for the first barrier
task.delay(1, function()
    -- Look for barriers in the correct location: Workspace.Worlds.Spawn.MAP.Gates
    local gatesFolder = workspace:FindFirstChild("Worlds")
    local testBarrier = nil
    
    if gatesFolder then
        gatesFolder = gatesFolder:FindFirstChild("Spawn")
        if gatesFolder then
            gatesFolder = gatesFolder:FindFirstChild("MAP")
            if gatesFolder then
                gatesFolder = gatesFolder:FindFirstChild("Gates")
                if gatesFolder then
                    -- Try to find ZoneBarrier_1_2
                    testBarrier = gatesFolder:FindFirstChild("ZoneBarrier_1_2")
                end
            end
        end
    end
    
    -- If not found in the correct location, try the old location for backward compatibility
    if not testBarrier then
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
                            -- Try to find Barrier_1_2
                            testBarrier = oldGatesFolder:FindFirstChild("Barrier_1_2")
                        end
                    end
                end
            end
        end
    end
    
    -- If still not found, search the entire workspace
    if not testBarrier then
        testBarrier = workspace:FindFirstChild("ZoneBarrier_1_2", true)
        if not testBarrier then
            testBarrier = workspace:FindFirstChild("Barrier_1_2", true)
        end
    end
    
    if testBarrier then
        print("TEST: Found barrier directly:", testBarrier.Name)
        
        -- Remove any existing prompt and create a new one
        local testPrompt = testBarrier:FindFirstChild("UnlockPrompt")
        if testPrompt then
            print("TEST: Removing existing prompt")
            testPrompt:Destroy()
        end
        
        print("TEST: Creating new prompt for barrier")
        testPrompt = Instance.new("ProximityPrompt")
        testPrompt.Name = "UnlockPrompt"
        testPrompt.ActionText = "View Zone"
        testPrompt.ObjectText = "Zone Barrier"
        testPrompt.KeyboardKeyCode = Enum.KeyCode.E
        testPrompt.HoldDuration = 0
        testPrompt.MaxActivationDistance = 10
        testPrompt.RequiresLineOfSight = false
        testPrompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
        testPrompt.Enabled = true
        testPrompt.Style = Enum.ProximityPromptStyle.Default
        testPrompt.ClickablePrompt = true
        testPrompt.AutoLocalize = true
        testPrompt.Parent = testBarrier
        
        print("TEST: Prompt properties:")
        print("  - Enabled:", testPrompt.Enabled)
        print("  - MaxActivationDistance:", testPrompt.MaxActivationDistance)
        print("  - HoldDuration:", testPrompt.HoldDuration)
        print("  - KeyboardKeyCode:", testPrompt.KeyboardKeyCode)
        print("  - Exclusivity:", testPrompt.Exclusivity)
        
        -- Add a direct connection to the prompt using a different approach
        local connection = testPrompt.Triggered:Connect(function(plr)
            print("TEST: Direct prompt trigger by", plr.Name)
            if plr == player then
                task.spawn(function()
                    showUnlockGUI(testBarrier)
                end)
            end
        end)
        print("TEST: Added direct connection to prompt:", connection ~= nil)
        
        -- Add a key press handler as another backup
        local keyPressConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.KeyCode == Enum.KeyCode.E then
                print("TEST: E key pressed, gameProcessed =", gameProcessed)
                -- Even if game processed it, we still want to check
                -- Check if player is near the barrier
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local distance = (character.HumanoidRootPart.Position - testBarrier.Position).Magnitude
                    print("TEST: Distance to barrier:", distance)
                    if distance <= 15 then -- Increased distance for better detection
                        print("TEST: E key pressed near barrier")
                        task.spawn(function()
                            showUnlockGUI(testBarrier)
                        end)
                    end
                end
            end
        end)
        print("TEST: Added key press handler:", keyPressConnection ~= nil)
        
        -- Add a global key press handler that works anywhere
        local globalKeyHandler = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.G then
                print("TEST: G key pressed - global override")
                task.spawn(function()
                    showUnlockGUI(testBarrier)
                end)
            end
        end)
        print("TEST: Added global key handler (press G to show GUI):", globalKeyHandler ~= nil)
        
        -- Add a ClickDetector as a backup
        local clickDetector = testBarrier:FindFirstChild("ClickDetector")
        if not clickDetector then
            clickDetector = Instance.new("ClickDetector")
            clickDetector.MaxActivationDistance = 10
            clickDetector.Parent = testBarrier
        end
        
        clickDetector.MouseClick:Connect(function(plr)
            print("TEST: Direct click by", plr.Name)
            if plr == player then
                task.spawn(function()
                    showUnlockGUI(testBarrier)
                end)
            end
        end)
        
        -- Add a touch handler as a last resort
        -- Find a BasePart in the barrier to attach the Touched event to
        local foundPart = false
        for _, part in ipairs(testBarrier:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Touched:Connect(function(hit)
                    local character = player.Character
                    if character and hit:IsDescendantOf(character) then
                        -- Only show once per approach
                        if not _G.touchCooldown then
                            _G.touchCooldown = true
                            print("TEST: Barrier touched by player")
                            task.spawn(function()
                                showUnlockGUI(testBarrier)
                            end)
                            -- Reset cooldown after 3 seconds
                            task.delay(3, function()
                                _G.touchCooldown = false
                            end)
                        end
                    end
                end)
                foundPart = true
                print("TEST: Added touch handler to part:", part.Name)
                break
            end
        end
        
        if not foundPart then
            print("TEST: No BasePart found in barrier to attach Touched event")
        end
        
        print("TEST: Added all interaction handlers to barrier")
    else
        print("TEST: No barrier found directly in workspace")
    end
end)

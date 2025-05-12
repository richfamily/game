--[[
    EmergencyAvatarHandler.lua
    A server-side script that handles the GetStarterAvatar RemoteEvent
    This script will create a starter avatar for the player when they click the emergency button
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- Create the Remotes folder if it doesn't exist
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not remotes then
    remotes = Instance.new("Folder")
    remotes.Name = "Remotes"
    remotes.Parent = ReplicatedStorage
    print("Created Remotes folder")
end

-- Create the GetStarterAvatar RemoteEvent if it doesn't exist
local getStarterAvatarEvent = remotes:FindFirstChild("GetStarterAvatar")
if not getStarterAvatarEvent then
    getStarterAvatarEvent = Instance.new("RemoteEvent")
    getStarterAvatarEvent.Name = "GetStarterAvatar"
    getStarterAvatarEvent.Parent = remotes
    print("Created GetStarterAvatar RemoteEvent")
end

-- Create the UpdateUI RemoteEvent if it doesn't exist
local updateUIEvent = remotes:FindFirstChild("UpdateUI")
if not updateUIEvent then
    updateUIEvent = Instance.new("RemoteEvent")
    updateUIEvent.Name = "UpdateUI"
    updateUIEvent.Parent = remotes
    print("Created UpdateUI RemoteEvent")
end

-- Function to create a starter avatar for a player
local function createStarterAvatar(player)
    -- Check if the player already has an avatar
    local playerData = player:FindFirstChild("PlayerData")
    if playerData and playerData:FindFirstChild("Avatars") and #playerData.Avatars:GetChildren() > 0 then
        print("Player " .. player.Name .. " already has avatars")
        return
    end
    
    -- Create the PlayerData folder if it doesn't exist
    if not playerData then
        playerData = Instance.new("Folder")
        playerData.Name = "PlayerData"
        playerData.Parent = player
        print("Created PlayerData folder for " .. player.Name)
    end
    
    -- Create the Avatars folder if it doesn't exist
    local avatars = playerData:FindFirstChild("Avatars")
    if not avatars then
        avatars = Instance.new("Folder")
        avatars.Name = "Avatars"
        avatars.Parent = playerData
        print("Created Avatars folder for " .. player.Name)
    end
    
    -- Create a starter avatar
    local avatar = Instance.new("Model")
    avatar.Name = "StarterAvatar"
    
    -- Create a simple part for the avatar
    local part = Instance.new("Part")
    part.Name = "Body"
    part.Size = Vector3.new(2, 2, 2)
    part.Position = player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
    part.Anchored = false
    part.CanCollide = false
    part.BrickColor = BrickColor.new("Bright blue")
    part.Shape = Enum.PartType.Ball
    part.Parent = avatar
    
    -- Create a billboard GUI for the avatar
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "NameTag"
    billboardGui.Size = UDim2.new(0, 100, 0, 40)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.Adornee = part
    billboardGui.Parent = part
    
    -- Create a text label for the avatar's name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Text = "Starter Avatar"
    nameLabel.Parent = billboardGui
    
    -- Create a weld to attach the avatar to the player
    local weld = Instance.new("Weld")
    weld.Name = "FollowWeld"
    weld.Part0 = player.Character.HumanoidRootPart
    weld.Part1 = part
    weld.C0 = CFrame.new(0, 0, -5) -- Position the avatar behind the player
    weld.Parent = part
    
    -- Parent the avatar to the Avatars folder
    avatar.Parent = avatars
    
    -- Create a copy in the workspace so it's visible
    local workspaceAvatar = avatar:Clone()
    workspaceAvatar.Name = player.Name .. "'s Avatar"
    workspaceAvatar.Parent = workspace
    
    -- Store a reference to the workspace avatar in the player's avatar
    local workspaceRef = Instance.new("ObjectValue")
    workspaceRef.Name = "WorkspaceRef"
    workspaceRef.Value = workspaceAvatar
    workspaceRef.Parent = avatar
    
    -- Notify the player that they received an avatar
    updateUIEvent:FireClient(player, {
        Type = "StarterAvatarReceived",
        PlayerData = {
            Avatars = {avatar}
        }
    })
    
    print("Created starter avatar for " .. player.Name)
    return avatar
end

-- Handle the GetStarterAvatar RemoteEvent
getStarterAvatarEvent.OnServerEvent:Connect(function(player)
    print("GetStarterAvatar event received from " .. player.Name)
    
    -- Create a starter avatar for the player
    local success, result = pcall(function()
        return createStarterAvatar(player)
    end)
    
    if success then
        print("Successfully created starter avatar for " .. player.Name)
    else
        warn("Failed to create starter avatar for " .. player.Name .. ": " .. tostring(result))
        
        -- Notify the player of the error
        updateUIEvent:FireClient(player, {
            Type = "StarterAvatarError",
            ErrorMessage = "Failed to create avatar: " .. tostring(result)
        })
    end
end)

print("EmergencyAvatarHandler initialized")

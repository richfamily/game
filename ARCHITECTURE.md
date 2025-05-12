# Roblox Fantasy Pet Simulator - Architecture Overview

This document provides an overview of the architecture and design of the Roblox Fantasy Pet Simulator game. It explains how the different modules interact with each other and how the game's core systems work.

## Table of Contents

1. [Project Structure](#project-structure)
2. [Core Modules](#core-modules)
3. [Configuration Files](#configuration-files)
4. [Game Flow](#game-flow)
5. [Data Management](#data-management)
6. [Implementation Guide](#implementation-guide)

## Project Structure

The project follows a modular architecture with clear separation of concerns:

```
RobloxFantasyPetSim/
├── README.md                 # Project overview and documentation
├── ARCHITECTURE.md           # This file - architecture documentation
├── ServerScriptService/      # Server-side scripts
│   ├── DataManager/          # Data persistence scripts
│   ├── GameManager/          # Game flow control scripts
│   ├── PetManager/           # Pet-related scripts
│   └── ZoneManager/          # Zone-related scripts
├── ReplicatedStorage/        # Shared resources
│   ├── Config/               # Configuration files
│   │   ├── GameConfig.lua    # General game settings
│   │   ├── PetConfig.lua     # Pet definitions and settings
│   │   ├── AuraConfig.lua    # Aura definitions and settings
│   │   ├── RelicConfig.lua   # Relic definitions and settings
│   │   └── ZoneConfig.lua    # Zone definitions and settings
│   └── Modules/              # Shared modules
│       ├── Utilities.lua     # Utility functions
│       ├── DataManager.lua   # Data management module
│       ├── PetManager.lua    # Pet management module
│       ├── ZoneManager.lua   # Zone management module
│       ├── CurrencyManager.lua # Currency management module
│       ├── DrawManager.lua   # Draw system module
│       └── RelicManager.lua  # Relic management module
├── StarterGui/               # UI elements
│   ├── MainUI/               # Main game interface
│   ├── PetInventory/         # Pet inventory interface
│   └── Shop/                 # Shop interface
└── StarterPlayerScripts/     # Client-side scripts
    ├── UIController/         # UI control scripts
    └── GameController/       # Client-side game logic
```

## Core Modules

### Utilities.lua
- Provides general utility functions used throughout the game
- Includes functions for formatting numbers, handling tables, generating unique IDs, etc.

### DataManager.lua
- Handles player data saving and loading
- Manages player progression, inventory, and statistics
- Provides methods for updating player data and saving to DataStore

### PetManager.lua
- Manages pet-related functionality
- Handles pet creation, stats calculation, and pet interactions
- Provides methods for equipping pets, adding experience, and fusing pets

### ZoneManager.lua
- Manages zone-related functionality
- Handles zone creation, enemy spawning, and zone progression
- Provides methods for unlocking zones, damaging enemies, and handling rebirth statues

### CurrencyManager.lua
- Manages currency-related functionality
- Handles earning, spending, and tracking different types of currencies
- Provides methods for adding/removing currency and checking balances

### DrawManager.lua
- Manages the draw system for pets, auras, and relics
- Handles the randomization and rarity determination for draws
- Provides methods for performing draws and calculating draw chances

### RelicManager.lua
- Manages relic-related functionality
- Handles relic creation, effect calculation, and relic interactions
- Provides methods for equipping relics and calculating relic bonuses

## Configuration Files

### GameConfig.lua
- Contains general game settings and configuration
- Defines starting values, mechanics settings, and progression parameters

### PetConfig.lua
- Contains pet definitions, stats, and rarity information
- Defines the leveling system and fusion mechanics for pets

### AuraConfig.lua
- Contains aura definitions, effects, and rarity information
- Defines the leveling system and fusion mechanics for auras

### RelicConfig.lua
- Contains relic definitions, effects, and rarity information
- Defines the leveling system and combination mechanics for relics

### ZoneConfig.lua
- Contains zone definitions, enemy types, and progression requirements
- Defines the rebirth system, boss placement (every 5 zones), and difficulty scaling

## Game Flow

1. **Player Joins Game**
   - DataManager loads or creates player data
   - Player is placed in their highest unlocked zone or the starting zone

2. **Core Gameplay Loop**
   - Player controls pets to attack enemies in the current zone
   - Defeating enemies rewards currency (primarily Coins)
   - Currency is used to unlock new zones, draw pets, and upgrade existing pets
   - As players progress through zones, they unlock more powerful pets, auras, and relics

3. **Progression Systems**
   - **Zone Progression**: Players unlock new zones by spending Coins
   - **Pet Collection**: Players collect pets through the draw system using Coins
   - **Aura Collection**: Players collect auras through the draw system using Diamonds
   - **Relic Collection**: Players collect relics through the draw system using Rubies
   - **Rebirth System**: Players can rebirth at rebirth statues to reset progress but gain permanent multipliers

4. **Economy Systems**
   - **Coins**: Primary currency, earned from defeating enemies and bosses
   - **Diamonds**: Secondary currency, earned at 10% of coins earned from defeating enemies
   - **Rubies**: Special currency for obtaining powerful relics, earned only from defeating bosses at 10% of diamonds earned

## Data Management

The DataManager module handles all player data persistence using Roblox's DataStore service:

- **Player Data Structure**:
  ```lua
  {
      -- Currencies
      Coins = 100,
      Diamonds = 10,
      Rubies = 0,
      
      -- Collections
      Pets = {}, -- Array of pet objects
      Auras = {}, -- Array of aura objects
      Relics = {}, -- Array of relic objects
      
      -- Progression
      UnlockedZones = {1}, -- Array of unlocked zone numbers
      RebirthLevel = 0,
      
      -- Multipliers
      Multipliers = {
          Coins = 1,
          Damage = 1,
          Speed = 1
      },
      
      -- Statistics
      Stats = {
          TotalCoinsEarned = 0,
          TotalDiamondsEarned = 0,
          TotalRubiesEarned = 0,
          EnemiesDefeated = 0,
          BossesDefeated = 0,
          PetsHatched = 0,
          AurasObtained = 0,
          RelicsDiscovered = 0,
          ZonesUnlocked = 1,
          HighestZoneReached = 1,
          RebirthCount = 0,
          TotalPetLevels = 0
      },
      
      -- Timestamps
      LastSave = 0,
      LastLogin = 0,
      PlayTime = 0,
      JoinDate = 0
  }
  ```

- **Data Saving**: Player data is automatically saved at regular intervals and when the player leaves the game
- **Data Loading**: Player data is loaded when the player joins the game
- **Data Updates**: Various modules update player data through the DataManager's methods

## Implementation Guide

To implement this pet simulator game in Roblox Studio:

1. **Set Up Project Structure**:
   - Create the folder structure as outlined in the Project Structure section
   - Import all the Lua files into their respective folders

2. **Configure Game Settings**:
   - Review and adjust the configuration files to match your desired game balance
   - Add or modify pets, auras, relics, and zones as needed

3. **Implement Server Scripts**:
   - Create server scripts that initialize the core modules
   - Set up event handlers for player actions

4. **Implement Client Scripts**:
   - Create client scripts that handle UI interactions
   - Set up event handlers for player input

5. **Create UI Elements**:
   - Design and implement the user interface elements
   - Connect UI elements to client scripts

6. **Create Game Assets**:
   - Design and create 3D models for pets, auras, relics, and zones
   - Create particle effects and sounds for game feedback

7. **Testing and Balancing**:
   - Test the game thoroughly to ensure all systems work correctly
   - Balance the game economy and progression to ensure a fun experience

## Module Initialization Example

Here's an example of how to initialize the core modules in a server script:

```lua
-- Server script in ServerScriptService

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Import modules
local DataManager = require(ReplicatedStorage.Modules.DataManager)
local PetManager = require(ReplicatedStorage.Modules.PetManager)
local ZoneManager = require(ReplicatedStorage.Modules.ZoneManager)
local CurrencyManager = require(ReplicatedStorage.Modules.CurrencyManager)
local DrawManager = require(ReplicatedStorage.Modules.DrawManager)
local RelicManager = require(ReplicatedStorage.Modules.RelicManager)

-- Initialize modules
local dataManager = DataManager.new()
local petManager = PetManager.new()
local zoneManager = ZoneManager.new()
local currencyManager = CurrencyManager.new()
local drawManager = DrawManager.new()
local relicManager = RelicManager.new()

-- Player joined event
Players.PlayerAdded:Connect(function(player)
    -- Load player data
    local playerData = dataManager:LoadData(player)
    
    -- Set up player's game state
    -- ...
    
    -- Create player's starting zone
    local startingZoneNumber = 1
    if #playerData.UnlockedZones > 0 then
        startingZoneNumber = math.max(unpack(playerData.UnlockedZones))
    end
    local startingZoneID = "ZONE_1_" .. startingZoneNumber
    local zonePosition = Vector3.new(0, 0, 0) -- Adjust as needed
    local zone = zoneManager:CreateZone(startingZoneID, zonePosition)
    
    -- Teleport player to starting zone
    -- ...
end)

-- Player leaving event
Players.PlayerRemoving:Connect(function(player)
    -- Save player data
    dataManager:PlayerRemoving(player)
end)

-- Set up remote events for client-server communication
-- ...
```

This architecture provides a solid foundation for building a robust pet simulator game in Roblox. The modular design allows for easy expansion and modification of game features while maintaining clean separation of concerns.

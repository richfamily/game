# Roblox Fantasy Pet Simulator - Implementation Guide

This guide provides step-by-step instructions for implementing the Fantasy Pet Simulator game in Roblox Studio. It explains how to set up the project, import the code, and create the necessary UI elements.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Setup](#project-setup)
3. [Importing Code](#importing-code)
4. [Creating UI Elements](#creating-ui-elements)
5. [Creating Game Assets](#creating-game-assets)
6. [Testing and Debugging](#testing-and-debugging)
7. [Next Steps](#next-steps)

## Prerequisites

Before you begin, make sure you have:

- Roblox Studio installed
- Basic understanding of Lua programming
- Basic understanding of Roblox Studio's interface
- The complete code package for the Fantasy Pet Simulator

## Project Setup

1. **Create a new Roblox place**
   - Open Roblox Studio
   - Select "New" → "Baseplate" to create a new place

2. **Set up the basic services**
   - Make sure the following services are available:
     - ServerScriptService
     - ReplicatedStorage
     - StarterGui
     - StarterPlayerScripts
     - Workspace

3. **Configure place settings**
   - Go to "File" → "Game Settings"
   - Set an appropriate name for your game (e.g., "Fantasy Pet Simulator")
   - Configure other settings as needed

## Importing Code

1. **Create the folder structure**
   - In ReplicatedStorage, create the following folders:
     - Config
     - Modules
     - Remotes (this will be created by the GameInit script)
   - In ServerScriptService, create the following folders:
     - GameManager
     - DataManager
     - PetManager
     - ZoneManager
   - In StarterPlayerScripts, create the following folders:
     - GameController
   - In StarterGui, create the following folders:
     - MainUI
     - PetInventory
     - Shop

2. **Import configuration files**
   - Copy the following files to ReplicatedStorage/Config:
     - GameConfig.lua
     - PetConfig.lua
     - AuraConfig.lua
     - RelicConfig.lua
     - ZoneConfig.lua

3. **Import module files**
   - Copy the following files to ReplicatedStorage/Modules:
     - Utilities.lua
     - DataManager.lua
     - PetManager.lua
     - ZoneManager.lua
     - CurrencyManager.lua
     - DrawManager.lua
     - RelicManager.lua

4. **Import server scripts**
   - Copy GameInit.lua to ServerScriptService/GameManager

5. **Import client scripts**
   - Copy ClientInit.lua to StarterPlayerScripts/GameController

## Creating UI Elements

The client script references several UI elements that need to be created in StarterGui. Here's how to create them:

1. **Create MainUI**
   - In StarterGui, create a ScreenGui named "MainUI"
   - Add the following elements to MainUI:
     - CurrencyDisplay: Frame
       - Coins: TextLabel
       - Diamonds: TextLabel
       - Rubies: TextLabel
     - Tabs: Frame
       - Pets: ImageButton
         - Selected: Frame (initially invisible)
       - Shop: ImageButton
         - Selected: Frame (initially invisible)
       - Stats: ImageButton
         - Selected: Frame (initially invisible)
       - Teleport: ImageButton
         - Selected: Frame (initially invisible)
       - AutoAttack: ImageButton
         - Background changes to yellow when active
     - PetInventory: Frame
       - Filters: Frame
         - All: TextButton (with UIStroke for selection)
         - Equipped: TextButton (with UIStroke for selection)
         - Unequipped: TextButton (with UIStroke for selection)
       - PetSlots: ScrollingFrame
         - Template: Frame (set Visible to false)
           - PetName: TextLabel
           - PetRarity: TextLabel
           - PetLevel: TextLabel
           - PetImage: ImageLabel
           - RarityColor: Frame
           - EquipButton: Frame
             - EquipImage: ImageButton (visible when pet is not equipped)
             - EquippedImage: ImageButton (visible when pet is equipped)
           - AuraButton: ImageButton
           - InfoButton: ImageButton
       - PetCount: TextLabel
     - Shop: Frame (initially invisible)
       - Tabs: Frame
         - Pets: TextButton
           - Selected: Frame (initially visible)
         - Auras: TextButton
           - Selected: Frame (initially invisible)
         - Relics: TextButton
           - Selected: Frame (initially invisible)
       - Tiers: Frame
         - Basic: TextButton
           - Selected: Frame (initially visible)
         - Premium: TextButton
           - Selected: Frame (initially invisible)
         - Ultimate: TextButton
           - Selected: Frame (initially invisible)
       - ChancesContainer: Frame
       - DrawCost: TextLabel
       - DrawButton: TextButton
       - MultiDrawCost: TextLabel
       - MultiDrawButton: TextButton
     - TeleportFrame: Frame (initially invisible)
       - WorldTabs: Frame
         - World1: ImageButton
           - Selected: Frame (initially visible)
         - World2: ImageButton
           - Selected: Frame (initially invisible)
       - WorldScroll: ScrollingFrame
         - World1Frame: Frame (initially visible)
           - ZoneScroll: ScrollingFrame
             - UIListLayout
             - ZoneEntryTemplate: Frame (set Visible = false)
               - ZoneName: TextButton (clickable to teleport)
               - ZoneDesc: TextLabel
             - Zone entries (created dynamically by cloning the template)
         - World2Frame: Frame (initially invisible)
           - ZoneScroll: ScrollingFrame
             - UIListLayout
             - ZoneEntryTemplate: Frame (set Visible = false)
               - ZoneName: TextButton (clickable to teleport)
               - ZoneDesc: TextLabel
             - Zone entries (created dynamically by cloning the template)
     - StatsUI: Frame (initially invisible)
       - CoinsEarned: TextLabel
       - DiamondsEarned: TextLabel
       - RubiesEarned: TextLabel
       - EnemiesDefeated: TextLabel
       - BossesDefeated: TextLabel
       - PetsHatched: TextLabel
       - AurasObtained: TextLabel
       - RelicsDiscovered: TextLabel
       - ZonesUnlocked: TextLabel
       - HighestZone: TextLabel
       - RebirthCount: TextLabel
       - PlayTime: TextLabel
       - CoinMultiplier: TextLabel
       - DamageMultiplier: TextLabel
       - SpeedMultiplier: TextLabel
       - PetCollection: TextLabel
       - AuraCollection: TextLabel
       - RelicCollection: TextLabel

2. **Style the UI elements**
   - Apply appropriate colors, fonts, and sizes to all UI elements
   - Position elements correctly within their parent frames
   - Add appropriate icons and images

3. **Main UI Frame Descriptions**
   - **CurrencyDisplay**: Located at the top-right corner of the screen
     - Purpose: Shows the player's current currency amounts
     - Contains three sub-frames (Coins, Diamonds, Rubies), each with an ImageLabel (icon) and TextLabel (amount)
     - Should be always visible regardless of which tab is active
   
   - **Tabs**: Located at the left center side of the screen
     - Purpose: Navigation hub for all game interfaces
     - Contains four ImageButtons with icon graphics (no text):
       - Pets button: Opens the pet inventory
       - Shop button: Opens the shop interface
       - Stats button: Opens the stats interface
       - Teleport button: Opens the teleport interface
     - Each button should have a distinct icon representing its function
     - Should be always visible and positioned vertically
     - Consider adding hover effects or tooltips to explain each button's function
   
   - **PetInventory**: Main content area
     - Purpose: Displays and manages the player's pets
     - Contains a filter bar at the top with options (All, Equipped, Unequipped)
     - Contains a scrolling frame of pet slots, each showing pet info and action buttons
     - Shows pet count at the bottom
     - Initially invisible, shown when the Pets button is clicked
     - Should appear in the center of the screen, not overlapping with the Tabs frame
   
   - **Shop**: Main content area
     - Purpose: Allows players to draw (purchase) pets, auras, and relics
     - Contains tabs for different draw types (Pets, Auras, Relics)
     - Contains tier options (Basic, Premium, Ultimate)
     - Shows draw chances, costs, and buttons for single and multi-draws
     - Initially invisible, shown when the Shop button is clicked
     - Should appear in the center of the screen, not overlapping with the Tabs frame
   
   - **StatsUI**: Main content area
     - Purpose: Displays player statistics and achievements
     - Contains multiple TextLabels showing various stats (currencies earned, enemies defeated, etc.)
     - Contains multiplier information
     - Contains collection progress
     - Initially invisible, shown when the Stats button is clicked
     - Should appear in the center of the screen, not overlapping with the Tabs frame
   
   - **TeleportFrame**: Full-screen overlay
     - Purpose: Allows players to teleport between zones
     - Contains world tabs at the top
     - Contains a scrolling list of zones with zone info and teleport buttons
     - Shows indicators for special zones (boss zones, rebirth zones)
     - Initially invisible, shown when the Teleport button in the Tabs frame is clicked
     - Should appear in the center of the screen, potentially covering most of the screen except the Tabs frame

4. **Currency Display Formatting**
   - Currency values should be formatted according to these rules:
     - Numbers under 1,000: Display as is (e.g., "123")
     - Numbers from 1,000 to 999,999: Add comma separators (e.g., "123,456")
     - Numbers from 1,000,000 to 999,999,999: Use "m" suffix with one decimal place (e.g., "1.2m")
     - Numbers from 1,000,000,000 to 999,999,999,999: Use "b" suffix with one decimal place (e.g., "1.2b")
     - Numbers from 1,000,000,000,000 to 999,999,999,999,999: Use "t" suffix with one decimal place (e.g., "1.2t")
     - Numbers from 1,000,000,000,000,000 to 999,999,999,999,999,999: Use "qa" suffix with one decimal place (e.g., "1.2qa")
     - Numbers from 1,000,000,000,000,000,000 and above: Use "qi" suffix with one decimal place (e.g., "1.2qi")
   - The Utilities.lua module provides the FormatNumber function for this formatting
   - All currency displays should use TextLabels inside their respective frames:
     - currencyDisplay.Coins.TextLabel
     - currencyDisplay.Diamonds.TextLabel
     - currencyDisplay.Rubies.TextLabel

## Creating Game Assets

The game requires various assets to function properly:

1. **Create pet models**
   - Create 3D models for each pet defined in PetConfig.lua
   - Place them in ReplicatedStorage/Assets/Pets
   - Name them according to their ModelID in the config

2. **Create aura effects**
   - Create particle effects for each aura defined in AuraConfig.lua
   - Place them in ReplicatedStorage/Assets/Auras
   - Name them according to their VisualEffect in the config

3. **Create relic models**
   - Create 3D models for each relic defined in RelicConfig.lua
   - Place them in ReplicatedStorage/Assets/Relics
   - Name them according to their ModelID in the config

4. **Create zone assets**
   - Create background models/images for each zone
   - Create enemy models for each zone
   - Create boss models for zones that are multiples of 5 (5, 10, 15, etc.)
   - Create zone barriers between zones with unlock cost displays
   - Create rebirth statues for even-numbered zones
   - Place them in appropriate folders in ReplicatedStorage/Assets

5. **Create 3D world interactions**
   - **Zone Barriers**:
     - Place physical barriers between zones named "ZoneBarrier_[WorldNumber]_[ZoneNumber]"
     - Add ProximityPrompt named "UnlockPrompt" to each barrier
     - Create a ScreenGUI in StarterGUI for zone unlocking (see details below)
     - Connect proximity events to show the unlock GUI when triggered
     
   - **Zone Unlock ScreenGUI Structure**:
     ```
     - ZoneUnlockGUI (ScreenGUI, initially invisible)
       - Background (Frame)
         - Size: {1, 0}, {1, 0} (full screen)
         - BackgroundColor3: Black
         - BackgroundTransparency: 0.5
         - ZIndex: 1
       
       - ZoneInfoFrame (Frame)
         - Size: {0.4, 0}, {0.3, 0}
         - Position: {0.5, 0}, {0.4, 0}
         - AnchorPoint: {0.5, 0.5} (centered)
         - BackgroundColor3: Dark gray
         
         - ZoneNameLabel (TextLabel)
           - Size: {0.9, 0}, {0.3, 0}
           - Position: {0.5, 0}, {0.1, 0}
           - AnchorPoint: {0.5, 0}
           - Font: GothamBold
           - TextSize: 24
         
         - ZoneDescriptionLabel (TextLabel)
           - Size: {0.9, 0}, {0.4, 0}
           - Position: {0.5, 0}, {0.4, 0}
           - AnchorPoint: {0.5, 0}
           - Font: Gotham
           - TextSize: 18
           - TextWrapped: true
       
       - UnlockFrame (Frame)
         - Size: {0.4, 0}, {0.2, 0}
         - Position: {0.5, 0}, {0.7, 0}
         - AnchorPoint: {0.5, 0.5}
         - BackgroundTransparency: 1
         
         - CostLabel (TextLabel)
           - Size: {0.9, 0}, {0.4, 0}
           - Position: {0.5, 0}, {0.2, 0}
           - AnchorPoint: {0.5, 0.5}
           - Font: GothamBold
           - TextSize: 20
         
         - UnlockButton (ImageButton)
           - Size: {0.6, 0}, {0.5, 0}
           - Position: {0.5, 0}, {0.7, 0}
           - AnchorPoint: {0.5, 0.5}
           - BackgroundColor3: Green
           - Text: "UNLOCK"
           - Font: GothamBold
           - TextSize: 18
       
       - CloseButton (ImageButton)
         - Size: {0.05, 0}, {0.05, 0}
         - Position: {0.95, 0}, {0.05, 0}
         - AnchorPoint: {1, 0}
         - Text: "X"
         - Font: GothamBold
         - TextSize: 14
     ```
   
   - **Boss Interactions**:
     - Create larger, more detailed models for bosses
     - Add ClickDetector to each boss
     - Add BillboardGui for health display
     - Connect click events to damage the boss
   
   - **Rebirth Statues**:
     - Create statue models for even-numbered zones
     - Add ProximityPrompt to each statue (triggered with E key)
     - Connect ProximityPrompt to show rebirth confirmation UI
     - Create rebirth confirmation UI with cost and benefits display

## Testing and Debugging

1. **Test in Studio**
   - Run the game in Roblox Studio
   - Check the Output window for any errors
   - Test basic functionality:
     - Player joining
     - Data loading
     - Zone creation
     - Pet equipping
     - Enemy attacking

2. **Debug common issues**
   - If RemoteEvents or RemoteFunctions are not found, check that GameInit.lua is running correctly
   - If player data is not loading, check the DataManager module
   - If zones are not appearing, check the ZoneManager module
   - If UI is not updating, check the ClientInit script

## Next Steps

Once you have the basic game functioning, consider these enhancements:

1. **Add sound effects**
   - Add sounds for:
     - Attacking enemies
     - Collecting coins
     - Drawing pets
     - Unlocking zones
     - Rebirthing

2. **Add animations**
   - Add animations for:
     - Pets attacking
     - Enemies taking damage
     - Drawing pets
     - Unlocking zones

3. **Add visual effects**
   - Add particle effects for:
     - Coin collection
     - Pet attacks
     - Enemy defeats
     - Zone unlocks
     - Rebirths

4. **Expand the game**
   - Add more worlds
   - Add more pets, auras, and relics
   - Add more game mechanics
   - Add more progression systems

## Conclusion

This implementation guide provides the basic steps to get your Fantasy Pet Simulator up and running in Roblox Studio. The modular design of the code allows for easy expansion and modification, so feel free to customize the game to your liking.

Remember to thoroughly test your game before publishing it to ensure a smooth player experience. Good luck with your pet simulator game!

---

For more detailed information about the game's architecture and design, refer to the ARCHITECTURE.md file.

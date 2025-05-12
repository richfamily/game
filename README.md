# Roblox Fantasy Pet Simulator

A robust pet simulator game with features similar to Pet Simulator 99, plus additional unique mechanics:
- Multiple worlds with 100 zones each
- Rebirth statues every other zone
- Bosses appear every 5 zones
- Three types of draws: Coins for Pets, Diamonds for Auras, and Rubies for unique player bonuses (Relics)
- Ability to equip auras on pets
- Portal system between worlds

## Currency System

- **Coins**: Earned from defeating regular enemies in zones
- **Diamonds**: Earned at 10% of coins earned from enemies
- **Rubies**: Earned only from defeating bosses, at 10% of diamonds earned from that boss

## Project Structure

- **ServerScriptService**: Server-side scripts and logic
  - **DataManager**: Handles player data saving/loading
  - **GameManager**: Controls game flow and mechanics
  - **PetManager**: Manages pet creation, stats, and behaviors
  - **ZoneManager**: Handles zone creation and progression
  
- **ReplicatedStorage**: Shared modules and assets
  - **Modules**: Shared code modules
  - **Assets**: Shared assets (models, animations, etc.)
  - **Config**: Game configuration files
  
- **StarterGui**: User interface elements
  - **MainUI**: Main game interface
  - **PetInventory**: Pet inventory interface
  - **Shop**: Shop interface for purchases
  
- **StarterPlayerScripts**: Client-side scripts
  - **UIController**: Controls UI interactions
  - **GameController**: Client-side game logic
  
- **Workspace**: Game world objects
  - **Zones**: Contains all game zones
  - **Portals**: Portal objects for world transitions
  - **RebirthStatues**: Rebirth statue objects

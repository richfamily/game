--[[
    GearConfig.lua
    Contains configuration for the gear system
]]

local GearConfig = {
    -- Gear Types
    Types = {
        "Weapon",
        "Head",
        "Chest",
        "Boots",
        "Pants",
        "Gloves"
    },
    
    -- Gear Rarities
    Rarities = {
        {
            Name = "Common",
            Chance = 0.50,
            StatMultiplier = 1.0,
            Color = Color3.fromRGB(255, 255, 255)
        },
        {
            Name = "Uncommon",
            Chance = 0.25,
            StatMultiplier = 1.5,
            Color = Color3.fromRGB(0, 255, 0)
        },
        {
            Name = "Rare",
            Chance = 0.15,
            StatMultiplier = 2.0,
            Color = Color3.fromRGB(0, 100, 255)
        },
        {
            Name = "Epic",
            Chance = 0.07,
            StatMultiplier = 3.0,
            Color = Color3.fromRGB(170, 0, 255)
        },
        {
            Name = "Legendary",
            Chance = 0.025,
            StatMultiplier = 5.0,
            Color = Color3.fromRGB(255, 215, 0)
        },
        {
            Name = "Mythical",
            Chance = 0.005,
            StatMultiplier = 10.0,
            Color = Color3.fromRGB(255, 0, 0)
        }
    },
    
    -- Gear Definitions
    Definitions = {
        -- Weapons
        WEAPON_BASIC_SWORD = {
            Name = "Basic Sword",
            Type = "Weapon",
            Description = "A simple sword for beginners",
            BaseDamage = 5,
            BaseSpeed = 0,
            AvailableRarities = {"Common", "Uncommon", "Rare"},
            MinZone = 1,
            MaxZone = 10,
            DrawType = "Coins",
            ModelID = "rbxassetid://12345678"
        },
        WEAPON_FIRE_BLADE = {
            Name = "Fire Blade",
            Type = "Weapon",
            Description = "A sword imbued with fire magic",
            BaseDamage = 15,
            BaseSpeed = 0,
            AvailableRarities = {"Uncommon", "Rare", "Epic"},
            MinZone = 5,
            MaxZone = 20,
            DrawType = "Coins",
            ModelID = "rbxassetid://12345679"
        },
        WEAPON_FROST_AXE = {
            Name = "Frost Axe",
            Type = "Weapon",
            Description = "An axe with frost enchantment",
            BaseDamage = 25,
            BaseSpeed = -2, -- Slower but more damage
            AvailableRarities = {"Rare", "Epic", "Legendary"},
            MinZone = 15,
            MaxZone = 40,
            DrawType = "Coins",
            ModelID = "rbxassetid://12345680"
        },
        WEAPON_LIGHTNING_DAGGER = {
            Name = "Lightning Dagger",
            Type = "Weapon",
            Description = "A fast dagger that strikes like lightning",
            BaseDamage = 10,
            BaseSpeed = 5, -- Faster but less damage
            AvailableRarities = {"Rare", "Epic", "Legendary"},
            MinZone = 20,
            MaxZone = 50,
            DrawType = "Coins",
            ModelID = "rbxassetid://12345681"
        },
        
        -- Head Gear
        HEAD_BASIC_HELMET = {
            Name = "Basic Helmet",
            Type = "Head",
            Description = "A simple helmet for protection",
            BaseDamage = 2,
            BaseSpeed = 0,
            AvailableRarities = {"Common", "Uncommon", "Rare"},
            MinZone = 1,
            MaxZone = 10,
            DrawType = "Coins",
            ModelID = "rbxassetid://12345682"
        },
        HEAD_MAGE_HAT = {
            Name = "Mage Hat",
            Type = "Head",
            Description = "A hat that enhances magical abilities",
            BaseDamage = 5,
            BaseSpeed = 1,
            AvailableRarities = {"Uncommon", "Rare", "Epic"},
            MinZone = 10,
            MaxZone = 30,
            DrawType = "Coins",
            ModelID = "rbxassetid://12345683"
        },
        
        -- Chest Gear
        CHEST_BASIC_ARMOR = {
            Name = "Basic Armor",
            Type = "Chest",
            Description = "Simple armor for protection",
            BaseDamage = 3,
            BaseSpeed = -1,
            AvailableRarities = {"Common", "Uncommon", "Rare"},
            MinZone = 1,
            MaxZone = 10,
            DrawType = "Coins",
            ModelID = "rbxassetid://12345684"
        },
        CHEST_ELEMENTAL_ROBE = {
            Name = "Elemental Robe",
            Type = "Chest",
            Description = "A robe imbued with elemental magic",
            BaseDamage = 7,
            BaseSpeed = 2,
            AvailableRarities = {"Rare", "Epic", "Legendary"},
            MinZone = 15,
            MaxZone = 40,
            DrawType = "Coins",
            ModelID = "rbxassetid://12345685"
        },
        
        -- Boots Gear
        BOOTS_BASIC_SHOES = {
            Name = "Basic Shoes",
            Type = "Boots",
            Description = "Simple shoes for walking",
            BaseDamage = 0,
            BaseSpeed = 2,
            AvailableRarities = {"Common", "Uncommon", "Rare"},
            MinZone = 1,
            MaxZone = 10,
            DrawType = "Coins",
            ModelID = "rbxassetid://12345686"
        },
        BOOTS_SPEED_RUNNERS = {
            Name = "Speed Runners",
            Type = "Boots",
            Description = "Boots that enhance movement speed",
            BaseDamage = 0,
            BaseSpeed = 5,
            AvailableRarities = {"Uncommon", "Rare", "Epic"},
            MinZone = 10,
            MaxZone = 30,
            DrawType = "Coins",
            ModelID = "rbxassetid://12345687"
        },
        
        -- Pants Gear
        PANTS_BASIC_LEGGINGS = {
            Name = "Basic Leggings",
            Type = "Pants",
            Description = "Simple leggings for protection",
            BaseDamage = 1,
            BaseSpeed = 1,
            AvailableRarities = {"Common", "Uncommon", "Rare"},
            MinZone = 1,
            MaxZone = 10,
            DrawType = "Coins",
            ModelID = "rbxassetid://12345688"
        },
        PANTS_ENCHANTED_GREAVES = {
            Name = "Enchanted Greaves",
            Type = "Pants",
            Description = "Greaves with magical enchantments",
            BaseDamage = 3,
            BaseSpeed = 3,
            AvailableRarities = {"Rare", "Epic", "Legendary"},
            MinZone = 20,
            MaxZone = 50,
            DrawType = "Coins",
            ModelID = "rbxassetid://12345689"
        },
        
        -- Gloves Gear
        GLOVES_BASIC_GAUNTLETS = {
            Name = "Basic Gauntlets",
            Type = "Gloves",
            Description = "Simple gauntlets for protection",
            BaseDamage = 2,
            BaseSpeed = 0,
            AvailableRarities = {"Common", "Uncommon", "Rare"},
            MinZone = 1,
            MaxZone = 10,
            DrawType = "Coins",
            ModelID = "rbxassetid://12345690"
        },
        GLOVES_POWER_FISTS = {
            Name = "Power Fists",
            Type = "Gloves",
            Description = "Gauntlets that enhance striking power",
            BaseDamage = 8,
            BaseSpeed = -1,
            AvailableRarities = {"Rare", "Epic", "Legendary"},
            MinZone = 15,
            MaxZone = 40,
            DrawType = "Coins",
            ModelID = "rbxassetid://12345691"
        }
    },
    
    -- Fusion System
    FusionSystem = {
        -- Number of same-type gear needed for fusion
        RequiredCount = 3,
        
        -- Chance to get a higher rarity when fusing
        UpgradeChance = 0.3,
        
        -- Stat boost from fusion (multiplier)
        FusionBoost = 1.2
    },
    
    -- Enhancement System
    EnhancementSystem = {
        -- Maximum enhancement level
        MaxLevel = 10,
        
        -- Cost multiplier per level (base cost * level * multiplier)
        CostMultiplier = 1.5,
        
        -- Stat increase per level (percentage)
        StatIncreasePerLevel = 0.1, -- 10% per level
        
        -- Chance to fail enhancement (increases with level)
        FailChance = {
            [1] = 0.0,  -- Level 1: 0% chance to fail
            [2] = 0.1,  -- Level 2: 10% chance to fail
            [3] = 0.2,  -- Level 3: 20% chance to fail
            [4] = 0.3,  -- Level 4: 30% chance to fail
            [5] = 0.4,  -- Level 5: 40% chance to fail
            [6] = 0.5,  -- Level 6: 50% chance to fail
            [7] = 0.6,  -- Level 7: 60% chance to fail
            [8] = 0.7,  -- Level 8: 70% chance to fail
            [9] = 0.8,  -- Level 9: 80% chance to fail
            [10] = 0.9  -- Level 10: 90% chance to fail
        },
        
        -- On failure, gear level decreases by this amount
        FailLevelDecrease = 1
    }
}

return GearConfig

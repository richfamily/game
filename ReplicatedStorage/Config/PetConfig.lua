--[[
    PetConfig.lua
    Contains pet definitions, stats, and rarity information
]]

local PetConfig = {
    -- Pet Variants
    Variants = {
        Normal = {
            Name = "Normal",
            StatMultiplier = 1.0,
            ModelSuffix = "_MODEL" -- e.g., DOG_BASIC_MODEL
        },
        Golden = {
            Name = "Golden",
            StatMultiplier = 1.3, -- Golden pets are 1.3x as powerful
            ModelSuffix = "_GOLDEN_MODEL" -- e.g., DOG_BASIC_GOLDEN_MODEL
        }
    },
    
    -- Golden Upgrade System
    GoldenUpgradeSystem = {
        CostMultiplier = 15, -- 15x the drawing price
        CurrencyType = "Rubies", -- Use Rubies for upgrades
        UnlockZone = 10 -- Unlock golden upgrades after zone 10
    },
    
    -- Rarity Definitions
    Rarities = {
        {
            Name = "Common",
            Color = Color3.fromRGB(255, 255, 255), -- White
            Chance = 0.50, -- 50% chance
            StatMultiplier = 1.0
        },
        {
            Name = "Uncommon",
            Color = Color3.fromRGB(0, 255, 0), -- Green
            Chance = 0.25, -- 25% chance
            StatMultiplier = 1.5
        },
        {
            Name = "Rare",
            Color = Color3.fromRGB(0, 112, 221), -- Blue
            Chance = 0.15, -- 15% chance
            StatMultiplier = 2.0
        },
        {
            Name = "Epic",
            Color = Color3.fromRGB(163, 53, 238), -- Purple
            Chance = 0.07, -- 7% chance
            StatMultiplier = 3.0
        },
        {
            Name = "Legendary",
            Color = Color3.fromRGB(255, 215, 0), -- Gold
            Chance = 0.025, -- 2.5% chance
            StatMultiplier = 5.0
        },
        {
            Name = "Mythical",
            Color = Color3.fromRGB(255, 0, 0), -- Red
            Chance = 0.005, -- 0.5% chance
            StatMultiplier = 10.0
        }
    },
    
    -- Pet Definitions
    Pets = {
        -- World 1 Pets
        -- Zone 1-10 Pets
        {
            ID = "DOG_BASIC",
            Name = "Basic Dog",
            Description = "A loyal companion that helps you collect coins.",
            BaseDamage = 5,
            BaseSpeed = 10,
            BaseCoinsMultiplier = 1.0,
            ModelID = "DOG_BASIC_MODEL", -- Reference to the model in ReplicatedStorage/Assets
            UnlockZone = 1,
            AvailableRarities = {"Common", "Uncommon", "Rare"},
            DrawType = "Coins"
        },
        {
            ID = "CAT_BASIC",
            Name = "Basic Cat",
            Description = "A nimble feline that quickly collects coins.",
            BaseDamage = 4,
            BaseSpeed = 12,
            BaseCoinsMultiplier = 1.1,
            ModelID = "CAT_BASIC_MODEL",
            UnlockZone = 1,
            AvailableRarities = {"Common", "Uncommon", "Rare"},
            DrawType = "Coins"
        },
        {
            ID = "RABBIT_BASIC",
            Name = "Basic Rabbit",
            Description = "A fast rabbit that hops around collecting coins.",
            BaseDamage = 3,
            BaseSpeed = 15,
            BaseCoinsMultiplier = 1.0,
            ModelID = "RABBIT_BASIC_MODEL",
            UnlockZone = 2,
            AvailableRarities = {"Common", "Uncommon", "Rare"},
            DrawType = "Coins"
        },
        
        -- Zone 11-20 Pets
        {
            ID = "WOLF_FOREST",
            Name = "Forest Wolf",
            Description = "A powerful wolf from the deep forest.",
            BaseDamage = 15,
            BaseSpeed = 12,
            BaseCoinsMultiplier = 1.2,
            ModelID = "WOLF_FOREST_MODEL",
            UnlockZone = 11,
            AvailableRarities = {"Uncommon", "Rare", "Epic"},
            DrawType = "Coins"
        },
        {
            ID = "FOX_FOREST",
            Name = "Forest Fox",
            Description = "A cunning fox that finds hidden treasures.",
            BaseDamage = 12,
            BaseSpeed = 14,
            BaseCoinsMultiplier = 1.3,
            ModelID = "FOX_FOREST_MODEL",
            UnlockZone = 11,
            AvailableRarities = {"Uncommon", "Rare", "Epic"},
            DrawType = "Coins"
        },
        
        -- Zone 21-30 Pets
        {
            ID = "BEAR_MOUNTAIN",
            Name = "Mountain Bear",
            Description = "A strong bear from the mountains with immense power.",
            BaseDamage = 25,
            BaseSpeed = 8,
            BaseCoinsMultiplier = 1.5,
            ModelID = "BEAR_MOUNTAIN_MODEL",
            UnlockZone = 21,
            AvailableRarities = {"Rare", "Epic", "Legendary"},
            DrawType = "Coins"
        },
        {
            ID = "EAGLE_MOUNTAIN",
            Name = "Mountain Eagle",
            Description = "A majestic eagle that soars high and collects coins from above.",
            BaseDamage = 20,
            BaseSpeed = 18,
            BaseCoinsMultiplier = 1.4,
            ModelID = "EAGLE_MOUNTAIN_MODEL",
            UnlockZone = 21,
            AvailableRarities = {"Rare", "Epic", "Legendary"},
            DrawType = "Coins"
        },
        
        -- Zone 31-40 Pets
        {
            ID = "SHARK_OCEAN",
            Name = "Ocean Shark",
            Description = "A fearsome shark that dominates the ocean depths.",
            BaseDamage = 35,
            BaseSpeed = 15,
            BaseCoinsMultiplier = 1.6,
            ModelID = "SHARK_OCEAN_MODEL",
            UnlockZone = 31,
            AvailableRarities = {"Rare", "Epic", "Legendary"},
            DrawType = "Coins"
        },
        {
            ID = "DOLPHIN_OCEAN",
            Name = "Ocean Dolphin",
            Description = "An intelligent dolphin that finds rare treasures.",
            BaseDamage = 30,
            BaseSpeed = 20,
            BaseCoinsMultiplier = 1.7,
            ModelID = "DOLPHIN_OCEAN_MODEL",
            UnlockZone = 31,
            AvailableRarities = {"Rare", "Epic", "Legendary"},
            DrawType = "Coins"
        },
        
        -- Zone 41-50 Pets
        {
            ID = "DRAGON_FIRE",
            Name = "Fire Dragon",
            Description = "A powerful dragon that breathes fire and melts coins.",
            BaseDamage = 50,
            BaseSpeed = 18,
            BaseCoinsMultiplier = 2.0,
            ModelID = "DRAGON_FIRE_MODEL",
            UnlockZone = 41,
            AvailableRarities = {"Epic", "Legendary", "Mythical"},
            DrawType = "Coins"
        },
        {
            ID = "PHOENIX_FIRE",
            Name = "Fire Phoenix",
            Description = "A legendary phoenix that rises from the ashes with renewed strength.",
            BaseDamage = 45,
            BaseSpeed = 22,
            BaseCoinsMultiplier = 2.1,
            ModelID = "PHOENIX_FIRE_MODEL",
            UnlockZone = 41,
            AvailableRarities = {"Epic", "Legendary", "Mythical"},
            DrawType = "Coins"
        },
        
        -- Zone 51-60 Pets
        {
            ID = "GOLEM_CRYSTAL",
            Name = "Crystal Golem",
            Description = "A massive golem made of pure crystal with incredible strength.",
            BaseDamage = 70,
            BaseSpeed = 12,
            BaseCoinsMultiplier = 2.3,
            ModelID = "GOLEM_CRYSTAL_MODEL",
            UnlockZone = 51,
            AvailableRarities = {"Epic", "Legendary", "Mythical"},
            DrawType = "Coins"
        },
        {
            ID = "FAIRY_CRYSTAL",
            Name = "Crystal Fairy",
            Description = "A magical fairy that enhances the power of other pets.",
            BaseDamage = 60,
            BaseSpeed = 25,
            BaseCoinsMultiplier = 2.5,
            ModelID = "FAIRY_CRYSTAL_MODEL",
            UnlockZone = 51,
            AvailableRarities = {"Epic", "Legendary", "Mythical"},
            DrawType = "Coins"
        },
        
        -- Zone 61-70 Pets
        {
            ID = "ROBOT_TECH",
            Name = "Tech Robot",
            Description = "An advanced robot with cutting-edge technology.",
            BaseDamage = 90,
            BaseSpeed = 20,
            BaseCoinsMultiplier = 2.7,
            ModelID = "ROBOT_TECH_MODEL",
            UnlockZone = 61,
            AvailableRarities = {"Epic", "Legendary", "Mythical"},
            DrawType = "Coins"
        },
        {
            ID = "DRONE_TECH",
            Name = "Tech Drone",
            Description = "A high-tech drone that scans for valuable resources.",
            BaseDamage = 80,
            BaseSpeed = 30,
            BaseCoinsMultiplier = 2.8,
            ModelID = "DRONE_TECH_MODEL",
            UnlockZone = 61,
            AvailableRarities = {"Epic", "Legendary", "Mythical"},
            DrawType = "Coins"
        },
        
        -- Zone 71-80 Pets
        {
            ID = "GHOST_SPIRIT",
            Name = "Spirit Ghost",
            Description = "An ethereal ghost that phases through obstacles.",
            BaseDamage = 110,
            BaseSpeed = 25,
            BaseCoinsMultiplier = 3.0,
            ModelID = "GHOST_SPIRIT_MODEL",
            UnlockZone = 71,
            AvailableRarities = {"Legendary", "Mythical"},
            DrawType = "Coins"
        },
        {
            ID = "WRAITH_SPIRIT",
            Name = "Spirit Wraith",
            Description = "A powerful wraith that drains energy from enemies.",
            BaseDamage = 120,
            BaseSpeed = 22,
            BaseCoinsMultiplier = 3.2,
            ModelID = "WRAITH_SPIRIT_MODEL",
            UnlockZone = 71,
            AvailableRarities = {"Legendary", "Mythical"},
            DrawType = "Coins"
        },
        
        -- Zone 81-90 Pets
        {
            ID = "TITAN_COSMIC",
            Name = "Cosmic Titan",
            Description = "A colossal titan with the power of the cosmos.",
            BaseDamage = 150,
            BaseSpeed = 18,
            BaseCoinsMultiplier = 3.5,
            ModelID = "TITAN_COSMIC_MODEL",
            UnlockZone = 81,
            AvailableRarities = {"Legendary", "Mythical"},
            DrawType = "Coins"
        },
        {
            ID = "NEBULA_COSMIC",
            Name = "Cosmic Nebula",
            Description = "A living nebula that contains the energy of a thousand stars.",
            BaseDamage = 140,
            BaseSpeed = 24,
            BaseCoinsMultiplier = 3.7,
            ModelID = "NEBULA_COSMIC_MODEL",
            UnlockZone = 81,
            AvailableRarities = {"Legendary", "Mythical"},
            DrawType = "Coins"
        },
        
        -- Zone 91-100 Pets (Final Zone of World 1)
        {
            ID = "DEITY_DIVINE",
            Name = "Divine Deity",
            Description = "A divine being with unimaginable power.",
            BaseDamage = 200,
            BaseSpeed = 30,
            BaseCoinsMultiplier = 4.0,
            ModelID = "DEITY_DIVINE_MODEL",
            UnlockZone = 91,
            AvailableRarities = {"Mythical"},
            DrawType = "Coins"
        },
        {
            ID = "GUARDIAN_DIVINE",
            Name = "Divine Guardian",
            Description = "The ultimate guardian of the divine realm.",
            BaseDamage = 220,
            BaseSpeed = 28,
            BaseCoinsMultiplier = 4.2,
            ModelID = "GUARDIAN_DIVINE_MODEL",
            UnlockZone = 91,
            AvailableRarities = {"Mythical"},
            DrawType = "Coins"
        }
    },
    
    -- Pet Leveling System
    LevelingSystem = {
        MaxLevel = 50,
        ExperiencePerLevel = function(level)
            return 100 * (level ^ 1.5)
        end,
        StatIncrease = {
            Damage = 0.05, -- 5% increase per level
            Speed = 0.03, -- 3% increase per level
            CoinsMultiplier = 0.02 -- 2% increase per level
        }
    },
    
    -- Fusion System (Combining pets)
    FusionSystem = {
        SameTypeBonus = 0.2, -- 20% bonus when fusing same type
        RarityUpgradeChance = {
            Common = 0.5, -- 50% chance to upgrade from Common to Uncommon
            Uncommon = 0.4, -- 40% chance to upgrade from Uncommon to Rare
            Rare = 0.3, -- 30% chance to upgrade from Rare to Epic
            Epic = 0.2, -- 20% chance to upgrade from Epic to Legendary
            Legendary = 0.1, -- 10% chance to upgrade from Legendary to Mythical
            Mythical = 0 -- Cannot upgrade from Mythical
        },
        RequiredPetsForFusion = 3
    }
}

return PetConfig

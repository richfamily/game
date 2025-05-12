--[[
    RelicConfig.lua
    Contains relic definitions, effects, and rarity information
    Relics provide unique bonuses that affect all player stats
    Relics are obtained using Diamonds
]]

local RelicConfig = {
    -- Rarity Definitions
    Rarities = {
        {
            Name = "Common",
            Color = Color3.fromRGB(255, 255, 255), -- White
            Chance = 0.40, -- 40% chance
            EffectMultiplier = 1.0
        },
        {
            Name = "Uncommon",
            Color = Color3.fromRGB(0, 255, 0), -- Green
            Chance = 0.25, -- 25% chance
            EffectMultiplier = 1.5
        },
        {
            Name = "Rare",
            Color = Color3.fromRGB(0, 112, 221), -- Blue
            Chance = 0.15, -- 15% chance
            EffectMultiplier = 2.0
        },
        {
            Name = "Epic",
            Color = Color3.fromRGB(163, 53, 238), -- Purple
            Chance = 0.10, -- 10% chance
            EffectMultiplier = 3.0
        },
        {
            Name = "Legendary",
            Color = Color3.fromRGB(255, 215, 0), -- Gold
            Chance = 0.07, -- 7% chance
            EffectMultiplier = 4.5
        },
        {
            Name = "Mythical",
            Color = Color3.fromRGB(255, 0, 0), -- Red
            Chance = 0.03, -- 3% chance
            EffectMultiplier = 7.0
        }
    },
    
    -- Relic Definitions
    Relics = {
        -- Basic Relics (Available from start)
        {
            ID = "LUCKY_COIN",
            Name = "Lucky Coin",
            Description = "An ancient coin that brings good fortune to its owner.",
            Effect = {
                Type = "GlobalMultiplier",
                Value = 0.05 -- 5% increase to all stats
            },
            ModelID = "LUCKY_COIN_MODEL", -- Reference to the model in ReplicatedStorage/Assets
            UnlockZone = 1,
            AvailableRarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
        },
        {
            ID = "WARRIORS_EMBLEM",
            Name = "Warrior's Emblem",
            Description = "An emblem worn by ancient warriors, enhancing combat abilities.",
            Effect = {
                Type = "DamageMultiplier",
                Value = 0.10 -- 10% increase to damage
            },
            ModelID = "WARRIORS_EMBLEM_MODEL",
            UnlockZone = 1,
            AvailableRarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
        },
        {
            ID = "SWIFT_BOOTS",
            Name = "Swift Boots",
            Description = "Magical boots that enhance the wearer's speed.",
            Effect = {
                Type = "SpeedMultiplier",
                Value = 0.10 -- 10% increase to speed
            },
            ModelID = "SWIFT_BOOTS_MODEL",
            UnlockZone = 1,
            AvailableRarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
        },
        {
            ID = "TREASURE_HUNTER",
            Name = "Treasure Hunter",
            Description = "A compass that points to hidden treasures.",
            Effect = {
                Type = "CoinMultiplier",
                Value = 0.10 -- 10% increase to coin collection
            },
            ModelID = "TREASURE_HUNTER_MODEL",
            UnlockZone = 1,
            AvailableRarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
        },
        
        -- Intermediate Relics (Unlocked in mid zones)
        {
            ID = "ANCIENT_SCROLL",
            Name = "Ancient Scroll",
            Description = "A scroll containing ancient knowledge that enhances all abilities.",
            Effect = {
                Type = "GlobalMultiplier",
                Value = 0.10 -- 10% increase to all stats
            },
            ModelID = "ANCIENT_SCROLL_MODEL",
            UnlockZone = 20,
            AvailableRarities = {"Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
        },
        {
            ID = "DRAGON_FANG",
            Name = "Dragon Fang",
            Description = "A fang from a powerful dragon, significantly enhancing damage.",
            Effect = {
                Type = "DamageMultiplier",
                Value = 0.20 -- 20% increase to damage
            },
            ModelID = "DRAGON_FANG_MODEL",
            UnlockZone = 25,
            AvailableRarities = {"Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
        },
        {
            ID = "WIND_CRYSTAL",
            Name = "Wind Crystal",
            Description = "A crystal infused with wind energy, significantly enhancing speed.",
            Effect = {
                Type = "SpeedMultiplier",
                Value = 0.20 -- 20% increase to speed
            },
            ModelID = "WIND_CRYSTAL_MODEL",
            UnlockZone = 30,
            AvailableRarities = {"Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
        },
        {
            ID = "GOLDEN_CHALICE",
            Name = "Golden Chalice",
            Description = "A chalice made of pure gold, significantly enhancing coin collection.",
            Effect = {
                Type = "CoinMultiplier",
                Value = 0.20 -- 20% increase to coin collection
            },
            ModelID = "GOLDEN_CHALICE_MODEL",
            UnlockZone = 35,
            AvailableRarities = {"Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
        },
        
        -- Advanced Relics (Unlocked in later zones)
        {
            ID = "CELESTIAL_ORB",
            Name = "Celestial Orb",
            Description = "An orb containing celestial energy, greatly enhancing all abilities.",
            Effect = {
                Type = "GlobalMultiplier",
                Value = 0.20 -- 20% increase to all stats
            },
            ModelID = "CELESTIAL_ORB_MODEL",
            UnlockZone = 50,
            AvailableRarities = {"Rare", "Epic", "Legendary", "Mythical"}
        },
        {
            ID = "TITANS_GAUNTLET",
            Name = "Titan's Gauntlet",
            Description = "A gauntlet worn by ancient titans, greatly enhancing damage.",
            Effect = {
                Type = "DamageMultiplier",
                Value = 0.35 -- 35% increase to damage
            },
            ModelID = "TITANS_GAUNTLET_MODEL",
            UnlockZone = 55,
            AvailableRarities = {"Rare", "Epic", "Legendary", "Mythical"}
        },
        {
            ID = "MERCURY_SANDALS",
            Name = "Mercury Sandals",
            Description = "Sandals infused with mercury, greatly enhancing speed.",
            Effect = {
                Type = "SpeedMultiplier",
                Value = 0.35 -- 35% increase to speed
            },
            ModelID = "MERCURY_SANDALS_MODEL",
            UnlockZone = 60,
            AvailableRarities = {"Rare", "Epic", "Legendary", "Mythical"}
        },
        {
            ID = "MIDAS_CROWN",
            Name = "Midas Crown",
            Description = "A crown worn by King Midas, greatly enhancing coin collection.",
            Effect = {
                Type = "CoinMultiplier",
                Value = 0.35 -- 35% increase to coin collection
            },
            ModelID = "MIDAS_CROWN_MODEL",
            UnlockZone = 65,
            AvailableRarities = {"Rare", "Epic", "Legendary", "Mythical"}
        },
        
        -- Elite Relics (Unlocked in end-game zones)
        {
            ID = "COSMIC_CUBE",
            Name = "Cosmic Cube",
            Description = "A cube containing the power of the cosmos, massively enhancing all abilities.",
            Effect = {
                Type = "GlobalMultiplier",
                Value = 0.35 -- 35% increase to all stats
            },
            ModelID = "COSMIC_CUBE_MODEL",
            UnlockZone = 80,
            AvailableRarities = {"Epic", "Legendary", "Mythical"}
        },
        {
            ID = "GODSLAYER_BLADE",
            Name = "Godslayer Blade",
            Description = "A blade capable of slaying gods, massively enhancing damage.",
            Effect = {
                Type = "DamageMultiplier",
                Value = 0.50 -- 50% increase to damage
            },
            ModelID = "GODSLAYER_BLADE_MODEL",
            UnlockZone = 85,
            AvailableRarities = {"Epic", "Legendary", "Mythical"}
        },
        {
            ID = "CHRONOS_HOURGLASS",
            Name = "Chronos Hourglass",
            Description = "An hourglass that controls time, massively enhancing speed.",
            Effect = {
                Type = "SpeedMultiplier",
                Value = 0.50 -- 50% increase to speed
            },
            ModelID = "CHRONOS_HOURGLASS_MODEL",
            UnlockZone = 90,
            AvailableRarities = {"Epic", "Legendary", "Mythical"}
        },
        {
            ID = "PHILOSOPHERS_STONE",
            Name = "Philosopher's Stone",
            Description = "The legendary stone that turns base metals into gold, massively enhancing coin collection.",
            Effect = {
                Type = "CoinMultiplier",
                Value = 0.50 -- 50% increase to coin collection
            },
            ModelID = "PHILOSOPHERS_STONE_MODEL",
            UnlockZone = 95,
            AvailableRarities = {"Epic", "Legendary", "Mythical"}
        },
        
        -- Mythical Relics (Extremely rare, end-game content)
        {
            ID = "UNIVERSE_CORE",
            Name = "Universe Core",
            Description = "The core of the universe, containing unlimited power.",
            Effect = {
                Type = "GlobalMultiplier",
                Value = 0.75 -- 75% increase to all stats
            },
            ModelID = "UNIVERSE_CORE_MODEL",
            UnlockZone = 100,
            AvailableRarities = {"Mythical"}
        }
    },
    
    -- Relic Leveling System
    LevelingSystem = {
        MaxLevel = 20,
        ExperiencePerLevel = function(level)
            return 300 * (level ^ 1.4)
        end,
        EffectIncrease = 0.05 -- 5% increase to effect value per level
    },
    
    -- Relic Combination System (Combining relics for enhanced effects)
    CombinationSystem = {
        -- Combinations of relics that provide special bonuses when equipped together
        Combinations = {
            {
                Name = "Warrior's Set",
                RequiredRelics = {"WARRIORS_EMBLEM", "DRAGON_FANG", "TITANS_GAUNTLET"},
                Bonus = {
                    Type = "DamageMultiplier",
                    Value = 0.25 -- Additional 25% damage when all three are equipped
                }
            },
            {
                Name = "Speed Demon Set",
                RequiredRelics = {"SWIFT_BOOTS", "WIND_CRYSTAL", "MERCURY_SANDALS"},
                Bonus = {
                    Type = "SpeedMultiplier",
                    Value = 0.25 -- Additional 25% speed when all three are equipped
                }
            },
            {
                Name = "Treasure Hunter Set",
                RequiredRelics = {"TREASURE_HUNTER", "GOLDEN_CHALICE", "MIDAS_CROWN"},
                Bonus = {
                    Type = "CoinMultiplier",
                    Value = 0.25 -- Additional 25% coins when all three are equipped
                }
            },
            {
                Name = "Cosmic Set",
                RequiredRelics = {"CELESTIAL_ORB", "COSMIC_CUBE", "UNIVERSE_CORE"},
                Bonus = {
                    Type = "GlobalMultiplier",
                    Value = 0.50 -- Additional 50% to all stats when all three are equipped
                }
            }
        },
        
        -- Maximum number of relics a player can equip at once
        MaxEquippedRelics = 5
    }
}

return RelicConfig

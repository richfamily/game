--[[
    AvatarConfig.lua
    Defines the configuration for avatars in the game
]]

local AvatarConfig = {
    -- Rebirth Rewards System
    RebirthRewards = {
        -- Cycle of rewards that repeats
        RewardCycle = {
            {
                Type = "AttackBoost",
                Value = 0.05, -- 5% attack boost
                Description = "5% Attack Boost"
            },
            {
                Type = "DrawLuckBoost",
                Value = 0.05, -- 5% draw luck boost
                Description = "5% Draw Luck Boost"
            },
            {
                Type = "NewAvatar",
                Description = "New Avatar"
                -- The actual avatar will be determined based on the rebirth level
            }
        },
        
        -- Special avatars unlocked through rebirth
        RebirthAvatars = {
            {
                ID = "REBIRTH_AVATAR_1",
                Name = "Rebirth Novice",
                Description = "An avatar unlocked after your first rebirth.",
                ModelID = "REBIRTH_AVATAR_1_MODEL",
                BaseDamage = 10,
                BaseSpeed = 18,
                BaseCoinsMultiplier = 1.2,
                UnlockRebirthLevel = 1,
                AvailableRarities = {"Uncommon"},
                SpecialAbilities = {
                    {
                        Name = "Rebirth Boost",
                        Description = "Increases all stats by 5% for each rebirth level",
                        Effect = "RebirthBoost",
                        Value = 0.05
                    }
                }
            },
            {
                ID = "REBIRTH_AVATAR_5",
                Name = "Rebirth Adept",
                Description = "An avatar unlocked after your fifth rebirth.",
                ModelID = "REBIRTH_AVATAR_5_MODEL",
                BaseDamage = 20,
                BaseSpeed = 20,
                BaseCoinsMultiplier = 1.5,
                UnlockRebirthLevel = 5,
                AvailableRarities = {"Rare"},
                SpecialAbilities = {
                    {
                        Name = "Rebirth Mastery",
                        Description = "Increases all stats by 8% for each rebirth level",
                        Effect = "RebirthBoost",
                        Value = 0.08
                    }
                }
            },
            {
                ID = "REBIRTH_AVATAR_10",
                Name = "Rebirth Master",
                Description = "An avatar unlocked after your tenth rebirth.",
                ModelID = "REBIRTH_AVATAR_10_MODEL",
                BaseDamage = 40,
                BaseSpeed = 25,
                BaseCoinsMultiplier = 2.0,
                UnlockRebirthLevel = 10,
                AvailableRarities = {"Epic"},
                SpecialAbilities = {
                    {
                        Name = "Rebirth Supremacy",
                        Description = "Increases all stats by 10% for each rebirth level",
                        Effect = "RebirthBoost",
                        Value = 0.1
                    }
                }
            },
            {
                ID = "REBIRTH_AVATAR_25",
                Name = "Rebirth Legend",
                Description = "An avatar unlocked after your 25th rebirth.",
                ModelID = "REBIRTH_AVATAR_25_MODEL",
                BaseDamage = 80,
                BaseSpeed = 30,
                BaseCoinsMultiplier = 3.0,
                UnlockRebirthLevel = 25,
                AvailableRarities = {"Legendary"},
                SpecialAbilities = {
                    {
                        Name = "Rebirth Dominance",
                        Description = "Increases all stats by 15% for each rebirth level",
                        Effect = "RebirthBoost",
                        Value = 0.15
                    }
                }
            },
            {
                ID = "REBIRTH_AVATAR_50",
                Name = "Rebirth God",
                Description = "An avatar unlocked after your 50th rebirth.",
                ModelID = "REBIRTH_AVATAR_50_MODEL",
                BaseDamage = 150,
                BaseSpeed = 40,
                BaseCoinsMultiplier = 5.0,
                UnlockRebirthLevel = 50,
                AvailableRarities = {"Mythical"},
                SpecialAbilities = {
                    {
                        Name = "Rebirth Divinity",
                        Description = "Increases all stats by 20% for each rebirth level",
                        Effect = "RebirthBoost",
                        Value = 0.2
                    }
                }
            }
        }
    },
    
    -- List of all available avatars
    Avatars = {
        {
            ID = "STARTER_AVATAR",
            Name = "Starter Avatar",
            Description = "Your first avatar. A reliable companion on your journey.",
            ModelID = "STARTER_AVATAR_MODEL", -- Reference to the model in ReplicatedStorage
            BaseDamage = 5,
            BaseSpeed = 16,
            BaseCoinsMultiplier = 1.0,
            DrawType = "None", -- This avatar is given to players at the start
            UnlockZone = 1,
            AvailableRarities = {"Common"},
            SpecialAbilities = {}
        }
        -- More avatars can be added here as the game expands
    },
    
    -- Avatar rarities and their stat multipliers
    Rarities = {
        {
            Name = "Common",
            Color = Color3.fromRGB(200, 200, 200), -- Light gray
            StatMultiplier = 1.0,
            Chance = 0.70
        },
        {
            Name = "Uncommon",
            Color = Color3.fromRGB(100, 255, 100), -- Light green
            StatMultiplier = 1.5,
            Chance = 0.20
        },
        {
            Name = "Rare",
            Color = Color3.fromRGB(100, 100, 255), -- Light blue
            StatMultiplier = 2.0,
            Chance = 0.07
        },
        {
            Name = "Epic",
            Color = Color3.fromRGB(200, 100, 255), -- Purple
            StatMultiplier = 3.0,
            Chance = 0.02
        },
        {
            Name = "Legendary",
            Color = Color3.fromRGB(255, 200, 100), -- Orange
            StatMultiplier = 5.0,
            Chance = 0.008
        },
        {
            Name = "Mythical",
            Color = Color3.fromRGB(255, 100, 100), -- Red
            StatMultiplier = 10.0,
            Chance = 0.002
        }
    },
    
    -- Avatar variants (e.g., Normal, Golden)
    Variants = {
        Normal = {
            Name = "Normal",
            ModelSuffix = "_MODEL",
            StatMultiplier = 1.0
        },
        Golden = {
            Name = "Golden",
            ModelSuffix = "_GOLDEN_MODEL",
            StatMultiplier = 2.0
        }
    },
    
    -- Leveling system for avatars
    LevelingSystem = {
        MaxLevel = 50,
        ExperiencePerLevel = function(level)
            -- Formula: 100 * level^1.5
            return math.floor(100 * math.pow(level, 1.5))
        end,
        StatIncrease = {
            Damage = 0.05, -- 5% increase per level
            Speed = 0.02, -- 2% increase per level
            CoinsMultiplier = 0.03 -- 3% increase per level
        }
    },
    
    -- Fusion system for avatars
    FusionSystem = {
        RequiredAvatarsForFusion = 3,
        SameTypeBonus = 0.5, -- 50% bonus if all avatars are the same type
        RarityUpgradeChance = {
            Common = 0.3, -- 30% chance to upgrade from Common to Uncommon
            Uncommon = 0.25, -- 25% chance to upgrade from Uncommon to Rare
            Rare = 0.2, -- 20% chance to upgrade from Rare to Epic
            Epic = 0.15, -- 15% chance to upgrade from Epic to Legendary
            Legendary = 0.1 -- 10% chance to upgrade from Legendary to Mythical
        }
    },
    
    -- Golden upgrade system for avatars
    GoldenUpgradeSystem = {
        UnlockZone = 10, -- Zone required to unlock golden upgrades
        CurrencyType = "Rubies", -- Currency used for golden upgrades
        CostMultiplier = 10 -- Multiplier for the cost of golden upgrades
    },
    
    -- Avatar equip limit (how many avatars a player can have active at once)
    EquipLimit = 1 -- Start with just 1 avatar equipped
}

return AvatarConfig

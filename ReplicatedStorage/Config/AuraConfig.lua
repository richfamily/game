--[[
    AuraConfig.lua
    Contains aura definitions, effects, and rarity information
    Auras are special effects that can be equipped on pets (one per pet)
    Auras are obtained using Diamonds
]]

local AuraConfig = {
    -- Rarity Definitions (similar to pets but with different chances)
    Rarities = {
        {
            Name = "Common",
            Color = Color3.fromRGB(255, 255, 255), -- White
            Chance = 0.45, -- 45% chance
            EffectMultiplier = 1.0
        },
        {
            Name = "Uncommon",
            Color = Color3.fromRGB(0, 255, 0), -- Green
            Chance = 0.25, -- 25% chance
            EffectMultiplier = 1.3
        },
        {
            Name = "Rare",
            Color = Color3.fromRGB(0, 112, 221), -- Blue
            Chance = 0.15, -- 15% chance
            EffectMultiplier = 1.7
        },
        {
            Name = "Epic",
            Color = Color3.fromRGB(163, 53, 238), -- Purple
            Chance = 0.08, -- 8% chance
            EffectMultiplier = 2.2
        },
        {
            Name = "Legendary",
            Color = Color3.fromRGB(255, 215, 0), -- Gold
            Chance = 0.05, -- 5% chance
            EffectMultiplier = 3.0
        },
        {
            Name = "Mythical",
            Color = Color3.fromRGB(255, 0, 0), -- Red
            Chance = 0.02, -- 2% chance
            EffectMultiplier = 5.0
        }
    },
    
    -- Aura Definitions
    Auras = {
        -- Damage-focused Auras
        {
            ID = "FLAME_AURA",
            Name = "Flame Aura",
            Description = "Surrounds the pet with flames, increasing damage.",
            Effect = {
                Type = "Damage",
                Value = 0.15 -- 15% increase to damage
            },
            VisualEffect = "FLAME_PARTICLE", -- Reference to particle effect
            UnlockZone = 1,
            AvailableRarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
        },
        {
            ID = "THUNDER_AURA",
            Name = "Thunder Aura",
            Description = "Electrifies the pet, significantly boosting damage.",
            Effect = {
                Type = "Damage",
                Value = 0.25 -- 25% increase to damage
            },
            VisualEffect = "THUNDER_PARTICLE",
            UnlockZone = 20,
            AvailableRarities = {"Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
        },
        {
            ID = "VOID_AURA",
            Name = "Void Aura",
            Description = "Infuses the pet with void energy, massively increasing damage.",
            Effect = {
                Type = "Damage",
                Value = 0.40 -- 40% increase to damage
            },
            VisualEffect = "VOID_PARTICLE",
            UnlockZone = 50,
            AvailableRarities = {"Epic", "Legendary", "Mythical"}
        },
        
        -- Speed-focused Auras
        {
            ID = "WIND_AURA",
            Name = "Wind Aura",
            Description = "Surrounds the pet with wind, increasing speed.",
            Effect = {
                Type = "Speed",
                Value = 0.20 -- 20% increase to speed
            },
            VisualEffect = "WIND_PARTICLE",
            UnlockZone = 1,
            AvailableRarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
        },
        {
            ID = "SWIFT_AURA",
            Name = "Swift Aura",
            Description = "Enhances the pet's agility, significantly boosting speed.",
            Effect = {
                Type = "Speed",
                Value = 0.30 -- 30% increase to speed
            },
            VisualEffect = "SWIFT_PARTICLE",
            UnlockZone = 25,
            AvailableRarities = {"Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
        },
        {
            ID = "CHRONO_AURA",
            Name = "Chrono Aura",
            Description = "Bends time around the pet, massively increasing speed.",
            Effect = {
                Type = "Speed",
                Value = 0.50 -- 50% increase to speed
            },
            VisualEffect = "CHRONO_PARTICLE",
            UnlockZone = 60,
            AvailableRarities = {"Epic", "Legendary", "Mythical"}
        },
        
        -- Coin-focused Auras
        {
            ID = "FORTUNE_AURA",
            Name = "Fortune Aura",
            Description = "Brings good fortune to the pet, increasing coin collection.",
            Effect = {
                Type = "Coins",
                Value = 0.25 -- 25% increase to coin collection
            },
            VisualEffect = "FORTUNE_PARTICLE",
            UnlockZone = 1,
            AvailableRarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
        },
        {
            ID = "WEALTH_AURA",
            Name = "Wealth Aura",
            Description = "Attracts wealth to the pet, significantly boosting coin collection.",
            Effect = {
                Type = "Coins",
                Value = 0.40 -- 40% increase to coin collection
            },
            VisualEffect = "WEALTH_PARTICLE",
            UnlockZone = 30,
            AvailableRarities = {"Uncommon", "Rare", "Epic", "Legendary", "Mythical"}
        },
        {
            ID = "MIDAS_AURA",
            Name = "Midas Aura",
            Description = "Turns everything the pet touches to gold, massively increasing coin collection.",
            Effect = {
                Type = "Coins",
                Value = 0.60 -- 60% increase to coin collection
            },
            VisualEffect = "MIDAS_PARTICLE",
            UnlockZone = 70,
            AvailableRarities = {"Epic", "Legendary", "Mythical"}
        },
        
        -- Multi-effect Auras (Unlocked in later zones)
        {
            ID = "ELEMENTAL_AURA",
            Name = "Elemental Aura",
            Description = "Infuses the pet with elemental power, boosting damage and speed.",
            Effect = {
                Type = "Multi",
                Values = {
                    Damage = 0.20, -- 20% increase to damage
                    Speed = 0.15 -- 15% increase to speed
                }
            },
            VisualEffect = "ELEMENTAL_PARTICLE",
            UnlockZone = 40,
            AvailableRarities = {"Rare", "Epic", "Legendary", "Mythical"}
        },
        {
            ID = "CELESTIAL_AURA",
            Name = "Celestial Aura",
            Description = "Blesses the pet with celestial energy, boosting damage and coin collection.",
            Effect = {
                Type = "Multi",
                Values = {
                    Damage = 0.25, -- 25% increase to damage
                    Coins = 0.30 -- 30% increase to coin collection
                }
            },
            VisualEffect = "CELESTIAL_PARTICLE",
            UnlockZone = 55,
            AvailableRarities = {"Epic", "Legendary", "Mythical"}
        },
        {
            ID = "COSMIC_AURA",
            Name = "Cosmic Aura",
            Description = "Infuses the pet with cosmic power, boosting all stats.",
            Effect = {
                Type = "Multi",
                Values = {
                    Damage = 0.30, -- 30% increase to damage
                    Speed = 0.25, -- 25% increase to speed
                    Coins = 0.35 -- 35% increase to coin collection
                }
            },
            VisualEffect = "COSMIC_PARTICLE",
            UnlockZone = 80,
            AvailableRarities = {"Legendary", "Mythical"}
        },
        
        -- Special Mythical-only Auras (Endgame content)
        {
            ID = "DIVINE_AURA",
            Name = "Divine Aura",
            Description = "The ultimate aura, massively boosting all stats.",
            Effect = {
                Type = "Multi",
                Values = {
                    Damage = 0.50, -- 50% increase to damage
                    Speed = 0.40, -- 40% increase to speed
                    Coins = 0.60 -- 60% increase to coin collection
                }
            },
            VisualEffect = "DIVINE_PARTICLE",
            UnlockZone = 90,
            AvailableRarities = {"Mythical"}
        }
    },
    
    -- Aura Leveling System
    LevelingSystem = {
        MaxLevel = 25,
        ExperiencePerLevel = function(level)
            return 200 * (level ^ 1.3)
        end,
        EffectIncrease = 0.04 -- 4% increase to effect value per level
    },
    
    -- Aura Fusion System (Combining auras)
    FusionSystem = {
        SameTypeBonus = 0.15, -- 15% bonus when fusing same type
        RarityUpgradeChance = {
            Common = 0.45, -- 45% chance to upgrade from Common to Uncommon
            Uncommon = 0.35, -- 35% chance to upgrade from Uncommon to Rare
            Rare = 0.25, -- 25% chance to upgrade from Rare to Epic
            Epic = 0.15, -- 15% chance to upgrade from Epic to Legendary
            Legendary = 0.08, -- 8% chance to upgrade from Legendary to Mythical
            Mythical = 0 -- Cannot upgrade from Mythical
        },
        RequiredAurasForFusion = 3
    }
}

return AuraConfig

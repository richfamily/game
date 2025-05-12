--[[
    GameConfig.lua
    Contains general game settings and configuration
]]

local GameConfig = {
    -- Game Version
    Version = "1.0.0",
    
    -- Currency Settings
    CurrencyTypes = {
        "Coins",
        "Diamonds",
        "Rubies"
    },
    
    -- Starting Values for New Players
    StartingValues = {
        Coins = 100,
        Diamonds = 10,
        Rubies = 0,
        Avatars = {}, -- Will be populated with starter avatar in AvatarManager
        Auras = {},
        UnlockedZones = {1}, -- Start with only the first zone unlocked
        RebirthLevel = 0,
        Multipliers = {
            Coins = 1,
            Damage = 1,
            Speed = 1
        }
    },
    
    -- World Settings
    WorldSettings = {
        WorldCount = 1, -- Start with 1 world, expandable
        ZonesPerWorld = 100,
        RebirthStatueInterval = 2, -- Every other zone has a rebirth statue
    },
    
    -- Game Mechanics
    Mechanics = {
        AvatarEquipLimit = 1, -- Maximum number of avatars a player can equip at once
        AuraEquipLimit = 1, -- Maximum number of auras per avatar
        AutoCollectRadius = 10, -- Radius for auto-collecting items
        MaxPlayerSpeed = 50, -- Maximum player movement speed
    },
    
    -- Draw Settings
    DrawSettings = {
        Coins = {
            BasicDraw = 50,
            PremiumDraw = 450,
            UltimateDraw = 1000,
        },
        Diamonds = {
            BasicDraw = 10,
            PremiumDraw = 90,
            UltimateDraw = 200,
        },
        Rubies = {
            BasicDraw = 5,
            PremiumDraw = 45,
            UltimateDraw = 100,
        }
    },
    
    -- Game Difficulty Scaling
    DifficultyScaling = {
        ZoneHealthMultiplier = 1.5, -- Health multiplier per zone
        ZoneCoinMultiplier = 1.3, -- Coin reward multiplier per zone
        BossHealthMultiplier = 5, -- Boss health compared to regular enemies
        BossRewardMultiplier = 10, -- Boss reward compared to regular enemies
    }
}

return GameConfig

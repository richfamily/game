--[[
    ZoneConfig.lua
    Contains zone definitions, enemy types, and progression requirements
    Each world has 100 zones, with a rebirth statue every other zone
    Bosses appear every 5 zones
]]

local ZoneConfig = {
    -- World Definitions
    Worlds = {
        {
            ID = "WORLD_1",
            Name = "Mystic Meadows",
            Description = "A peaceful meadow with mystical creatures.",
            UnlockRequirement = nil, -- First world is unlocked by default
            BackgroundColor = Color3.fromRGB(120, 200, 80), -- Light green
            BackgroundID = "WORLD_1_BACKGROUND", -- Reference to the background image/model
            MusicID = "WORLD_1_MUSIC" -- Reference to the background music
        }
        -- Additional worlds can be added here in the future
    },
    
    -- Zone Definitions for World 1
    Zones = {
        -- Zone 1-10: Meadow Theme
        {
            ID = "ZONE_1_1",
            Name = "Grassy Plains",
            Description = "A peaceful plain with gentle creatures.",
            WorldID = "WORLD_1",
            ZoneNumber = 1,
            UnlockCost = 0, -- First zone is free
            BackgroundID = "ZONE_1_1_BACKGROUND",
            HasRebirthStatue = false, -- Rebirth statues are on even-numbered zones
            EnemyTypes = {"GRASS_SLIME", "MEADOW_BUNNY"},
            CoinMultiplier = 1.0,
            BaseEnemyHealth = 10,
            BossType = "GIANT_GRASS_SLIME",
            BossHealth = 50,
            BossReward = 100
        },
        {
            ID = "ZONE_1_2",
            Name = "Flower Fields",
            Description = "A colorful field filled with magical flowers.",
            WorldID = "WORLD_1",
            ZoneNumber = 2,
            UnlockCost = 100,
            BackgroundID = "ZONE_1_2_BACKGROUND",
            HasRebirthStatue = true, -- Even-numbered zone has rebirth statue
            EnemyTypes = {"FLOWER_SPRITE", "POLLEN_PUFF"},
            CoinMultiplier = 1.3,
            BaseEnemyHealth = 15,
            BossType = "FLOWER_QUEEN",
            BossHealth = 75,
            BossReward = 150
        },
        {
            ID = "ZONE_1_3",
            Name = "Mushroom Grove",
            Description = "A mysterious grove filled with giant mushrooms.",
            WorldID = "WORLD_1",
            ZoneNumber = 3,
            UnlockCost = 250,
            BackgroundID = "ZONE_1_3_BACKGROUND",
            HasRebirthStatue = false,
            EnemyTypes = {"MUSHROOM_CAP", "SPORE_SPRITE"},
            CoinMultiplier = 1.6,
            BaseEnemyHealth = 22,
            BossType = "MUSHROOM_ELDER",
            BossHealth = 110,
            BossReward = 225
        },
        {
            ID = "ZONE_1_4",
            Name = "Dewdrop Dell",
            Description = "A misty dell where magical dewdrops form.",
            WorldID = "WORLD_1",
            ZoneNumber = 4,
            UnlockCost = 500,
            BackgroundID = "ZONE_1_4_BACKGROUND",
            HasRebirthStatue = true,
            EnemyTypes = {"DEW_SPRITE", "MIST_WISP"},
            CoinMultiplier = 2.0,
            BaseEnemyHealth = 33,
            BossType = "MIST_ELEMENTAL",
            BossHealth = 165,
            BossReward = 340
        },
        {
            ID = "ZONE_1_5",
            Name = "Butterfly Haven",
            Description = "A sanctuary for magical butterflies.",
            WorldID = "WORLD_1",
            ZoneNumber = 5,
            UnlockCost = 1000,
            BackgroundID = "ZONE_1_5_BACKGROUND",
            HasRebirthStatue = false,
            EnemyTypes = {"FLUTTER_WING", "NECTAR_SPRITE"},
            CoinMultiplier = 2.5,
            BaseEnemyHealth = 50,
            BossType = "MONARCH_GUARDIAN",
            BossHealth = 250,
            BossReward = 500
        },
        {
            ID = "ZONE_1_6",
            Name = "Sunbeam Glade",
            Description = "A glade where sunbeams touch the earth with magic.",
            WorldID = "WORLD_1",
            ZoneNumber = 6,
            UnlockCost = 2000,
            BackgroundID = "ZONE_1_6_BACKGROUND",
            HasRebirthStatue = true,
            EnemyTypes = {"LIGHT_SPRITE", "SUN_MOTE"},
            CoinMultiplier = 3.0,
            BaseEnemyHealth = 75,
            BossType = "SOLAR_GUARDIAN",
            BossHealth = 375,
            BossReward = 750
        },
        {
            ID = "ZONE_1_7",
            Name = "Whispering Willows",
            Description = "Ancient willows that whisper secrets of the meadow.",
            WorldID = "WORLD_1",
            ZoneNumber = 7,
            UnlockCost = 4000,
            BackgroundID = "ZONE_1_7_BACKGROUND",
            HasRebirthStatue = false,
            EnemyTypes = {"WILLOW_WISP", "BARK_SPRITE"},
            CoinMultiplier = 3.6,
            BaseEnemyHealth = 112,
            BossType = "ANCIENT_WILLOW",
            BossHealth = 560,
            BossReward = 1120
        },
        {
            ID = "ZONE_1_8",
            Name = "Clover Crossing",
            Description = "A lucky crossing filled with four-leaf clovers.",
            WorldID = "WORLD_1",
            ZoneNumber = 8,
            UnlockCost = 8000,
            BackgroundID = "ZONE_1_8_BACKGROUND",
            HasRebirthStatue = true,
            EnemyTypes = {"LUCKY_SPRITE", "CLOVER_GUARDIAN"},
            CoinMultiplier = 4.3,
            BaseEnemyHealth = 168,
            BossType = "FORTUNE_KEEPER",
            BossHealth = 840,
            BossReward = 1680
        },
        {
            ID = "ZONE_1_9",
            Name = "Honeybee Hollow",
            Description = "A hollow filled with magical honeybees.",
            WorldID = "WORLD_1",
            ZoneNumber = 9,
            UnlockCost = 16000,
            BackgroundID = "ZONE_1_9_BACKGROUND",
            HasRebirthStatue = false,
            EnemyTypes = {"HONEY_SPRITE", "WORKER_BEE"},
            CoinMultiplier = 5.2,
            BaseEnemyHealth = 252,
            BossType = "QUEEN_BEE",
            BossHealth = 1260,
            BossReward = 2520
        },
        {
            ID = "ZONE_1_10",
            Name = "Rainbow's End",
            Description = "The legendary end of the rainbow, filled with treasures.",
            WorldID = "WORLD_1",
            ZoneNumber = 10,
            UnlockCost = 32000,
            BackgroundID = "ZONE_1_10_BACKGROUND",
            HasRebirthStatue = true,
            EnemyTypes = {"RAINBOW_SPRITE", "PRISM_GUARDIAN"},
            CoinMultiplier = 6.2,
            BaseEnemyHealth = 378,
            BossType = "SPECTRUM_KEEPER",
            BossHealth = 1890,
            BossReward = 3780
        },
        
        -- Zone 11-20: Forest Theme
        {
            ID = "ZONE_1_11",
            Name = "Ancient Woods",
            Description = "The entrance to an ancient, magical forest.",
            WorldID = "WORLD_1",
            ZoneNumber = 11,
            UnlockCost = 64000,
            BackgroundID = "ZONE_1_11_BACKGROUND",
            HasRebirthStatue = false,
            EnemyTypes = {"FOREST_SPRITE", "WOODLAND_GUARDIAN"},
            CoinMultiplier = 7.4,
            BaseEnemyHealth = 567,
            BossType = "ELDER_TREANT",
            BossHealth = 2835,
            BossReward = 5670
        },
        {
            ID = "ZONE_1_12",
            Name = "Mossy Hollow",
            Description = "A hollow covered in ancient, magical moss.",
            WorldID = "WORLD_1",
            ZoneNumber = 12,
            UnlockCost = 128000,
            BackgroundID = "ZONE_1_12_BACKGROUND",
            HasRebirthStatue = true,
            EnemyTypes = {"MOSS_SPRITE", "LICHEN_GUARDIAN"},
            CoinMultiplier = 8.9,
            BaseEnemyHealth = 850,
            BossType = "MOSS_COLOSSUS",
            BossHealth = 4250,
            BossReward = 8500
        },
        
        -- Continue with zones 13-100 following the same pattern
        -- For brevity, we'll skip to the final zone
        
        {
            ID = "ZONE_1_100",
            Name = "Divine Gateway",
            Description = "The final zone of Mystic Meadows, gateway to new worlds.",
            WorldID = "WORLD_1",
            ZoneNumber = 100,
            UnlockCost = 1000000000, -- 1 billion
            BackgroundID = "ZONE_1_100_BACKGROUND",
            HasRebirthStatue = true,
            EnemyTypes = {"DIVINE_GUARDIAN", "CELESTIAL_BEING"},
            CoinMultiplier = 1000.0,
            BaseEnemyHealth = 10000000,
            BossType = "WORLD_KEEPER",
            BossHealth = 50000000,
            BossReward = 100000000,
            HasPortal = true, -- This zone has a portal to the next world
            PortalDestination = "WORLD_2" -- Portal leads to World 2
        }
    },
    
    -- Zone Unlock Requirements
    UnlockRequirements = {
        -- Function to calculate the cost to unlock a zone based on zone number
        CalculateUnlockCost = function(zoneNumber)
            if zoneNumber == 1 then
                return 0 -- First zone is free
            else
                return math.floor(100 * (2 ^ (zoneNumber - 2)))
            end
        end
    },
    
    -- Rebirth System
    RebirthSystem = {
        -- Function to calculate rebirth rewards based on zone and current rebirth level
        CalculateRebirthReward = function(zoneNumber, currentRebirthLevel)
            local baseReward = zoneNumber * 0.01 -- 1% per zone
            local levelMultiplier = 1 + (currentRebirthLevel * 0.1) -- 10% increase per rebirth level
            return baseReward * levelMultiplier
        end,
        
        -- Function to calculate the cost of rebirthing
        CalculateRebirthCost = function(currentRebirthLevel)
            return 1000 * (currentRebirthLevel + 1) ^ 2
        end,
        
        -- Maximum rebirth level
        MaxRebirthLevel = 100
    },
    
    -- Enemy Types for World 1
    EnemyTypes = {
        -- Meadow Enemies (Zone 1-10)
        {
            ID = "GRASS_SLIME",
            Name = "Grass Slime",
            Description = "A slime infused with grass energy.",
            ModelID = "GRASS_SLIME_MODEL",
            BaseHealth = 10,
            BaseDamage = 2,
            BaseCoins = 5,
            ZoneRange = {1, 10}
        },
        {
            ID = "MEADOW_BUNNY",
            Name = "Meadow Bunny",
            Description = "A magical bunny that hops around the meadow.",
            ModelID = "MEADOW_BUNNY_MODEL",
            BaseHealth = 8,
            BaseDamage = 1,
            BaseCoins = 6,
            ZoneRange = {1, 10}
        },
        -- Add more enemy types for each zone range
        
        -- Forest Enemies (Zone 11-20)
        {
            ID = "FOREST_SPRITE",
            Name = "Forest Sprite",
            Description = "A mischievous sprite that lives in the forest.",
            ModelID = "FOREST_SPRITE_MODEL",
            BaseHealth = 50,
            BaseDamage = 10,
            BaseCoins = 30,
            ZoneRange = {11, 20}
        },
        -- Add more enemy types for each zone range
        
        -- Divine Enemies (Zone 91-100)
        {
            ID = "DIVINE_GUARDIAN",
            Name = "Divine Guardian",
            Description = "A powerful guardian of divine energy.",
            ModelID = "DIVINE_GUARDIAN_MODEL",
            BaseHealth = 5000000,
            BaseDamage = 100000,
            BaseCoins = 5000000,
            ZoneRange = {91, 100}
        },
        {
            ID = "CELESTIAL_BEING",
            Name = "Celestial Being",
            Description = "A being made of pure celestial energy.",
            ModelID = "CELESTIAL_BEING_MODEL",
            BaseHealth = 7500000,
            BaseDamage = 150000,
            BaseCoins = 7500000,
            ZoneRange = {91, 100}
        }
    },
    
    -- Boss Types for World 1
    BossTypes = {
        -- Meadow Bosses (Zone 1-10)
        {
            ID = "GIANT_GRASS_SLIME",
            Name = "Giant Grass Slime",
            Description = "A massive slime that rules over the grassy plains.",
            ModelID = "GIANT_GRASS_SLIME_MODEL",
            BaseHealth = 50,
            BaseDamage = 10,
            BaseCoins = 100,
            ZoneNumber = 1
        },
        -- Add more boss types for each zone
        
        -- Final Boss of World 1
        {
            ID = "WORLD_KEEPER",
            Name = "World Keeper",
            Description = "The ultimate guardian of Mystic Meadows.",
            ModelID = "WORLD_KEEPER_MODEL",
            BaseHealth = 50000000,
            BaseDamage = 1000000,
            BaseCoins = 100000000,
            ZoneNumber = 100
        }
    }
}

-- Generate the remaining zones programmatically
local function generateRemainingZones()
    local themes = {
        {start = 1, finish = 10, name = "Meadow", enemies = {"GRASS_SPRITE", "FLOWER_SPRITE"}},
        {start = 11, finish = 20, name = "Forest", enemies = {"FOREST_SPRITE", "WOODLAND_GUARDIAN"}},
        {start = 21, finish = 30, name = "Mountain", enemies = {"ROCK_GOLEM", "MOUNTAIN_EAGLE"}},
        {start = 31, finish = 40, name = "Ocean", enemies = {"WATER_ELEMENTAL", "CORAL_GUARDIAN"}},
        {start = 41, finish = 50, name = "Volcano", enemies = {"FIRE_ELEMENTAL", "LAVA_SPRITE"}},
        {start = 51, finish = 60, name = "Crystal", enemies = {"CRYSTAL_GOLEM", "GEM_SPRITE"}},
        {start = 61, finish = 70, name = "Tech", enemies = {"ROBOT_SENTINEL", "TECH_DRONE"}},
        {start = 71, finish = 80, name = "Spirit", enemies = {"GHOST_WISP", "PHANTOM_GUARDIAN"}},
        {start = 81, finish = 90, name = "Cosmic", enemies = {"STAR_BEING", "NEBULA_ENTITY"}},
        {start = 91, finish = 100, name = "Divine", enemies = {"DIVINE_GUARDIAN", "CELESTIAL_BEING"}}
    }
    
    -- We've already defined zones 1-12 and 100 above, so we'll generate 13-99
    for i = 13, 99 do
        local theme
        for _, t in ipairs(themes) do
            if i >= t.start and i <= t.finish then
                theme = t
                break
            end
        end
        
        local hasRebirthStatue = (i % 2 == 0) -- Even-numbered zones have rebirth statues
        local hasBoss = (i % 5 == 0) -- Bosses appear every 5 zones
        local zoneNumber = i
        local unlockCost = ZoneConfig.UnlockRequirements.CalculateUnlockCost(zoneNumber)
        local baseEnemyHealth = 10 * (1.5 ^ (zoneNumber - 1))
        local coinMultiplier = 1.0 * (1.2 ^ (math.floor((zoneNumber - 1) / 5)))
        
        local zone = {
            ID = "ZONE_1_" .. zoneNumber,
            Name = theme.name .. " Zone " .. (zoneNumber - theme.start + 1),
            Description = "Zone " .. zoneNumber .. " of " .. theme.name .. " theme.",
            WorldID = "WORLD_1",
            ZoneNumber = zoneNumber,
            UnlockCost = unlockCost,
            BackgroundID = "ZONE_1_" .. zoneNumber .. "_BACKGROUND",
            HasRebirthStatue = hasRebirthStatue,
            EnemyTypes = theme.enemies,
            CoinMultiplier = coinMultiplier,
            BaseEnemyHealth = baseEnemyHealth
        }
        
        -- Only add boss to zones that are multiples of 5
        if hasBoss then
            zone.BossType = "BOSS_" .. theme.name:upper() .. "_" .. (zoneNumber - theme.start + 1)
            zone.BossHealth = baseEnemyHealth * 5
            zone.BossReward = baseEnemyHealth * 10
        end
        
        table.insert(ZoneConfig.Zones, zone)
    end
    
    return ZoneConfig
end

-- Call the function to generate the remaining zones
return generateRemainingZones()

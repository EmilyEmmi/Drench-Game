--[[

NOTE: Here's a way to automatically add everything from this API, so you don't need
to use "drenchGameAPI.[whatever]":

for name,value in pairs(drenchGameAPI) do
    _ENV[name] = value
end

Note that this will override any functions/variables with the same name.

]]

_G.drenchGameAPI = {}
drenchGameAPI.drenchVersion = 1.2
drenchGameAPI.MISC_GAME_MAPS = MISC_GAME_MAPS

-- Adds a new game mode! Games are all defined in z_gameData.lua- I will not be offering more tutorials.
---@param data table Table defining information about the game mode
---@return integer id ID for the newly added game mode
drenchGameAPI.drench_add_game_mode = function(data)
    table.insert(GAME_MODE_DATA, data)
    GAME_MODE_MAX = GAME_MODE_MAX + 1
    return GAME_MODE_MAX - 1
end

-- Adds a new map for the "miscellaneous" game modes (Star Steal, Bomb Tag, and Dice Block Battle)
-- NOTE: These maps should all contain exactly one object with the "bhvStealStar" behavior for Star Steal.
---@param level LevelNum The level's ID (Usually a LEVEL_ constant)
---@param spawnPos Vec3f The starting position for players.
---@param spawnAngle Vec3s The starting angle for players.
---@param spawnDist integer? The distance between each player (defaults to 200 units)
---@param spawnLine boolean? If true, the players spawn in a line (like in Red Light Green Light)
drenchGameAPI.drench_add_misc_game_map = function(level, spawnPos, spawnAngle, spawnDist, spawnLine)
    table.insert(MISC_GAME_MAPS, level)

    LEVEL_SPAWN_DATA[level] = {
        spawnPos = spawnPos,
        spawnAngle = spawnAngle,
        spawnDist = spawnDist,
        spawnLine = spawnLine,
    }
end

-- Adds a new map for all game modes provided.
-- Adding maps exclusive to Star Steal, Bomb Tag, or Dice Block Battle is not currently supported.
---@param level LevelNum The level's ID (Usually a LEVEL_ constant)
---@param modes table Table of modes that the map supports. Use the GAME_MODE_ constants in the API.
---@param spawnPos Vec3f The starting position for players.
---@param spawnAngle Vec3s The starting angle for players.
---@param spawnDist integer? The distance between each player (defaults to 200 units)
---@param spawnLine boolean? If true, the players spawn in a line (like in Red Light Green Light)
drenchGameAPI.drench_add_map = function(level, modes, spawnPos, spawnAngle, spawnDist, spawnLine)
    if #modes == 0 then return end

    local addMisc = false
    for i, mode in ipairs(modes) do
        local gData = GAME_MODE_DATA[mode]
        if gData and gData.level then
            if type(gData.level) ~= "table" then
                gData.level = {gData.level}
            elseif gData.level == MISC_GAME_MAPS then
                addMisc = true
            end
            table.insert(gData.level, level)
        end
    end

    if addMisc then
        table.insert(MISC_GAME_MAPS, level)
    end

    LEVEL_SPAWN_DATA[level] = {
        spawnPos = spawnPos,
        spawnAngle = spawnAngle,
        spawnDist = spawnDist,
        spawnLine = spawnLine,
    }
end

-- Get the total amount of minigames available
---@return integer total The total amount of minigames
drenchGameAPI.drench_get_total_game_modes = function()
    return GAME_MODE_MAX
end

-- Get the ID of the currently loaded game mode
---@return integer total The current game mode
drenchGameAPI.drench_get_current_game_mode = function()
    return gGlobalSyncTable.gameMode
end

-- Get the current game state
---@return integer state The current game state
drenchGameAPI.drench_get_game_state = function()
    return gGlobalSyncTable.gameState
end

-- Get the data table for the currently loaded game mode
---@return table data The data table for the current game mode
drenchGameAPI.drench_get_current_game_mode_data = function()
    return GAME_MODE_DATA[gGlobalSyncTable.gameMode]
end

-- Get the data table for the the specified game mode
---@param gameMode integer The game mode
---@return table data The data table for the specified game mode
drenchGameAPI.drench_get_game_mode_data = function(gameMode)
    return GAME_MODE_DATA[gameMode]
end

-- Get the level spawn info table for the the specified level
---@param level LevelNum The level
---@return table data The spawn info data table for the specified level
drenchGameAPI.drench_get_level_spawn_data = function(level)
    return LEVEL_SPAWN_DATA[level]
end

-- To access sync fields from this mod, use these
drenchGameAPI.gDrenchGlobalSyncTable = gGlobalSyncTable
drenchGameAPI.gDrenchPlayerSyncTable = gPlayerSyncTable

drenchGameAPI.GAME_MODE_GLASS = GAME_MODE_GLASS
drenchGameAPI.GAME_MODE_RED_GREEN_LIGHT = GAME_MODE_RED_GREEN_LIGHT
drenchGameAPI.GAME_MODE_STAR_STEAL = GAME_MODE_STAR_STEAL
drenchGameAPI.GAME_MODE_KOTH = GAME_MODE_KOTH
drenchGameAPI.GAME_MODE_BOMB_TAG = GAME_MODE_BOMB_TAG
drenchGameAPI.GAME_MODE_MINGLE = GAME_MODE_MINGLE
drenchGameAPI.GAME_MODE_LIGHTS_OUT = GAME_MODE_LIGHTS_OUT
drenchGameAPI.GAME_MODE_DICE = GAME_MODE_DICE
drenchGameAPI.GAME_MODE_DUEL = GAME_MODE_DUEL

drenchGameAPI.GAME_STATE_LOBBY = GAME_STATE_LOBBY
drenchGameAPI.GAME_STATE_RULES = GAME_STATE_RULES
drenchGameAPI.GAME_STATE_ACTIVE = GAME_STATE_ACTIVE
drenchGameAPI.GAME_STATE_MINI_END = GAME_STATE_MINI_END
drenchGameAPI.GAME_STATE_SCORES = GAME_STATE_SCORES
drenchGameAPI.GAME_STATE_GAME_END = GAME_STATE_GAME_END

drenchGameAPI.ACT_SPECTATE = ACT_SPECTATE
drenchGameAPI.ACT_GB_FALL = ACT_GB_FALL
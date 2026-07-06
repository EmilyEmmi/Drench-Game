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

-- Updates the spawn data for a level. Highly recommended.
-- Note that all add map functions do this automatically.
---@param level LevelNum The level's ID (Usually a LEVEL_ constant)
---@param spawnPos Vec3f The starting position for players.
---@param spawnAngle integer? The starting angle (yaw) for players.
---@param spawnDist integer? The distance between each player (defaults to 200 units)
---@param spawnLine boolean? If true, the players spawn in a line (like in Red Light Green Light)
drenchGameAPI.drench_update_spawn_data = function(level, spawnPos, spawnAngle, spawnDist, spawnLine)
    LEVEL_SPAWN_DATA[level] = {
        spawnPos = spawnPos,
        spawnAngle = spawnAngle,
        spawnDist = spawnDist,
        spawnLine = spawnLine,
    }
end

-- Adds a setup function to a specific level, called by the host in the HOOK_ON_SYNC_VALID hook.
-- It has no arguments and no return values.
---@param level LevelNum The level the setup function is for.
---@param setupFunc function The function to run.
drenchGameAPI.drench_add_sync_setup = function(level, setupFunc)
    LEVEL_SYNC_SETUP[level] = setupFunc
end

-- Adds a new map for the "miscellaneous" game modes (Star Steal, Bomb Tag, and Dice Block Battle)
-- NOTE: These maps should all contain exactly one object with the "bhvStealStar" behavior for Star Steal.
---@param level LevelNum The level's ID (Usually a LEVEL_ constant)
---@param spawnPos Vec3f The starting position for players.
---@param spawnAngle integer? The starting angle (yaw) for players.
---@param spawnDist integer? The distance between each player (defaults to 200 units)
---@param spawnLine boolean? If true, the players spawn in a line (like in Red Light Green Light)
drenchGameAPI.drench_add_misc_game_map = function(level, spawnPos, spawnAngle, spawnDist, spawnLine)
    table.insert(MISC_GAME_MAPS, level)

    drenchGameAPI.drench_update_spawn_data(level, spawnPos, spawnAngle, spawnDist, spawnLine)
end

-- Adds a new map for all game modes provided.
-- Adding maps exclusive to Star Steal, Bomb Tag, or Dice Block Battle (on their own) is not currently supported.
---@param level LevelNum The level's ID (Usually a LEVEL_ constant)
---@param modes table Table of modes that the map supports. Use the GAME_MODE_ constants in the API.
---@param spawnPos Vec3f The starting position for players.
---@param spawnAngle integer? The starting angle (yaw) for players.
---@param spawnDist integer? The distance between each player (defaults to 200 units)
---@param spawnLine boolean? If true, the players spawn in a line (like in Red Light Green Light)
drenchGameAPI.drench_add_map = function(level, modes, spawnPos, spawnAngle, spawnDist, spawnLine)
    if modes == nil or #modes == 0 then return end

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

    drenchGameAPI.drench_update_spawn_data(level, spawnPos, spawnAngle, spawnDist, spawnLine)
end

-- Functions for adding/changing music and sfx (see audio.lua)
drenchGameAPI.drench_update_music_track = update_music_track
drenchGameAPI.drench_update_sfx = update_sfx

-- Misc audio functions
drenchGameAPI.drench_play_stream_sfx = play_stream_sfx
drenchGameAPI.drench_stop_stream_sfx = stop_stream_sfx
drenchGameAPI.drench_stream_music_fade = stream_music_fade
drenchGameAPI.drench_get_target_volume = get_target_volume
drenchGameAPI.drench_set_music_frequency = set_music_frequency

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

-- Get the amount of teams selected
---@return integer teams The amount of teams selected
drenchGameAPI.drench_get_team_count = function()
    return gGlobalSyncTable.teamCount or 0
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

-- Returns if Debug Mode is active (when Cheats is enabled)
---@return boolean debug True if debug mode is active
drenchGameAPI.drench_is_debug_mode = function()
    return DEBUG_MODE
end

-- Returns if Solo Debug Mode is active (when Cheats is enabled and only one player is in the room)
---@return boolean debug True if solo debug mode is active
drenchGameAPI.drench_is_solo_debug = do_solo_debug

-- Some utility functions
drenchGameAPI.spawn_object_no_rotate = spawn_object_no_rotate
drenchGameAPI.set_to_spawn_pos = set_to_spawn_pos
drenchGameAPI.calculate_players_to_eliminate = calculate_players_to_eliminate
drenchGameAPI.attempt_raise_score = attempt_raise_score
drenchGameAPI.get_safe_score = get_safe_score
drenchGameAPI.get_winners_table = get_winners_table
drenchGameAPI.get_angle_between_points = get_angle_between_points
drenchGameAPI.add_line_to_table = add_line_to_table
drenchGameAPI.spawn_orange_number_at_pos = spawn_orange_number_at_pos
drenchGameAPI.sonic_lose_one_ring = sonic_lose_one_ring

-- To access sync fields from this mod, use these
drenchGameAPI.gDrenchGlobalSyncTable = gGlobalSyncTable
drenchGameAPI.gDrenchPlayerSyncTable = gPlayerSyncTable

-- Game mode constants
drenchGameAPI.GAME_MODE_GLASS = GAME_MODE_GLASS
drenchGameAPI.GAME_MODE_RED_GREEN_LIGHT = GAME_MODE_RED_GREEN_LIGHT
drenchGameAPI.GAME_MODE_STAR_STEAL = GAME_MODE_STAR_STEAL
drenchGameAPI.GAME_MODE_KOTH = GAME_MODE_KOTH
drenchGameAPI.GAME_MODE_BOMB_TAG = GAME_MODE_BOMB_TAG
drenchGameAPI.GAME_MODE_MINGLE = GAME_MODE_MINGLE
drenchGameAPI.GAME_MODE_LIGHTS_OUT = GAME_MODE_LIGHTS_OUT
drenchGameAPI.GAME_MODE_DICE = GAME_MODE_DICE
drenchGameAPI.GAME_MODE_DUEL = GAME_MODE_DUEL

-- Game state constants
drenchGameAPI.GAME_STATE_LOBBY = GAME_STATE_LOBBY
drenchGameAPI.GAME_STATE_RULES = GAME_STATE_RULES
drenchGameAPI.GAME_STATE_ACTIVE = GAME_STATE_ACTIVE
drenchGameAPI.GAME_STATE_MINI_END = GAME_STATE_MINI_END
drenchGameAPI.GAME_STATE_SCORES = GAME_STATE_SCORES
drenchGameAPI.GAME_STATE_GAME_END = GAME_STATE_GAME_END

-- Action contants
drenchGameAPI.ACT_SPECTATE = ACT_SPECTATE
drenchGameAPI.ACT_GB_FALL = ACT_GB_FALL

-- Level IDs
drenchGameAPI.LEVEL_LOBBY = LEVEL_LOBBY
drenchGameAPI.LEVEL_GLASS = LEVEL_GLASS
drenchGameAPI.LEVEL_RGLIGHT = LEVEL_RGLIGHT
drenchGameAPI.LEVEL_LIGHTS_OUT = LEVEL_LIGHTS_OUT
drenchGameAPI.LEVEL_MINGLE = LEVEL_MINGLE
drenchGameAPI.LEVEL_KOTH = LEVEL_KOTH
drenchGameAPI.LEVEL_DUEL = LEVEL_DUEL
drenchGameAPI.LEVEL_TOAD_TOWN = LEVEL_TOAD_TOWN
drenchGameAPI.LEVEL_KOOPA_KEEP = LEVEL_KOOPA_KEEP

-- Object IDs
drenchGameAPI.id_bhvButton = id_bhvButton
drenchGameAPI.id_bhvScreen = id_bhvScreen
drenchGameAPI.id_bhvMingleCarousel = id_bhvMingleCarousel
drenchGameAPI.id_bhvLockSwitch = id_bhvLockSwitch
drenchGameAPI.id_bhvMingleDoor = id_bhvMingleDoor
drenchGameAPI.id_bhvGlass = id_bhvGlass
drenchGameAPI.id_bhvGBThwomp = id_bhvGBThwomp
drenchGameAPI.id_bhvFakeExplosion = id_bhvFakeExplosion
drenchGameAPI.id_bhvRGDoll = id_bhvRGDoll
drenchGameAPI.id_bhvDollLaser = id_bhvDollLaser
drenchGameAPI.id_bhvStealStar = id_bhvStealStar
drenchGameAPI.id_bhvBTBomb = id_bhvBTBomb
drenchGameAPI.id_bhvKothArea = id_bhvKothArea
drenchGameAPI.id_bhvEffectCoin = id_bhvEffectCoin
drenchGameAPI.id_bhvFallingBomb = id_bhvFallingBomb
drenchGameAPI.id_bhvArenaSpring = id_bhvArenaSpring
drenchGameAPI.id_bhvArenaSpringChild = id_bhvArenaSpringChild
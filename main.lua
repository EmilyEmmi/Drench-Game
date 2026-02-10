-- name: \\#00ffd5\\Drench Game v1.2 (beta 2.10.2026)
-- description: Squid Game in Mario 64!\n\nCommissioned by Drenchy\nInspired by Dani's \"Crab Game\"\n\nProgramming: EmilyEmmi\n\nMaps: biobak, EmilyEmmi, Woissil\n\nSoundtrack: murioz, Awesome Seal Guy (YT)\n\nVoice Acting:\nEspi as Toad\nSqueex as Mingle Callout\nTrashcam as Waluigi\n\nAds: Squeex's Community\n\nSpecial Thanks: Squishy
-- category: gamemode
-- incompatible: gamemode
-- pausable: false

gServerSettings.bubbleDeath = 0
gLevelValues.fixCollisionBugs = 1 -- fixes invis walls on map

GAME_STATE_LOBBY = 0
GAME_STATE_RULES = 1
GAME_STATE_ACTIVE = 2
GAME_STATE_MINI_END = 3
GAME_STATE_SCORES = 4
GAME_STATE_GAME_END = 5

GAME_MODE_GLASS = 0
GAME_MODE_RED_GREEN_LIGHT = 1
GAME_MODE_STAR_STEAL = 2
GAME_MODE_KOTH = 3
GAME_MODE_BOMB_TAG = 4
GAME_MODE_MINGLE = 5
GAME_MODE_LIGHTS_OUT = 6
GAME_MODE_DICE = 7
GAME_MODE_DUEL = 8 -- needs to be at the end due to its special nature
GAME_MODE_MAX = 9

TEAM_SELECTION_RANDOM = 0
TEAM_SELECTION_HOST = 1
TEAM_SELECTION_PLAYER = 2

LEVEL_LOBBY = level_register('level_SGlobby_entry', COURSE_NONE, 'Lobby', 'lobby', 28000, 0x50, 0x50, 0x50)
LEVEL_GLASS = level_register('level_bridge_entry', COURSE_NONE, 'Glass Bridge', 'bridge', 28000, 0x28, 0x28, 0x28)
LEVEL_RGLIGHT = level_register('level_rglight_entry', COURSE_NONE, 'Red/Green Light', 'rglight', 28000, 0x28, 0x28, 0x28)
LEVEL_LIGHTS_OUT = level_register('level_SGlobbydark_entry', COURSE_NONE, 'Lobby?', 'lobbydark', 28000, 0x50, 0x50, 0x50)
LEVEL_MINGLE = level_register('level_mingle_entry', COURSE_NONE, 'Mingle', 'mingle', 28000, 0x28, 0x28, 0x28)
LEVEL_KOTH = level_register('level_koth_entry', COURSE_NONE, 'K.O.T.H.', 'koth', 28000, 0x28, 0x28, 0x28)
LEVEL_DUEL = level_register('level_arena_entry', COURSE_NONE, 'Duel', 'duel', 28000, 0x28, 0x28, 0x28) -- TODO: needs glowup?
LEVEL_TOAD_TOWN = level_register('level_toad_town_entry', COURSE_NONE, 'Toad Town', 'toadtown', 28000, 0x28, 0x28, 0x28)
LEVEL_KOOPA_KEEP = level_register('level_bowser_castle_entry', COURSE_NONE, 'Koopa Keep', 'koopakeep', 28000, 0x28, 0x28, 0x28)
gLevelValues.entryLevel = LEVEL_LOBBY

-- team data (copied from Kart Battles)
-- in order: light color, dark color, full name (+ color code), short name
TEAM_DATA = {
    { { r = 225, g = 5, b = 49 },       { r = 80, g = 20, b = 20 },       "\\#ff4040\\Red Team",    "Red" }, -- red (modified ruby)
    { { r = 0x00, g = 0x2f, b = 0xc8 }, { r = 20, g = 40, b = 80 },       "\\#4040ff\\Blue Team",   "Blu" }, -- blue (modified cobalt)
    { { r = 0x20, g = 0xc8, b = 0x20 }, { r = 20, g = 80, b = 20 },       "\\#40ff40\\Green Team",  "Grn" }, -- green (modified clover)
    { { r = 0xe7, g = 0xe7, b = 0x21 }, { r = 80, g = 80, b = 20 },       "\\#ffff40\\Yellow Team", "Ylw" }, -- yellow (modified busy bee)
    { { r = 0xff, g = 0x8a, b = 0x00 }, { r = 80, g = 50, b = 20 },       "\\#ffa014\\Orange Team", "Org" }, -- orange (modified... orange)
    { { r = 0x5a, g = 0x94, b = 0xff }, { r = 20, g = 50, b = 80 },       "\\#40ffff\\Cyan Team",   "Cyn" }, -- cyan (modified azure)
    { { r = 0xff, g = 0x8e, b = 0xb2 }, { r = 0x82, g = 0x10, b = 0x27 }, "\\#ffa1eb\\Pink Team",   "Pnk" }, -- pink (modified bubblegum)
    { { r = 0x71, g = 0x36, b = 0xc8 }, { r = 0x26, g = 0x26, b = 0x47 }, "\\#a040ff\\Violet Team", "Vlt" }, -- violet (modified waluigi)
}

SELECT_MODE_CHOOSE = 0
SELECT_MODE_ORDER = 1
SELECT_MODE_RANDOM = 2
SELECT_MODE_ALL = 3

DUEL_STATE_WAIT = 0
DUEL_STATE_ACTIVE = 1
DUEL_STATE_END = 2

gGlobalSyncTable.gameState = GAME_STATE_LOBBY
gGlobalSyncTable.gameMode = 0
gGlobalSyncTable.gameTimer = 0
gGlobalSyncTable.gameLevel = -1
gGlobalSyncTable.miniGameNum = 0
gGlobalSyncTable.round = 1
gGlobalSyncTable.roundTimer = 0
gGlobalSyncTable.freezeRoundTimer = false
gGlobalSyncTable.eliminateThisRound = 0

gGlobalSyncTable.maxMiniGames = 5
gGlobalSyncTable.finalDuel = true
gGlobalSyncTable.eliminationMode = false
gGlobalSyncTable.gameModeSelection = SELECT_MODE_RANDOM
gGlobalSyncTable.selectedMode = -1
gGlobalSyncTable.percentToStart = 75
gGlobalSyncTable.forceStart = false
gGlobalSyncTable.allDuel = false
gGlobalSyncTable.gameLevelOverride = -1
gGlobalSyncTable.teamCount = 0
gGlobalSyncTable.teamSelection = TEAM_SELECTION_RANDOM
gGlobalSyncTable.includeAllDuel = false
gGlobalSyncTable.endWith1v1 = false

gGlobalSyncTable.starStealOwner = 255
gGlobalSyncTable.minglePlayerCount = 1
gGlobalSyncTable.mingleSpinTime = 0
gGlobalSyncTable.mingleHurry = false
gGlobalSyncTable.mingleMaxDoors = 0
gGlobalSyncTable.mingleDoorsOpen = 0
gGlobalSyncTable.duelState = DUEL_STATE_WAIT

desyncTimer = 0
playerLocalTimer = 0
lightsOutTimeUntilBlackout = 0
lightsOutBlackoutTimer = 0
lightsOutDamageDealt = 0
mingleWasOnCarousel = false
duelEnding = false
duelLastState = 0
duelBombSpawnTimer = 0
duelTimeUntilBomb = 0
duelLastAttacker = -1
rejoin_data = {}
rejoin_check = {}
csVersion = (charSelectExists and charSelect.version_get_full().major) or 0
disableMusic = 0

-- default values for all players
for i=0,MAX_PLAYERS-1 do
    local sMario = gPlayerSyncTable[i]
    sMario.points = 0
    sMario.earnedPoints = 0
    sMario.spectator = false
    sMario.eliminated = false
    sMario.roundEliminated = 0
    sMario.roundScore = 0
    sMario.holdingBomb = false
    sMario.victory = false
    sMario.validForDuel = false
    sMario.rejoinID = "-1"
end

local firstLoaded = false
function load_on_sync()
    local sMario = gPlayerSyncTable[0]
    sMario.ready = false
    duelLastAttacker = -1

    if firstLoaded then return end
    math.randomseed(get_time())
    firstLoaded = true
    sMario.points = 0
    sMario.earnedPoints = 0
    sMario.spectator = false
    sMario.eliminated = (gGlobalSyncTable.gameState ~= GAME_STATE_LOBBY)
    sMario.roundEliminated = 0
    sMario.roundScore = 0
    sMario.holdingBomb = false
    sMario.victory = false
    sMario.validForDuel = gGlobalSyncTable.allDuel
    sMario.rejoinID = get_coopnet_id(0)
    sMario.team = calculate_lowest_member_team()
    if sMario.rejoinID == "-1" then
        sMario.rejoinID = gNetworkPlayers[0].name
    end

    if waitRejoinData then
        on_packet_rejoin(waitRejoinData, true)
        waitRejoinData = nil
    end
end

hook_event(HOOK_ON_SYNC_VALID, load_on_sync)

function starting_setup()
    if gGlobalSyncTable.gameState == GAME_STATE_LOBBY then
        set_to_spawn_pos(gMarioStates[0], true)
        return
    end

    local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode or 0]
    if gData.startingSetup then
        gData.startingSetup()
    end

    set_to_spawn_pos(gMarioStates[0], true)
end

hook_event(HOOK_ON_LEVEL_INIT, starting_setup)

-- setup on sync, for Glass Bridge
function sync_setup()
    set_to_spawn_pos(gMarioStates[0], true)
    if gGlobalSyncTable.gameState == GAME_STATE_LOBBY or (not network_is_server()) then return end

    local np = gNetworkPlayers[0]
    if np.currLevelNum == LEVEL_GLASS then
        local toEliminate = calculate_players_to_eliminate((not gGlobalSyncTable.eliminationMode), true)

        -- assign each pane its break status
        local glass = obj_get_first_with_behavior_id_and_field_s32(id_bhvGlass, 0x2F, 0)
        -- the amount of panes can't exceed half we intend to eliminate plus 2, to ensure elimination games don't end really easily
        local totalPanes = clamp(math.ceil(toEliminate / 2) + 2, 3, 10)
        local row = 0
        while glass do
            if row >= totalPanes then
                glass.oBobombFuseTimer = 2
                local otherGlass = obj_get_next_with_same_behavior_id_and_field_s32(glass, 0x2F, row)
                if otherGlass then
                    otherGlass.oBobombFuseTimer = 2
                end
                network_send_object(glass, true)
                if otherGlass then network_send_object(otherGlass, true) end
            else
                local otherGlass = obj_get_next_with_same_behavior_id_and_field_s32(glass, 0x2F, row)
                local glassBreak = math.random(0, 1)
                if glassBreak == 0 then
                    glass.oBobombFuseTimer = 0
                    if otherGlass then
                        otherGlass.oBobombFuseTimer = 1
                    end
                else
                    glass.oBobombFuseTimer = 1
                    if otherGlass then
                        otherGlass.oBobombFuseTimer = 0
                    end
                end
                if DEBUG_MODE then log_to_console(tostring(row) .. ": " .. tostring(glassBreak)) end
                network_send_object(glass, true)
                if otherGlass then network_send_object(otherGlass, true) end
            end

            row = row + 1
            glass = obj_get_first_with_behavior_id_and_field_s32(id_bhvGlass, 0x2F, row)
        end
    end
end

hook_event(HOOK_ON_SYNC_VALID, sync_setup)

localWasEliminated = false
local finalWaterHeight = 0
---@param m MarioState
function before_mario_update(m)
    menu_controls(m)
    local sMario = gPlayerSyncTable[m.playerIndex]
    if (not sMario.spectator) and (gGlobalSyncTable.gameState == GAME_STATE_LOBBY or gGlobalSyncTable.gameState == GAME_STATE_GAME_END) then
        return
    end

    -- update water in Toad Town
    if gNetworkPlayers[0].currLevelNum == LEVEL_TOAD_TOWN then
        if m.floor and m.floor.type == SURFACE_WATER then
            finalWaterHeight = m.floorHeight + 20
            set_water_level(0, m.floorHeight + 20, false)
        else
            if m.playerIndex == 0 then
                finalWaterHeight = gLevelValues.floorLowerLimitMisc
            end
            set_water_level(0, gLevelValues.floorLowerLimitMisc, false)
        end
    end

    -- Put mario in spectate action
    if (sMario.eliminated or sMario.spectator or (sMario.victory and gGlobalSyncTable.gameMode ~= GAME_MODE_DUEL))
    and m.action ~= ACT_SPECTATE and m.action ~= ACT_END_SEQUENCE then
        set_mario_action(m, ACT_SPECTATE, 0)
        if m.playerIndex == 0 and m.area.camera then
            m.area.camera.cutscene = 0
            m.statusForCamera.action = m.action
            m.statusForCamera.cameraEvent = 0
            set_camera_mode(m.area.camera, m.area.camera.defMode, 1)

            if sMario.eliminated and not (sMario.spectator or localWasEliminated) then
                spawn_object_no_rotate(id_bhvFakeExplosion, E_MODEL_EXPLOSION, m.pos.x, m.pos.y, m.pos.z, nil, true)
            end
        end
    end
    if m.playerIndex == 0 then
        localWasEliminated = sMario.eliminated
    end
end

hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)

local storedSafeScore = 0
local marioPoleTime = {}
local marioBounceTimer = {}
local marioDesyncTimer = {}
local afkTimer = 0
local afkSpectator = false
---@param m MarioState
function mario_update(m)
    -- run standings at start of mario update
    if m.playerIndex == 0 then
        local standings = get_standings_table("roundScore")
        storedSafeScore = get_safe_score(standings)
    end

    -- update water in Toad Town
    if m.playerIndex == MAX_PLAYERS-1 and gNetworkPlayers[0].currLevelNum == LEVEL_TOAD_TOWN then
        set_water_level(0, finalWaterHeight, false)
    end

    -- push mario out of ceilings
    if m.ceil and m.ceil.object == nil and m.pos.y + m.marioObj.hitboxHeight >= m.ceilHeight then
        local ceilAngle = atan2s(m.ceil.normal.z, m.ceil.normal.x);
        m.pos.x = m.pos.x + 10 * sins(ceilAngle)
        m.pos.z = m.pos.z + 10 * coss(ceilAngle)
    end

    local np = gNetworkPlayers[m.playerIndex]
    local sMario = gPlayerSyncTable[m.playerIndex]
    -- rejoin check
    if network_is_server() and np.connected and m.playerIndex ~= 0 and rejoin_check[m.playerIndex] and sMario.rejoinID and sMario.rejoinID ~= "-1" then
        rejoin_check[m.playerIndex] = nil
        local rejoinID = sMario.rejoinID
        if DEBUG_MODE then log_to_console(tostring(rejoinID)) end
        for i, data in ipairs(rejoin_data) do
            if data.rejoinID == rejoinID then
                if DEBUG_MODE then log_to_console("Attempting rejoin") end
                network_send_to(m.playerIndex, true, data)
                table.remove(rejoin_data, i)
                break
            end
        end
    end

    -- afk check
    if m.playerIndex == 0 then
        if (not inMenu) and m.controller.buttonDown == 0 and m.controller.stickX == 0 and m.controller.stickY == 0 and m.controller.extStickX == 0 and m.controller.extStickY == 0 then
            if (not sMario.spectator) and gGlobalSyncTable.gameState == GAME_STATE_ACTIVE and m.action ~= ACT_SPECTATE then
                afkTimer = afkTimer + 1
                if afkTimer == 50 * 30 then
                    djui_chat_message_create("\\#ff5050\\You will be forced to spectate if you don't move in 10 seconds!")
                elseif afkTimer >= 60 * 30 then
                    afkSpectator = true
                    toggle_spectator()
                    djui_chat_message_create("\\#ff5050\\You were made a spectator. Move again to cancel.")
                end
            end
        else
            afkTimer = 0
            if sMario.spectator and afkSpectator then
                afkSpectator = false
                toggle_spectator()
            end
        end
    end
    
    -- team palette
    if sMario.team and sMario.team ~= 0 and gGlobalSyncTable.teamMode ~= 0 then
        local data = TEAM_DATA[sMario.team or 0]
        if data then
            set_override_team_colors(np, data[1], data[2])
        end
    else
        network_player_reset_override_palette_custom(np)
    end

    -- large amounts of desync checks
    if np.connected and m.playerIndex ~= 0 and gGlobalSyncTable.gameState ~= GAME_STATE_LOBBY then
        if network_is_server() and ((sMario.team ~= 0) ~= (gGlobalSyncTable.teamCount ~= 0)) then
            if gGlobalSyncTable.teamCount == 0 then
                sMario.team = 0
            else
                sMario.team = calculate_lowest_member_team(0)
            end
        end
        local desyncTimer = marioDesyncTimer[m.playerIndex] or 0
        local np0 = gNetworkPlayers[0]
        if network_is_server() and (np.currLevelNum ~= np0.currLevelNum or np.currAreaIndex ~= np0.currAreaIndex or np.currActNum ~= np0.currActNum) then
            desyncTimer = desyncTimer + 1
        elseif (m.action == ACT_SPECTATE) ~= (sMario.eliminated or sMario.spectator or (sMario.victory and gGlobalSyncTable.gameMode ~= GAME_MODE_DUEL)) then
            desyncTimer = desyncTimer + 1
        else
            desyncTimer = 0
        end
        if desyncTimer >= 90 then
            desyncTimer = 0
            if network_is_server() then
                on_packet_request_desync_fix({}, true)
            else
                network_send_to(1, true, {
                    id = PACKET_REQUEST_DESYNC_FIX,
                    from = network_global_index_from_local(0),
                })
            end
        end
        marioDesyncTimer[m.playerIndex] = desyncTimer
    end

    -- bouncy beds
    if marioBounceTimer[m.playerIndex] == nil then
        marioBounceTimer[m.playerIndex] = 0
    elseif marioBounceTimer[m.playerIndex] ~= 0 then
        marioBounceTimer[m.playerIndex] = marioBounceTimer[m.playerIndex] - 1
    end
    if m.floor and m.floor.type == SURFACE_0004 and m.action ~= ACT_SPECTATE then
        if m.pos.y + m.vel.y <= m.floorHeight then
            -- ignore fall damage
            m.peakHeight = m.pos.y
        end

        if m.action & (ACT_FLAG_AIR | ACT_FLAG_ON_POLE) == 0 and m.health > 0xFF and marioBounceTimer[m.playerIndex] == 0 then
            if m.action == ACT_GROUND_POUND_LAND then
                set_mario_action(m, ACT_TRIPLE_JUMP, 0)
                m.vel.y = 80
            else
                set_mario_action(m, ACT_DOUBLE_JUMP, 0)
                m.vel.y = 69
                m.flags = m.flags | MARIO_MARIO_SOUND_PLAYED -- this is annoying
            end
            play_sound(SOUND_ACTION_BOUNCE_OFF_OBJECT, m.marioObj.header.gfx.cameraToObject)
            marioPoleTime[m.playerIndex] = 0
            marioBounceTimer[m.playerIndex] = 5
        end
    end

    -- slippery poles
    if marioPoleTime[m.playerIndex] == nil then
        marioPoleTime[m.playerIndex] = 0
    end
    if m.action & ACT_FLAG_ON_POLE ~= 0 then
        marioPoleTime[m.playerIndex] = marioPoleTime[m.playerIndex] + 1
        local downVel = 0
        if marioPoleTime[m.playerIndex] > 150 then
            downVel = math.min((marioPoleTime[m.playerIndex] - 150) // 8, 30)
        end
        
        if downVel > 0 then
            m.marioObj.oMarioPolePos = m.marioObj.oMarioPolePos - downVel
            if m.action == ACT_TOP_OF_POLE then
                set_mario_action(m, ACT_TOP_OF_POLE_TRANSITION, 1)
            end
            set_mario_particle_flags(m, PARTICLE_DUST, 0)
            if m.action ~= ACT_CLIMBING_POLE then
                play_climbing_sounds(m, 2);
                reset_rumble_timers(m);
                set_sound_moving_speed(SOUND_BANK_MOVING, downVel * 2)
            end
        end
    elseif m.action & (ACT_FLAG_AIR | ACT_FLAG_ON_POLE) == 0 then
        marioPoleTime[m.playerIndex] = 0
    end

    local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode or 0]
    if gServerSettings.headlessServer ~= 0 and network_is_server() and m.playerIndex == 0 then
        -- headless is eliminated by default
        sMario.eliminated = true
        sMario.spectator = true
        localWasEliminated = true
    end
    if gGlobalSyncTable.gameState == GAME_STATE_ACTIVE and np.connected and not (sMario.eliminated or sMario.victory) then
        if gData.marioUpdateFunc then
            gData.marioUpdateFunc(m)
        end
        if not gData.fallDamage then
            m.peakHeight = m.pos.y -- disable fall damage
        end
        if m.playerIndex == 0 and sMario.spectator and not sMario.eliminated then
            eliminate_mario(m)
        end
    else
        m.peakHeight = m.pos.y -- disable fall damage
        m.health = 0x880
    end

    -- set description
    local highlight = false
    local yellow = false
    local desc = ""
    if sMario.spectator then
        network_player_set_description(np, "Spectator", 100, 100, 100, 255)
    elseif gGlobalSyncTable.gameState == GAME_STATE_LOBBY then
        if sMario.ready then
            highlight = true
            desc = "Ready!"
        else
            desc = "Waiting..."
        end
    elseif gGlobalSyncTable.gameState == GAME_STATE_GAME_END then
        if gGlobalSyncTable.eliminationMode then
            if sMario.eliminated then
                desc = "Dead"
            else
                highlight = true
                desc = "Alive"
            end
        elseif gGlobalSyncTable.teamCount == 0 then
            network_player_set_description(np, tostring(sMario.points or 0), 255, 255, 255, 255)
        else
            local points = sMario.points
            for_each_connected_player(function(i)
                local sMario2 = gPlayerSyncTable[i]
                if (i ~= m.playerIndex) and sMario2.team == sMario.team and sMario2.team ~= 0 then
                    points = points + sMario2.points
                end
            end)
            network_player_set_description(np, tostring(points) .. " (" .. tostring(sMario.points or 0) .. ")", 255, 255, 255, 255)
        end
    else
        local newDesc, newHighlight, newYellow = nil, false, false
        if gData.descFunc then
            newDesc, newHighlight, newYellow = gData.descFunc(m.playerIndex)
            newHighlight = newHighlight or false
            newYellow = newYellow or false
        end
        
        if newDesc then
            desc = newDesc
            highlight = newHighlight
            yellow = newYellow
        elseif sMario.eliminated then
            desc = "Dead"
        elseif (gGlobalSyncTable.gameState ~= GAME_STATE_LOBBY) and gData.autoElimination then
            -- faded red or green based on our placement
            highlight = (sMario.roundScore and sMario.roundScore >= storedSafeScore)
            desc = string.format("%.01f", (sMario.roundScore or 0)/10)
        elseif sMario.victory then
            highlight = true
            desc = "Finished"
        else
            highlight = true
            yellow = (gData.victoryFunc ~= nil)
            desc = "Alive"
        end
    end
    if desc ~= "" then
        local color = {}
        local alpha = 255
        if sMario.team == nil or sMario.team <= 0 or sMario.team > #TEAM_DATA then
            if yellow then
                color = {r = 255, g = 255, b = 80}
            elseif highlight then
                color = {r = 80, g = 255, b = 80}
            elseif desc == "Dead" then
                color = {r = 255, g = 40, b = 40}
            else
                color = {r = 255, g = 80, b = 80}
            end
        else
            color = TEAM_DATA[sMario.team][1]
            if not (highlight or yellow) then
                alpha = 100
            end
        end
        network_player_set_description(np, desc, color.r, color.g, color.b, alpha)
    end

    if m.playerIndex ~= 0 then
        if gGlobalSyncTable.gameState == GAME_STATE_RULES and m.action ~= ACT_SPECTATE then
            set_to_spawn_pos(m)
        end
        return
    end

    local warpLevel = -1
    if gGlobalSyncTable.gameState == GAME_STATE_LOBBY then
        desyncTimer = 0
        warpLevel = LEVEL_LOBBY
        gNametagsSettings.showHealth = false
        gServerSettings.playerInteractions = PLAYER_INTERACTIONS_NONE
        sMario.points = 0
        sMario.roundScore = 0
        sMario.earnedPoints = 0
        sMario.eliminated = false
        sMario.roundEliminated = 0
        sMario.holdingBomb = false
        if sMario.spectator then
            sMario.team = 0
        end
    elseif gGlobalSyncTable.gameState == GAME_STATE_GAME_END then
        warpLevel = LEVEL_LOBBY
        gNametagsSettings.showHealth = false

        if m.action ~= ACT_END_SEQUENCE then
            m.pos.x, m.pos.y, m.pos.z = 0, -1747, -1200
            m.faceAngle.y = 0
            set_mario_action(m, ACT_END_SEQUENCE, 0)
            m.actionState = 0
            -- win animation
            local winners = get_winners_table()
            if #winners > 0 then
                for i, index in ipairs(winners) do
                    if m.playerIndex == index then
                        m.actionState = 1
                        if #winners > 1 then
                            m.pos.x = 200 * (-0.5 * (#winners + 1) + i)
                        end
                        break
                    end
                end
            else
                m.actionState = 2
            end
        end
    else
        warpLevel = gData.level or -1
        if type(warpLevel) == "table" then
            warpLevel = gGlobalSyncTable.gameLevel or -1
        end

        if gGlobalSyncTable.gameState == GAME_STATE_RULES then
            if gGlobalSyncTable.gameMode == GAME_MODE_DUEL then
                sMario.eliminated = (not sMario.validForDuel)
            elseif not gGlobalSyncTable.eliminationMode then
                sMario.eliminated = sMario.spectator or false
            end
            sMario.earnedPoints = 0
            sMario.roundScore = 0
            sMario.victory = false
            sMario.roundEliminated = 0

            if m.action ~= ACT_SPECTATE then
                set_to_spawn_pos(m)
            end
            if gGlobalSyncTable.gameTimer > 450 and not network_is_server() then
                desyncTimer = desyncTimer + 1
                if desyncTimer >= 30 then
                    desyncTimer = 0
                    network_send_to(1, true, {
                        id = PACKET_REQUEST_DESYNC_FIX,
                        from = network_global_index_from_local(0),
                    })
                end
            else
                desyncTimer = 0
            end

            gServerSettings.playerInteractions = PLAYER_INTERACTIONS_NONE
        elseif gGlobalSyncTable.gameState == GAME_STATE_ACTIVE then
            gServerSettings.playerInteractions = gData.interact or PLAYER_INTERACTIONS_NONE
            gServerSettings.playerKnockbackStrength = gData.kbStrength or 20
            if gData.kbStrengthOverrideFunc then
                gServerSettings.playerKnockbackStrength = gData.kbStrengthOverrideFunc() or gServerSettings.playerKnockbackStrength
            end

            gNametagsSettings.showHealth = gData.showHealth or (gData.showHealthSpec and m.action == ACT_SPECTATE) or false
            if not (sMario.victory or sMario.eliminated) and gData.victoryFunc and gData.victoryFunc(m) then
                sMario.victory = true
            end

            -- mercy rule for KOTH and Star Steal
            if gData.mercyRuleScale and not (sMario.eliminated or sMario.spectator) then
                local roundTime = gData.roundTime or 0
                if gData.firstRoundTime and gGlobalSyncTable.round == 1 then
                    roundTime = gData.firstRoundTime
                end

                -- amount of points we can possibly have in the remaining time
                local maxPossibleScore = gData.mercyRuleScale * math.ceil((roundTime - gGlobalSyncTable.roundTimer) / 30)
                maxPossibleScore = sMario.roundScore + maxPossibleScore
                if roundTime ~= 0 and maxPossibleScore < storedSafeScore then
                    local alivePlayers = 0
                    for_each_connected_player(function(index)
                        local sMario2 = gPlayerSyncTable[index]
                        if not (sMario2.eliminated) then
                            alivePlayers = alivePlayers + 1
                        end
                        if alivePlayers > 2 then return true end
                    end)

                    if alivePlayers == 2 then -- exactly two left (if we allowed one, both would be eliminated since the safe score would briefly be 999)
                        eliminate_mario(m)
                        djui_chat_message_create("\\#ff5050\\Eliminated by mercy rule-\nyou can't earn enough points to win.")
                    end
                end
            end
        elseif gGlobalSyncTable.gameState == GAME_STATE_SCORES then
            desyncTimer = 0
        end
    end

    local warpAct = 0
    if gGlobalSyncTable.gameState ~= GAME_STATE_LOBBY then
        warpAct = gGlobalSyncTable.miniGameNum
    end

    if warpLevel ~= -1 and (np.currLevelNum ~= warpLevel or np.currActNum ~= warpAct) and ((np.currAreaSyncValid and np.currLevelSyncValid) or m.area.localAreaTimer > 30) then
        m.health = 0x880
        warp_to_level(warpLevel, 1, warpAct)
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)

-- update function; handles game timers, lighting, and some parts of certain minigames.
function update()
    -- CS support
    if charSelectExists then
        charSelect.restrict_palettes(gGlobalSyncTable.teamMode == 0)
    end

    local np0 = gNetworkPlayers[0]
    if np0.currLevelNum == LEVEL_LIGHTS_OUT then
        -- lighting during Lights Out
        set_lighting_dir(0, 90)
        local r, g, b = 100, 50, 50
        local vr, vg, vb = 255, 255, 255
        if lightsOutBlackoutTimer ~= 0 then
            local t = 0
            if lightsOutBlackoutTimer == 90 then
                play_sound(SOUND_GENERAL2_PURPLE_SWITCH, gGlobalSoundSource)
            elseif lightsOutBlackoutTimer > 80 then
                t = (90 - lightsOutBlackoutTimer) / 10
            elseif lightsOutBlackoutTimer >= 10 then
                t = 1
            else
                t = lightsOutBlackoutTimer / 10
                if lightsOutBlackoutTimer == 9 then
                    play_sound(SOUND_GENERAL2_PURPLE_SWITCH, gGlobalSoundSource)
                end
            end
            r = r * (1 - t)
            g = g * (1 - t)
            b = b * (1 - t)
            vr = vr * (1 - t)
            vg = vg * (1 - t)
            vb = vb * (1 - t)
            lightsOutBlackoutTimer = lightsOutBlackoutTimer - 1
        end
        set_lighting_color(0, r)
        set_lighting_color(1, g)
        set_lighting_color(2, b)
        set_vertex_color(0, vr)
        set_vertex_color(1, vg)
        set_vertex_color(2, vb)
    elseif gGlobalSyncTable.gameMode == GAME_MODE_MINGLE and gGlobalSyncTable.gameState == GAME_STATE_ACTIVE and gGlobalSyncTable.mingleHurry then
        -- dim lighting during Mingle
        set_lighting_dir(0, 0)
        set_lighting_color(0, 100)
        set_lighting_color(1, 100)
        set_lighting_color(2, 100)
        set_vertex_color(0, 100)
        set_vertex_color(1, 100)
        set_vertex_color(2, 100)
        lightsOutBlackoutTimer = 0
    else
        set_lighting_dir(0, 0)
        set_lighting_color(0, 255)
        set_lighting_color(1, 255)
        set_lighting_color(2, 255)
        set_vertex_color(0, 255)
        set_vertex_color(1, 255)
        set_vertex_color(2, 255)
        lightsOutBlackoutTimer = 0
    end

    -- music
    local currentMusic = ""
    if gGlobalSyncTable.gameState == GAME_STATE_LOBBY then
        stream_music_fade(1)
        currentMusic = "lobby"
    elseif gGlobalSyncTable.gameState == GAME_STATE_ACTIVE or (gGlobalSyncTable.gameMode == GAME_MODE_DUEL and gGlobalSyncTable.gameState == GAME_STATE_MINI_END) then
        local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode or 0]
        currentMusic = gData.music or "slider"

        -- dynamic track (slider madness and slider casino):
        -- section 1: default
        -- section 2: half are alive
        -- section 3: 2 players left (takes priority over 2)
        if currentMusic == "slider" or currentMusic == "sliderCasino" then
            local alivePlayers = 0
            local validPlayers = 0
            for_each_connected_player(function(index)
                validPlayers = validPlayers + 1
                local sMario = gPlayerSyncTable[index]
                if not (sMario.eliminated) then
                    alivePlayers = alivePlayers + 1
                end
            end)

            local percentAlive = ((validPlayers ~= 0) and (alivePlayers / validPlayers)) or 0
            if percentAlive == 1 then
                -- do nothing; play section 1
            elseif alivePlayers <= 2 then
                -- this is first in case we're playing with a low amount of players.
                -- section 2 is skipped in that case.
                currentMusic = currentMusic .. "3"
            elseif percentAlive <= 0.5 then
                currentMusic = currentMusic .. "2"
            end
        end
        
        if gGlobalSyncTable.gameMode == GAME_MODE_RED_GREEN_LIGHT and get_target_volume() ~= 0 then
            -- environment sounds for Red Light, Green Light
            play_sound(SOUND_GENERAL2_BIRD_CHIRP2, gGlobalSoundSource)
        elseif gGlobalSyncTable.gameMode == GAME_MODE_DUEL and (duelEnding or gGlobalSyncTable.gameState ~= GAME_STATE_ACTIVE) then
            currentMusic = "finalOutro"
        end
    elseif gGlobalSyncTable.gameState == GAME_STATE_RULES then
        currentMusic = "scores"
        if gGlobalSyncTable.gameMode == GAME_MODE_DUEL then
            currentMusic = ""
            if gGlobalSyncTable.gameTimer < 300 then
                play_sound(SOUND_AIR_HOWLING_WIND, gGlobalSoundSource)
            end
        elseif gGlobalSyncTable.gameTimer >= 300 then
            stream_music_fade(0)
        end
    elseif (gGlobalSyncTable.gameState == GAME_STATE_SCORES) or (gGlobalSyncTable.gameState == GAME_STATE_GAME_END) or (gGlobalSyncTable.gameState == GAME_STATE_MINI_END) then
        disable_time_stop()
        stream_music_fade(1)
        local frequency = 0.75
        for_each_connected_player(function(index)
            local sMario = gPlayerSyncTable[index]
            if gGlobalSyncTable.eliminationMode then
                -- check alive players; if none are alive, use 0.75 frequency
                if (not sMario.eliminated) then
                    frequency = 1
                    return true
                end
            elseif sMario.earnedPoints and sMario.earnedPoints ~= 0 then
                -- check if anyone has points; if not, use 0.75 frequency
                frequency = 1
                return true
            end
        end)
        set_music_frequency(frequency)
        currentMusic = "scores"
    end
    set_background_music(0, 0, 0)
    update_music(currentMusic)
    local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode or 0]

    if gGlobalSyncTable.gameState == GAME_STATE_ACTIVE and gData.globalUpdateFunc then
        gData.globalUpdateFunc()
    end

    if gGlobalSyncTable.gameState ~= GAME_STATE_LOBBY and gGlobalSyncTable.gameState ~= GAME_STATE_SCORES then
        if network_is_server() then
            gGlobalSyncTable.selectedMode = -1
            gGlobalSyncTable.gameLevelOverride = -1
            gGlobalSyncTable.forceStart = false
        end
    else
        playerLocalTimer = 0
        lightsOutTimeUntilBlackout = 0
        lightsOutBlackoutTimer = 0
        lightsOutDamageDealt = 0
        mingleWasOnCarousel = false
        duelEnding = false
        duelLastState = 0
    end

    if not network_is_server() then return end

    if gGlobalSyncTable.gameState == GAME_STATE_LOBBY then
        rejoin_data = {}
        local totalReady = 0
        local connected = 0
        for_each_connected_player(function(i)
            connected = connected + 1
            local sMario = gPlayerSyncTable[i]
            if sMario.ready then
                totalReady = totalReady + 1
            end
        end)

        -- start when enough people are ready
        local percent = gGlobalSyncTable.percentToStart / 100
        if connected ~= 0 and (connected > 1 or do_solo_debug()) and (gGlobalSyncTable.forceStart or (totalReady / connected >= percent)) then
            gGlobalSyncTable.gameTimer = gGlobalSyncTable.gameTimer + 1

            if gGlobalSyncTable.gameTimer >= 150 then
                if gGlobalSyncTable.eliminationMode then
                    gGlobalSyncTable.includeAllDuel = false
                elseif gGlobalSyncTable.teamCount == 2 then
                    gGlobalSyncTable.finalDuel = false
                end

                do_game_mode_selection((gGlobalSyncTable.gameTimer == 150))

                if gGlobalSyncTable.selectedMode ~= -1 then
                    if gGlobalSyncTable.teamSelection ~= TEAM_SELECTION_RANDOM then
                        do_team_selection()
                    end
                    gGlobalSyncTable.gameState = GAME_STATE_RULES

                    gGlobalSyncTable.gameMode = gGlobalSyncTable.selectedMode
                    gGlobalSyncTable.gameTimer = 0
                    gGlobalSyncTable.miniGameNum = 1
                    gGlobalSyncTable.gameWinner = -1
                    gGlobalSyncTable.roundTimer = 0
                    gGlobalSyncTable.eliminateThisRound = calculate_players_to_eliminate(true)
                    
                    gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode or 0]
                    if type(gData.level) == "table" then
                        -- Pick from map list at random
                        if gGlobalSyncTable.gameLevelOverride ~= -1 then
                            gGlobalSyncTable.gameLevel = gGlobalSyncTable.gameLevelOverride
                        else
                            local newLevel = math.random(1, #gData.level)
                            gGlobalSyncTable.gameLevel = gData.level[newLevel]
                        end
                    end
                end
            end
        else
            gGlobalSyncTable.gameTimer = 0
        end
    elseif gGlobalSyncTable.gameState == GAME_STATE_RULES then
        gGlobalSyncTable.round = 1
        gGlobalSyncTable.freezeRoundTimer = false
        gGlobalSyncTable.starStealOwner = 255
        gGlobalSyncTable.mingleHurry = false
        gGlobalSyncTable.duelState = DUEL_STATE_WAIT
        gGlobalSyncTable.gameTimer = gGlobalSyncTable.gameTimer + 1
        if gGlobalSyncTable.gameTimer >= 450 then
            gGlobalSyncTable.gameState = GAME_STATE_ACTIVE
            gGlobalSyncTable.gameTimer = 0
        end
    elseif gGlobalSyncTable.gameState == GAME_STATE_ACTIVE then
        if not gGlobalSyncTable.freezeRoundTimer then
            gGlobalSyncTable.roundTimer = gGlobalSyncTable.roundTimer + 1
        end
        gGlobalSyncTable.gameTimer = gGlobalSyncTable.gameTimer + 1
        local miniGameEnd = true
        local alivePlayers = 0
        local aliveTeams = 0
        local teamCounted = {}
        for_each_connected_player(function(i)
            local sMario = gPlayerSyncTable[i]
            if not sMario.eliminated then
                alivePlayers = alivePlayers + 1
                if sMario.team and sMario.team ~= 0 then
                    if not teamCounted[sMario.team] then
                        teamCounted[sMario.team] = 1
                        aliveTeams = aliveTeams + 1
                    end
                else
                    aliveTeams = aliveTeams + 1
                end
                if not sMario.victory then
                    miniGameEnd = false
                end
            end
            --if (not miniGameEnd) and (alivePlayers > 1) then return true end
        end)

        if gData.hostUpdateFunc then
            local result = gData.hostUpdateFunc()
            if result ~= nil then
                miniGameEnd = result
            end
        end

        -- recalculate players to eliminate if it's everyone
        if alivePlayers > 1 and gGlobalSyncTable.eliminateThisRound > 1 and gGlobalSyncTable.eliminateThisRound >= alivePlayers then
            gGlobalSyncTable.eliminateThisRound = calculate_players_to_eliminate()
        end

        -- end early in elimination-type minigames
        if (not gData.victoryFunc) and (aliveTeams <= 1) and not do_solo_debug() then
            miniGameEnd = true
        end

        local roundTime = gData.roundTime or 0
        if gData.firstRoundTime and gGlobalSyncTable.round == 1 then
            roundTime = gData.firstRoundTime
        end
        if roundTime ~= 0 and gGlobalSyncTable.roundTimer >= roundTime then
            local eliminated = 0
            if gData.eliminateFunc then
                eliminated = gData.eliminateFunc()
            elseif gGlobalSyncTable.eliminateThisRound ~= 0 then
                -- eliminate the specified amount of players
                local safeScore = get_safe_score(get_standings_table("roundScore"))
                for_each_connected_player(function(index)
                    local sMario = gPlayerSyncTable[index]
                    if (not sMario.eliminated) and sMario.roundScore and (sMario.roundScore < safeScore) then
                        eliminate_mario(gMarioStates[index])
                        eliminated = eliminated + 1
                    end
                end)
            end

            -- end early in elimination-type minigames
            alivePlayers = alivePlayers - eliminated
            aliveTeams = alivePlayers
            if gGlobalSyncTable.teamCount ~= 0 then
                -- do a recount
                alivePlayers = 0
                aliveTeams = 0
                teamCounted = {}
                for_each_connected_player(function(i)
                    local sMario = gPlayerSyncTable[i]
                    if not sMario.eliminated then
                        alivePlayers = alivePlayers + 1
                        if sMario.team and sMario.team ~= 0 then
                            if not teamCounted[sMario.team] then
                                teamCounted[sMario.team] = 1
                                aliveTeams = aliveTeams + 1
                            end
                        else
                            aliveTeams = aliveTeams + 1
                        end
                        if not sMario.victory then
                            miniGameEnd = false
                        end
                    end
                    --if (not miniGameEnd) and (alivePlayers > 1) then return true end
                end)
            end
            if (not gData.victoryFunc) and (aliveTeams <= 1) and not do_solo_debug() then
                miniGameEnd = true
            end
            
            -- cut round-based minigames short in elimination mode if too many players are eliminated
            if (not gData.victoryFunc) and gGlobalSyncTable.eliminationMode then
                local toEliminate, hitMinimum = calculate_players_to_eliminate(false, true)
                if hitMinimum then
                    miniGameEnd = true
                end
            end

            if not miniGameEnd then
                gGlobalSyncTable.roundTimer = 0
                gGlobalSyncTable.round = gGlobalSyncTable.round + 1
                gGlobalSyncTable.eliminateThisRound = calculate_players_to_eliminate()
            end
        end

        local maxTime = gData.maxTime or 3 * 30 * 60 -- default 3 minutes max
        if gData.maxRounds and gData.roundTime and gData.roundTime > 0 then
            maxTime = gData.firstRoundTime or gData.roundTime
            maxTime = maxTime + gData.roundTime * (gData.maxRounds-1)
        end
        
        if miniGameEnd or (maxTime ~= -1 and gGlobalSyncTable.gameTimer >= maxTime) then
            gGlobalSyncTable.gameTimer = 0
            gGlobalSyncTable.gameState = GAME_STATE_MINI_END

            if not gGlobalSyncTable.eliminationMode then
                -- adjust points in team mode to make uneven teams more fair
                local teamMultiplier = {}
                if gGlobalSyncTable.teamCount ~= 0 then
                    local countPerTeam = {}
                    local validPlayers = 0
                    for i=0,MAX_PLAYERS-1 do
                        if gNetworkPlayers[i].connected then
                            validPlayers = validPlayers + 1
                            local sMario = gPlayerSyncTable[i]
                            if sMario.team and sMario.team ~= 0 then
                                if countPerTeam[sMario.team] then
                                    countPerTeam[sMario.team] = countPerTeam[sMario.team] + 1
                                else
                                    countPerTeam[sMario.team] = 1
                                end
                            end
                        end
                    end
                    local expectedPerTeam = math.ceil(validPlayers / gGlobalSyncTable.teamCount)
                    for team,count in pairs(countPerTeam) do
                        teamMultiplier[team] = expectedPerTeam / count
                    end
                end

                -- calculate scores if we won, or if there is no victory condition and we survived
                local highestPlacement = 1
                if (gData.doPlacementPoints) then
                    for_each_connected_player(function(i)
                        local sMario2 = gPlayerSyncTable[i]
                        if sMario2.eliminated and sMario2.roundEliminated
                        and highestPlacement < sMario2.roundEliminated then
                            highestPlacement = sMario2.roundEliminated
                        end
                    end)
                end

                local didMultiplier = false
                for_each_connected_player(function(i)
                    local sMario = gPlayerSyncTable[i]
                    if sMario.points == nil then sMario.points = 0 end
                    if (not sMario.eliminated) and (gData.victoryFunc == nil or sMario.victory) then
                        if gData.pointCalcFunc then
                            sMario.earnedPoints = gData.pointCalcFunc(i) or 0
                        else
                            sMario.earnedPoints = 20
                        end
                    elseif (gData.doEliminationPoints or gData.autoElimination) and gGlobalSyncTable.round > 1 and sMario.roundEliminated and sMario.roundEliminated >= 1 then
                        sMario.earnedPoints = math.floor(((sMario.roundEliminated - 1) / gGlobalSyncTable.round) * 20) -- points based on total rounds
                    elseif gData.doPlacementPoints and sMario.roundEliminated and sMario.roundEliminated >= 1 then
                        sMario.earnedPoints = math.floor(((sMario.roundEliminated - 1) / highestPlacement) * 20) -- points based on time eliminated
                    end
                    
                    if sMario.team and teamMultiplier[sMario.team] and teamMultiplier[sMario.team] ~= 1 then
                        sMario.multiplier = teamMultiplier[sMario.team]
                        didMultiplier = true
                    else
                        sMario.multiplier = 1
                    end
                end)
                if didMultiplier and not is_final_duel() then
                    network_send_include_self(true, {id = PACKET_GLOBAL_MSG, text = "\\#ffff50\\Points adjusted to account for uneven teams."})
                end
            elseif gData.victoryFunc then
                -- eliminate anyone who didn't win if there was a victory condition
                for_each_connected_player(function(i)
                    local sMario = gPlayerSyncTable[i]
                    if not (sMario.victory or sMario.eliminated) then
                        eliminate_mario(gMarioStates[i])
                    end
                end)
            end
        end
    elseif gGlobalSyncTable.gameState == GAME_STATE_MINI_END then
        gGlobalSyncTable.gameTimer = gGlobalSyncTable.gameTimer + 1
        local endTime = 120
        if gGlobalSyncTable.gameMode == GAME_MODE_DUEL then
            endTime = endTime + 3 * 30 -- add 3 seconds
        end
        if gGlobalSyncTable.gameTimer >= endTime then
            if is_final_duel() then
                gGlobalSyncTable.gameState = GAME_STATE_GAME_END
                gGlobalSyncTable.gameWinner = -1
                -- set winner to the one who won the duel
                for_each_connected_player(function(i)
                    local sMario = gPlayerSyncTable[i]
                    if sMario.victory then
                        gGlobalSyncTable.gameWinner = network_global_index_from_local(i)
                        return true
                    end
                end)
                return
            end

            gGlobalSyncTable.gameState = GAME_STATE_SCORES
            gGlobalSyncTable.roundTimer = 0
            gGlobalSyncTable.round = 1

            -- add earned points
            if not gGlobalSyncTable.eliminationMode then
                for_each_connected_player(function(i)
                    local sMario = gPlayerSyncTable[i]
                    if sMario.multiplier and sMario.multiplier ~= 1 then
                        sMario.earnedPoints = math.ceil(sMario.earnedPoints * sMario.multiplier)
                    end
                    sMario.points = sMario.points + sMario.earnedPoints
                end)
            end
        end
    elseif gGlobalSyncTable.gameState == GAME_STATE_SCORES then
        gGlobalSyncTable.gameTimer = gGlobalSyncTable.gameTimer + 1
        if gGlobalSyncTable.gameTimer > 450 then
            local connectionsNeeded = 2
            local validPlayers = 0
            for_each_connected_player(function(index)
                validPlayers = validPlayers + 1
                if validPlayers >= connectionsNeeded then return true end
            end)
            if validPlayers == 0 or not (do_solo_debug() or validPlayers >= connectionsNeeded) then
                gGlobalSyncTable.gameTimer = 450
            end
        end

        if gGlobalSyncTable.gameTimer >= 480 then
            local alivePlayers = MAX_PLAYERS
            local aliveTeams = alivePlayers
            local aliveTable = {}
            if gGlobalSyncTable.eliminationMode then
                alivePlayers = 0
                aliveTeams = 0
                local teamCounted = {}
                for_each_connected_player(function(i)
                    local sMario = gPlayerSyncTable[i]
                    if not sMario.eliminated then
                        alivePlayers = alivePlayers + 1
                        table.insert(aliveTable, i)
                        if sMario.team and sMario.team ~= 0 then
                            if not teamCounted[sMario.team] then
                                teamCounted[sMario.team] = 1
                                aliveTeams = aliveTeams + 1
                            end
                        else
                            aliveTeams = aliveTeams + 1
                        end
                        --if alivePlayers > 2 then return true end
                    end
                end)
            end

            if (not do_solo_debug()) and (aliveTeams <= 1) then
                end_game()
            else
                if gGlobalSyncTable.miniGameNum >= gGlobalSyncTable.maxMiniGames then
                    end_game()
                else
                    -- select new mode
                    if gGlobalSyncTable.finalDuel and ((gGlobalSyncTable.miniGameNum == gGlobalSyncTable.maxMiniGames - 1) or (aliveTeams == 2)) then
                        -- do ending duel
                        gGlobalSyncTable.allDuel = false
                        for i = 0, MAX_PLAYERS - 1 do
                            gPlayerSyncTable[i].validForDuel = false
                        end

                        local prevTeam = -1
                        if gGlobalSyncTable.eliminationMode then
                            for i, index in ipairs(aliveTable) do
                                local sMario = gPlayerSyncTable[index]
                                sMario.validForDuel = true
                            end
                        else
                            local standings = get_standings_table("points")
                            local numValid = 0
                            local prevScore = 0
                            while #standings ~= 0 do
                                local index = standings[1][1]
                                local score = standings[1][2]
                                if prevScore ~= score then
                                    prevScore = score
                                    if numValid >= 2 then
                                        break
                                    end
                                end
                                local sMario = gPlayerSyncTable[index]
                                sMario.validForDuel = true
                                table.remove(standings, 1)
                                if sMario.team == nil or sMario.team == 0 or sMario.team ~= prevTeam then
                                    numValid = numValid + 1
                                    prevTeam = sMario.team
                                end
                            end
                        end

                        gGlobalSyncTable.selectedMode = GAME_MODE_DUEL
                    else
                        do_game_mode_selection((gGlobalSyncTable.gameTimer == 480), true)
                    end

                    if gGlobalSyncTable.selectedMode ~= -1 then
                        gGlobalSyncTable.gameTimer = 0
                        gGlobalSyncTable.miniGameNum = gGlobalSyncTable.miniGameNum + 1
                        gGlobalSyncTable.gameMode = gGlobalSyncTable.selectedMode
                        gGlobalSyncTable.round = 1
                        gGlobalSyncTable.eliminateThisRound = calculate_players_to_eliminate(not gGlobalSyncTable.eliminationMode)
                        gGlobalSyncTable.gameState = GAME_STATE_RULES

                        gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode or 0]
                        if type(gData.level) == "table" then
                            -- Pick from map list at random
                            if gGlobalSyncTable.gameLevelOverride ~= -1 then
                                gGlobalSyncTable.gameLevel = gGlobalSyncTable.gameLevelOverride
                            else
                                local newLevel = math.random(1, #gData.level)
                                gGlobalSyncTable.gameLevel = gData.level[newLevel]
                            end
                        end
                    end
                end
            end
        end
    elseif gGlobalSyncTable.gameState == GAME_STATE_GAME_END then
        gGlobalSyncTable.gameTimer = gGlobalSyncTable.gameTimer + 1
        if gGlobalSyncTable.gameTimer >= 450 then
            gGlobalSyncTable.gameState = GAME_STATE_LOBBY
            gGlobalSyncTable.gameTimer = 0
            if gGlobalSyncTable.teamSelection == TEAM_SELECTION_RANDOM then
                do_team_selection()
            end
        end
    end
end

hook_event(HOOK_UPDATE, update)

-- eliminate on death if the game is active
function on_death(m)
    if m.playerIndex ~= 0 or gGlobalSyncTable.gameState ~= GAME_STATE_ACTIVE then return false end
    local sMario = gPlayerSyncTable[0]
    if sMario.eliminated or sMario.victory then return false end
    eliminate_mario(m)
    gMarioStates[0].health = 0x880
    return false
end

hook_event(HOOK_ON_DEATH, on_death)

-- make bomb tag players move slightly faster
function before_phys_step(m, stepType)
    if gGlobalSyncTable.gameState ~= GAME_STATE_ACTIVE then return end

    if gGlobalSyncTable.gameMode == GAME_MODE_BOMB_TAG and gPlayerSyncTable[m.playerIndex].holdingBomb
    and m.action & ACT_FLAG_INVULNERABLE == 0 then -- don't affect knockback actions
        m.vel.x = m.vel.x * 1.1
        m.vel.z = m.vel.z * 1.1
    end
end
hook_event(HOOK_BEFORE_PHYS_STEP, before_phys_step)

-- no act select
function no_act_select(level)
    return false
end

hook_event(HOOK_USE_ACT_SELECT, no_act_select)

-- don't allow interactions with eliminated or spectating players (also prevents interaction while not on the bridge in glass bridge)
function allow_pvp_attack(attacker, victim, interaction)
    local sAttacker = gPlayerSyncTable[attacker.playerIndex]
    local sVictim = gPlayerSyncTable[victim.playerIndex]

    local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode or 0]
    if sAttacker.eliminated or sVictim.eliminated or sAttacker.victory or sVictim.victory then
        return false
    elseif gData and gData.allowPvpFunc then
        return gData.allowPvpFunc(attacker, victim, interaction)
    end
end

hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp_attack)

function on_pvp_attack(attacker, victim, interaction)
    if victim.playerIndex ~= 0 or attacker.playerIndex == 0 or gGlobalSyncTable.gameState ~= GAME_STATE_ACTIVE then return end

    local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode or 0]
    if gData and gData.onPvpFunc then
        gData.onPvpFunc(attacker, victim, interaction)
    end
end

hook_event(HOOK_ON_PVP_ATTACK, on_pvp_attack)

-- Notify about new dice chance
function dice_block_chance_change(tag, oldVal, newVal)
    if gGlobalSyncTable.gameState ~= GAME_STATE_ACTIVE or gGlobalSyncTable.gameMode ~= GAME_MODE_DICE then return end
    if (oldVal == nil or newVal == nil) or (oldVal == newVal) then return end

    local dieMax = 20
    local chance = math.min(newVal + 1, dieMax)
    text = string.format("\\#ffff50\\You now have a %d%% chance of getting a kill!", chance*100/dieMax)
    djui_chat_message_create(text)
end
hook_on_sync_table_change(gPlayerSyncTable[0], "roundScore", "roundScore", dice_block_chance_change)

-- don't display nametags in lights out
function on_nametags_render(index)
    if gGlobalSyncTable.gameState ~= GAME_STATE_ACTIVE then return end

    local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode]
    if gData and gData.nametagFunc then
        return gData.nametagFunc(index)
    end
end

hook_event(HOOK_ON_NAMETAGS_RENDER, on_nametags_render)

-- allow keeping data after rejoining
---@param m MarioState
function on_player_connected(m)
    rejoin_check[m.playerIndex] = 1
end

hook_event(HOOK_ON_PLAYER_CONNECTED, on_player_connected)

---@param m MarioState
function on_player_disconnected(m)
    if gGlobalSyncTable.gameState == GAME_STATE_LOBBY or gGlobalSyncTable.gameState == GAME_STATE_GAME_END then
        if network_is_server() then
            gPlayerSyncTable[m.playerIndex].eliminated = true
        end
        return
    end

    local sMario = gPlayerSyncTable[m.playerIndex]
    local rejoinID = sMario.rejoinID
    local roundScore = sMario.roundScore or 0
    local eliminated = sMario.eliminated
    -- prevent cheesing games by leaving
    if (m.floor and m.floor.type == SURFACE_DEATH_PLANE) or (gGlobalSyncTable.gameMode == GAME_MODE_LIGHTS_OUT) then
        roundScore = 0
        eliminated = true
    end

    -- In team mode, distribute points to other players on team on disconnect
    if gGlobalSyncTable.teamCount ~= 0 and sMario.team ~= 0 then
        local teammates = {}
        local points = sMario.points or 0
        if gGlobalSyncTable.gameState == GAME_STATE_MINI_END then
            points = points + (sMario.earnedPoints or 0)
        end

        if points ~= 0 then
            for i=0,MAX_PLAYERS-1 do
                local np2 = gNetworkPlayers[i]
                local sMario2 = gPlayerSyncTable[i]
                if i ~= m.playerIndex and np2.connected and sMario2.team == sMario.team then
                    table.insert(teammates, i)
                end
            end

            if #teammates ~= 0 then
                local name = network_get_player_text_color_string(m.playerIndex) .. gNetworkPlayers[m.playerIndex].name
                local teamName = TEAM_DATA[sMario.team][3] or "???"
                djui_chat_message_create(name .. "'s\\#ffff50\\ points were distributed among "..teamName.."\\#ffff50\\.")

                if network_is_server() then
                    -- Reset points so we don't get them back when rejoining
                    sMario.points = 0
                    sMario.earnedPoints = 0

                    -- Distrubute points as evenly as possible
                    -- extra points are given by index priority
                    local pointsPerPlayer = points // #teammates
                    local extra = points % #teammates
                    for i,index in ipairs(teammates) do
                        local sMario2 = gPlayerSyncTable[index]
                        local newPoints = pointsPerPlayer
                        if extra ~= 0 then
                            newPoints = newPoints + 1
                            extra = extra - 1
                        end
                        sMario2.points = sMario2.points + newPoints
                    end
                end
            end
        end
    end

    if rejoinID and ((not eliminated) or sMario.points ~= 0 or sMario.earnedPoints ~= 0 or roundScore ~= 0) then
        local name = network_get_player_text_color_string(m.playerIndex) .. gNetworkPlayers[m.playerIndex].name
        djui_chat_message_create(name .. "\\#ffff50\\ can rejoin to restore their progress.")
        if not network_is_server() then return end
        table.insert(rejoin_data, {
            id = PACKET_REJOIN,
            rejoinID = rejoinID,
            team = sMario.team,
            leftMiniGame = gGlobalSyncTable.miniGameNum,
            leftRound = gGlobalSyncTable.round,
            points = sMario.points or 0,
            earnedPoints = sMario.earnedPoints or 0,
            roundScore = roundScore or 0,
            eliminated = eliminated,
            roundEliminated = sMario.roundEliminated or 0,
            validForDuel = sMario.validForDuel or false,
        })
        sMario.rejoinID = "-1"
        -- give all remote players the rejoin check flag, in case the player rejoined before the disconnect process
        for i=1,MAX_PLAYERS-1 do
            rejoin_check[i] = 1
        end
    end
    if network_is_server() then
        sMario.eliminated = true
        sMario.roundEliminated = 0
        sMario.team = 0
    end
end

hook_event(HOOK_ON_PLAYER_DISCONNECTED, on_player_disconnected)

-- prevent OOB death; add water effect to fountain on Toad Town
---@param m MarioState
function override_geometry_inputs(m)
    if m.floor == nil and m.action ~= ACT_END_SEQUENCE then
        set_to_spawn_pos(m, true)
        return true
    end
end

hook_event(HOOK_MARIO_OVERRIDE_GEOMETRY_INPUTS, override_geometry_inputs)

-- fix bug where grabbing a pole from the very bottom knocks mario off
-- also disables cannon interaction
function allow_interact(m, o, type)
    if type == INTERACT_POLE and m.pos.y - o.oPosY + o.hitboxDownOffset < 0 then
        return false
    elseif type == INTERACT_CANNON_BASE then
        return false
    end
end

hook_event(HOOK_ALLOW_INTERACT, allow_interact)

-- Cap BLJS
function before_set_mario_action(m, action)
    if action == ACT_LONG_JUMP and m.forwardVel < -60 then
        m.forwardVel = -60
    end
end

hook_event(HOOK_BEFORE_SET_MARIO_ACTION, before_set_mario_action)

-- custom action when losing Glass Bridge, also used in Bomb Tag when respawning while not holding a bomb
---@param m MarioState
function act_gb_fall(m)
    m.actionTimer = m.actionTimer + 1
    play_character_sound_if_no_flag(m, CHAR_SOUND_WAAAOOOW, MARIO_MARIO_SOUND_PLAYED)

    common_air_action_step(m, ACT_HARD_FORWARD_GROUND_KB_INTERACTABLE, CHAR_ANIM_AIRBORNE_ON_STOMACH, AIR_STEP_CHECK_LEDGE_GRAB);
    m.marioObj.header.gfx.angle.x = m.actionTimer * 0x1000 - 0x4000
    m.marioObj.header.gfx.angle.y = m.faceAngle.y + m.actionTimer * 0x800
    m.marioObj.header.gfx.angle.z = m.actionTimer * 0x1200
    return 0
end

ACT_GB_FALL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
hook_mario_action(ACT_GB_FALL, act_gb_fall)

-- custom action when landing after ACT_GB_FALL, duplicate of ACT_HARD_FORWARD_GROUND_KB but without invulnerable flags
---@param m MarioState
function act_hard_forward_ground_kb_interactable(m)
    if (not m) then return 0 end
    local animFrame = common_ground_knockback_action(m, CHAR_ANIM_LAND_ON_STOMACH, 21, 1, m.actionArg)
    if (animFrame == 23 and m.health < 0x100) then
        set_mario_action(m, ACT_DEATH_ON_STOMACH, 0)
    end

    return 0
end

ACT_HARD_FORWARD_GROUND_KB_INTERACTABLE = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING)
hook_mario_action(ACT_HARD_FORWARD_GROUND_KB_INTERACTABLE, act_hard_forward_ground_kb_interactable)

-- custom action for end sequence
---@param m MarioState
function act_end_sequence(m)
    m.health = 0x880
    m.actionTimer = m.actionTimer + 1
    if m.playerIndex == 0 then
        if m.actionTimer == 1 then
            start_cutscene(m.area.camera, CUTSCENE_LOOP)
        end

        -- focus in front of mario
        local speed = 1
        local pos = { x = 0, y = m.pos.y, z = m.pos.z }
        local goalFocus = { x = 0, y = 0, z = 0 }
        local goalPos = { x = 0, y = 0, z = 0 }
        local offsetFocus = { x = 0, y = 150, z = -400 }
        local offsetPos = { x = 0, y = 150, z = -800 }

        offset_rotated(goalFocus, pos, offsetFocus, m.faceAngle)
        offset_rotated(goalPos, pos, offsetPos, m.faceAngle);
        approach_vec3f_asymptotic(gLakituState.goalFocus, goalFocus, speed, speed, speed);
        approach_vec3f_asymptotic(gLakituState.goalPos, goalPos, speed, speed, speed);

        -- pour coins from the top if there is at least 1 winner
        if m.actionState ~= 2 then
            spawn_object_no_rotate(id_bhvEffectCoin, E_MODEL_YELLOW_COIN, 0, m.pos.y + 2500, m.pos.z, nil, false)
        end
    end

    if m.actionState == 1 then
        m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags & ~GRAPH_RENDER_INVISIBLE
        vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
        vec3s_copy(m.marioObj.header.gfx.angle, m.faceAngle)
        set_character_animation(m, CHAR_ANIM_STAR_DANCE)
        if m.actionTimer >= 40 then
            m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
        end
        if m.actionTimer == 42 then
            play_character_sound(m, CHAR_SOUND_HERE_WE_GO)
        end
    else
        m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
    end
end

ACT_END_SEQUENCE = allocate_mario_action(ACT_GROUP_CUTSCENE | ACT_FLAG_INTANGIBLE)
hook_mario_action(ACT_END_SEQUENCE, act_end_sequence)

-- packets
function on_packet_star_steal(data, self)
    local npAttacker = network_player_from_global_index(data.newOwner)
    local aPlayerColor = network_get_player_text_color_string(npAttacker.localIndex)
    local aName = npAttacker.name
    if npAttacker.localIndex == 0 then
        aName = "You"
    end
    aName = aPlayerColor .. aName

    play_sound(SOUND_MENU_STAR_SOUND, gGlobalSoundSource)
    if data.oldOwner then
        local npVictim = network_player_from_global_index(data.oldOwner)
        local vPlayerColor = network_get_player_text_color_string(npVictim.localIndex)
        local vName = npVictim.name .. "'s"
        if npVictim.localIndex == 0 then
            vName = "your"
        end
        vName = vPlayerColor .. vName

        djui_popup_create(aName .. "\\#ffffff\\ stole " .. vName .. "\\#ffffff\\ \\#ffff50\\Star\\#ffffff\\!", 1)
    else
        djui_popup_create(aName .. "\\#ffffff\\ stole the \\#ffff50\\Star\\#ffffff\\!", 1)
    end
end

function on_packet_mingle_callout(data, self)
    stream_music_fade(0)
    play_stream_sfx("playerCallout" .. data.count, gGlobalSoundSource, 2)
end

function on_packet_mingle_restart(data, self)
    update_music("") -- restarts the track
    local m = gMarioStates[0]
    m.health = 0x880
    set_to_spawn_pos(m, true)
end

function on_packet_rejoin(data, self)
    -- wait for sync valid
    if DEBUG_MODE then log_to_console("Got rejoin packet; loaded:" .. tostring(firstLoaded)) end
    if not firstLoaded then
        waitRejoinData = data
        return
    end

    djui_chat_message_create("\\#ffff50\\Your progress was restored!")
    local sMario = gPlayerSyncTable[0]
    sMario.points = data.points or 0
    sMario.team = data.team or sMario.team
    -- only restore certain values if we're on the same mini game we left on
    if gGlobalSyncTable.miniGameNum == data.leftMiniGame and gGlobalSyncTable.gameState ~= GAME_STATE_SCORES then
        sMario.roundScore = data.roundScore or 0
        sMario.earnedPoints = data.earnedPoints or 0
        sMario.validForDuel = gGlobalSyncTable.allDuel or data.validForDuel
        if gGlobalSyncTable.round == data.leftRound and data.eliminated ~= nil then
            sMario.eliminated = data.eliminated
            sMario.roundEliminated = data.roundEliminated or 0
            local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode]
            if gData and gData.rejoinFunc then
                gData.rejoinFunc(sMario)
            end
        else
            sMario.roundEliminated = data.leftRound or 0
        end
    end
end

function on_packet_blackout(data, self)
    lightsOutBlackoutTimer = 90
end

function on_packet_mod_choose(data, self)
    if not inMenu then
        enter_menu(3)
    end
    djui_chat_message_create("\\#ffff50\\Since you're the first moderator available, you will pick this minigame!")
end

function on_packet_global_msg(data, self)
    djui_chat_message_create(data.text)
end

function on_packet_damage(data, self)
    lightsOutDamageDealt = lightsOutDamageDealt + (data.damage or 0)
end

function on_packet_kill(data, self)
    local np = network_player_from_global_index(data.from)
    if not np then return end
    local name = network_get_player_text_color_string(np.localIndex) .. np.name
    if not gGlobalSyncTable.freezeRoundTimer then
        djui_chat_message_create("\\#ffff50\\You killed "..name.."!\n\\#ffff50\\Got a full heal!")
        gMarioStates[0].healCounter = 31
    else
        djui_chat_message_create("\\#ffff50\\You killed "..name.."!")
    end
end

local syncFields = {
    "team",
    "points",
    "earnedPoints",
    "eliminated",
    "victory",
    "holdingBomb",
}
local syncFieldsGlobal = {
    "gameMode",
    "gameState",
    "minigameNum",
    "eliminationMode",
    "duelState",
    "gameMode",
    "teamCount",
    "starStealOwner",
}
function on_packet_request_desync_fix(data, self)
    local newData = {id = PACKET_DESYNC_FIX}
    local newDataSolo = {}
    for a, field in ipairs(syncFieldsGlobal) do
        local value = gGlobalSyncTable[field]
        if value ~= nil then
            --print(tostring(field)..": "..tostring(value))
            newData[field] = value
        end
    end

    for i=0,MAX_PLAYERS - 1 do
        newDataSolo[i] = {id = PACKET_DESYNC_FIX, player = network_global_index_from_local(i)}
        for a, field in ipairs(syncFields) do
            local value = gPlayerSyncTable[i][field]
            if value ~= nil then
                newDataSolo[i][field] = value
            end
        end
    end

    if data.from then
        local localIndex = network_local_index_from_global(data.from) or 255
        if localIndex ~= 255 then
            network_send_to(localIndex, true, newData)
            for i=0,MAX_PLAYERS - 1 do
                network_send_to(localIndex, true, newDataSolo[i])
            end
        end
    else
        network_send(true, newData)
        for i=0,MAX_PLAYERS - 1 do
            network_send(true, newDataSolo[i])
        end
    end
end

function on_packet_desync_fix(data, self)
    if not firstLoaded then return end

    local syncTable = gGlobalSyncTable
    if data.player then
        localIndex = network_local_index_from_global(data.player) or 255
        if localIndex == 255 then return end
        syncTable = gPlayerSyncTable[localIndex]
    end
    for field, value in pairs(data) do
        --print(field, value, data.player)
        if field ~= "id" and field ~= "player" and field:sub(1, 1) ~= "_" and value ~= nil then
            rawset(syncTable._table, field, value) -- set without sending packet
        end
    end
end

function on_packet_dice_roll(data, self)
    local text = string.format("\\#ffff50\\You rolled %d (needed %d+). ", data.roll, data.chance)
    if data.roll < data.chance then
        text = text .. "You got unlucky..."
        djui_chat_message_create(text)
        local sMario = gPlayerSyncTable[0]
        sMario.roundScore = sMario.roundScore + 2
    else
        text = text .. "You got \'em!"
        djui_chat_message_create(text)
    end
end

PACKET_STAR_STEAL = 0
PACKET_MINGLE_CALLOUT = 1
PACKET_MINGLE_RESTART = 2
PACKET_REJOIN = 3
PACKET_BLACKOUT = 4
PACKET_MOD_CHOOSE = 5
PACKET_GLOBAL_MSG = 6
PACKET_DAMAGE = 7
PACKET_KILL = 8
PACKET_REQUEST_DESYNC_FIX = 9
PACKET_DESYNC_FIX = 10
PACKET_DICE_ROLL = 11
sPacketTable = {
    [PACKET_STAR_STEAL] = on_packet_star_steal,
    [PACKET_MINGLE_CALLOUT] = on_packet_mingle_callout,
    [PACKET_MINGLE_RESTART] = on_packet_mingle_restart,
    [PACKET_REJOIN] = on_packet_rejoin,
    [PACKET_BLACKOUT] = on_packet_blackout,
    [PACKET_MOD_CHOOSE] = on_packet_mod_choose,
    [PACKET_GLOBAL_MSG] = on_packet_global_msg,
    [PACKET_DAMAGE] = on_packet_damage,
    [PACKET_KILL] = on_packet_kill,
    [PACKET_REQUEST_DESYNC_FIX] = on_packet_request_desync_fix,
    [PACKET_DESYNC_FIX] = on_packet_desync_fix,
    [PACKET_DICE_ROLL] = on_packet_dice_roll,
}

function on_packet_receive(data)
    if data.id and sPacketTable[data.id] then
        sPacketTable[data.id](data, false)
    end
end

hook_event(HOOK_ON_PACKET_RECEIVE, on_packet_receive)

-- the one chat command
function desync_fix_command(msg)
    if network_is_server() then
        on_packet_request_desync_fix({}, true)
    elseif network_is_moderator() then
        network_send_to(1, true, {
            id = PACKET_REQUEST_DESYNC_FIX,
        })
    else
        djui_chat_message_create("\\#ff5050\\You have permission to perform this command... or DO you?\n(No, you don't have moderator)")
        return true
    end
    djui_chat_message_create("Attempting to correct desync...")
    return true
end
hook_chat_command("desync", "- Attempt to fix desync issues", desync_fix_command)
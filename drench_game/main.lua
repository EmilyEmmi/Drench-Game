-- name: Drench Game
-- description: Don't leak this.
-- description_actual: Squid Game in Mario 64!\n\nCommissioned by Drenchy\nInspired by Dani's \"Crab Game\"\n\nProgramming: EmilyEmmi\n\nMaps: biobak, EmilyEmmi, Woissil\n\nSoundtrack: murioz\n\nVoice Acting:\nEspi as Toad\nSqueex as Mingle Callout\nTrashcam as Waluigi
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
GAME_MODE_DUEL = 7 -- needs to be at the end due to its special nature
GAME_MODE_MAX = 8

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

GAME_MODE_DATA = {
    [GAME_MODE_GLASS] = {
        name = "Glass Bridge",
        desc =
        "Get across the bridge without falling! Only one glass pane is safe in each row. Will you push your luck, or let someone else take the fall?",
        level = LEVEL_GLASS,
        interact = PLAYER_INTERACTIONS_SOLID,
        kbStrength = 10,
        music = "dire",
        marioUpdateFunc = function(m) -- switch to custom falling action
            if m.action & ACT_GROUP_MASK ~= ACT_GROUP_CUTSCENE and m.action ~= ACT_GB_FALL and m.action ~= ACT_BUBBLED
                and m.floor and m.floor.type == SURFACE_DEATH_PLANE and m.vel.y <= -75 and m.pos.y - m.floorHeight <= 8000 then
                set_mario_action(m, ACT_GB_FALL, 0)
            end
        end,
        victoryFunc = function(m)
            if (m.action & ACT_FLAG_AIR == 0 and m.floor and m.floor.type == SURFACE_TIMER_END) then
                if gPlayerSyncTable[m.playerIndex].earnedPoints >= 20 then
                    return true
                elseif m.playerIndex == 0 then
                    play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
                    djui_chat_message_create("\\#ff5050\\You aren't allowed to skip any glass panes!")
                    set_to_spawn_pos(m, true)
                end
            end
            return false
        end,
    },
    [GAME_MODE_LIGHTS_OUT] = {
        name = "Lights Out",
        desc =
        "This is a simple game: Stay alive. You'll earn 10 points for surviving this game. You could attack other players for some extra points... but wouldn't that be risky?",
        descElim =
        "This is a simple game: Stay alive. There's nothing to hurt you here unless you start attacking each other or something. But why would you do that?",
        maxTime = 3 * 60 * 30, -- 3 minutes
        level = LEVEL_LIGHTS_OUT,
        interact = PLAYER_INTERACTIONS_PVP,
        music = "dire",
        fallDamage = true,
        marioUpdateFunc = function(m)
            if m.playerIndex ~= 0 then return end
            if gGlobalSyncTable.eliminationMode then return end
            local sMario = gPlayerSyncTable[0]
            local currentPoints = (lightsOutDamageDealt // 4) -- 1 point for every 4 damage dealt
            if (not gGlobalSyncTable.eliminationMode) and currentPoints > sMario.earnedPoints then
                local newPoints = (currentPoints - sMario.earnedPoints)
                sMario.earnedPoints = currentPoints
                djui_chat_message_create("\\#ffff50\\+" .. newPoints .. " point(s) (" .. newPoints * 4 .. " DMG)")
                play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
            end
        end,
        pointCalcFunc = function(index) -- 10 points on top of existing points
            local sMario = gPlayerSyncTable[index]
            return sMario.earnedPoints + 10
        end,
        hostUpdateFunc = function()
            if gGlobalSyncTable.gameTimer == 1 then
                lightsOutTimeUntilBlackout = math.random(15, 60) * 30 -- 15-60 seconds
            end
            lightsOutTimeUntilBlackout = lightsOutTimeUntilBlackout - 1
            if lightsOutTimeUntilBlackout == 0 then
                lightsOutTimeUntilBlackout = math.random(15, 60) * 30 -- 15-60 seconds
                network_send_include_self(true, { id = PACKET_BLACKOUT })
            end
        end,
    },
    [GAME_MODE_RED_GREEN_LIGHT] = {
        name = "Red Light, Green Light",
        desc =
        "Reach the finish line! When Toad shouts \"Red Light!\", don't let him see you moving! You can move behind obstacles to avoid being seen. Tread carefully!",
        maxTime = 3 * 60 * 30, -- 3 minutes
        level = LEVEL_RGLIGHT,
        music = "", -- no music
        interact = PLAYER_INTERACTIONS_SOLID,
        kbStrength = 10,
        victoryFunc = function(m)
            return (m.floor and m.floor.type == SURFACE_TIMER_END)
        end,
    },
    [GAME_MODE_MINGLE] = {
        name = "Mingle",
        desc =
        "Stay on the carousel ride! When the music stops, get into a room with the specified number of players- no more, no less. Use the switch inside of the room to lock players out. Cooperation is key!",
        level = LEVEL_MINGLE,
        interact = PLAYER_INTERACTIONS_SOLID,
        kbStrength = 10,
        showHealth = true,
        roundTime = 13 * 30, -- 13 seconds
        music = "mingle",
        toEliminate = 0, -- so this game uses elimination logic for points
        marioUpdateFunc = function(m)
            if (not gGlobalSyncTable.mingleHurry) and (m.floor == nil or m.floor.object == nil) then
                if m.playerIndex == 0 and mingleWasOnCarousel then
                    mingleWasOnCarousel = false
                    play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
                    djui_chat_message_create("Stay on the carousel!")
                end
                m.health = m.health - 8
            elseif m.playerIndex == 0 then
                mingleWasOnCarousel = true
            end
        end,
        eliminateFunc = function() -- eliminate players not in a room with the right amount of people
            local eliminated = 0
            local roomData = {}
            for_each_connected_player(function(i)
                local m = gMarioStates[i]
                local sMario = gPlayerSyncTable[i]
                if (not sMario.eliminated) then
                    local roomNum = 0
                    local o = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvLockSwitch)
                    if o and dist_between_objects(m.marioObj, o) <= 1000 then
                        roomNum = o.oBehParams2ndByte + 1
                    end
                    if roomData[roomNum] == nil then
                        roomData[roomNum] = {}
                    end
                    table.insert(roomData[roomNum], m)
                end
            end)
            for a, room in pairs(roomData) do
                if DEBUG_MODE then log_to_console(tostring(a) .. ": " .. tostring(#room)) end
                if a == 0 or #room ~= gGlobalSyncTable.minglePlayerCount then
                    for b, m in ipairs(room) do
                        eliminated = eliminated + 1
                        eliminate_mario(m)
                    end
                end
            end
            return eliminated
        end,
        hostUpdateFunc = function()
            if ((not gGlobalSyncTable.mingleHurry) and gGlobalSyncTable.roundTimer < 90) or gGlobalSyncTable.roundTimer == 90 then
                gGlobalSyncTable.roundTimer = 90
                gGlobalSyncTable.mingleSpinTime = math.random(27, 45) * 30 -- 30-45 seconds
                if gGlobalSyncTable.mingleHurry then
                    gGlobalSyncTable.mingleHurry = false
                    network_send_include_self(true, {
                        id = PACKET_MINGLE_RESTART,
                    })
                end
            elseif not gGlobalSyncTable.mingleHurry then
                gGlobalSyncTable.roundTimer = 90
                gGlobalSyncTable.mingleSpinTime = gGlobalSyncTable.mingleSpinTime - 1
                if gGlobalSyncTable.mingleSpinTime <= 0 then
                    gGlobalSyncTable.mingleHurry = true
                    local alivePlayers = 0
                    for_each_connected_player(function(i)
                        local sMario = gPlayerSyncTable[i]
                        if (not sMario.eliminated) then
                            alivePlayers = alivePlayers + 1
                        end
                        if alivePlayers >= 5 then return true end
                    end)
                    local maxPlayerCount = alivePlayers
                    if (not gGlobalSyncTable.eliminationMode) then
                        -- ensure game eliminates everyone
                        maxPlayerCount = maxPlayerCount - 1
                    end
                    maxPlayerCount = clamp(maxPlayerCount, 1, 4)
                    gGlobalSyncTable.minglePlayerCount = math.random(1, maxPlayerCount)
                    gGlobalSyncTable.mingleMaxDoors = 8
                    -- after 2 rounds, there will be a limited number of doors available
                    if gGlobalSyncTable.round > 2 then
                        gGlobalSyncTable.mingleMaxDoors = maxPlayerCount // gGlobalSyncTable.minglePlayerCount
                        gGlobalSyncTable.mingleDoorsOpen = 0
                        -- bitwise value representing which doors are open
                        local availableToOpen = {}
                        for i = 0, 7 do
                            table.insert(availableToOpen, i)
                        end
                        for i = 1, gGlobalSyncTable.mingleMaxDoors do
                            local tableIndex = math.random(1, #availableToOpen)
                            local door = availableToOpen[tableIndex]
                            table.remove(availableToOpen, tableIndex)
                            gGlobalSyncTable.mingleDoorsOpen = gGlobalSyncTable.mingleDoorsOpen | (1 << door)
                        end
                    end
                    network_send_include_self(true, {
                        id = PACKET_MINGLE_CALLOUT,
                        count = gGlobalSyncTable.minglePlayerCount,
                    })
                end
            end
        end,
    },
    [GAME_MODE_STAR_STEAL] = {
        name = "Star Steal",
        desc =
        "Get the Star, and hold it to increase your score! Hit a player to take the Star from them! You'll be eliminated if your score is too low. Hmmm, this seems familiar...",
        level = -1, -- selects toad town or koopa keep
        interact = PLAYER_INTERACTIONS_PVP, -- so invulnerability frames exist
        firstRoundTime = 2 * 60 * 30,       -- 2 minutes
        roundTime = 30 * 30,                -- 30 seconds
        toEliminate = 0.25,                 -- get rid of 1/4 of players
        marioUpdateFunc = function(m)       -- earn points when holding star, and give to nearest on hit
            local sMario = gPlayerSyncTable[m.playerIndex]
            local gIndex = network_global_index_from_local(m.playerIndex)
            m.health = 0x880
            if gIndex == gGlobalSyncTable.starStealOwner then
                -- speed cap
                if m.forwardVel > 40 then
                    m.forwardVel = 40
                end
                m.particleFlags = m.particleFlags | PARTICLE_SPARKLES

                -- don't continue if we're not the local player
                if m.playerIndex ~= 0 then
                    m.hurtCounter = 0
                    return
                end

                if m.hurtCounter ~= 0 then
                    m.hurtCounter = 0
                    -- give to nearest
                    local maxDist = 10000
                    local selectedPlayer = 0
                    for_each_connected_player(function(index)
                        if index == 0 then return end
                        local sMario2 = gPlayerSyncTable[index]
                        if sMario2.eliminated then return end
                        local dist = dist_between_objects(gMarioStates[index].marioObj, m.marioObj)
                        if (not sMario2.eliminated) and dist < maxDist then
                            maxDist = dist
                            selectedPlayer = index
                        end
                    end)
                    if selectedPlayer ~= 0 then
                        gGlobalSyncTable.starStealOwner = network_global_index_from_local(selectedPlayer)
                        -- send packet to notify about steal
                        network_send_include_self(true, {
                            id = PACKET_STAR_STEAL,
                            oldOwner = gIndex,
                            newOwner = gGlobalSyncTable.starStealOwner,
                        })
                    end
                else
                    starStealLocalTimer = starStealLocalTimer + 1
                    if starStealLocalTimer >= 30 then
                        starStealLocalTimer = 0
                        sMario.roundScore = sMario.roundScore + 1
                    end
                end
            elseif m.playerIndex == 0 then
                starStealLocalTimer = 0
            end
        end,
    },
    [GAME_MODE_BOMB_TAG] = {
        name = "Bomb Tag",
        desc =
        "Don't hold a Bob-Omb! Tag another player to pass your Bob-Omb to them. If you're holding a Bob-Omb when time runs out... you can probably guess what happens.",
        level = -1, -- selects toad town or koopa keep
        interact = PLAYER_INTERACTIONS_PVP, -- so invulnerability frames exist
        kbStrength = 10,
        roundTime = 30 * 30,                -- 30 seconds
        marioUpdateFunc = function(m)       -- full health, and that's it
            m.health = 0x880
            if m.action == ACT_LAVA_BOOST then
                set_to_spawn_pos(m, true)
                if not gPlayerSyncTable[m.playerIndex].holdingBomb then
                    set_mario_action(m, ACT_GB_FALL, 0)
                    m.freeze = 30
                end
            end
        end,
        toEliminate = 0,           -- so this game uses elimination logic for points
        eliminateFunc = function() -- eliminate all players that are holding a bomb
            local eliminated = 0
            for_each_connected_player(function(i)
                local sMario = gPlayerSyncTable[i]
                if (not sMario.eliminated) and sMario.holdingBomb then
                    eliminated = eliminated + 1
                    eliminate_mario(gMarioStates[i])
                end
            end)
            return eliminated
        end,
        hostUpdateFunc = function() -- assign bombs at start of bomb tag
            if gGlobalSyncTable.roundTimer ~= 1 then return end

            local aliveTable = {}
            for_each_connected_player(function(i)
                local sMario = gPlayerSyncTable[i]
                if not sMario.eliminated then
                    sMario.holdingBomb = false
                    table.insert(aliveTable, i)
                end
            end)
            local bombsToAssign = 1
            if #aliveTable > 2 then
                bombsToAssign = math.random(1, 2)
            end

            -- shuffle table
            for i = #aliveTable, 2, -1 do
                local j = math.random(i)
                aliveTable[i], aliveTable[j] = aliveTable[j], aliveTable[i]
            end
            -- sort table so that the players with the most points will get the bombs
            -- (we still do the shuffle first in case of ties)
            if not gGlobalSyncTable.eliminationMode then
                table.sort(aliveTable, function(a, b)
                    local aPoints = (gPlayerSyncTable[a].points or 0)
                    local bPoints = (gPlayerSyncTable[b].points or 0)
                    return aPoints > bPoints
                end)
            end

            while bombsToAssign ~= 0 and #aliveTable ~= 0 do
                local index = aliveTable[1]
                gPlayerSyncTable[index].holdingBomb = true
                table.remove(aliveTable, 1)
                bombsToAssign = bombsToAssign - 1
            end
        end,
    },
    [GAME_MODE_KOTH] = {
        name = "King Of The Hill",
        desc =
        "Get to the top of the hill! Stand in the circle to increase your score. If your score is too low when time runs out, you'll be eliminated! Stand your ground!",
        level = LEVEL_KOTH,
        interact = PLAYER_INTERACTIONS_PVP, -- so invulnerability frames exist
        kbStrength = 25,
        firstRoundTime = 60 * 30,           -- 1 minute
        roundTime = 30 * 30,                -- 30 seconds
        toEliminate = 0.25,                 -- eliminate 1/4 of players
        marioUpdateFunc = function(m)       -- full health, and that's it
            m.health = 0x880
        end,
    },
    [GAME_MODE_DUEL] = {
        name = "Duel",
        desc =
        "It's a 1v1 (probably)! No gimmicks here- the first person to 2 wins will win this minigame. It's time to LOCK IN.",
        descElim =
        "It's a 1v1 (probably)! No gimmicks here- the first person to get 2 wins, wins it ALL. It's time to LOCK IN.",
        level = LEVEL_DUEL,
        interact = PLAYER_INTERACTIONS_PVP,
        maxTime = -1,        -- NO max time
        roundTime = 63 * 30, -- 1:03 (3 is for the countdown)
        music = "final",
        kbStrength = 25,
        showHealth = true,
        victoryFunc = function(m)
            return false -- prevent elimination end
        end,
        hostUpdateFunc = function()
            if gGlobalSyncTable.duelState == DUEL_STATE_WAIT then
                if gGlobalSyncTable.roundTimer >= 90 or gGlobalSyncTable.round == 1 then
                    gGlobalSyncTable.roundTimer = 90
                    gGlobalSyncTable.duelState = DUEL_STATE_ACTIVE
                end
            elseif gGlobalSyncTable.duelState == DUEL_STATE_ACTIVE then
                -- sudden death bombs
                if gGlobalSyncTable.freezeRoundTimer then
                    duelBombSpawnTimer = duelBombSpawnTimer + 1
                    if duelBombSpawnTimer >= 10 * 30 and duelBombSpawnTimer % duelTimeUntilBomb == 0 then
                        local x, y, z = math.random(-2500, 2500), 2000, math.random(-2500, 2500)
                        spawn_object_no_rotate(id_bhvFallingBomb, E_MODEL_BLACK_BOBOMB, x, y, z, function(o)
                            o.oVelY = -50
                            o.oMoveAngleYaw = math.random(0, 0xFFFF)
                        end, true)
                        if duelTimeUntilBomb > 5 then
                            duelTimeUntilBomb = duelTimeUntilBomb - 1
                        end
                    end
                else
                    duelBombSpawnTimer = 0
                    duelTimeUntilBomb = 30
                end

                local alivePlayers = 0
                local duelers = 0
                local aliveIndex = -1
                for_each_connected_player(function(index)
                    local sMario = gPlayerSyncTable[index]
                    if sMario.validForDuel then
                        duelers = duelers + 1
                        if sMario.victory then
                            -- skip to end
                            duelers = 1
                            alivePlayers = 1
                            aliveIndex = index
                            return true
                        elseif (not sMario.eliminated) then
                            alivePlayers = alivePlayers + 1
                            aliveIndex = index
                            if alivePlayers >= 2 then return true end
                        end
                    end
                end)
                if alivePlayers <= 1 and ((not do_solo_debug()) or alivePlayers <= 0) then
                    gGlobalSyncTable.roundTimer = 0
                    gGlobalSyncTable.round = gGlobalSyncTable.round + 1
                    gGlobalSyncTable.duelState = DUEL_STATE_END
                    if aliveIndex ~= -1 then
                        local sMario = gPlayerSyncTable[aliveIndex]
                        if duelers <= 1 then
                            sMario.roundScore = 2 -- end immediately
                        else
                            sMario.roundScore = sMario.roundScore + 1
                        end
                        if sMario.roundScore >= 2 then
                            sMario.victory = true
                            return true -- end game
                        end
                    end
                end
            elseif gGlobalSyncTable.duelState == DUEL_STATE_END then
                gGlobalSyncTable.freezeRoundTimer = false
                if gGlobalSyncTable.roundTimer >= 150 then
                    gGlobalSyncTable.roundTimer = 0
                    gGlobalSyncTable.duelState = DUEL_STATE_WAIT
                end
            end
            return false -- prevent game end
        end,
        eliminateFunc = function()
            -- when the round ends, the one with greater health wins
            -- on tie, HP is set to 1
            gGlobalSyncTable.round = gGlobalSyncTable.round - 1
            gGlobalSyncTable.freezeRoundTimer = true
            local aliveTable = {}
            local maxHealth = 0xFF
            for_each_connected_player(function(index)
                local sMario = gPlayerSyncTable[index]
                if sMario.validForDuel and not sMario.eliminated then
                    table.insert(aliveTable, index)
                    local health = gMarioStates[index].health
                    if maxHealth < health then
                        maxHealth = health
                    end
                end
            end)
            for i, index in ipairs(aliveTable) do
                local m = gMarioStates[index]
                if m.health < maxHealth then
                    eliminate_mario(m)
                end
            end
            return 0
        end,
        globalUpdateFunc = function()
            local m0 = gMarioStates[0]
            local sMario0 = gPlayerSyncTable[0]
            if gGlobalSyncTable.duelState == DUEL_STATE_WAIT then
                duelEnding = false
                if sMario0.validForDuel then
                    sMario0.eliminated = false
                    m0.health = 0x880
                    if m0.action == ACT_SPECTATE then m0.action = ACT_FREEFALL end
                    set_to_spawn_pos(m0, (duelLastState ~= DUEL_STATE_WAIT))
                end
            end
            duelLastState = gGlobalSyncTable.duelState

            -- slow down time on KO
            local aliveIndex = -1
            local alivePlayers = 0
            local someoneDying = false
            for_each_connected_player(function(index)
                local m = gMarioStates[index]
                local sMario = gPlayerSyncTable[index]
                if (not sMario.eliminated) then
                    if m.health > 0xFF then
                        alivePlayers = alivePlayers + 1
                        aliveIndex = index
                        if alivePlayers >= 2 then return true end
                    else
                        someoneDying = true
                    end
                end
            end)
            if alivePlayers < 2 and someoneDying and m0.area and m0.area.localAreaTimer % 2 == 0 then
                if alivePlayers == 1 then
                    local sMario = gPlayerSyncTable[aliveIndex]
                    duelEnding = (sMario.roundScore >= 1)
                else
                    duelEnding = false
                end
                enable_time_stop_including_mario()
            else
                disable_time_stop()
            end
        end,
        marioUpdateFunc = function(m)
            if m.playerIndex ~= 0 then return end

            local sMario = gPlayerSyncTable[0]
            if not sMario.validForDuel then
                sMario.eliminated = true
                localWasEliminated = true
                return
            end

            -- one health in sudden death
            if m.health > 0x100 and gGlobalSyncTable.freezeRoundTimer then
                m.health = 0x100
            end

            if m.health <= 0xFF and not sMario.eliminated then
                duelDeathTimer = duelDeathTimer + 1
                if duelDeathTimer >= 20 then
                    eliminate_mario(m)
                end
            else
                duelDeathTimer = 0
            end
        end,
    }
}

LEVEL_SPAWN_DATA = {
    [LEVEL_LOBBY] = {
        spawnPos = { x = 0, y = 1000, z = 0 },
        spawnAngle = 0x8000,
        spawnLine = true,
    },
    [LEVEL_GLASS] = {
        spawnPos = { x = 0, y = 1000, z = -8000 },
        spawnAngle = 0,
    },
    [LEVEL_LIGHTS_OUT] = {
        spawnPos = { x = 0, y = 1000, z = 0 },
        spawnDist = 1000,
        spawnAngle = 0x8000,
    },
    [LEVEL_RGLIGHT] = {
        spawnPos = { x = 0, y = 1000, z = 0 },
        spawnAngle = 0x8000,
        spawnLine = true,
    },
    [LEVEL_KOTH] = {
        spawnPos = { x = -2400, y = 1000, z = 1486 },
        spawnAngle = 17698,
    },
    [LEVEL_MINGLE] = {
        spawnPos = { x = 0, y = 500, z = 0 },
        spawnDist = 750,
    },
    [LEVEL_DUEL] = {
        spawnPos = { x = 0, y = 500, z = 0 },
        spawnDist = 2000,
        spawnAngle = 0,
    },
    [LEVEL_TOAD_TOWN] = {
        spawnPos = { x = 0, y = 500, z = 0 },
        spawnDist = 1100,
    },
    [LEVEL_KOOPA_KEEP] = {
        spawnPos = { x = 1210, y = -737, z = -2088 },
        spawnDist = 400,
    },
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
gGlobalSyncTable.gameModeSelection = SELECT_MODE_ALL
gGlobalSyncTable.selectedMode = -1
gGlobalSyncTable.percentToStart = 75
gGlobalSyncTable.forceStart = false
gGlobalSyncTable.allDuel = false
gGlobalSyncTable.gameLevelOverride = -1

gGlobalSyncTable.starStealOwner = 255
gGlobalSyncTable.minglePlayerCount = 1
gGlobalSyncTable.mingleSpinTime = 0
gGlobalSyncTable.mingleHurry = false
gGlobalSyncTable.mingleMaxDoors = 0
gGlobalSyncTable.mingleDoorsOpen = 0
gGlobalSyncTable.duelState = DUEL_STATE_WAIT

starStealLocalTimer = 0
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

    if gGlobalSyncTable.gameMode == GAME_MODE_GLASS then
        -- spawn thwomps for all players
        for i = 0, MAX_PLAYERS - 1 do
            local m = gMarioStates[i]
            spawn_object_no_rotate(id_bhvGBThwomp, E_MODEL_THWOMP, m.pos.x, m.pos.y + 1000, m.pos.z,
                function(o) o.oBehParams = i end, false)
        end
    elseif gGlobalSyncTable.gameMode == GAME_MODE_BOMB_TAG then
        -- spawn visible bombs for all players
        for i = 0, MAX_PLAYERS - 1 do
            local m = gMarioStates[i]
            spawn_object_no_rotate(id_bhvBTBomb, E_MODEL_BLACK_BOBOMB, m.pos.x, m.pos.y + 250, m.pos.z,
                function(o) o.oBehParams = i end, false)
        end
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
        local toEliminate = calculate_players_to_eliminate((not gGlobalSyncTable.eliminationMode), 0.5)

        -- assign each pane its break status
        local glass = obj_get_first_with_behavior_id_and_field_s32(id_bhvGlass, 0x2F, 0)
        -- the amount of panes can't exceed the amount we intend to eliminate plus 2, to ensure elimination games don't end really easily
        local totalPanes = (do_solo_debug() and 3) or (toEliminate + 2)
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
    if (sMario.eliminated or sMario.spectator or (sMario.victory and gGlobalSyncTable.gameMode ~= GAME_MODE_DUEL)) and m.action ~= ACT_SPECTATE then
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
    if network_is_server() and m.playerIndex ~= 0 and rejoin_check[m.playerIndex] and sMario.rejoinID and sMario.rejoinID ~= "-1" then
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
        if (not inMenu) and m.controller.buttonDown == 0 and m.controller.stickX == 0 and m.controller.stickY == 0 then
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
            downVel = math.min((marioPoleTime[m.playerIndex] - 150) // 8, 24)
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
        if sMario.spectator and not sMario.eliminated then
            eliminate_mario(m)
        end
    else
        m.peakHeight = m.pos.y -- disable fall damage
        m.health = 0x880
    end

    -- set description
    if sMario.spectator then
        network_player_set_description(np, "Spectator", 100, 100, 100, 255)
    elseif gGlobalSyncTable.gameState == GAME_STATE_LOBBY then
        if sMario.ready then
            network_player_set_description(np, "Ready!", 80, 255, 80, 255)
        else
            network_player_set_description(np, "Waiting..", 255, 80, 80, 255)
        end
    elseif gGlobalSyncTable.gameState == GAME_STATE_GAME_END then
        if gGlobalSyncTable.eliminationMode then
            if sMario.eliminated then
                network_player_set_description(np, "Dead", 255, 40, 40, 255)
            else
                network_player_set_description(np, "Alive", 80, 255, 80, 255)
            end
        else
            network_player_set_description(np, tostring(sMario.points or 0), 255, 255, 255, 255)
        end
    elseif (gGlobalSyncTable.gameMode == GAME_MODE_DUEL and sMario.validForDuel) then
        if sMario.eliminated then
            network_player_set_description(np, tostring(sMario.roundScore or 0), 255, 80, 80, 255)
        else
            network_player_set_description(np, tostring(sMario.roundScore or 0), 80, 255, 80, 255)
        end
    elseif sMario.eliminated then
        network_player_set_description(np, "Dead", 255, 40, 40, 255)
    elseif (gGlobalSyncTable.gameState ~= GAME_STATE_LOBBY) and gData.toEliminate and gData.toEliminate ~= 0 then
        -- faded red or green based on our placement
        if sMario.roundScore and sMario.roundScore >= storedSafeScore then
            network_player_set_description(np, tostring(sMario.roundScore or 0), 80, 255, 80, 255)
        else
            network_player_set_description(np, tostring(sMario.roundScore or 0), 255, 80, 80, 255)
        end
    elseif gGlobalSyncTable.gameState == GAME_STATE_ACTIVE and gGlobalSyncTable.gameMode == GAME_MODE_BOMB_TAG and sMario.holdingBomb then
        network_player_set_description(np, "Bomb", 255, 255, 80, 255)
    else
        network_player_set_description(np, "Alive", 80, 255, 80, 255)
    end

    if m.playerIndex ~= 0 then
        if gGlobalSyncTable.gameState == GAME_STATE_RULES and m.action ~= ACT_SPECTATE then
            set_to_spawn_pos(m)
        end
        return
    end

    local warpLevel = -1
    if gGlobalSyncTable.gameState == GAME_STATE_LOBBY then
        warpLevel = LEVEL_LOBBY
        gNametagsSettings.showHealth = false
        gServerSettings.playerInteractions = PLAYER_INTERACTIONS_NONE
        sMario.points = 0
        sMario.roundScore = 0
        sMario.earnedPoints = 0
        sMario.eliminated = false
        sMario.roundEliminated = 0
        sMario.holdingBomb = false
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
        if warpLevel == -1 then
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

            gServerSettings.playerInteractions = PLAYER_INTERACTIONS_NONE
        elseif gGlobalSyncTable.gameState == GAME_STATE_ACTIVE then
            gServerSettings.playerInteractions = gData.interact or PLAYER_INTERACTIONS_NONE
            gServerSettings.playerKnockbackStrength = gData.kbStrength or 20
            if gGlobalSyncTable.gameMode == GAME_MODE_MINGLE and gGlobalSyncTable.mingleHurry then
                gServerSettings.playerKnockbackStrength = 20
            end

            gNametagsSettings.showHealth = gData.showHealth or false
            if not (sMario.victory or sMario.eliminated) and gData.victoryFunc and gData.victoryFunc(m) then
                sMario.victory = true
            end
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

        -- dynamic track:
        -- section 1: default
        -- section 2: half are alive
        -- section 3: 2 players left (takes priority over 2)
        if currentMusic == "slider" then
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
                currentMusic = "slider3"
            elseif percentAlive <= 0.5 then
                currentMusic = "slider2"
            end
        end

        -- environment sounds for Red Light, Green Light
        if gGlobalSyncTable.gameMode == GAME_MODE_RED_GREEN_LIGHT and get_target_volume() ~= 0 then
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
        starStealLocalTimer = 0
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
                do_game_mode_selection((gGlobalSyncTable.gameTimer == 150))

                if gGlobalSyncTable.selectedMode ~= -1 then
                    gGlobalSyncTable.gameState = GAME_STATE_RULES

                    gGlobalSyncTable.gameMode = gGlobalSyncTable.selectedMode
                    gGlobalSyncTable.gameTimer = 0
                    gGlobalSyncTable.miniGameNum = 1
                    gGlobalSyncTable.gameWinner = -1
                    gGlobalSyncTable.roundTimer = 0
                    gGlobalSyncTable.eliminateThisRound = calculate_players_to_eliminate()
                    -- pick toad town or koopa keep at random
                    local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode or 0]
                    if gData.level == -1 then
                        if gGlobalSyncTable.gameLevelOverride ~= -1 then
                            gGlobalSyncTable.gameLevel = gGlobalSyncTable.gameLevelOverride
                        else
                            local newLevel = LEVEL_TOAD_TOWN
                            if math.random(0, 1) == 1 then
                                newLevel = LEVEL_KOOPA_KEEP
                            end
                            gGlobalSyncTable.gameLevel = newLevel
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
        for_each_connected_player(function(i)
            local sMario = gPlayerSyncTable[i]
            if not sMario.eliminated then
                alivePlayers = alivePlayers + 1
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
        if (not gData.victoryFunc) and alivePlayers <= 1 and not do_solo_debug() then
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
            if (not gData.victoryFunc) and alivePlayers <= 1 and not do_solo_debug() then
                miniGameEnd = true
            end
            
            -- cut Bomb Tag, Star Steal, and Mingle short in elimination mode if too many players are eliminated
            if (not gData.victoryFunc) and gGlobalSyncTable.eliminationMode then
                local toEliminate, hitMinimum = calculate_players_to_eliminate(false, 1) -- number here is irrelevant, just should be non-zero
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

        local maxTime = gData.maxTime or 5 * 30 * 60 -- default 5 minutes max
        if miniGameEnd or (maxTime ~= -1 and gGlobalSyncTable.gameTimer >= maxTime) then
            gGlobalSyncTable.gameTimer = 0
            gGlobalSyncTable.gameState = GAME_STATE_MINI_END

            if not gGlobalSyncTable.eliminationMode then
                -- calculate scores if we won, or if there is no victory condition and we survived
                for_each_connected_player(function(i)
                    local sMario = gPlayerSyncTable[i]
                    if sMario.points == nil then sMario.points = 0 end
                    if (not sMario.eliminated) and (gData.victoryFunc == nil or sMario.victory) then
                        if gData.pointCalcFunc then
                            sMario.earnedPoints = gData.pointCalcFunc(i) or 0
                        else
                            sMario.earnedPoints = 20
                        end
                    elseif gData.toEliminate and gGlobalSyncTable.round > 1 and sMario.roundEliminated and sMario.roundEliminated >= 1 then
                        sMario.earnedPoints = math.floor(((sMario.roundEliminated - 1) / gGlobalSyncTable.round) * 20) -- points based on total rounds
                    end
                end)
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
                -- set winner to the one who won
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
            local alivePlayers = 3
            local aliveTable = {}
            if gGlobalSyncTable.eliminationMode then
                alivePlayers = 0
                for_each_connected_player(function(i)
                    local sMario = gPlayerSyncTable[i]
                    if not sMario.eliminated then
                        alivePlayers = alivePlayers + 1
                        table.insert(aliveTable, i)
                        --if alivePlayers > 2 then return true end
                    end
                end)
            end

            if (not do_solo_debug()) and alivePlayers <= 1 then
                end_game()
            else
                if gGlobalSyncTable.miniGameNum >= gGlobalSyncTable.maxMiniGames then
                    end_game()
                else
                    -- select new mode
                    if gGlobalSyncTable.finalDuel and ((gGlobalSyncTable.miniGameNum == gGlobalSyncTable.maxMiniGames - 1) or (alivePlayers == 2)) then
                        -- do ending duel
                        gGlobalSyncTable.allDuel = false
                        for i = 0, MAX_PLAYERS - 1 do
                            gPlayerSyncTable[i].validForDuel = false
                        end

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
                                gPlayerSyncTable[index].validForDuel = true
                                table.remove(standings, 1)
                                numValid = numValid + 1
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
                        gGlobalSyncTable.eliminateThisRound = calculate_players_to_eliminate(not gGlobalSyncTable
                        .eliminationMode)
                        gGlobalSyncTable.gameState = GAME_STATE_RULES
                        -- pick toad town or koopa keep at random
                        local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode or 0]
                        if gData.level == -1 then
                            if gGlobalSyncTable.gameLevelOverride ~= -1 then
                                gGlobalSyncTable.gameLevel = gGlobalSyncTable.gameLevelOverride
                            else
                                local newLevel = LEVEL_TOAD_TOWN
                                if math.random(0, 1) == 1 then
                                    newLevel = LEVEL_KOOPA_KEEP
                                end
                                gGlobalSyncTable.gameLevel = newLevel
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
        end
    end
end

hook_event(HOOK_UPDATE, update)

-- eliminate on death if the game is active
function on_death(m)
    if m.playerIndex ~= 0 or gGlobalSyncTable.gameState ~= GAME_STATE_ACTIVE then return false end
    local sMario = gPlayerSyncTable[0]
    if sMario.eliminated then return false end
    eliminate_mario(m)
    gMarioStates[0].health = 0x880
    return false
end

hook_event(HOOK_ON_DEATH, on_death)

-- no act select
function no_act_select(level)
    return false
end

hook_event(HOOK_USE_ACT_SELECT, no_act_select)

-- don't allow interactions with eliminated or spectating players (also prevents interaction while not on the bridge in glass bridge)
function allow_pvp_attack(attacker, victim, interaction)
    local sAttacker = gPlayerSyncTable[attacker.playerIndex]
    local sVictim = gPlayerSyncTable[victim.playerIndex]

    if sAttacker.eliminated or sVictim.eliminated or sAttacker.victory or sVictim.victory then
        return false
    elseif gGlobalSyncTable.gameMode == GAME_MODE_GLASS and (sAttacker.earnedPoints == 0 or sVictim.earnedPoints == 0) then
        return false
    end
end

hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp_attack)

function on_pvp_attack(attacker, victim, interaction)
    if victim.playerIndex ~= 0 or attacker.playerIndex == 0 then return end

    local gIndex = network_global_index_from_local(0)
    if gGlobalSyncTable.gameMode == GAME_MODE_STAR_STEAL then -- steal star
        victim.hurtCounter = 0
        if gGlobalSyncTable.starStealOwner == gIndex then
            gGlobalSyncTable.starStealOwner = network_global_index_from_local(attacker.playerIndex)
            -- send packet to notify about steal
            network_send_include_self(true, {
                id = PACKET_STAR_STEAL,
                oldOwner = gIndex,
                newOwner = gGlobalSyncTable.starStealOwner,
            })
        end
    elseif gGlobalSyncTable.gameMode == GAME_MODE_BOMB_TAG then -- pass bomb
        victim.hurtCounter = 0
        local sVictim = gPlayerSyncTable[victim.playerIndex]
        local sAttacker = gPlayerSyncTable[attacker.playerIndex]
        if sAttacker.holdingBomb and not sVictim.holdingBomb then
            sAttacker.holdingBomb = false
            sVictim.holdingBomb = true
        end
    elseif gGlobalSyncTable.gameMode == GAME_MODE_LIGHTS_OUT then -- points for damage in Lights Out
        network_send_to(attacker.playerIndex, true, {
            id = PACKET_DAMAGE,
            damage = victim.hurtCounter // 4,
        })
    elseif gGlobalSyncTable.gameMode == GAME_MODE_DUEL then
        duelLastAttacker = attacker.playerIndex
    end
end

hook_event(HOOK_ON_PVP_ATTACK, on_pvp_attack)

-- don't display nametags in lights out
function on_nametags_render(index, name)
    if index ~= 0 and gGlobalSyncTable.gameMode == GAME_MODE_LIGHTS_OUT and gMarioStates[0].action ~= ACT_SPECTATE then
        return ""
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
    if gGlobalSyncTable.gameState == GAME_STATE_LOBBY or gGlobalSyncTable.gameState == GAME_STATE_GAME_END then return end

    local sMario = gPlayerSyncTable[m.playerIndex]
    local rejoinID = sMario.rejoinID
    -- prevent cheesing games by leaving
    if (m.floor and m.floor.type == SURFACE_DEATH_PLANE) or (gGlobalSyncTable.gameMode == GAME_MODE_LIGHTS_OUT)
        or (gGlobalSyncTable.gameMode == GAME_MODE_BOMB_TAG and sMario.holdingBomb) then
        sMario.roundScore = 0
        sMario.eliminated = true
    end
    if rejoinID and ((not sMario.eliminated) or sMario.points ~= 0 or sMario.earnedPoints ~= 0 or sMario.roundScore ~= 0) then
        local name = network_get_player_text_color_string(m.playerIndex) .. gNetworkPlayers[m.playerIndex].name
        djui_chat_message_create(name .. "\\#ffff50\\ can rejoin to restore their progress.")
        if not network_is_server() then return end
        table.insert(rejoin_data, {
            id = PACKET_REJOIN,
            rejoinID = rejoinID,
            leftMiniGame = gGlobalSyncTable.miniGameNum,
            leftRound = gGlobalSyncTable.round,
            points = sMario.points or 0,
            earnedPoints = sMario.earnedPoints or 0,
            roundScore = sMario.roundScore or 0,
            eliminated = sMario.eliminated,
            roundEliminated = sMario.roundEliminated or 0,
        })
        sMario.rejoinID = "-1"
    end
    sMario.eliminated = true
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

-- custom action when losing Glass Bridge
---@param m MarioState
function act_gb_fall(m)
    m.actionTimer = m.actionTimer + 1
    play_character_sound_if_no_flag(m, CHAR_SOUND_WAAAOOOW, MARIO_MARIO_SOUND_PLAYED)

    common_air_action_step(m, ACT_HARD_FORWARD_GROUND_KB, CHAR_ANIM_AIRBORNE_ON_STOMACH, AIR_STEP_CHECK_LEDGE_GRAB);
    m.marioObj.header.gfx.angle.x = m.actionTimer * 0x1000 - 0x4000
    m.marioObj.header.gfx.angle.y = m.faceAngle.y + m.actionTimer * 0x800
    m.marioObj.header.gfx.angle.z = m.actionTimer * 0x1200
    return 0
end

ACT_GB_FALL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
hook_mario_action(ACT_GB_FALL, act_gb_fall)

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
    -- only restore certain values if we're on the same mini game we left on
    if gGlobalSyncTable.miniGameNum == data.leftMiniGame and gGlobalSyncTable.gameState ~= GAME_STATE_SCORES then
        sMario.roundScore = data.roundScore or 0
        sMario.earnedPoints = data.earnedPoints or 0
        if gGlobalSyncTable.round == data.leftRound and data.eliminated ~= nil then
            sMario.eliminated = data.eliminated
            sMario.roundEliminated = data.roundEliminated or 0
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

function on_packet_no_moderators(data, self)
    djui_chat_message_create("\\#ffff50\\Since there were no moderators available, the minigame was selected at random.")
end

function on_packet_damage(data, self)
    lightsOutDamageDealt = lightsOutDamageDealt + (data.damage or 0)
end

function on_packet_kill(data, self)
    local np = network_player_from_global_index(data.from)
    if not np then return end
    local name = network_get_player_text_color_string(np.localIndex) .. np.name
    djui_chat_message_create("\\#ffff50\\You killed "..name.."!")
    if not gGlobalSyncTable.freezeRoundTimer then
        gMarioStates[0].healCounter = 31
    end
end

PACKET_STAR_STEAL = 0
PACKET_MINGLE_CALLOUT = 1
PACKET_MINGLE_RESTART = 2
PACKET_REJOIN = 3
PACKET_BLACKOUT = 4
PACKET_MOD_CHOOSE = 5
PACKET_NO_MODERATORS = 6
PACKET_DAMAGE = 7
PACKET_KILL = 8
sPacketTable = {
    [PACKET_STAR_STEAL] = on_packet_star_steal,
    [PACKET_MINGLE_CALLOUT] = on_packet_mingle_callout,
    [PACKET_MINGLE_RESTART] = on_packet_mingle_restart,
    [PACKET_REJOIN] = on_packet_rejoin,
    [PACKET_BLACKOUT] = on_packet_blackout,
    [PACKET_MOD_CHOOSE] = on_packet_mod_choose,
    [PACKET_NO_MODERATORS] = on_packet_no_moderators,
    [PACKET_DAMAGE] = on_packet_damage,
    [PACKET_KILL] = on_packet_kill,
}

function on_packet_receive(data)
    if data.id and sPacketTable[data.id] then
        sPacketTable[data.id](data, false)
    end
end

hook_event(HOOK_ON_PACKET_RECEIVE, on_packet_receive)

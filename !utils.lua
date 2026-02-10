gGlobalSoundSource = {x = 0, y = 0, z = 0}
DEBUG_MODE = _G.cheatsApi -- allows solo testing, and also displays some things in console for Mingle and Glass Bridge

-- spawns an object but sets yaw, pitch, and roll to 0 (since it normally copies Mario's)
function spawn_object_no_rotate(id, model, x, y, z, func, sync)
    local spawnFunc = spawn_non_sync_object
    if sync then
        spawnFunc = spawn_sync_object
    end

    return spawnFunc(id, model, x, y, z, function(o)
        o.oFaceAngleYaw, o.oFaceAnglePitch, o.oFaceAngleRoll = 0, 0, 0
        if func then func(o) end
    end)
end

-- gets the pitch and yaw from the point "from" to the point "to"
function get_angle_between_points(from, to)
    local x = to.x - from.x;
    local y = to.y - from.y;
    local z = to.z - from.z;

    local pitch = atan2s(math.sqrt(x * x + z * z), y);
    local yaw = atan2s(z, x);
    return pitch, yaw
end

-- runs a function for each connected player. If the function returns true, it will stop processing
-- if global is TRUE, it will run in global index order
function for_each_connected_player(func, global)
    if global then
        for g = 0, MAX_PLAYERS - 1 do
            local i = network_local_index_from_global(g)
            if i ~= 255 and (gNetworkPlayers[i].connected) and (not gPlayerSyncTable[i].spectator) and func(i) then break end
        end
        return
    end

    for i = 0, MAX_PLAYERS - 1 do
        if (gNetworkPlayers[i].connected) and (not gPlayerSyncTable[i].spectator) and func(i) then break end
    end
end

-- do solo debug if DEBUG_MODE is true and there aren't any other players
function do_solo_debug()
    return DEBUG_MODE and network_player_connected_count() <= 1
end

-- Converts string into a table using a determiner (but stop splitting after a certain amount)
function split(s, delimiter, limit_)
    local limit = limit_ or 999
    local result = {}
    local finalmatch = ""
    local i = 0
    for match in (s):gmatch(string.format("[^%s]+", delimiter)) do
        --djui_chat_message_create(match)
        i = i + 1
        if i >= limit then
            finalmatch = finalmatch .. match .. delimiter
        else
            table.insert(result, match)
        end
    end
    if i >= limit then
        finalmatch = string.sub(finalmatch, 1, string.len(finalmatch) - string.len(delimiter))
        table.insert(result, finalmatch)
    end
    return result
end

-- adds a string to a table, adding multiple entries if the line goes over
function add_line_to_table(thisTable, line, lengthLimit)
    local lineTooLong = true
    local LIMIT = 100
    local appendColor = ""
    while lineTooLong do
        LIMIT = LIMIT - 1
        if LIMIT <= 0 then break end
        line = appendColor .. line
        local newLine = ""
        local lineOverflow = ""
        local words = split(line, " ")
        lineTooLong = false
        for i, word in ipairs(words) do
            if lineTooLong then
                lineOverflow = lineOverflow .. word
                if i ~= #words then lineOverflow = lineOverflow .. " " end
            else
                local newLineWithWord = newLine .. word
                if djui_hud_measure_text(remove_color(newLineWithWord)) > lengthLimit then
                    lineTooLong = true
                    local dum, dum2
                    dum, appendColor, dum2 = remove_color(newLineWithWord, true)
                    if appendColor == nil then appendColor = "" end
                    -- if word is too long, split the word up
                    if i == 1 or djui_hud_measure_text(remove_color(word)) > lengthLimit then
                        local wordLength = djui_hud_measure_text(remove_color(word))
                        while wordLength > lengthLimit do
                            LIMIT = LIMIT - 1
                            if LIMIT <= 0 then break end
                            lineOverflow = word:sub(-2) .. lineOverflow
                            word = word:sub(1, -2)
                            wordLength = djui_hud_measure_text(remove_color(word))
                        end
                    else
                        lineOverflow = lineOverflow .. word
                    end
                    if i ~= #words then lineOverflow = lineOverflow .. " " end
                else
                    newLine = newLineWithWord
                end
                if i ~= #words then newLine = newLine .. " " end
            end
        end
        line = lineOverflow
        table.insert(thisTable, newLine)
    end
end

-- removes color string
function remove_color(text, get_color)
    local start = text:find("\\")
    local next = 1
    while (next) and (start) do
        start = text:find("\\")
        if start then
            next = text:find("\\", start + 1)
            if not next then
                next = text:len() + 1
            end

            if get_color then
                local color = text:sub(start, next)
                local render = text:sub(1, start - 1)
                text = text:sub(next + 1)
                return text, color, render
            else
                text = text:sub(1, start - 1) .. text:sub(next + 1)
            end
        end
    end
    return text
end

-- stops color text at the limit selected
function cap_color_text(text, limit)
    local slash = false
    local capped_text = ""
    local chars = 0
    local luaPoint = 0
    while luaPoint < text:len() do
        luaPoint = luaPoint + 1
        local char = text:sub(luaPoint, luaPoint)

        -- special characters are treated as multiple by lua: not doing this WILL cause game crashes!
        if string.byte(char) >= 128 then
            local foundEndChar = true
            while string.byte(char, char:len()) >= 128 do
                if luaPoint >= text:len() or char:len() >= 3 then -- 3 is the max, because the japanese characters are 3 lua characters long
                    foundEndChar = false
                    break
                end
                luaPoint = luaPoint + 1
                char = char .. text:sub(luaPoint, luaPoint)
            end
            if foundEndChar then
                luaPoint = luaPoint - 1
                char = char:sub(1, -2)
            end
        end

        if char == "\\" then
            slash = not slash
        elseif not slash then
            chars = chars + 1
            if chars > limit then break end
        end
        capped_text = capped_text .. char
    end
    return capped_text
end

-- converts hex string to RGB values
function convert_color(text)
    if text:sub(2, 2) ~= "#" then
        return nil
    end
    text = text:sub(3, -2)
    local rstring, gstring, bstring = "", "", ""
    if text:len() ~= 3 and text:len() ~= 6 then return 255, 255, 255, 255 end
    if text:len() == 6 then
        rstring = text:sub(1, 2) or "ff"
        gstring = text:sub(3, 4) or "ff"
        bstring = text:sub(5, 6) or "ff"
    else
        rstring = text:sub(1, 1) .. text:sub(1, 1)
        gstring = text:sub(2, 2) .. text:sub(2, 2)
        bstring = text:sub(3, 3) .. text:sub(3, 3)
    end
    local r = tonumber("0x" .. rstring) or 255
    local g = tonumber("0x" .. gstring) or 255
    local b = tonumber("0x" .. bstring) or 255
    return r, g, b, 255 -- alpha is no longer writeable
end

-- prints text on the screen... with color!
function djui_hud_print_text_with_color(text, x, y, scale, alpha)
    djui_hud_set_color(255, 255, 255, alpha or 255)
    local space = 0
    local color = ""
    local render = ""
    text, color, render = remove_color(text, true)
    while render do
        local r, g, b, a = convert_color(color)
        djui_hud_print_text(render, x + space, y, scale);
        if r then djui_hud_set_color(r, g, b, alpha or a) end
        space = space + djui_hud_measure_text(render) * scale
        text, color, render = remove_color(text, true)
    end
    djui_hud_print_text(text, x + space, y, scale);
end

-- prints text on the screen... with color! ... and an outline!
function djui_hud_print_text_with_color_and_outline(text, x, y, scale, alpha, outlineSize_)
    djui_hud_set_color(255, 255, 255, alpha or 255)
    local space = 0
    local color = ""
    local render = ""
    local outlineSize = (outlineSize_ or 1) * scale
    text, color, render = remove_color(text, true)
    while render do
        local r, g, b, a = convert_color(color)
        if render ~= "" then
            local currColor = djui_hud_get_color()
            djui_hud_set_color(0, 0, 0, currColor.a)
            djui_hud_print_text(render, x + space + outlineSize, y, scale);
            djui_hud_print_text(render, x + space - outlineSize, y, scale);
            djui_hud_print_text(render, x + space, y + outlineSize, scale);
            djui_hud_print_text(render, x + space, y - outlineSize, scale);
            djui_hud_set_color(currColor.r, currColor.g, currColor.b, currColor.a)
            djui_hud_print_text(render, x + space, y, scale);
        end
        if r then djui_hud_set_color(r, g, b, alpha or a) end
        space = space + djui_hud_measure_text(render) * scale
        text, color, render = remove_color(text, true)
    end
    local currColor = djui_hud_get_color()
    djui_hud_set_color(0, 0, 0, currColor.a)
    djui_hud_print_text(text, x + space + outlineSize, y, scale);
    djui_hud_print_text(text, x + space - outlineSize, y, scale);
    djui_hud_print_text(text, x + space, y + outlineSize, scale);
    djui_hud_print_text(text, x + space, y - outlineSize, scale);
    djui_hud_set_color(currColor.r, currColor.g, currColor.b, currColor.a)
    djui_hud_print_text(text, x + space, y, scale);
end

-- converts time in frames into a string
function get_time_string(frames)
    if frames < 0 then frames = 0 end
    local seconds = math.ceil(frames / 30)
    local minutes = seconds // 60
    seconds = seconds % 60
    if minutes ~= 0 then
        return string.format("%d:%02d",minutes,seconds)
    end
    return tostring(seconds).."s"
end

--[[
calculates the number of players to eliminated this round, based on:
- The amount of alive players
- The rounds remaining
- If this is elimination mode (ignores game mode eliminatees)
]]
function calculate_players_to_eliminate(ignoreEliminated, forceCalc)
    local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode or 0]
    local hitMinimum = false
    if not (gData.autoElimination or forceCalc) then return 0, false end
    
    local alivePlayers = (do_solo_debug() and MAX_PLAYERS-1) or 0
    local connectedPlayers = alivePlayers
    for_each_connected_player(function(i)
        local sMario = gPlayerSyncTable[i]
        connectedPlayers = connectedPlayers + 1
        if ignoreEliminated or not (sMario.eliminated) then
            alivePlayers = alivePlayers + 1
        end
    end)

    local roundsLeft = 1
    if gData.maxRounds then
        roundsLeft = math.max(gData.maxRounds - gGlobalSyncTable.round + 1, 1)
    end

    local maxToEliminate = (alivePlayers-1)
    if gGlobalSyncTable.eliminationMode then
        -- different calculation for elimination mode
        -- we want to eliminate all but one player by the end of the final minigame, ideally
        local minigamesLeft = (gGlobalSyncTable.maxMiniGames - gGlobalSyncTable.miniGameNum) + 1
        local wantToEliminate = alivePlayers - 1
        -- unless final duel is on, in which case we want to eliminate all but TWO players by the end of the PENULTIMATE minigame.
        -- So the final two can duke it out!
        if gGlobalSyncTable.finalDuel and minigamesLeft > 1 then
            minigamesLeft = minigamesLeft - 1
            wantToEliminate = wantToEliminate - 1
        end
        local eliminateThisGame = wantToEliminate // minigamesLeft -- meaning we want to eliminate this many more players (rounding down)

        -- divide goal by the rounds left to get the amount to eliminate this round (rounding down)
        -- note that the minimum is 1
        maxToEliminate = eliminateThisGame // roundsLeft
    else
        -- progressively eliminate more players over time, always ending with a 1v1
        -- ex: in a 5 round game with 16 players, the elimination numbers will be: 5, 4, 3, 2, 1
        if roundsLeft > 2 then
            local equal = (alivePlayers-1) / roundsLeft
            maxToEliminate = math.floor(equal) + math.ceil(equal) - 1
        elseif roundsLeft > 1 then
            maxToEliminate = (alivePlayers-2)
        end
    end

    if maxToEliminate <= 0 then
        hitMinimum = true
        maxToEliminate = 1
    end
    return maxToEliminate, hitMinimum
end

-- eliminates a player, setting their round eliminated field as well as their eliminated field
-- also sets roundEliminated to their placement if this game uses placement points
function eliminate_mario(m)
    local sMario = gPlayerSyncTable[m.playerIndex]
    if not sMario.eliminated then
        sMario.eliminated = true
        sMario.roundEliminated = gGlobalSyncTable.round

        local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode]
        if gData and gData.doPlacementPoints then
            local highestPlacement = 0
            for_each_connected_player(function(i)
                if i == m.playerIndex then return end
                local sMario2 = gPlayerSyncTable[i]
                if sMario2.eliminated and sMario2.roundEliminated
                and highestPlacement < sMario2.roundEliminated then
                    highestPlacement = sMario2.roundEliminated
                end
            end)
            sMario.roundEliminated = highestPlacement + 1
        end
        
        if m.playerIndex == 0 and gGlobalSyncTable.gameMode == GAME_MODE_DUEL and duelLastAttacker ~= -1 then
            network_send_to(duelLastAttacker, true, {
                id = PACKET_KILL,
                from = network_global_index_from_local(0)
            })
        end
    end
end

-- returns a table with standings sorted from highest score to lowest score,
-- using the specified field as the score (subtracting subField)
function get_standings_table(field, subField)
    local standings = {}
    local teamScore = {}
    for_each_connected_player(function(i)
        local sMario = gPlayerSyncTable[i]
        if (field == "points" or field == "earnedPoints") or (not sMario.eliminated) then
            local score = sMario[field] or 0
            if subField then
                score = score - (sMario[subField] or 0)
            end
            table.insert(standings, {i, score})
            -- use team score for points field
            if field == "points" and sMario.team and sMario.team ~= 0 then
                if teamScore[sMario.team] then
                    teamScore[sMario.team] = teamScore[sMario.team] + score
                else
                    teamScore[sMario.team] = score
                end
            end
        end
    end)

    -- use team score for points field
    if gGlobalSyncTable.teamCount ~= 0 and field == "points" then
        for i,data in ipairs(standings) do
            local sMario = gPlayerSyncTable[data[1]]
            if sMario.team and sMario.team ~= 0 then
                standings[i][2] = teamScore[sMario.team] or 0
            end
        end
    end

    table.sort(standings, function(a,b)
        if a[2] == b[2] then
            local sMarioA = gPlayerSyncTable[a[1]]
            local sMarioB = gPlayerSyncTable[b[1]]
            return (sMarioA.team or 0) < (sMarioB.team or 0)
        end
        return a[2] > b[2]
    end)
    return standings
end

-- returns a table with standings sorted with the field set to TRUE at the top and FALSE and the bottom
-- (or reversed)
function get_standings_table_bool(field, reverse_)
    local reverse = reverse_ or false
    local standings = {}
    for_each_connected_player(function(i)
        local sMario = gPlayerSyncTable[i]
        if (field == "eliminated") or (not sMario.eliminated) then
            local value = sMario[field] or false
            table.insert(standings, {i, value})
        end
    end)
    table.sort(standings, function(a,b)
        if a[2] ~= b[2] then
            return (a[2] == reverse)
        else
            return a[1] > b[1]
        end
    end)
    return standings
end

-- sends a packet and runs its code ourselves as well
function network_send_include_self(reliable, data)
    network_send(reliable, data)
    if data.id and sPacketTable[data.id] then
        sPacketTable[data.id](data, true)
    end
end

-- returns the current value approach the goal value at some rate (50% for going halfway there each time, etc)
function smooth_approach(goal, current, rate)
    local diff = (goal - current)
    local result = goal
    if diff > 1 then
        result = current + math.ceil(diff * rate)
    elseif diff < 1 then
        result = current + math.floor(diff * rate)
    end
    return result
end

-- get place string (1st, 2nd, etc.)
function placeString(num)
    local twoDigit = num % 100
    local oneDigit = num % 10
    if num == 1 then
        return "\\#e3bc2d\\1st"
    elseif num == 2 then
        return "\\#c5d8de\\2nd"
    elseif num == 3 then
        return "\\#b38752\\3rd"
    end

    if twoDigit > 3 and twoDigit < 20 then
        return tostring(num) .. "th"
    elseif oneDigit == 1 then
        return tostring(num) .. "st"
    elseif oneDigit == 2 then
        return tostring(num) .. "nd"
    elseif oneDigit == 3 then
        return tostring(num) .. "rd"
    end
    return tostring(num) .. "th"
end

-- sets player to the spawn position based on the game mode
---@param m MarioState
function set_to_spawn_pos(m, yPos)
    local spawnPos = m.spawnInfo.startPos
    local spawnAngle = 0
    local dist = 200
    local line = false
    
    local spawnData = LEVEL_SPAWN_DATA[gNetworkPlayers[0].currLevelNum]
    if spawnData then
        spawnPos = spawnData.spawnPos or spawnPos
        spawnAngle = spawnData.spawnAngle or spawnAngle
        dist = spawnData.spawnDist or dist
        line = spawnData.spawnLine or false
    end

    local angle = 0
    if m.action ~= ACT_SPECTATE then
        local alivePlayers = 0
        local ourNum = 0
        for_each_connected_player(function(i)
            local sMario2 = gPlayerSyncTable[i]
            if not (gGlobalSyncTable.gameState ~= GAME_STATE_LOBBY and (gGlobalSyncTable.eliminationMode or gGlobalSyncTable.gameMode == GAME_MODE_DUEL) and sMario2.eliminated) then
                alivePlayers = alivePlayers + 1
                if i == m.playerIndex then
                    ourNum = alivePlayers - 1
                end
            end
        end, true)
        if do_solo_debug() then
            ourNum = 15
            alivePlayers = 16
        end
        if not line then
            angle = math.floor((ourNum / alivePlayers) * 0xFFFF) + spawnAngle
        else
            angle = (ourNum % 2 * 0x8000) - 0x4000 + spawnAngle
            dist = ((ourNum + 1) // 2) * dist
        end
    else
        dist = 0
    end

    m.pos.x = spawnPos.x + dist * sins(angle)
    m.pos.z = spawnPos.z + dist * coss(angle)
    if yPos then
        set_mario_action(m, ACT_SPAWN_SPIN_AIRBORNE, 0)
        m.pos.y = spawnPos.y
        m.vel.y = 0
        if line or dist <= 200 then
            m.faceAngle.y = spawnAngle
        else
            m.marioObj.oPosX = m.pos.x
            m.marioObj.oPosZ = m.pos.z
            m.faceAngle.y = obj_angle_to_point(m.marioObj, spawnPos.x, spawnPos.z)
        end
        m.intendedYaw = m.faceAngle.y

        if m.playerIndex == 0 then
            --djui_chat_message_create(tostring(m.faceAngle.y)..":"..tostring(dist))
            reset_camera(m.area.camera)

            -- set camera to behind mario? (this doesn't actually work like, at all. I don't care though)
            gLakituState.pos.x = m.pos.x + sins(m.faceAngle.y + 0x8000) * 2000
            gLakituState.pos.z = m.pos.z + coss(m.faceAngle.y + 0x8000) * 2000
            gLakituState.posHSpeed = 0
            gLakituState.posVSpeed = 0
            vec3f_copy(m.area.camera.pos, gLakituState.pos)
            vec3f_copy(gLakituState.curPos, gLakituState.pos)
            vec3f_copy(gLakituState.goalPos, gLakituState.pos)
            m.area.camera.yaw = m.faceAngle.y + 0x8000
            --center_rom_hack_camera()
        end
    end
end

-- ends the game, setting the winner based on the results if not set already
function end_game()
    gGlobalSyncTable.gameTimer = 0
    gGlobalSyncTable.gameState = GAME_STATE_GAME_END
    if gGlobalSyncTable.gameWinner == -1 then
        local winnerIndex = -1
        if gGlobalSyncTable.eliminationMode then
            for_each_connected_player(function(index)
                local sMario = gPlayerSyncTable[index]
                if (not sMario.eliminated) then
                    if winnerIndex ~= -1 then
                        winnerIndex = -1
                        return true
                    end
                    winnerIndex = index
                end
            end)
        else
            local standings = get_standings_table("points")
            local prevScore = 0
            while #standings ~= 0 do
                local index = standings[1][1]
                local score = standings[1][2]
                if prevScore ~= score then
                    prevScore = score
                    if winnerIndex ~= -1 then
                        break
                    end
                elseif winnerIndex ~= -1 then
                    winnerIndex = -1
                    break
                end
                table.remove(standings, 1)
                winnerIndex = index
            end
        end
        -- game winner will be -1 if there are multiple or zero
        if winnerIndex ~= -1 then
            gGlobalSyncTable.gameWinner = network_global_index_from_local(winnerIndex)
        end
    end
end

-- returns TRUE if we're in the final duel game
function is_final_duel()
    return gGlobalSyncTable.gameMode == GAME_MODE_DUEL and gGlobalSyncTable.finalDuel and gGlobalSyncTable.miniGameNum == gGlobalSyncTable.maxMiniGames and gGlobalSyncTable.gameState ~= GAME_STATE_LOBBY
end

-- returns a table of players that won the entire game; ordered by global index, but each index is local
function get_winners_table()
    local winners = {}
    if gGlobalSyncTable.gameWinner ~= -1 then
        local index = network_local_index_from_global(gGlobalSyncTable.gameWinner)
        local np = gNetworkPlayers[index]
        if np.connected then
            table.insert(winners, index)
            -- also include teammates
            if gGlobalSyncTable.teamCount ~= 0 then
                local sMario = gPlayerSyncTable[index]
                if sMario.team and sMario.team ~= 0 then
                    for_each_connected_player(function(index2)
                        local sMario2 = gPlayerSyncTable[index2]
                        if index ~= index2 and sMario2.team == sMario.team then
                            table.insert(winners, index2)
                        end
                    end, true)
                end
            end
        end
        return winners
    end

    if gGlobalSyncTable.eliminationMode then
        for_each_connected_player(function(index)
            local sMario = gPlayerSyncTable[index]
            if (not sMario.eliminated) then
                table.insert(winners, index)
            end
        end, true)
    else
        local standings = get_standings_table("points")
        local prevScore = 0
        while #standings ~= 0 do
            local index = standings[1][1]
            local score = standings[1][2]
            if prevScore ~= score then
                prevScore = score
                if #winners ~= 0 then
                    break
                end
            end
            table.remove(standings, 1)
            table.insert(winners, index)
        end

        table.sort(winners, function(a, b)
            local gIndexA = network_global_index_from_local(a)
            local gIndexB = network_global_index_from_local(b)
            return gIndexA < gIndexB
        end)
    end

    return winners
end

-- get the score needed to not die this round
function get_safe_score(standings)
    local safeScore = 9990
    local prevScore = 0
    local toEliminate = 0
    -- work backwards
    for i=#standings,1,-1 do
        local data = standings[i]
        local score = data[2]
        if prevScore ~= score then
            prevScore = score
            if toEliminate >= gGlobalSyncTable.eliminateThisRound then
                safeScore = score
                break
            end
        end
        if toEliminate >= gGlobalSyncTable.eliminateThisRound then
            safeScore = score + 1
            break
        end
        toEliminate = toEliminate + 1
    end
    return safeScore
end

-- selects the next game mode
local recentModes = {}
local recentTotal = 0
function do_game_mode_selection(openMenu, doOrder)
    local selectedMode = gGlobalSyncTable.selectedMode
    local maxPick = GAME_MODE_MAX - 2 -- don't pick duel
    local manuallyChose = false
    if gGlobalSyncTable.includeAllDuel then
        maxPick = GAME_MODE_MAX - 1 -- DO pick duel
    end

    -- reset picked
    if gGlobalSyncTable.gameState == GAME_STATE_LOBBY then
        recentModes = {}
        recentTotal = 0
    end

    if (gGlobalSyncTable.gameModeSelection == SELECT_MODE_ORDER or gGlobalSyncTable.gameModeSelection == SELECT_MODE_ALL) and doOrder then
        if gGlobalSyncTable.gameMode == GAME_MODE_DUEL then
            selectedMode = 0 -- the other equation can select Red Light, Green Light, which is unintuitive
        else
            selectedMode = (gGlobalSyncTable.gameMode + 1) % (maxPick + 1)
        end
    elseif gGlobalSyncTable.gameModeSelection == SELECT_MODE_CHOOSE or gGlobalSyncTable.gameModeSelection == SELECT_MODE_ORDER then
        manuallyChose = true
        if openMenu and selectedMode == -1 then
            if gServerSettings.headlessServer == 0 then
                if not inMenu then
                    enter_menu(3)
                end
            else
                local foundMod = false
                for_each_connected_player(function(index)
                    local sMario = gPlayerSyncTable[index]
                    if sMario.isModerator then
                        network_send_to(index, true, {id = PACKET_MOD_CHOOSE})
                        foundMod = true
                        return true
                    end
                end)
                if not foundMod then
                    network_send(true, {id = PACKET_GLOBAL_MSG, text = "\\#ffff50\\Since there were no moderators available, the minigame was selected at random."})
                    selectedMode = math.random(0, maxPick)
                    manuallyChose = false
                    local LIMIT = 100
                    while recentModes[selectedMode] and LIMIT ~= 0 do
                        selectedMode = math.random(0, maxPick)
                        LIMIT = LIMIT - 1
                    end
                end
            end
        end
    elseif gGlobalSyncTable.gameModeSelection == SELECT_MODE_RANDOM then
        selectedMode = math.random(0, maxPick)
        local LIMIT = 100
        while recentModes[selectedMode] and LIMIT ~= 0 do
            selectedMode = math.random(0, maxPick)
            LIMIT = LIMIT - 1
        end
    elseif gGlobalSyncTable.gameModeSelection == SELECT_MODE_ALL then
        selectedMode = 0
        if gGlobalSyncTable.finalDuel or gGlobalSyncTable.includeAllDuel then
            gGlobalSyncTable.maxMiniGames = GAME_MODE_MAX
        else
            gGlobalSyncTable.maxMiniGames = GAME_MODE_MAX - 1 -- account for no duel
        end
    end

    if selectedMode == GAME_MODE_DUEL and not manuallyChose then
        gGlobalSyncTable.allDuel = true
    end
    if selectedMode == GAME_MODE_DUEL and gGlobalSyncTable.allDuel then
        for i=0,MAX_PLAYERS-1 do
            gPlayerSyncTable[i].validForDuel = true
        end
    end
    
    if selectedMode ~= -1 and recentModes[selectedMode] == nil then
        recentModes[selectedMode] = 1
        recentTotal = recentTotal + 1
        -- clear recent modes
        if recentTotal >= maxPick+1 then
            recentModes = {}
            recentModes[selectedMode] = 1
            recentTotal = 1
        end
    end
    gGlobalSyncTable.selectedMode = selectedMode
end

-- toggles spectator mode for the local player
function toggle_spectator()
    local sMario0 = gPlayerSyncTable[0]
    local skipCheck = gGlobalSyncTable.gameState == GAME_STATE_LOBBY
        or (gGlobalSyncTable.gameState ~= GAME_STATE_ACTIVE and not gGlobalSyncTable.eliminationMode)
    sMario0.spectator = not sMario0.spectator
    if sMario0.spectator then
        duelLastAttacker = -1
        eliminate_mario(gMarioStates[0])
        djui_chat_message_create("\\#ffff50\\Entered spectator mode.")
    else
        if (sMario0.team == nil or sMario0.team == 0) then
            sMario0.team = calculate_lowest_member_team()
        end

        if skipCheck then
            djui_chat_message_create("\\#ffff50\\Exited spectator mode.")
        elseif gGlobalSyncTable.eliminationMode and (gGlobalSyncTable.gameMode ~= GAME_MODE_DUEL or not sMario0.validForDuel) then
            djui_chat_message_create("\\#ffff50\\You will exit spectator after this game.")
        elseif gGlobalSyncTable.gameMode == GAME_MODE_DUEL and sMario0.validForDuel then
            if gGlobalSyncTable.duelState == DUEL_STATE_ACTIVE then
                djui_chat_message_create("\\#ffff50\\You will exit spectator after this round.")
            else
                djui_chat_message_create("\\#ffff50\\Exited spectator mode.")
            end
        else
            djui_chat_message_create("\\#ffff50\\You will exit spectator after this minigame.")
        end
    end
end

-- cs support for palettes (copied from Kart Battles)
function network_player_reset_override_palette_custom(np)
    if charSelectExists and charSelect.character_get_current_palette_number and charSelect.character_get_current_palette_number(np.localIndex) ~= 0 then
        -- nothing
    else
        return network_player_reset_override_palette(np)
    end
end

-- used for team colors (copied from Kart Battles)
function set_override_team_colors(np, lightColor, darkColor)
    local m = gMarioStates[np.localIndex]
    network_player_reset_override_palette_part(np, GLOVES)
    network_player_reset_override_palette_part(np, SKIN)
    network_player_reset_override_palette_part(np, SHOES)
    network_player_reset_override_palette_part(np, HAIR)
    network_player_set_override_palette_color(np, EMBLEM, darkColor)
    network_player_set_override_palette_color(np, CAP, lightColor)
    network_player_set_override_palette_color(np, PANTS, darkColor)
    network_player_set_override_palette_color(np, SHIRT, lightColor)
    if m.marioBodyState.modelState & MODEL_STATE_METAL ~= 0 then
        network_player_set_override_palette_color(np, METAL, lightColor)
        return
    end
end

function network_player_reset_override_palette_part(np, part)
    network_player_set_override_palette_color(np, part, network_player_get_palette_color(np, part))
end

-- assigns the specified player to whichever team has the least amount of members (copied from Kart Battles)
function calculate_lowest_member_team(index_)
    local index = index_ or 0 -- excludes this player
    local teamTotal = gGlobalSyncTable.teamCount
    if teamTotal == 0 then return 0 end

    local teamCounts = {}
    local possible = {}
    local minTeamCount = 99
    for i = 1, teamTotal do
        table.insert(teamCounts, 0)
        table.insert(possible, i)
    end

    for_each_connected_player(function(i)
        if i ~= index then
            local team = gPlayerSyncTable[i].team or 0
            if team ~= 0 then
                teamCounts[team] = teamCounts[team] + 1
            end
        end
    end)
    for team, count in pairs(teamCounts) do
        if count < minTeamCount then
            possible = { team }
            minTeamCount = count
        elseif count == minTeamCount then
            table.insert(possible, team)
        end
    end
    return possible[math.random(1, #possible)]
end

-- assign teams based on team selection setting
function do_team_selection()
    local teamTotal = gGlobalSyncTable.teamCount
    if teamTotal == 0 then return end

    local possible = {}
    local teamCount = {}
    for team=1,teamTotal do
        teamCount[team] = 0
        table.insert(possible, team)
    end

    local validList = {}
    local validPlayers = 0
    for_each_connected_player(function(index)
        table.insert(validList, index)
        validPlayers = validPlayers + 1
        -- consider already assigned players
        if gGlobalSyncTable.teamSelection == TEAM_SELECTION_HOST then
            local sMario = gPlayerSyncTable[index]
            if sMario.team and sMario.team ~= 0 and sMario.team <= teamTotal then
                local team = sMario.team
                teamCount[team] = teamCount[team] + 1
                table.remove(validList, #validList)
            end
        end
    end)

    if #validList == 0 then return end

    local perTeam = validPlayers // teamTotal
    local extra = validPlayers % teamTotal
    -- remove teams that already have enough people
    if gGlobalSyncTable.teamSelection == TEAM_SELECTION_HOST then
        for team=1,teamTotal do
            local removeTeam = false
            if teamCount[team] > perTeam then
                removeTeam = true
            elseif teamCount[team] == perTeam then
                if extra == 0 then
                    removeTeam = true
                else
                    extra = extra - 1
                end
            end
            if removeTeam then
                local teamIndex = 0
                for a=1,#possible do
                    if a == team then
                        teamIndex = a
                        break
                    end
                end
                if teamIndex ~= 0 then
                    table.remove(possible, teamIndex)
                end
            end
        end
    end

    if #possible == 0 then return end -- hopefully this should never run

    -- shuffle table
    for i = #validList, 2, -1 do
        local j = math.random(i)
        validList[i], validList[j] = validList[j], validList[i]
    end

    for i,index in ipairs(validList) do
        local sMario = gPlayerSyncTable[index]
        local currTeam = sMario.team or 0
        local teamIndex = 0
        local team = 0
        if gGlobalSyncTable.teamSelection ~= TEAM_SELECTION_PLAYER or currTeam == 0 or currTeam > teamTotal then
            teamIndex = math.random(1, #possible)
            team = possible[teamIndex]
        else
            -- assign based on already chosen team, unless it breaks balance
            team = currTeam
            for a=1,#possible do
                if possible[a] == team then
                    teamIndex = a
                    break
                end
            end
            if teamIndex == 0 then
                teamIndex = math.random(1, #possible)
                team = possible[teamIndex]
            end
        end

        sMario.team = team
        teamCount[team] = teamCount[team] + 1
        if teamCount[team] > perTeam then
            table.remove(possible, teamIndex)
            extra = extra - 1
        elseif teamCount[team] == perTeam and extra == 0 then
            table.remove(possible, teamIndex)
        end

        if #possible == 0 then break end
    end
end

-- adds to the player's roundScore, unless the value is "cap" points ahead of all others, in which case it instead displays a message and does not raise the score
local capNotify = false
function attempt_raise_score(sMario, value_, capValue_)
    local value = value_ or 1
    local capValue = capValue_ or 200
    local newValue = sMario.roundScore + value
    local capScore = false
    local secondLargest = 0
    for_each_connected_player(function(i)
        if i == 0 then return end
        local sMario2 = gPlayerSyncTable[i]
        if sMario2.team ~= 0 and sMario2.team == sMario.team then return end -- ignore same team
        capScore = true -- so we don't cap in single player
        if sMario2.roundScore >= (newValue - capValue) then
            capScore = false
            return true
        elseif sMario2.roundScore > secondLargest then -- second largest is the one who
            secondLargest = sMario2.roundScore
        end
    end)

    if capScore then
        newValue = secondLargest + capValue
        if sMario.roundScore > newValue then
            capValue = sMario.roundScore - secondLargest
        end
        if not capNotify then
            capNotify = true
            capValue = capValue // 10
            djui_chat_message_create("\\#ff5050\\You're ahead by "..capValue.." points! Score capped to keep things fair.")
        end
    else
        capNotify = false
    end

    if sMario.roundScore < newValue then
        sMario.roundScore = newValue
    end
end

-- Spawns an orange number at the given position
function spawn_orange_number_at_pos(num, x, y, z, sync)
    spawn_object_no_rotate(id_bhvOrangeNumber, E_MODEL_NUMBER, x, y, z, function(o)
        o.oBehParams2ndByte = num
        o.oBehParams = (num & 0xFF) << 16;
    end, sync)
end

-- For sonic in extra characters: Sets rings to 10
-- It's a bit silly, but despite taking the index, it will only run
-- if it is set to zero to prevent syncing bugs.
function sonic_set_full_rings(index)
    if (not extraCharsSonic) or index ~= 0 then return end
    extraCharsSonic.set_rings(index, 10)
end

-- For sonic in extra characters: Lose one ring. If we don't have any rings to lose, KILL.
function sonic_lose_one_ring(index_)
    if not extraCharsSonic then return end

    local index = index_ or 0
    local rings = extraCharsSonic.get_rings(index)
    local usingRingHealth = extraCharsSonic.using_ring_health(index)

    if rings > 0 then
        extraCharsSonic.set_rings(index, rings - 1)
    elseif usingRingHealth then
        extraCharsSonic.sonic_set_dead(gMarioStates[index])
        return
    end

    if not usingRingHealth then return end

    extraCharsSonic.drop_ring(index)
end
-- disable everything except camera and health
function behind_hud_render()
    hud_set_value(HUD_DISPLAY_FLAGS,
        HUD_DISPLAY_FLAGS_CAMERA | HUD_DISPLAY_FLAGS_POWER | HUD_DISPLAY_FLAGS_CAMERA_AND_POWER)
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, behind_hud_render)

-- all hud stuff
local scoreMenuTimer = 0
local addPointTimer = 0
local scoreMenuFinal = false
local standingsBarCurrY = {}
local lastCountdownNumber = 0
local countdownTimer = 0
local hudHint = -1
local hud_hints = {
    "Wah-hah! Wario thinks you should punch your opponents to get them out! Show no mercy!",
    "It's a me, Mario! Have you seen the-a gold pot? That must be a lot-a coins! Wowza!",
    "It's me, Toad! Listen, I've played these games before! If you have Elimination Mode active... you'll be gone forever if you're eliminated! The horror! AAAAA!",
    "Hello, I'm Luigi and I'm here to tell you about Choose Mode. The host can choose any game they'd like to play, including setting up 1v1 Duel games. I highly recommend you give the option a chance.",
    "Wah, that big Toad in Red Light, Green Light is a CHEATER! He'll try and fake you out, and will sometimes turn WHILE saying \"Green Light\"! Wah, only I should be allowed to cheat!",
    "Toad again! We're fighting each other with these coins looming above us... it must be a metaphor for something! I just know it!",
    "Wario's favorite game is Glass Bridge! There's NO way to tell which glass pane is safe, even if you've worked in a glass factory! I always wait for someone else to go to see which is the right one, wah ha!",
    "This mod was a collaboration with many people, too many to list in these tips! But most of the programming was done by EmilyEmmi, who is very cool. These tips are not biased, of course.",
    "Wah, they say that not riding the carousel in Mingle is \"cheating\", eh? I'll throw my opponents off and get them in trouble! How's that for cheating, huh?",
    "Star Steal is one of my-a personal favorites! You move slower while holding the Super Star, so you'll need to-a dodge, ha-ha!",
    "It's Toad! I dread playing Bomb Tag... I always get hit at the last second! The players holding Bob-Ombs run faster, so my advice is to try and flank them! Screaming also helps! AAAAA!",
    "Hello, I'm Luigi and I find the minigame \"King Of The Hill\" to be an enjoyable experience. I myself am against fighting though, so I just wait until the coast is clear.",
    "I'ma Wario! Want to crush your enemies in Duel or Lights Out? Use the Ground Pound! It deals BIG damage if you can time it right! Give me a cut of the money though, since I invented it!",
    "Every music track except the one for Mingle was created by murioz! Without her contributions, you'd be listening to Bob-Omb Battlefield over and over...",
    "The lobby, Mingle, Glass Bridge, and Red Light, Green Light maps were created by biobak, who is also working on the upcoming rom hack \"Return To Yoshi's Island\"!",
    "The King Of The Hill, Toad Town, and Koopa Keep maps were created by Woissil on short notice. Whomp's Fortress was used as a debug map, and you could fall off and lose instantly... it was not fun.",
    "The Duels map was created by me, EmilyEmmi. That's why it's so barebones compared to the others...",
    "I'M TOAD AND I HATE LIGHTS OUT! I try to climb the chains to get away, but they're too slippery and I fall and get hurt! OUCH!",
    "Wah, I was looking into Bomb Tag, and I found out that IT'S RIGGED! They always give the Bob-Ombs to the players that have held them for the least amount of time! They must hate winners like me!",
    "Hello, player. Have you noticed that some doors will refuse to open in Mingle? Apparently, less doors are available after the 3rd round. I hope you find this advice useful.",
    "You have to look out for-a more than just players in Star Steal! If you fall into lava, you'll also lose the Star-a! Be careful!",
    "I'ma Wario, and I'ma gonna win Duels with my exclusive info! You can get a full heal if you take out another player. It's the perfect strategy, since I'm the best brawler around!",
    "This mod is brought to you by our (totally legit) sponsors from the Squeex YouTube community! You can see their ads on the monitor in the lobby.",
    "This audio files used to take up 23.7 MB! It took ages to download. After Squishy trimmed and compressed all of the audio, this size was reduced to just over 2.5 MB. Wow...",
}
function on_hud_render()
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_SPECIAL)

    -- reset score menu fields
    if gGlobalSyncTable.gameState ~= GAME_STATE_SCORES then
        scoreMenuTimer = 0
        addPointTimer = 0
        hudHint = -1
        scoreMenuFinal = false
    end

    if inMenu then
        return render_menu()
    end

    -- side bar
    local sideBarLines = {}
    local screenWidth, screenHeight = djui_hud_get_screen_width(), djui_hud_get_screen_height()
    local width = math.floor(screenWidth * 0.2)
    local scale = 0.25
    local lengthLimit = width / scale - 40 * scale
    if gGlobalSyncTable.gameState == GAME_STATE_LOBBY then
        scale = 0.2
        lengthLimit = width / scale - 40 * scale
        for_each_connected_player(function(i)
            local sMario = gPlayerSyncTable[i]
            local addStr = "\\#ff5050\\Waiting..."
            if sMario.ready then
                addStr = "\\#50ff50\\Ready!"
            end
            local name = network_get_player_text_color_string(i) .. gNetworkPlayers[i].name
            name = cap_color_text(name, 18)
            add_line_to_table(sideBarLines, name .. ": " .. addStr, lengthLimit)
        end)
        if gGlobalSyncTable.gameTimer ~= 0 then
            local timeUntilStart = math.max(5 - gGlobalSyncTable.gameTimer // 30, 0)
            add_line_to_table(sideBarLines, "Starting in " .. tostring(timeUntilStart), lengthLimit)
        end
    elseif gGlobalSyncTable.gameState == GAME_STATE_RULES then
        local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode]
        add_line_to_table(sideBarLines, "\\#ffff50\\" .. gData.name, lengthLimit)
        if gGlobalSyncTable.eliminationMode then
            table.insert(sideBarLines, "\\#ff5050\\Elimination Mode")
        end
        table.insert(sideBarLines, "Minigame " .. gGlobalSyncTable.miniGameNum .. "/" .. gGlobalSyncTable.maxMiniGames)
        table.insert(sideBarLines, "")

        local desc = gData.desc
        if (is_final_duel() or gGlobalSyncTable.eliminationMode) then
            if gGlobalSyncTable.teamCount == 0 then
                desc = gData.descElim or desc
            else
                desc = gData.descTeamsElim or desc
            end
        elseif gGlobalSyncTable.teamCount ~= 0 then
            desc = gData.descTeams or desc
        end
        add_line_to_table(sideBarLines, desc, lengthLimit)

        if gGlobalSyncTable.gameTimer > 360 then
            local number = (450 - gGlobalSyncTable.gameTimer) // 30 + 1
            if lastCountdownNumber ~= number then
                lastCountdownNumber = number
                countdownTimer = 0
                play_sound(SOUND_GENERAL2_SWITCH_TICK_FAST, gGlobalSoundSource)
            end
            djui_hud_set_font(FONT_MENU)
            local alpha = 0
            if countdownTimer < 30 then
                alpha = -(255 * math.abs(countdownTimer - 15) // 15) + 255
            end
            local scale = 1
            local width = djui_hud_measure_text(tostring(number)) * scale
            local x = (screenWidth - width) / 2
            local y = screenHeight / 2 - 32 * scale
            djui_hud_set_color(255, 255, 255, alpha)
            djui_hud_print_text(tostring(number), x, y, scale)
            djui_hud_set_font(FONT_SPECIAL)
            countdownTimer = countdownTimer + 1
        else
            lastCountdownNumber = 0
        end
    elseif gGlobalSyncTable.gameState == GAME_STATE_ACTIVE then
        local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode]
        add_line_to_table(sideBarLines, "\\#ffff50\\" .. gData.name, lengthLimit)
        if gGlobalSyncTable.eliminationMode then
            table.insert(sideBarLines, "\\#ff5050\\Elimination Mode")
        end
        
        if gData.roundTime and gGlobalSyncTable.eliminateThisRound ~= 0 then
            if gGlobalSyncTable.eliminateThisRound == 1 then
                add_line_to_table(sideBarLines, "\\#ff5050\\Last place eliminated", lengthLimit)
            else
                add_line_to_table(sideBarLines,
                    "\\#ff5050\\Bottom " .. tostring(gGlobalSyncTable.eliminateThisRound) .. " eliminated", lengthLimit)
            end

            -- display our score and safe score
            local sMario0 = gPlayerSyncTable[0]
            local score = sMario0.roundScore or 0
            local scoreText = "Your score: "
            if sMario0.eliminated and (spectatedPlayer > 0 and spectatedPlayer < MAX_PLAYERS) then
                -- display spectated player's score instead
                score = gPlayerSyncTable[spectatedPlayer].roundScore or 0
                scoreText = "Their score: "
            end
            local scale = 0.25
            local safeScore = get_safe_score(get_standings_table("roundScore"))
            local color = "\\#50ff50\\"
            if safeScore > score then
                color = "\\#ff5050\\"
            end
            local text = string.format(scoreText .. color .. "%.01f", score/10)
            local text2 = string.format("Safe score: %.01f", safeScore/10)
            local width = djui_hud_measure_text(remove_color(text)) * scale
            local width2 = djui_hud_measure_text(remove_color(text2)) * scale
            local maxWidth = math.max(width, width2)
            local x = (screenWidth - maxWidth) / 2
            local y = 10 * scale
            djui_hud_set_color(0, 0, 0, 100)
            djui_hud_render_rect(x - 10 * scale, y - 10 * scale, maxWidth + 20 * scale, 84 * scale)
            x = (screenWidth - width) / 2
            djui_hud_print_text_with_color_and_outline(text, x, y, scale)
            y = y + 32 * scale
            x = (screenWidth - width2) / 2
            djui_hud_print_text_with_color_and_outline(text2, x, y, scale)
        end
        table.insert(sideBarLines, "")

        local roundTime = gData.roundTime or 0
        if gData.firstRoundTime and gGlobalSyncTable.round == 1 then
            roundTime = gData.firstRoundTime
        end
        if gGlobalSyncTable.freezeRoundTimer then
            roundTime = 0
        end
        local maxTime = gData.maxTime or 3 * 30 * 60 -- default 3 minutes max
        if gData.maxRounds and gData.roundTime and gData.roundTime > 0 then
            maxTime = gData.firstRoundTime or gData.roundTime
            maxTime = maxTime + gData.roundTime * (gData.maxRounds-1)
        end

        local gameTimeLeft = maxTime - gGlobalSyncTable.gameTimer
        local roundTimeLeft = roundTime - gGlobalSyncTable.roundTimer
        if maxTime == -1 then
            gameTimeLeft = 99999 -- FOREVER
        end

        ---@type boolean?,boolean?
        local sideBarOverride, sideBarDisable = false, false
        if gData.hudRenderFunc then
            sideBarOverride, sideBarDisable = gData.hudRenderFunc(screenWidth, screenHeight, sideBarLines,
            lengthLimit, roundTime, roundTimeLeft, gameTimeLeft, maxTime)
        end
        if sideBarDisable then
            sideBarLines = {} -- no side bar
        elseif not sideBarOverride then
            if roundTime ~= 0 and gameTimeLeft >= roundTimeLeft then
                add_line_to_table(sideBarLines, get_time_string(roundTimeLeft) .. " until elimination", lengthLimit)
            elseif maxTime ~= -1 then
                add_line_to_table(sideBarLines, get_time_string(gameTimeLeft) .. " until game ends", lengthLimit)
            else
                sideBarLines = {} -- no side bar
            end
        end

        if gMarioStates[0].action == ACT_SPECTATE then
            local scale = 0.2
            local text = "???"
            if spectatedPlayer > 0 and spectatedPlayer < MAX_PLAYERS then
                local np = gNetworkPlayers[spectatedPlayer]
                text = network_get_player_text_color_string(np.localIndex) .. np.name
            end
            text = "< " .. text .. "\\#ffffff\\ >"
            local width = djui_hud_measure_text(remove_color(text)) * scale
            local x = (screenWidth - width) / 2
            local y = screenHeight - 40 * scale
            djui_hud_set_color(0, 0, 0, 100)
            djui_hud_render_rect(x - 10 * scale, y - 10 * scale, width + 20 * scale, 52 * scale)
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_print_text_with_color_and_outline(text, x, y, scale, 255, 2)
        end
    elseif gGlobalSyncTable.gameState == GAME_STATE_MINI_END then
        if is_final_duel() then return end
        local scale = 1
        local text = "\\#ff2828\\No one won..."

        if gGlobalSyncTable.eliminationMode then
            local sMario = gPlayerSyncTable[0]
            if (not sMario.eliminated) then
                text = "\\#50ff50\\YOU SURVIVED"
            elseif sMario.roundEliminated ~= 0 then
                text = "\\#ff2828\\YOU DIED"
            else
                text = ""
            end
        else
            local standings = get_standings_table("earnedPoints")
            local foundWinner = false
            local prevScore = 0
            for i, data in ipairs(standings) do
                local index = data[1]
                if data[2] ~= 0 and ((not foundWinner) or prevScore == data[2]) then
                    prevScore = data[2]
                    if foundWinner then
                        text = "\\#ffff50\\Multiple winners!"
                        break
                    else
                        foundWinner = true
                        text = network_get_player_text_color_string(index) ..
                        gNetworkPlayers[index].name .. "\\#ffff50\\ wins!"
                    end
                elseif foundWinner and prevScore ~= data[2] then
                    break
                end
            end
        end

        if #text ~= 0 then
            local width = djui_hud_measure_text(remove_color(text)) * scale
            local x = (screenWidth - width) / 2
            local y = screenHeight / 2 - 16 * scale
            djui_hud_set_color(0, 0, 0, 100)
            djui_hud_render_rect(x - 10 * scale, y - 10 * scale, width + 20 * scale, 52 * scale)
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_print_text_with_color_and_outline(text, x, y, scale, 255, 2)
        end
    elseif gGlobalSyncTable.gameState == GAME_STATE_SCORES then
        local standings = {}
        local prevPlace = {}
        if gGlobalSyncTable.eliminationMode then
            scoreMenuFinal = true
            standings = get_standings_table_bool("eliminated")
        elseif not scoreMenuFinal then
            standings = get_standings_table("earnedPoints")
        else
            standings = get_standings_table("points")
            if gGlobalSyncTable.miniGameNum > 1 then
                local lastStandings = get_standings_table("points", "earnedPoints")
                local prevScore = 0
                local place = 1
                local newPlace = 0
                local prevTeam = -1
                for i, data in ipairs(lastStandings) do
                    local index = data[1]
                    local sMario = gPlayerSyncTable[index]
                    if sMario.team == nil or sMario.team == 0 or sMario.team ~= prevTeam then
                        newPlace = newPlace + 1
                        prevTeam = sMario.team
                    end
                    if data[2] ~= prevScore then
                        prevScore = data[2]
                        place = newPlace
                    end
                    prevPlace[index] = place
                end
            end
        end
        --djui_hud_set_font(FONT_NORMAL)

        while do_solo_debug() and #standings < MAX_PLAYERS do
            table.insert(standings, { #standings, #standings })
        end

        local scale = 0.2
        local width = screenWidth * 0.5
        local x = 0
        local y = 5
        local leftToEarn = false
        local prevScore = 0
        local place = 1
        local newPlace = 0
        local prevTeam = -1
        for i, data in ipairs(standings) do
            local index = data[1]
            local sMario = gPlayerSyncTable[index]
            local gamePoints = sMario.points or 0
            if not scoreMenuFinal then
                gamePoints = gamePoints - (sMario.earnedPoints or 0)
            elseif (not gGlobalSyncTable.eliminatedMode) and sMario.team and sMario.team ~= 0 then
                gamePoints = data[2]
            end
            local renderY = y
            if standingsBarCurrY[index] and scoreMenuTimer ~= 0 then
                renderY = smooth_approach(renderY, standingsBarCurrY[index], 0.25)
            end
            standingsBarCurrY[index] = renderY

            x = (screenWidth - width) / 2
            if sMario.team == nil or sMario.team == 0 or sMario.team > #TEAM_DATA then
                djui_hud_set_color(0, 0, 0, 100)
            else
                local color = TEAM_DATA[sMario.team][2]
                djui_hud_set_color(color.r, color.g, color.b, 100)
            end
            djui_hud_render_rect(x, renderY - 10 * scale, width, 52 * scale)

            x = x + 20 * scale
            if not gGlobalSyncTable.eliminationMode then
                if sMario.team == nil or sMario.team == 0 or sMario.team ~= prevTeam then
                    newPlace = newPlace + 1
                    prevTeam = sMario.team
                end
                if data[2] ~= prevScore then
                    prevScore = data[2]
                    place = newPlace
                end
                if prevPlace[index] then
                    local progressText = "\\#02fa13\\-"
                    if prevPlace[index] < place then
                        progressText = "\\#025dfa\\v"
                    elseif prevPlace[index] > place then
                        progressText = "\\#fa5102\\^"
                    end
                    djui_hud_print_text_with_color_and_outline(progressText, x, renderY, scale, 255, 2)
                end
                x = x + 30 * scale
                local text = placeString(place)
                djui_hud_print_text_with_color_and_outline(text, x, renderY, scale, 255, 2)
                x = x + 70 * scale
            end

            local np = gNetworkPlayers[index]
            local name = network_get_player_text_color_string(index) .. np.name
            djui_hud_print_text_with_color_and_outline(name, x, renderY, scale, 255, 2)

            local scoreText = ""
            local earned = (sMario.earnedPoints or 0)
            if not gGlobalSyncTable.eliminationMode then
                if (not scoreMenuFinal) and addPointTimer ~= 0 then
                    gamePoints = gamePoints + math.min(addPointTimer, earned)
                end
                earned = earned - addPointTimer
                scoreText = "\\#ffff50\\" .. tostring(gamePoints)
                if scoreMenuFinal and gGlobalSyncTable.teamCount ~= 0 then
                    scoreText = scoreText .. " (" .. tostring(sMario.points) .. ")"
                end
            elseif not data[2] then
                scoreText = "\\#50ff50\\Alive"
            else
                scoreText = "\\#ff2828\\Dead"
            end
            x = (screenWidth + width) / 2 - (djui_hud_measure_text(remove_color(scoreText)) + 20) * scale
            djui_hud_print_text_with_color_and_outline(scoreText, x, renderY, scale, 255, 2)

            if (not scoreMenuFinal) and earned > 0 then
                x = (screenWidth + width) / 2 - 120 * scale
                scoreText = "+" .. tostring(earned)
                leftToEarn = true
                scoreText = "\\#ffff50\\" .. scoreText
                djui_hud_print_text_with_color_and_outline(scoreText, x, renderY, scale, 255, 2)
            end

            y = y + 60 * scale
        end

        scoreMenuTimer = scoreMenuTimer + 1
        if leftToEarn and scoreMenuTimer >= 60 and scoreMenuTimer % 3 == 0 then
            addPointTimer = addPointTimer + 1
            play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
        end
        if (not (leftToEarn or scoreMenuFinal)) and scoreMenuTimer >= 150 then
            scoreMenuFinal = true
            play_sound(SOUND_MENU_STAR_SOUND, gGlobalSoundSource)
        end
        
        if hudHint == -1 then
            hudHint = math.random(1, #hud_hints)
        end
        local text = hud_hints[hudHint]
        local connectionsNeeded = 2
        local validPlayers = 0
        for_each_connected_player(function(index)
            validPlayers = validPlayers + 1
            if validPlayers >= connectionsNeeded then return true end
        end)
        if validPlayers == 0 or not (do_solo_debug() or validPlayers >= connectionsNeeded) then
            text = "Waiting for players..."
        end

        local scale = 0.2
        local lines = {}
        add_line_to_table(lines, text, (screenWidth * 0.8) / scale)
        local y = screenHeight - #lines * 32 * scale
        for i, line in ipairs(lines) do
            local width = djui_hud_measure_text(line) * scale
            local x = (screenWidth - width) / 2
            djui_hud_print_text_with_color_and_outline(line, x, y, scale, 255, 2)
            y = y + 32 * scale
        end
    elseif gGlobalSyncTable.gameState == GAME_STATE_GAME_END then
        local lines = {}
        local winners = get_winners_table()
        local names = {}
        local teamCounted = {}
        for i, index in ipairs(winners) do
            local sMario = gPlayerSyncTable[index]
            if sMario.team == nil or sMario.team == 0 or sMario.team > #TEAM_DATA then
                local text = network_get_player_text_color_string(index) .. gNetworkPlayers[index].name
                table.insert(names, text)
            elseif not teamCounted[sMario.team] then
                teamCounted[sMario.team] = 1
                local text = TEAM_DATA[sMario.team][3]
                table.insert(names, text)
            end
        end

        if #names == 0 then
            table.insert(lines, "\\#ff2828\\No one won...")
        elseif #names == 1 then
            local text = names[1] .. "\\#ffff50\\ wins!"
            table.insert(lines, text)
        else
            table.insert(lines, "\\#ffff50\\Winners:")
            for i, name in ipairs(names) do
                table.insert(lines, name)
            end
        end

        local scale = 0.5
        local y = 20
        for i, line in ipairs(lines) do
            local width = djui_hud_measure_text(remove_color(line)) * scale
            local x = (screenWidth - width) / 2
            djui_hud_set_color(0, 0, 0, 100)
            djui_hud_render_rect(x - 10 * scale, y - 10 * scale, width + 20 * scale, 52 * scale)
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_print_text_with_color_and_outline(line, x, y, scale, 255, 2)
            y = y + 52 * scale
        end
    end

    if #sideBarLines ~= 0 then
        local x = 10 * scale
        local y = (screenHeight / 2) - #sideBarLines * 16 * scale
        djui_hud_set_color(0, 0, 0, 100)
        djui_hud_render_rect(0, y - 10 * scale, width, (#sideBarLines * 32 + 20) * scale)
        for i, line in ipairs(sideBarLines) do
            djui_hud_print_text_with_color_and_outline(line, x, y, scale, 255, 2)
            y = y + 32 * scale
        end
    end
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)

-- radar in Star Steal
local starRadar = { prevX = 0, prevY = 0, prevScale = 0 }
function behind_hud_render()
    if gGlobalSyncTable.gameMode ~= GAME_MODE_STAR_STEAL or gGlobalSyncTable.gameState == GAME_STATE_LOBBY then return end

    local o = obj_get_first_with_behavior_id(id_bhvStealStar)
    if not o then return end

    djui_hud_set_resolution(RESOLUTION_N64)
    local pos = { x = o.oPosX, y = o.oPosY + 20, z = o.oPosZ }
    local out = { x = 0, y = 0, z = 0 }
    djui_hud_world_pos_to_screen_pos(pos, out)

    local dX = out.x
    local dY = out.y
    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    local dist = vec3f_dist(pos, gMarioStates[0].pos)
    local alpha = clamp(dist, 0, 900) - 800
    if alpha <= 0 then
        starRadar.prevX = dX
        starRadar.prevY = dY
        return
    end

    if out.z > -260 then
        local cdist = vec3f_dist(pos, gLakituState.pos)
        if (dist < cdist) then
            dY = 0
        else
            dY = screenHeight
        end
    end

    local tex = gTextures.star
    local scale = (clamp(dist, 0, 2400) / 2000)
    local width = tex.width * scale
    dX = dX - width / 2
    dY = dY - width / 2
    if dX > (screenWidth - width) then
        dX = (screenWidth - width)
    elseif dX < 0 then
        dX = 0
    end
    if dY > (screenHeight - width) then
        dY = (screenHeight - width)
    elseif dY < 0 then
        dY = 0
    end

    djui_hud_set_color(255, 255, 255, alpha)
    djui_hud_render_texture_interpolated(tex, starRadar.prevX, starRadar.prevY, starRadar.prevScale, starRadar.prevScale,
        dX, dY, scale, scale)

    starRadar.prevX = dX
    starRadar.prevY = dY
    starRadar.prevScale = scale
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, behind_hud_render)

-- the menu from geoguessr, which is from shine thief... wow
local teamNameRef = {"Random"}
for i=1,#TEAM_DATA do
    table.insert(teamNameRef, TEAM_DATA[i][3])
end

local menuSelectedMode = -1
function build_game_mode_menu(menu)
    for i = 0, GAME_MODE_MAX - 1 do
        local gData = GAME_MODE_DATA[i]
        table.insert(menu, {
            gData.name,
            function()
                menuSelectedMode = i
                if i == GAME_MODE_DUEL then
                    enter_menu(4)
                    return
                elseif type(gData.level) == "table" then
                    enter_menu(5)
                    return
                end
                gGlobalSyncTable.selectedMode = i
                djui_chat_message_create("Selected \\#ffff50\\" .. gData.name)
                inMenu = false
            end
        })
    end
end

function build_team_select_menu(menu)
    for i=0,MAX_PLAYERS-1 do
        table.insert(menu, {
            gNetworkPlayers[i].name,
            function(x)
                gPlayerSyncTable[i].team = x
            end,
            false,
            function() return (not gNetworkPlayers[i].connected) or gPlayerSyncTable[i].spectator end,
            currNum = gPlayerSyncTable[i].team or 0,
            minNum = 0,
            maxNum = gGlobalSyncTable.teamCount,
            runOnChange = true,
            nameRef = teamNameRef,
        })
    end
end

inMenu = false
local menuOption = 1
local menuID = 1
local stickCooldownX = 0
local stickCooldownY = 0
local cancelTime = 0
local specTime = 0
local frameCounter = 0
local menu_history = {}
-- menu data
menu_data = {
    [1] = {
        {
            "Game Settings",
            function()
                enter_menu(2)
            end,
            true,
        },
        {
            "Select Next Minigame",
            function()
                enter_menu(3)
            end,
            true,
            function()
                return (gGlobalSyncTable.gameState ~= GAME_STATE_LOBBY and gGlobalSyncTable.gameState ~= GAME_STATE_SCORES)
                    or (gGlobalSyncTable.gameModeSelection ~= SELECT_MODE_CHOOSE and (gGlobalSyncTable.gameModeSelection ~= SELECT_MODE_ORDER or gGlobalSyncTable.gameState ~= GAME_STATE_LOBBY))
            end,
        },
        {
            "Force Start Game",
            function()
                gGlobalSyncTable.forceStart = not gGlobalSyncTable.forceStart
                if gGlobalSyncTable.forceStart then
                    local connectionsNeeded = 2
                    local validPlayers = 0
                    for_each_connected_player(function(index)
                        validPlayers = validPlayers + 1
                        if validPlayers >= connectionsNeeded then return true end
                    end)
                    if validPlayers ~= 0 and (do_solo_debug() or validPlayers >= connectionsNeeded) then
                        djui_chat_message_create("\\#ffff50\\Starting the game...")
                    else
                        djui_chat_message_create("\\#ff5050\\Need at least 2 players!")
                        gGlobalSyncTable.forceStart = false
                    end
                else
                    djui_chat_message_create("\\#ff5050\\Canceled forced start.")
                end
            end,
            true,
            function() return (gGlobalSyncTable.gameState ~= GAME_STATE_LOBBY) end,
        },
        {
            "Cancel Game",
            function()
                if cancelTime >= get_time() - 5 then
                    gGlobalSyncTable.gameState = GAME_STATE_LOBBY
                    gGlobalSyncTable.gameTimer = 0
                    if gGlobalSyncTable.teamSelection == TEAM_SELECTION_RANDOM then
                        do_team_selection()
                    end
                    cancelTime = 0
                    inMenu = false
                else
                    djui_chat_message_create("\\#ff5050\\Are you sure? Press A again to continue.")
                    cancelTime = get_time()
                end
            end,
            true,
            function() return (gGlobalSyncTable.gameState == GAME_STATE_LOBBY) end,
        },
        {
            "Team",
            function(x)
                gPlayerSyncTable[0].team = x
            end,
            false,
            function() return not (gGlobalSyncTable.teamCount ~= 0 and gGlobalSyncTable.teamSelection == TEAM_SELECTION_PLAYER and gGlobalSyncTable.gameState == GAME_STATE_LOBBY) end,
            runOnChange = true,
            updateNum = function(button)
                button.maxNum = gGlobalSyncTable.teamCount or 0
                local team = gPlayerSyncTable[0].team or 0
                if team <= button.maxNum then
                    button.currNum = team
                else
                    button.currNum = 0
                end
            end,
            currNum = 0,
            minNum = 0,
            maxNum = 0,
            nameRef = teamNameRef,
        },
        {
            "Open CS Menu",
            function()
                charSelect.set_menu_open(true)
                inMenu = false
            end,
            false,
            function() return (not charSelectExists) end,
        },
        {
            "Spectate",
            function()
                local sMario0 = gPlayerSyncTable[0]
                local skipCheck = gGlobalSyncTable.gameState == GAME_STATE_LOBBY
                or (gGlobalSyncTable.gameState ~= GAME_STATE_ACTIVE and not gGlobalSyncTable.eliminationMode)
                if sMario0.spectator or skipCheck or specTime >= get_time() - 5 then
                    specTime = 0
                    toggle_spectator()
                    inMenu = false
                else
                    djui_chat_message_create("\\#ff5050\\WARNING: This will eliminate you! Press A again to continue.")
                    specTime = get_time()
                end
            end,
            false,
        },
        {
            "Music",
            function(x)
                disableMusic = x
            end,
            false,
            runOnChange = true,
            currNum = 0,
            minNum = 0,
            maxNum = 2,
            nameRef = {"\\#50ff50\\On", "\\#ff5050\\Off", "Mingle Only"},
            save = "disableMusic",
            localSave = true,
        },
        {
            "Exit Menu",
            function()
                inMenu = false
            end,
            false,
        },
    },
    [2] = {
        {
            "Game Mode Selection",
            function(x)
                gGlobalSyncTable.gameModeSelection = x
                gGlobalSyncTable.selectedMode = -1
            end,
            minNum = 0,
            currNum = gGlobalSyncTable.gameModeSelection,
            maxNum = 3,
            runOnChange = true,
            nameRef = { "Choose", "In Order", "Random", "All" },
            save = "gameModeSelection",
        },
        {
            "Include All Player Duel",
            function(x)
                gGlobalSyncTable.includeAllDuel = (x == 1)
            end,
            true,
            function() return (gGlobalSyncTable.gameModeSelection == SELECT_MODE_CHOOSE or gGlobalSyncTable.eliminationMode) end,
            currNum = (gGlobalSyncTable.includeAllDuel and 1) or 0,
            minNum = 0,
            maxNum = 1,
            runOnChange = true,
            nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
            save = "includeAllDuel",
        },
        {
            "Total Minigames",
            function(x)
                gGlobalSyncTable.maxMiniGames = x
            end,
            true,
            function() return gGlobalSyncTable.gameModeSelection == SELECT_MODE_ALL end,
            currNum = gGlobalSyncTable.maxMiniGames,
            maxNum = 99,
            runOnChange = true,
            save = "maxMiniGames",
        },
        {
            "Final Duel",
            function(x)
                gGlobalSyncTable.finalDuel = (x == 1)
            end,
            true,
            function() return (gGlobalSyncTable.gameModeSelection ~= SELECT_MODE_ALL and gGlobalSyncTable.maxMiniGames <= 1) or (gGlobalSyncTable.teamCount == 2 and not gGlobalSyncTable.eliminationMode) end,
            currNum = (gGlobalSyncTable.finalDuel and 1) or 0,
            minNum = 0,
            maxNum = 1,
            runOnChange = true,
            nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
            save = "finalDuel",
        },
        {
            "Elimination Mode",
            function(x)
                gGlobalSyncTable.eliminationMode = (x == 1)
            end,
            currNum = (gGlobalSyncTable.eliminationMode and 1) or 0,
            minNum = 0,
            maxNum = 1,
            runOnChange = true,
            nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
            save = "eliminationMode",
        },
        {
            "Percent Ready to Start",
            function(x)
                gGlobalSyncTable.percentToStart = x
            end,
            true,
            currNum = gGlobalSyncTable.percentToStart,
            minNum = 0,
            maxNum = 100,
            runOnChange = true,
            save = "percentToStart",
        },
        {
            "Teams",
            function(x)
                gGlobalSyncTable.teamCount = x
                if x == 0 then
                    for i=0,MAX_PLAYERS-1 do
                        gPlayerSyncTable[i].team = 0
                    end
                else
                    do_team_selection()
                end
            end,
            true,
            currNum = gGlobalSyncTable.teamCount,
            minNum = 0,
            maxNum = 8,
            excludeNum = 1,
            runOnChange = true,
            nameRef = { "\\#ff5050\\Off" },
            save = "teamCount",
        },
        {
            "Team Selection",
            function(x)
                gGlobalSyncTable.teamSelection = x
                if x == TEAM_SELECTION_RANDOM then
                    do_team_selection()
                end
            end,
            true,
            function()
                return gGlobalSyncTable.teamCount == 0
            end,
            currNum = gGlobalSyncTable.teamSelection,
            minNum = 0,
            maxNum = 2,
            runOnChange = true,
            nameRef = { "Random", "Host\'s Choice", "Players\' Choice" },
            save = "teamSelection",
        },
        {
            "Select Teams...",
            function()
                enter_menu(6)
            end,
            true,
            function()
                return gGlobalSyncTable.teamSelection ~= TEAM_SELECTION_HOST or gGlobalSyncTable.teamCount == 0
            end,
        },
    },
    [3] = { buildFunc = build_game_mode_menu }, -- auto built
    [4] = {
        {
            "Total Duelers",
            function(x)
                local secondToLastOption = menu_data[4][#menu_data[4] - 1]
                local lastOption = menu_data[4][#menu_data[4]]
                for i = 1, x do
                    menu_data[4][i + 1] = {
                        "Dueler " .. i,
                        function()
                            -- do nothing
                        end,
                        playerRef = true,
                        currNum = (menu_data[4][i + 1] and get_menu_option(4, i + 1)) or 0,
                        minNum = 0,
                        maxNum = MAX_PLAYERS - 1,
                    }
                end
                if #menu_data[4] > x + 1 then
                    for i = x + 2, #menu_data[4] do
                        menu_data[4][i] = nil
                    end
                end
                table.insert(menu_data[4], secondToLastOption)
                table.insert(menu_data[4], lastOption)
            end,
            currNum = 2,
            minNum = 2,
            maxNum = MAX_PLAYERS,
            runOnChange = true,
        },
        {
            "Dueler 1",
            function()
                -- do nothing
            end,
            playerRef = true,
            currNum = 0,
            minNum = 0,
            maxNum = MAX_PLAYERS - 1,
        },
        {
            "Dueler 2",
            function()
                -- do nothing
            end,
            playerRef = true,
            currNum = 0,
            minNum = 0,
            maxNum = MAX_PLAYERS - 1,
        },
        {
            "\\#50ff50\\Confirm Duelers",
            function()
                for i = 0, MAX_PLAYERS - 1 do
                    local sMario = gPlayerSyncTable[i]
                    sMario.validForDuel = false
                end
                local duelers = 0
                for i = 2, #menu_data[4] - 2 do
                    local index = get_menu_option(4, i)
                    local sMario = gPlayerSyncTable[index]
                    if not sMario.validForDuel then
                        duelers = duelers + 1
                        sMario.validForDuel = true
                    end
                end
                if do_solo_debug() or duelers >= 2 then
                    gGlobalSyncTable.selectedMode = GAME_MODE_DUEL
                    gGlobalSyncTable.allDuel = false
                    djui_chat_message_create("Selected \\#ffff50\\Duel")
                    inMenu = false
                else
                    djui_chat_message_create("\\#ff5050\\Must have at least 2 duelers!")
                end
            end,
        },
        {
            "\\#ffff50\\All Player Duel",
            function()
                gGlobalSyncTable.selectedMode = GAME_MODE_DUEL
                gGlobalSyncTable.allDuel = true
                djui_chat_message_create("Selected \\#ffff50\\Duel")
                inMenu = false
            end,
        },
    },
    [5] = { -- TODO: auto build with map list
        {
            "Toad Town",
            function()
                gGlobalSyncTable.gameLevelOverride = LEVEL_TOAD_TOWN
                gGlobalSyncTable.selectedMode = menuSelectedMode
                local gData = GAME_MODE_DATA[menuSelectedMode or 0]
                djui_chat_message_create("Selected \\#ffff50\\"..gData.name)
                inMenu = false
            end,
        },
        {
            "Koopa Keep",
            function()
                gGlobalSyncTable.gameLevelOverride = LEVEL_KOOPA_KEEP
                gGlobalSyncTable.selectedMode = menuSelectedMode
                local gData = GAME_MODE_DATA[menuSelectedMode or 0]
                djui_chat_message_create("Selected \\#ffff50\\"..gData.name)
                inMenu = false
            end,
        },
        {
            "Random",
            function()
                gGlobalSyncTable.gameLevelOverride = -1
                gGlobalSyncTable.selectedMode = menuSelectedMode
                local gData = GAME_MODE_DATA[menuSelectedMode or 0]
                djui_chat_message_create("Selected \\#ffff50\\"..gData.name)
                inMenu = false
            end,
        },
    },
    [6] = { buildFunc = build_team_select_menu }, -- auto built
}

-- show the menu
function render_menu()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_NORMAL)

    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    djui_hud_set_color(0, 0, 0, 200)
    djui_hud_render_rect(0, 0, screenWidth + 10, screenHeight + 10)

    local menu = menu_data[menuID]
    if not menu then return end

    -- first, determine menu size
    local scroll = false
    local scale = 2
    local renderButtons = 0
    for i, button in ipairs(menu) do
        if option_valid(button) then
            renderButtons = renderButtons + 1
        end
    end
    local totalButtons = renderButtons
    while (renderButtons * 40 * scale) > screenHeight do
        scroll = true
        renderButtons = renderButtons - 1
    end

    local x = 0
    local y = (screenHeight * 0.5) - (renderButtons * 20 * scale)
    if (renderButtons % 2 == 0) then
        y = y + 10 * scale
    end
    local downBy = 0
    while renderButtons + downBy < totalButtons and menuOption > totalButtons * 0.5 + downBy do
        y = y - 40 * scale
        downBy = downBy + 1
    end

    for i, button in ipairs(menu) do
        local text = button[1]
        if button.currNum then
            local optionText = ""
            if button.playerRef then
                local np = gNetworkPlayers[button.currNum]
                if not np.connected then
                    button.currNum = 0
                    np = gNetworkPlayers[0]
                end
                local playerColor = network_get_player_text_color_string(np.localIndex)
                optionText = playerColor .. np.name
            elseif button.nameRef and button.nameRef[button.currNum - button.minNum + 1] then
                optionText = button.nameRef[button.currNum - button.minNum + 1]
            elseif button.timeRef then
                if button.currNum ~= 0 then
                    local seconds = button.currNum
                    local minutes = seconds // 60
                    seconds = seconds % 60
                    optionText = string.format("%d:%02d", minutes, seconds)
                else
                    optionText = "Infinite"
                end
            else
                optionText = tostring(button.currNum)
                if button.optionPrefix then
                    optionText = button.optionPrefix .. optionText
                end
            end
            text = text .. "\\#5050ff\\  < " .. optionText .. " \\#5050ff\\>"
        end
        local width = djui_hud_measure_text(remove_color(text)) * scale

        x = (screenWidth - width) * 0.5

        if option_valid(button) then
            --djui_hud_set_color(255, 255, 255, 255)
            djui_hud_print_text_with_color(text, x, y, scale)
            if i == menuOption then
                djui_hud_set_color(64, 128, 64, sins(frameCounter * 500) * 50 + 25)
                frameCounter = frameCounter + 1
                if frameCounter >= 60 then frameCounter = 0 end
                djui_hud_render_rect(x - 6, y - 6, width + 12, 36 * scale + 12)
                if button.currNum and (not button.playerRef) and tonumber(button.maxNum) and button.maxNum >= 10 then
                    x = x + width + 20
                    djui_hud_set_color(255, 255, 255, 255)
                    djui_hud_print_text("Hold X to change by 10", x, y+10*scale, scale*0.5)
                end
            end
            y = y + 40 * scale
        end
    end

    if scroll then
        x = screenWidth - 50
        y = 50
        djui_hud_set_color(0, 0, 0, 255)
        djui_hud_render_rect(x, y, 20, screenHeight - 100)
        local portion = renderButtons / totalButtons
        local height = (screenHeight - 104) * portion
        y = y + ((screenHeight - 104) - height) * downBy / (totalButtons - renderButtons)
        djui_hud_set_color(155, 155, 155, 255)
        djui_hud_render_rect(x + 2, y + 2, 16, height)
    end
end

-- menu controls
sMenuInputsPressed = 0
sMenuInputsDown = 0
---@param m MarioState
function menu_controls(m)
    if m.playerIndex ~= 0 then return end
    if not inMenu then
        if m.controller.buttonPressed & START_BUTTON ~= 0 then
            m.controller.buttonPressed = m.controller.buttonPressed & ~START_BUTTON
            sMenuInputsDown = START_BUTTON
            open_menu()
        else
            return
        end
    end

    if m.freeze < 3 then m.freeze = 3 end

    -- Disable controls for everything but the menu
    sMenuInputsPressed = m.controller.buttonDown & (m.controller.buttonDown ~ sMenuInputsDown)
    sMenuInputsDown = m.controller.buttonDown
    m.controller.buttonDown = 0
    m.controller.buttonPressed = 0
    m.controller.stickX = 0
    m.controller.stickY = 0

    if sMenuInputsPressed & R_TRIG ~= 0 then
        djui_open_pause_menu()
    end

    local stickX = m.controller.rawStickX
    if (sMenuInputsDown & L_JPAD) ~= 0 then
        stickX = stickX - 65
    end
    if (sMenuInputsDown & R_JPAD) ~= 0 then
        stickX = stickX + 65
    end
    local stickY = m.controller.rawStickY
    if (sMenuInputsDown & D_JPAD) ~= 0 then
        stickY = stickY - 65
    end
    if (sMenuInputsDown & U_JPAD) ~= 0 then
        stickY = stickY + 65
    end

    if stickCooldownY > 0 then stickCooldownY = stickCooldownY - 1 end
    if stickCooldownX > 0 then stickCooldownX = stickCooldownX - 1 end

    local menu = menu_data[menuID]
    if not menu then
        inMenu = false
        return
    end
    local button = menu[menuOption]

    if (sMenuInputsPressed & A_BUTTON) ~= 0 and button and button[2] and not button.runOnChange then
        if not option_valid(button) then
            play_sound(SOUND_MENU_CAMERA_BUZZ, m.marioObj.header.gfx.cameraToObject)
        else
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
            button[2](button.currNum)
        end
    elseif (sMenuInputsPressed & B_BUTTON) ~= 0 then
        if #menu_history ~= 0 then
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
            enter_menu(menu_history[#menu_history][1], menu_history[#menu_history][2], true)
            table.remove(menu_history, #menu_history)
        else
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
            m.controller.buttonDown = B_BUTTON
            inMenu = false
        end
    elseif (sMenuInputsPressed & START_BUTTON) ~= 0 then
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
        m.controller.buttonDown = START_BUTTON
        inMenu = false
    end

    if not button then return end

    if button.currNum and stickCooldownX == 0 then
        local min = button.minNum or 1
        local max = button.maxNum or 999
        local change = (max - min >= 10 and sMenuInputsDown & X_BUTTON ~= 0 and 10) or 1
        if stickX > 64 then
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            button.currNum = button.currNum + change

            if max < button.currNum then
                button.currNum = min
            elseif button.currNum == button.excludeNum then
                button.currNum = button.currNum + 1
            end

            if button.playerRef then
                local np = gNetworkPlayers[button.currNum]
                while not np.connected do
                    button.currNum = button.currNum + 1
                    if max < button.currNum then
                        button.currNum = min
                    elseif button.currNum == button.excludeNum then
                        button.currNum = button.currNum + 1
                    end
                    np = gNetworkPlayers[button.currNum]
                end
            end

            stickCooldownX = 5
            if button.runOnChange and button[2] then
                button[2](button.currNum)
                if (network_is_server() or button.localSave) and button.save then
                    mod_storage_save(button.save, tostring(button.currNum))
                end
            end
        elseif stickX < -64 then
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            button.currNum = button.currNum - change
            if button.currNum < min then
                button.currNum = max
            elseif button.currNum == button.excludeNum then
                button.currNum = button.currNum - 1
            end

            if button.playerRef then
                local np = gNetworkPlayers[button.currNum]
                while not np.connected do
                    button.currNum = button.currNum - 1
                    if button.currNum < min then
                        button.currNum = max
                    elseif button.currNum == button.excludeNum then
                        button.currNum = button.currNum - 1
                    end
                    np = gNetworkPlayers[button.currNum]
                end
            end

            stickCooldownX = 5
            if button.runOnChange and button[2] then
                button[2](button.currNum)
                if (network_is_server() or button.localSave) and button.save then
                    mod_storage_save(button.save, tostring(button.currNum))
                end
            end
        end
    end

    if #menu > 1 and stickCooldownY == 0 then
        if stickY > 64 then
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            local valid = true
            local LIMIT = #menu
            while valid and LIMIT ~= 0 do
                LIMIT = LIMIT - 1
                menuOption = menuOption - 1
                if menuOption < 1 then
                    menuOption = #menu
                end
                button = menu[menuOption]
                valid = not option_valid(button)
            end
            stickCooldownY = 5
        elseif stickY < -64 then
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            local valid = true
            local LIMIT = #menu
            while valid and LIMIT ~= 0 do
                LIMIT = LIMIT - 1
                menuOption = menuOption + 1
                if #menu < menuOption then
                    menuOption = 1
                end
                button = menu[menuOption]
                valid = not option_valid(button)
            end
            stickCooldownY = 5
        end
    end
end

function open_menu()
    inMenu = not inMenu
    if inMenu then
        menu_history = {}
        sMenuInputsDown = gMarioStates[0].controller.buttonDown
        enter_menu(1, 1, true)
        play_sound(SOUND_MENU_PAUSE, gGlobalSoundSource)
    end
    return true
end

function enter_menu(id, option, back)
    if not back then
        table.insert(menu_history, { menuID, menuOption })
    end

    if not inMenu then
        inMenu = true
        menu_history = {}
        sMenuInputsDown = gMarioStates[0].controller.buttonDown
    end
    menuID = id or 1
    menuOption = option or 1

    -- check for valid options
    local menu = menu_data[menuID]
    if not menu then
        inMenu = false
        return
    elseif menu.buildFunc then
        menu_data[menuID] = { buildFunc = menu.buildFunc }
        menu = menu_data[menuID]
        menu.buildFunc(menu)
    end
    local totalValid = 0
    local lastValidOption = 0
    for i = 1, #menu do
        if option_valid(menu[i]) then
            totalValid = totalValid + 1
            lastValidOption = i
        elseif menuOption == i then
            if lastValidOption == 0 then
                menuOption = menuOption + 1
            else
                menuOption = lastValidOption
            end
        end
    end

    if totalValid == 0 then
        if #menu_history ~= 0 then
            enter_menu(menu_history[#menu_history][1], menu_history[#menu_history][2], true)
            table.remove(menu_history, #menu_history)
        else
            inMenu = false
        end
        return
    end

    for i, button in ipairs(menu) do
        if button.save then
            local value = 0
            if not button.localSave then
                value = gGlobalSyncTable[button.save]
            else
                value = _ENV[button.save]
            end
            if type(value) == "boolean" then
                button.currNum = (value and 1) or 0
            elseif type(value) == "number" and value % 1 == 0 then
                button.currNum = value
            end
        end
        if button.updateNum then
            button.updateNum(button)
        end
    end
end

function set_menu_option(id, option, value)
    menu_data[id][option].currNum = value
end

function get_menu_option(id, option)
    return menu_data[id][option].currNum
end

function option_valid(button)
    if button[3] and not (network_is_server() or network_is_moderator()) then
        return false
    elseif button[4] then
        return (not button[4]())
    end
    return true
end

-- load menu settings; never nesters be crying rn
for a, menu in ipairs(menu_data) do
    for b, button in ipairs(menu) do
        if (network_is_server() or button.localSave) and button.save then
            local value = tonumber(mod_storage_load(button.save))
            local min = button.minNum or 0
            local max = button.maxNum or 999
            if value and value % 1 == 0 and button.currNum and value >= min and value <= max then
                button[2](value)
                button.currNum = value
            end
        end
    end
end
-- CS support
if charSelectExists then
    charSelect.restrict_palettes(false)
end
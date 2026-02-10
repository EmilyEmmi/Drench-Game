-- spectate action
ACT_SPECTATE = ACT_BUBBLED -- replace bubbled action so it doesn't do syncing

spectatedPlayer = 0
local lastDir = 0
local lastDirTime = 0
function act_spectate(m)
    m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE;
    m.health = 0x880
    sonic_set_full_rings(m.playerIndex)
    if m.actionTimer < 15 then
        m.actionTimer = m.actionTimer + 1
    end

    if m.playerIndex ~= 0 then
        m.pos.x, m.pos.y, m.pos.z = 0, -10000, 0
        return
    end

    local sMario = gPlayerSyncTable[0]
    if not (sMario.spectator or sMario.eliminated or sMario.victory) then
        set_to_spawn_pos(m, true)
        return
    end

    -- allow switching; auto switch if our player is invalid
    local specM = gMarioStates[spectatedPlayer]
    local change = 0
    if spectatedPlayer == 0 or is_player_active(specM) == 0 then
        change = 1
        lastDirTime = 15
        m.actionTimer = 15
    elseif m.controller.buttonPressed & L_JPAD ~= 0 or m.controller.stickX < -32 then
        change = -1
    elseif m.controller.buttonPressed & R_JPAD ~= 0 or m.controller.stickX > 32 then
        change = 1
    end
    if m.actionTimer < 15 or (lastDir == change and lastDirTime < 15) then
        change = 0
    else
        lastDir = change
        lastDirTime = 0
    end
    lastDirTime = lastDirTime + 1

    if change ~= 0 then
        -- get first spectatable player after change
        local limit = 0
        while limit < MAX_PLAYERS do
            spectatedPlayer = (spectatedPlayer + change) % MAX_PLAYERS
            limit = limit + 1
            specM = gMarioStates[spectatedPlayer]
            if spectatedPlayer ~= 0 and is_player_active(specM) ~= 0 then
                break
            elseif limit >= MAX_PLAYERS then
                return
            end
        end
    end
    
    -- go to this player's position
    m.pos.x = specM.pos.x
    m.pos.y = specM.pos.y
    m.pos.z = specM.pos.z
end

hook_mario_action(ACT_SPECTATE, act_spectate)
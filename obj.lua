E_MODEL_GLASS = smlua_model_util_get_id("glassPane_geo")
E_MODEL_SCREEN = smlua_model_util_get_id("screen_geo")
E_MODEL_MINGLE_CAROUSEL = smlua_model_util_get_id("carousel_geo")
E_MODEL_LOCK_SWITCH = smlua_model_util_get_id("lockswitch_geo")
E_MODEL_MINGLE_DOOR = smlua_model_util_get_id("mingleDoor_geo")
E_MODEL_KOTH_AREA = smlua_model_util_get_id("kothArea_geo")
E_MODEL_LASER = smlua_model_util_get_id("laser_geo")

---@param o Object
function button_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE

    local hitbox = get_temp_object_hitbox()
    hitbox.interactType = INTERACT_BREAKABLE
    hitbox.height = 97
    hitbox.radius = 75
    obj_set_hitbox(o, hitbox)
end

---@param o Object
function button_loop(o)
    -- prevent interactions while jumping
    local m0 = gMarioStates[0]
    if m0.action & ACT_FLAG_ATTACKING == 0 and obj_check_hitbox_overlap(m0.marioObj, o) then
        o.oIntangibleTimer = 2
    end

    if o.oTimer > 5 and o.oInteractStatus & INT_STATUS_WAS_ATTACKED ~= 0 then
        -- don't interact in ground pound unless we land on top
        if m0.interactObj == o and m0.action ~= ACT_GROUND_POUND and (m0.action ~= ACT_GROUND_POUND_LAND or lateral_dist_between_objects(m0.marioObj, o ) <= 50) then
            cur_obj_play_sound_2(SOUND_GENERAL_MOVING_PLATFORM_SWITCH)
        
            gPlayerSyncTable[0].ready = not gPlayerSyncTable[0].ready
            if gPlayerSyncTable[0].ready then
                djui_chat_message_create("Ready!")
            else
                djui_chat_message_create("Not ready!")
            end
            o.oTimer = 0
        end
    end
    o.oInteractStatus = 0
end

id_bhvButton = hook_behavior(nil, OBJ_LIST_GENACTOR, false, button_init, button_loop, "bhvButton")

---@param o Object
function screen_init(o)
    obj_set_model_extended(o, E_MODEL_SCREEN)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    network_init_object(o, false, {"oAnimState"})
end

---@param o Object
function screen_loop(o)
    if gGlobalSyncTable.gameState ~= GAME_STATE_LOBBY then
        o.oAnimState = 0
        return
    end

    -- switch ad every minute
    if o.oAnimState == 0 or (network_is_server() and o.oTimer >= 60 * 30) then
        o.oTimer = 0
        o.oAnimState = math.random(1, 5)
        if network_is_server() then
            network_send_object(o, false)
        end
    end
end

id_bhvScreen = hook_behavior(nil, OBJ_LIST_LEVEL, false, screen_init, screen_loop, "bhvScreen")

---@param o Object
function mingle_carousel_init(o)
    obj_set_model_extended(o, E_MODEL_MINGLE_CAROUSEL)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_ACTIVE_FROM_AFAR
    o.header.gfx.skipInViewCheck = true
    o.collisionData = smlua_collision_util_get("carousel_collision")
end

---@param o Object
function mingle_carousel_loop(o)
    load_object_collision_model()
    if gGlobalSyncTable.gameState == GAME_STATE_ACTIVE and not gGlobalSyncTable.mingleHurry then
        o.oAngleVelYaw = 0x100
        o.oFaceAngleYaw = o.oFaceAngleYaw + o.oAngleVelYaw
    else
        o.oAngleVelYaw = 0
    end
end

id_bhvMingleCarousel = hook_behavior(nil, OBJ_LIST_SURFACE, false, mingle_carousel_init, mingle_carousel_loop, "bhvMingleCarousel")

---@param o Object
function lock_switch_init(o)
    obj_set_model_extended(o, E_MODEL_LOCK_SWITCH)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.collisionData = gGlobalObjectCollisionData.purple_switch_seg8_collision_0800C7A8
end

---@param o Object
function lock_switch_loop(o)
    load_object_collision_model()

    local anyPlayerOnPlatform = false
    for i=0,MAX_PLAYERS-1 do
        local m = gMarioStates[i]
        if (is_player_active(m) ~= 0) and m.marioObj and m.marioObj.platform == o then
            anyPlayerOnPlatform = true
            break
        end
    end
    
    if o.oAction == 0 then -- unpressed
        cur_obj_scale(1.5)
        local m = nearest_mario_state_to_object(o)
        if m and m.marioObj.platform == o and (m.action & MARIO_UNKNOWN_13 == 0) then
            if (lateral_dist_between_objects(o, m.marioObj) < 127.5) then
                o.oAction = 1
            end
        end
    elseif o.oAction == 1 then -- being pressed
        cur_obj_scale_over_time(2, 3, 1.5, 0.2);
        if (o.oTimer >= 3) then
            cur_obj_play_sound_2(SOUND_GENERAL2_PURPLE_SWITCH)
            o.oAction = 2
            --cur_obj_shake_screen(SHAKE_POS_SMALL);
            queue_rumble_data_object(o, 5, 80);
        end
    elseif o.oAction == 2 then -- pressed
        if not anyPlayerOnPlatform then
            o.oAction = 3
        end
    elseif o.oAction == 3 then -- being unpressed
        cur_obj_scale_over_time(2, 3, 0.2, 1.5);
        if (o.oTimer == 3) then
            o.oAction = 0
        end
    end
end

id_bhvLockSwitch = hook_behavior(nil, OBJ_LIST_SURFACE, false, lock_switch_init, lock_switch_loop, "bhvLockSwitch")

---@param o Object
function mingle_door_init(o)
    obj_set_model_extended(o, E_MODEL_MINGLE_DOOR)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.collisionData = smlua_collision_util_get("mingleDoor_collision")
    o.oAnimState = o.oBehParams2ndByte
    if o.setHome == 0 then
        cur_obj_set_home_once()
        o.oMoveAngleYaw = o.oFaceAngleYaw -- save current yaw into oMoveAngleYaw
    end
end

---@param o Object
function mingle_door_loop(o)
    load_object_collision_model()

    -- find associated switch
    local switch = o.parentObj
    if switch == nil or switch == o then
        switch = obj_get_first_with_behavior_id_and_field_s32(id_bhvLockSwitch, 0x2F, o.oBehParams2ndByte) or o
        o.parentObj = switch
    end

    local shouldBeClosed = (gGlobalSyncTable.gameState ~= GAME_STATE_MINI_END and (gGlobalSyncTable.gameState ~= GAME_STATE_ACTIVE
        or (not gGlobalSyncTable.mingleHurry) or (switch.oAction == 1 or switch.oAction == 2)))
    if (not shouldBeClosed) and gGlobalSyncTable.mingleMaxDoors < 8 then
        -- Interpret the value to determine which doors are open
        local value = gGlobalSyncTable.mingleDoorsOpen
        if ((1 << o.oBehParams2ndByte) & value) == 0 then
            shouldBeClosed = true
        end
    end

    local targetAngle = o.oMoveAngleYaw
    if not shouldBeClosed then
        targetAngle = targetAngle - 0x5000
    end

    local diff = o.oFaceAngleYaw
    o.oFaceAngleYaw = approach_s16_symmetric(o.oFaceAngleYaw, targetAngle, 0x1000)
    diff = (o.oFaceAngleYaw - diff) % 0x10000
    o.oAngleVelYaw = diff
end

id_bhvMingleDoor = hook_behavior(nil, OBJ_LIST_SURFACE, false, mingle_door_init, mingle_door_loop, "bhvMingleDoor")

---@param o Object
function glass_init(o)
    obj_set_model_extended(o, E_MODEL_GLASS)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oDrawingDistance = 10000
    o.collisionData = smlua_collision_util_get("glassPane_collision")

    if o.oSyncID ~= 0 then
        network_init_object(o, false, {"oAction", "activeFlags", "oBobombFuseTimer"})
    end
end

---@param o Object
function glass_loop(o)
    -- metal panes use the other animState
    if o.oBobombFuseTimer == 2 then
        o.oAnimState = 1
    else
        o.oAnimState = 0
    end

    if o.oBobombFuseTimer ~= 0 then
        load_object_collision_model()
        local m0 = gMarioStates[0]
        local sMario0 = gPlayerSyncTable[0]
        if sMario0.earnedPoints == nil then return end
        local newPoints = (o.oBehParams2ndByte*2-sMario0.earnedPoints+2)
        if m0.marioObj and m0.marioObj.platform == o and (not sMario0.eliminated) and newPoints > 0 then
            if newPoints <= 2 then
                -- points are still calculated even in elimination mode because they are used to determine if PVP is allowed
                if not gGlobalSyncTable.eliminationMode then
                    djui_chat_message_create("\\#ffff50\\+"..newPoints.." points")
                    play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
                end
                sMario0.earnedPoints = sMario0.earnedPoints + newPoints
            else
                play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
                djui_chat_message_create("\\#ff5050\\You aren't allowed to skip any glass panes!")
                set_to_spawn_pos(m0, true)
            end
        end
        return
    elseif o.oAction ~= 0 then
        cur_obj_play_sound_2(SOUND_GENERAL_BREAK_BOX)
        spawn_triangle_break_particles(5, 0x8B, 0.5, 0) -- MODEL_CARTOON_STAR
        obj_mark_for_deletion(o)
        return
    end

    --generate_yellow_sparkles(o.oPosX, o.oPosY, o.oPosZ, 200)

    -- break glass if about to land
    local m = nearest_mario_state_to_object(o)
    if m and m.playerIndex == 0 and m.floor and m.floor.object == o and ((m.marioObj and m.marioObj.platform == o) or (m.pos.y + m.vel.y * 2 < o.oPosY)) then
        cur_obj_change_action(1)
        network_send_object(o, true)
    else
        load_object_collision_model()
    end
end

id_bhvGlass = hook_behavior(nil, OBJ_LIST_SURFACE, false, glass_init, glass_loop, "bhvGlass")

-- thwomp that kills players that play cowardly in Glass Bridge. Not a sync object!
---@param o Object
function gb_thwomp_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.collisionData = gGlobalObjectCollisionData.thwomp_seg5_collision_0500B7D0
    cur_obj_disable_rendering()
end

---@param o Object
function gb_thwomp_loop(o)
    if o.oAction == 0 then
        cur_obj_disable_rendering()
        local m = gMarioStates[o.oBehParams]
        if (not m) or is_player_active(m) == 0 or m.action == ACT_GB_FALL or m.health <= 0xFF then
            o.oTimer = 0
            return
        end

        local sMario = gPlayerSyncTable[m.playerIndex]
        local expectedPoints = 0
        if gGlobalSyncTable.gameState == GAME_STATE_ACTIVE then
            -- We expect at least one pane in the first 10 seconds, and then another every 20 seconds
            expectedPoints = ((gGlobalSyncTable.gameTimer + 300) // 600) * 2
        end
        if sMario.eliminated or sMario.victory or (sMario.earnedPoints == nil) or sMario.earnedPoints >= expectedPoints then
            o.oTimer = 0
            m.health = 0x880
            return
        end

        m.health = m.health - 6 -- this generally won't finish before the thwomp shows up
        if o.oTimer == 1 and m.playerIndex == 0 then
            djui_chat_message_create("\\#ff5050\\Keep moving, or there will be consequences...")
        elseif o.oTimer >= 10 * 30 then
            o.oVelY = -150
            o.oPosY = m.pos.y - 15 * o.oVelY -- take 0.5 seconds to reach Mario
            o.oFaceAngleYaw = ((m.area.camera.yaw + 0x2000) % 0x4000) * 0x4000 -- nearest cardinal direction to camera
            cur_obj_change_action(1)
        end
    elseif o.oAction == 1 then
        o.oVelY = -150

        -- eliminate player
        local m = gMarioStates[o.oBehParams]
        local sMario = gPlayerSyncTable[m.playerIndex]
        if m and is_player_active(m) ~= 0 and m.action ~= ACT_SPECTATE and (not sMario.eliminated) then
            o.oPosX, o.oPosZ = m.pos.x, m.pos.z
            if m.playerIndex == 0 and m.pos.y > o.oPosY then
                eliminate_mario(m)
            end
        end

        o.oPosY = o.oPosY + o.oVelY
        cur_obj_update_floor_height()
        if o.oPosY <= o.oFloorHeight then
            o.oVelY = 0
            o.oPosY = o.oFloorHeight
            cur_obj_shake_screen(SHAKE_POS_SMALL)
            cur_obj_play_sound_2(SOUND_OBJ_THWOMP)
            cur_obj_change_action(2)
        end
        load_object_collision_model()
    elseif o.oAction == 2 then
        if o.oTimer > 9 then
            o.oVelY = o.oVelY + 2
            o.oPosY = o.oPosY + o.oVelY
            if o.oVelY >= 60 then
                o.oAction = 0
                cur_obj_disable_rendering()
            end
        else
            o.oVelY = 0
        end

        -- eliminate player
        local m = gMarioStates[o.oBehParams]
        local sMario = gPlayerSyncTable[m.playerIndex]
        if m and is_player_active(m) ~= 0 and m.action ~= ACT_SPECTATE and (not sMario.eliminated) then
            o.oPosX, o.oPosZ = m.pos.x, m.pos.z
            if m.playerIndex == 0 then
                eliminate_mario(m)
            end
        end

        load_object_collision_model()
    end
end

id_bhvGBThwomp = hook_behavior(nil, OBJ_LIST_SURFACE, false, gb_thwomp_init, gb_thwomp_loop, "bhvGBThwomp")

-- intangible explosion effect used for when players are eliminated
---@param o Object
function fake_explosion_init(o)
    o.oFlags = o.oFlags | (OBJ_FLAG_COMPUTE_DIST_TO_MARIO | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)
    obj_set_billboard(o)
    o.oAnimState = -1
    bhv_explosion_init()
end

---@param o Object
function fake_explosion_loop(o)
    cur_obj_become_intangible()
    bhv_explosion_loop()
    o.oAnimState = o.oAnimState + 1
end

id_bhvFakeExplosion = hook_behavior(nil, OBJ_LIST_UNIMPORTANT, false, fake_explosion_init, fake_explosion_loop, "bhvFakeExplosion")

-- Doll for Red Light, Green Light. All syncing is handled by the smallest global ID
---@param o Object
function rg_doll_init(o)
    o.oFlags = o.oFlags | OBJ_FLAG_COMPUTE_DIST_TO_MARIO
    o.oDrawingDistance = 40000 -- always render
    o.oBobombBlinkTimer = math.random(1 * 30, 3 * 30) -- used for turn time (starts at 1-3 seconds)
    o.oBobombFuseTimer = 0 -- used for turn speed
    o.oBobombBuddyCannonStatus = 0 -- used for speed leniency
    o.oOpacity = 255
    o.oAnimations = gObjectAnimations.toad_seg6_anims_0600FB58
    
    local laser = spawn_object_no_rotate(id_bhvDollLaser, E_MODEL_LASER, o.oPosX, o.oPosY, o.oPosZ, nil)
    if laser then laser.parentObj = o end
    
    obj_set_model_extended(o, E_MODEL_TOAD)
    cur_obj_scale(10)
    network_init_object(o, false, {"oTimer", "oAction", "oPrevAction", "oBobombFuseTimer", "oBobombBlinkTimer"})
end

---@param o Object
function rg_doll_loop(o)
    cur_obj_init_animation(4)

    if gGlobalSyncTable.gameState ~= GAME_STATE_ACTIVE then
        o.oAction = 0
        o.oTimer = 2
    end
    
    if DEBUG_MODE then
        local m = gMarioStates[0]
        local spawnPos = m.spawnInfo.startPos
        local spawnData = LEVEL_SPAWN_DATA[gNetworkPlayers[0].currLevelNum]
        if spawnData and spawnData.spawnPos then
            spawnPos = spawnData.spawnPos
        end
        log_to_console(tostring(clamp(math.floor(math.abs((spawnPos.z - m.pos.z) / (spawnPos.z - o.oPosZ)) * 17), 0, 15)))
    end

    local turnSpeed = 0xC00
    local turnSound = "Short"
    if o.oBobombFuseTimer == 1 then
        turnSpeed = 0x800
        turnSound = ""
    elseif o.oBobombFuseTimer == 2 then
        turnSpeed = 0x400
        turnSound = "Long"
    end

    local np = get_network_player_smallest_global()
    local doSync = (np and np.localIndex == 0)
    if o.oAction == 0 then -- facing away
        if o.oTimer == 1 then
            stream_music_fade(1)
            play_stream_sfx("greenLight"..turnSound, gGlobalSoundSource)
        end
        o.oFaceAngleYaw = approach_s16_symmetric(o.oFaceAngleYaw, o.oMoveAngleYaw, turnSpeed)
        o.oBobombBuddyCannonStatus = 0
        
        if doSync and gGlobalSyncTable.gameState == GAME_STATE_ACTIVE and o.oTimer > o.oBobombBlinkTimer then
            -- 33% chance to fake out if fully turned around
            if o.oMoveAngleYaw == o.oFaceAngleYaw and math.random(1, 3) == 1 then
                cur_obj_change_action(2)
            else
                cur_obj_change_action(1)
            end
            o.oBobombBlinkTimer = math.random(2 * 30, 10 * 30) -- 2 to 10 seconds
            o.oBobombFuseTimer = math.random(0, 2) -- which turn speed
            if o.oMoveAngleYaw ~= o.oFaceAngleYaw and o.oBobombFuseTimer == 2 then -- don't do slow turn if not fully turned around
                o.oBobombFuseTimer = 0
            end
            network_send_object(o, true)
        end
    elseif o.oAction == 1 then -- looking
        if o.oTimer == 1 then
            play_stream_sfx("redLight"..turnSound, gGlobalSoundSource)
            stop_green_light_sfx()
        end

        o.oFaceAngleYaw = approach_s16_symmetric(o.oFaceAngleYaw, o.oMoveAngleYaw + 0x8000, turnSpeed)
        -- check for elimination
        if o.oFaceAngleYaw == o.oMoveAngleYaw + 0x8000 then
            stream_music_fade(0)
            local sMario = gPlayerSyncTable[0]
            local m = gMarioStates[0]
            -- some leniency here
            if (not (sMario.eliminated or sMario.victory)) then
                -- allow moving behind walls
                local startPos = {x = o.oPosX, y = o.oPosY + 600, z = o.oPosZ}
                local endPos = {x = m.pos.x, y = (m.pos.y + m.marioObj.hitboxHeight - 40), z = m.pos.z}
                local colData = collision_find_surface_on_ray(startPos.x, startPos.y, startPos.z, endPos.x - startPos.x, endPos.y - startPos.y, endPos.z - startPos.z)
                if colData == nil or colData.surface == nil then
                    o.oBobombBuddyCannonStatus = o.oBobombBuddyCannonStatus + 1
                    if o.oBobombBuddyCannonStatus >= 5 and (m.action & ACT_FLAG_STATIONARY == 0 or m.action & ACT_FLAG_ATTACKING ~= 0) and (math.abs(m.forwardVel) > 2 or math.abs(m.vel.y) > 1) then
                        eliminate_mario(m)
                        -- points based on distance
                        local spawnPos = m.spawnInfo.startPos
                        local spawnData = LEVEL_SPAWN_DATA[gNetworkPlayers[0].currLevelNum]
                        if spawnData and spawnData.spawnPos then
                            spawnPos = spawnData.spawnPos
                        end
                        if m.pos.z >= spawnPos.z then
                            sMario.earnedPoints = 0
                        else
                            local points = math.floor(math.abs((spawnPos.z - m.pos.z) / (spawnPos.z - o.oPosZ)) * 17)
                            if points > 15 then points = 15 end
                            sMario.earnedPoints = points
                        end
                    end
                else
                    o.oBobombBuddyCannonStatus = 0
                end
            end
        end

        if doSync and o.oTimer > o.oBobombBlinkTimer then
            -- 25% chance to turn quickly
            if math.random(1, 4) == 1 then
                o.oBobombBlinkTimer = math.random(15, 30) -- 0.5 to 1 seconds
            else
                o.oBobombBlinkTimer = math.random(2 * 30, 5 * 30) -- 2 to 5 seconds
            end
            o.oBobombFuseTimer = math.random(0, 2) -- which turn speed
            cur_obj_change_action(0)
            network_send_object(o, true)
        end
    elseif o.oAction == 2 then -- fake out
        local targetAngle = o.oMoveAngleYaw + 0x8000
        if o.oTimer >= (0x4000 / turnSpeed) then
            targetAngle = o.oMoveAngleYaw
        end
        o.oFaceAngleYaw = approach_s16_symmetric(o.oFaceAngleYaw, targetAngle, turnSpeed)

        if doSync and o.oFaceAngleYaw == o.oMoveAngleYaw then
            o.oBobombBlinkTimer = math.random(15, 3 * 30) -- 0.5 to 3 seconds
            cur_obj_change_action(0)
            o.oTimer = 2
            network_send_object(o, true)
        end
    end

    -- offset angle right before update so Toad appears to look straight forward
    o.oFaceAngleYaw = o.oFaceAngleYaw - 0x1300
    obj_update_gfx_pos_and_angle(o)
    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x1300
end

function stop_green_light_sfx()
    stop_stream_sfx("sound-light-green")
    stop_stream_sfx("sound-light-green-short")
    stop_stream_sfx("sound-light-green-long")
end

id_bhvRGDoll = hook_behavior(nil, OBJ_LIST_GENACTOR, false, rg_doll_init, rg_doll_loop, "bhvRGDoll")

-- laser showing toad's eyesight in RLGL
function doll_laser_init(o)
    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    cur_obj_disable_rendering()
end

function doll_laser_loop(o)
    local doll = o.parentObj
    -- NOT looking and fully turned around
    if doll.oAction ~= 1 or doll.oFaceAngleYaw ~= doll.oMoveAngleYaw + 0x8000 then
        cur_obj_disable_rendering()
        return
    end
    cur_obj_enable_rendering()

    local m = gMarioStates[0]
    local startPos = {x = doll.oPosX, y = doll.oPosY + 600, z = doll.oPosZ}
    local endPos = {x = m.pos.x, y = (m.pos.y + m.marioObj.hitboxHeight - 40), z = m.pos.z}
    local colData = collision_find_surface_on_ray(startPos.x, startPos.y, startPos.z, endPos.x - startPos.x, endPos.y - startPos.y, endPos.z - startPos.z)
    
    if colData and colData.surface then
        vec3f_copy(endPos, colData.hitPos)
    end

    --startPos.x, startPos.y, startPos.z = m.pos.x, m.pos.y + 500, m.pos.z
    --o.oPosX, o.oPosY, o.oPosZ = endPos.x, endPos.y, endPos.z
    o.oPosX, o.oPosY, o.oPosZ = startPos.x, startPos.y, startPos.z
    local dist = vec3f_dist(startPos, endPos)
    local pitch, yaw = get_angle_between_points(startPos, endPos)
    o.oFaceAngleYaw = yaw
    o.oFaceAnglePitch = -pitch
    obj_scale_xyz(o, 1, 1, dist / 20)
end
id_bhvDollLaser = hook_behavior(nil, OBJ_LIST_UNIMPORTANT, false, doll_laser_init, doll_laser_loop, "bhvDollLaser")

-- stealable star in Star Steal
---@param o Object
function steal_star_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    cur_obj_set_home_once()

    network_init_object(o, false, {'oAction', 'oHomeX', 'oHomeY', 'oHomeZ'})
end

---@param o Object
function steal_star_loop(o)
    if gGlobalSyncTable.gameMode ~= GAME_MODE_STAR_STEAL then
        cur_obj_disable_rendering()
        return
    end

    cur_obj_enable_rendering()
    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x800
    
    if o.oAction == 0 then
        o.oPosX, o.oPosY, o.oPosZ = o.oHomeX, o.oHomeY, o.oHomeZ
        local m = nearest_mario_state_to_object(o)
        if network_is_server() and m and dist_between_objects(m.marioObj, o) <= 200 then
            gGlobalSyncTable.starStealOwner = network_global_index_from_local(m.playerIndex)
            cur_obj_change_action(1)
            network_send_object(o, true)
            -- send packet to notify about grab
            network_send_include_self(true, {
                id = PACKET_STAR_STEAL,
                newOwner = gGlobalSyncTable.starStealOwner,
            })
        end
    elseif o.oAction == 1 then
        local owner = gGlobalSyncTable.starStealOwner or 255
        if owner == 255 then
            if network_is_server() then
                cur_obj_change_action(0)
                network_send_object(o, true)
            end
            return
        end

        local np = network_player_from_global_index(owner)
        if (not (np and np.connected)) or is_player_active(gMarioStates[np.localIndex]) == 0 or gPlayerSyncTable[np.localIndex].eliminated then
            if network_is_server() then
                cur_obj_change_action(0)
                network_send_object(o, true)
            end
            return
        end

        local m = gMarioStates[np.localIndex]
        o.oPosX, o.oPosY, o.oPosZ = m.pos.x, m.pos.y + 250, m.pos.z
    end
end

id_bhvStealStar = hook_behavior(nil, OBJ_LIST_LEVEL, false, steal_star_init, steal_star_loop, "bhvStealStar")

-- bombs that appear above players' heads in Bomb Tag
---@param o Object
function bt_bomb_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oAnimations = gObjectAnimations.bobomb_seg8_anims_0802396C
    cur_obj_disable_rendering()
end

---@param o Object
function bt_bomb_loop(o)
    cur_obj_init_animation(0)
    if gGlobalSyncTable.gameMode ~= GAME_MODE_BOMB_TAG or gGlobalSyncTable.gameState ~= GAME_STATE_ACTIVE
    or o.oBehParams < 0 or o.oBehParams >= MAX_PLAYERS then
        cur_obj_disable_rendering()
        return
    end

    local m = gMarioStates[o.oBehParams]
    local sMario = gPlayerSyncTable[o.oBehParams]
    if is_player_active(m) == 0 or (not sMario.holdingBomb) or sMario.eliminated then
        cur_obj_disable_rendering()
        return
    end

    if o.header.gfx.node.flags & GRAPH_RENDER_ACTIVE == 0 then
        cur_obj_enable_rendering()
        cur_obj_play_sound_1(SOUND_AIR_BOBOMB_LIT_FUSE)
    end
    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x400
    o.oPosX, o.oPosY, o.oPosZ = m.pos.x, m.pos.y + 250, m.pos.z

    -- play fuse sound and spawn smoke when close to exploding
    local gData = GAME_MODE_DATA[GAME_MODE_BOMB_TAG]
    local roundTime = gData.roundTime or 0
    if gData.firstRoundTime and gGlobalSyncTable.round == 1 then
        roundTime = gData.firstRoundTime
    end
    local roundTimeLeft = roundTime - gGlobalSyncTable.roundTimer
    if roundTimeLeft <= 150 then
        if 7 & o.oTimer ~= 0 then
            spawn_object_no_rotate(id_bhvBobombFuseSmoke, E_MODEL_SMOKE, o.oPosX, o.oPosY, o.oPosZ, nil, false)
        end
        cur_obj_play_sound_1(SOUND_AIR_BOBOMB_LIT_FUSE)
    end
end

id_bhvBTBomb = hook_behavior(nil, OBJ_LIST_GENACTOR, false, bt_bomb_init, bt_bomb_loop, "bhvBTBomb")

-- area that grants points in king of the hill
---@param o Object
function koth_area_init(o)
    obj_set_model_extended(o, E_MODEL_KOTH_AREA)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.header.gfx.skipInViewCheck = true
end

---@param o Object
function koth_area_loop(o)
    if gGlobalSyncTable.gameMode ~= GAME_MODE_KOTH then
        cur_obj_disable_rendering()
        o.oTimer = 0
        return
    end

    cur_obj_enable_rendering()
    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x100
    if gGlobalSyncTable.gameState ~= GAME_STATE_ACTIVE then
        o.oAnimState = 0
        o.oTimer = 0
        return
    end

    local inside = false
    local m = gMarioStates[0]
    if (is_player_active(m) ~= 0) and m.marioObj and m.pos.y >= o.oPosY and lateral_dist_between_objects(m.marioObj, o) < 500 then
        inside = true
    end

    if not inside then
        o.oAnimState = 0
        o.oTimer = 0
    else
        o.oAnimState = 1

        if o.oTimer >= 3 then
            local sMario = gPlayerSyncTable[0]
            attempt_raise_score(sMario)
            o.oTimer = 0
        end
    end
end

id_bhvKothArea = hook_behavior(nil, OBJ_LIST_GENACTOR, false, koth_area_init, koth_area_loop, "bhvKothArea")

-- non-collideable coins used for the ending sequence
---@param o Object
function effect_coin_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oMoveAngleYaw = math.random(0, 0xFFFF)
    o.oForwardVel = 2
    o.oVelY = -10
    o.oWallHitboxRadius, o.oGravity, o.oBounciness, o.oDragStrength, o.oFriction, o.oBuoyancy = 30, -4, -0.7, 10, 10, 2
    obj_set_billboard(o)
    cur_obj_scale(0.5)
end

---@param o Object
function effect_coin_loop(o)
    o.oIntangibleTimer = -1
    bhv_coin_loop()
    o.oAnimState = o.oAnimState + 1
    if o.oTimer >= 200 then obj_mark_for_deletion(o) end
end
id_bhvEffectCoin = hook_behavior(nil, OBJ_LIST_UNIMPORTANT, false, effect_coin_init, effect_coin_loop)

-- falling bombs in Duel sudden death
---@param o Object
function falling_bomb_init(o)
    o.oAnimations = gObjectAnimations.bobomb_seg8_anims_0802396C
    o.oFlags = OBJ_FLAG_SET_FACE_YAW_TO_MOVE_YAW | OBJ_FLAG_COMPUTE_DIST_TO_MARIO | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oGravity = 2.5
    o.oFriction = 0.8
    o.oBuoyancy = 1.3
    o.oIntangibleTimer = 0
    o.oDamageOrCoinValue = 2
    o.hitboxRadius = 67
    o.hitboxHeight = 113
    o.oInteractType = INTERACT_DAMAGE
    network_init_object(o, true, {})
end

---@param o Object
function falling_bomb_loop(o)
    if o.oAction == 0 then
        cur_obj_init_animation(1)
        local collisionFlags = object_step();
        if ((collisionFlags & OBJ_COL_FLAG_GROUNDED) ~= 0) then
            cur_obj_change_action(1)
            o.oAnimState = 0
        end
    elseif o.oAction == 1 then
        if o.hitboxRadius == 67 then
            o.hitboxRadius, o.hitboxHeight, o.hitboxDownOffset = 300, 300, 300
            bhv_explosion_init()
            obj_set_billboard(o)
        end
        obj_set_model_extended(o, E_MODEL_EXPLOSION)
        bhv_explosion_loop()
        cur_obj_scale(o.oTimer / 4.5 + 2)
        o.oAnimState = o.oAnimState + 1
    end
end
id_bhvFallingBomb = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, false, falling_bomb_init, falling_bomb_loop)

-- lets you make poles longer than 2550 units tall (needed for dark lobby)
function custom_pole_init(o)
    local tenthHitboxHeight = o.oBehParams >> 0x10
    o.hitboxHeight = tenthHitboxHeight * 10
end
hook_behavior(id_bhvPoleGrabbing, OBJ_LIST_POLELIKE, false, custom_pole_init, nil, nil)
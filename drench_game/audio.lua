-- Inconsistent file types are mainly because I used whichever type was smallest
-- (some music also only existed as mp3)
local musicData = {
    lobby = {audio = audio_stream_load("lobby.ogg"), loop = true},
    dire = {audio = audio_stream_load("dire.ogg"), loop = true, loopStart = 2188700, loopEnd = 6789957},
    scores = {audio = audio_stream_load("scores.mp3"), loop = true},
    mingle = {audio = audio_stream_load("mingle.mp3")},
    final = {audio = audio_stream_load("final.mp3"), loop = true, loopStart = 1616135, loopEnd = 7158082},
    slider = {audio = audio_stream_load("sliderMadness.ogg"), loop = true}, -- TODO: this is meant to be dynamic
    -- finalOutro = {audio = audio_stream_load("finalOutro.mp3")}, -- TODO: implement
}

local soundData = {
    redLight = audio_sample_load("redLight.mp3"),
    redLightShort = audio_sample_load("redLightShort.ogg"),
    redLightLong = audio_sample_load("redLightLong.ogg"),
    greenLight = audio_sample_load("greenLight.ogg"),
    greenLightShort = audio_sample_load("greenLightShort.ogg"),
    greenLightLong = audio_sample_load("greenLightLong.ogg"),
    playerCallout1 = audio_sample_load("playerCallout1.mp3"),
    playerCallout2 = audio_sample_load("playerCallout2.ogg"),
    playerCallout3 = audio_sample_load("playerCallout3.ogg"),
    playerCallout4 = audio_sample_load("playerCallout4.mp3"),
}

-- set current streamed music and update volume
local currentMusic = ""
local musicVolume = 1
local targetVolume = 1
local musicFrequency = 1
local musicPaused = false
local pausePoint = 0
function update_music(music)
    if gServerSettings.headlessServer ~= 0 and network_is_server() then return end -- don't do this for headless

    -- update currently played music
    if currentMusic ~= music then
        -- stop current music
        if currentMusic ~= "" then
            local prevMusic = musicData[currentMusic]
            audio_stream_stop(prevMusic.audio)
            --audio_stream_set_looping(prevMusic.audio, false)
            --audio_stream_set_loop_points(prevMusic.audio, 0, 0)
        end
        
        musicVolume = 1
        targetVolume = 1
        musicFrequency = 1
        musicPaused = false
        currentMusic = music

        if music == "" then return end
        local thisMusic = musicData[music]
        if not thisMusic then
            log_to_console("Could not find music: "..music)
            currentMusic = ""
            return
        end
        
        audio_stream_set_volume(thisMusic.audio, musicVolume)
        audio_stream_set_frequency(thisMusic.audio, musicFrequency)
        audio_stream_play(thisMusic.audio, true, 1)
        audio_stream_set_looping(thisMusic.audio, thisMusic.loop or false)
        if thisMusic.loopEnd then
            audio_stream_set_loop_points(thisMusic.audio, thisMusic.loopStart or 0, thisMusic.loopEnd)
        end
        audio_stream_set_position(thisMusic.audio, 0)
    end

    if music == "" then return end
    
    local thisMusic = musicData[music]
    local newTargetVolume = targetVolume
    -- lower volume when paused
    if is_game_paused() or inMenu then
        newTargetVolume = targetVolume / 2
    end
    local diff = newTargetVolume - musicVolume
    if diff > 0 then
        musicVolume = math.min(musicVolume + 0.1, newTargetVolume)
    else
        musicVolume = math.max(musicVolume - 0.1, newTargetVolume)
    end
    audio_stream_set_volume(thisMusic.audio, musicVolume)
    audio_stream_set_frequency(thisMusic.audio, musicFrequency)

    -- pause at volume 0
    if musicVolume == 0 then
        audio_stream_pause(thisMusic.audio)
        if not musicPaused then
            musicPaused = true
            pausePoint = audio_stream_get_position(thisMusic.audio)
        end
    elseif musicPaused then
        musicPaused = false
        audio_stream_play(thisMusic.audio, false, musicVolume)
        audio_stream_set_position(thisMusic.audio, pausePoint)
    end
end

function play_stream_sfx(sound, pos, volume_)
    if gServerSettings.headlessServer ~= 0 and network_is_server() then return end -- don't do this for headless

    local volume = volume_ or 1
    local audio = soundData[sound]
    if not audio then
        log_to_console("Could not find sfx: "..sound)
        return
    end
    audio_sample_play(audio, pos, volume)
end

function stop_stream_sfx(sound)
    if gServerSettings.headlessServer ~= 0 and network_is_server() then return end -- don't do this for headless
    
    local audio = soundData[sound]
    if not audio then
        return
    end
    audio_sample_stop(audio)
end

function stream_music_fade(newTarget)
    targetVolume = newTarget
end

-- used for Red Light, Green Light
function get_target_volume()
    return targetVolume
end

function set_music_frequency(newFrequency)
    musicFrequency = newFrequency
end

-- does this even work?
function test_loop_point()
    local thisMusic = musicData[currentMusic]
    if not (thisMusic and thisMusic.loopEnd) then
        djui_chat_message_create("No point to test...")
        return true
    end
    -- set 3 seconds before loop
    audio_stream_set_position(thisMusic.audio, 0)
    --audio_stream_set_position(thisMusic.audio, thisMusic.loopEnd // 44100 - 3)
    return true
end
if DEBUG_MODE then
    hook_chat_command("looptest", "- Test the loop point for this track", test_loop_point)
end
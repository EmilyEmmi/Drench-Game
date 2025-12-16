-- All Files are .ogg format
-- Music is compressed to 22050 Hz and Sounds are compressed to 16000

local musicBitrate = 22050
local musicData = {
    lobby = {audio = audio_stream_load("music-lobby.ogg"), loop = true},
    dire = {audio = audio_stream_load("music-dire.ogg"), loop = true, loopStart = 49.630, loopEnd = 153.967},
    scores = {audio = audio_stream_load("music-scores.ogg"), loop = true, loopStart = 20.029, loopEnd = -0.2},
    mingle = {audio = audio_stream_load("music-mingle.ogg")},
    final = {audio = audio_stream_load("music-final.ogg"), loop = true, loopStart = 36.647, loopEnd = 162.315},
    slider = {audio = audio_stream_load("music-slider-madness-1.ogg"), loop = true, loopStart = 3.256, loopEnd = -1},
    slider2 = {audio = audio_stream_load("music-slider-madness-2.ogg"), loop = true},
    slider3 = {audio = audio_stream_load("music-slider-madness-3.ogg"), loop = true},
    finalOutro = {audio = audio_stream_load("music-final-outro.ogg")},
}

local soundData = {
    redLight = audio_sample_load("sound-light-red.ogg"),
    redLightShort = audio_sample_load("sound-light-red-short.ogg"),
    redLightLong = audio_sample_load("sound-light-red-long.ogg"),
    greenLight = audio_sample_load("sound-light-green.ogg"),
    greenLightShort = audio_sample_load("sound-light-green-short.ogg"),
    greenLightLong = audio_sample_load("sound-light-green-long.ogg"),
    playerCallout1 = audio_sample_load("sound-mingle-callout-1.ogg"),
    playerCallout2 = audio_sample_load("sound-mingle-callout-2.ogg"),
    playerCallout3 = audio_sample_load("sound-mingle-callout-3.ogg"),
    playerCallout4 = audio_sample_load("sound-mingle-callout-4.ogg"),
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
            local loopEnd = (thisMusic.loopEnd or -1)
            if loopEnd ~= -1 then
                loopEnd = loopEnd * musicBitrate
            end
            audio_stream_set_loop_points(thisMusic.audio, (thisMusic.loopStart or 0) * musicBitrate, loopEnd)
        end
        audio_stream_set_position(thisMusic.audio, 0)
    end

    if music == "" then return end
    
    local thisMusic = musicData[music]
    local newTargetVolume = targetVolume
    if disableMusic == 1 or (disableMusic ~= 0 and music ~= "mingle") then
        -- disable music based on settings
        newTargetVolume = 0
    elseif is_game_paused() or inMenu then
        -- lower volume when paused
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

    if DEBUG_MODE and gControllers[0].buttonDown & L_TRIG ~= 0 then
        audio_stream_set_frequency(thisMusic.audio, musicFrequency * 10)
        log_to_console(tostring(audio_stream_get_position(thisMusic.audio) * 48000 / musicBitrate))
    end

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
    if (not (thisMusic and thisMusic.loopEnd)) or thisMusic.loopEnd == -1 then
        djui_chat_message_create("No point to test...")
        return true
    end
    -- set 3 seconds before loop?
    audio_stream_set_position(thisMusic.audio, (thisMusic.loopEnd - 3))
    return true
end
if DEBUG_MODE then
    hook_chat_command("looptest", "- Test the loop point for this track", test_loop_point)
end
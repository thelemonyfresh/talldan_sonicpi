unless get(:nm_config_defined)


  set(:nm_config_defined, true)

  #
  # Helper Methods
  #

  define :playing_key do |button|
    "#{button}_playing".to_sym
  end

  define :pending_key do |button|
    "#{button}_pending".to_sym
  end

  define :restart_cue do |button|
    "#{button}_restart".to_sym
  end

  define :note_from_button do |button|
    button.to_s[1].to_i
  end

  define :channel_from_button do |button|
    channel = button.to_s[0]
    return 5 if channel == 'A'
    return 6 if channel == 'B'
  end

  #
  # Left Bank (A)
  #

  live_loop :nm_detect_loops_a do
    use_real_time
    note, val = sync "/midi/dj2go2/1/5/note_on"
    button = "A#{note}"

    if get(playing_key(button)) || get(pending_key(button))
      set playing_key(button), false
      set pending_key(button), false
      val = 0
    else
      set pending_key(button), true
      cue restart_cue(button)
      val = 1
    end

    midi_note_on note, val, channel: channel_from_button(button)
  end

  #
  # Right Bank (B)
  #

  live_loop :nm_detect_loops_b do
    use_real_time
    note, val = sync "/midi/dj2go2/1/6/note_on"
    button = "B#{note}"

    if get(playing_key(button)) || get(pending_key(button))
      set playing_key(button), false
      set pending_key(button), false
      val = 0
    else
      set pending_key(button), true
      cue restart_cue(button)
      val = 1
    end

    midi_note_on note, val, channel: channel_from_button(button)
  end

  #
  # sync method for loops
  #

  define :nm_sync do |button, sync_key|
    use_real_time

    sync restart_cue(button) unless get(playing_key(button))

    if get(pending_key(button))
      puts "I'm abt to wait for sync key"
      sync sync_key
      puts "now I'm after"
      set pending_key(button), false
      set playing_key(button), true
      midi_note_on note_from_button(button), 127, channel: channel_from_button(button)
    end
  end

end

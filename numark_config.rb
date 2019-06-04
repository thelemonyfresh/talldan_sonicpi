##
# L/R "grouping" knob
##


set(:A, 0) if get(:A).nil?
set(:B, 0) if get(:B).nil?

live_loop :nm_group_knobs_A do
  note, val = sync "/midi/dj2go2/1/1/control_change"

  if note == 22
    norm_val = (val/127.0)
    set(:A, norm_val)
  end
end

live_loop :nm_group_knobs_B do
  note, val = sync "/midi/dj2go2/1/2/control_change"

  if note == 22
    norm_val = (val/127.0)
    set(:B, norm_val)
  end
end

####
#  4 loop trigger buttons
####

#
# Helper Methods
#

define :playing_key do |button|
  "#{button}".to_sym
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
  button = "A#{note}".to_sym

  if get(playing_key(button))
    set playing_key(button), false
    val = 0
  else
    set playing_key(button), true
    val = 2
  end

  midi_note_on note, val, channel: channel_from_button(button)
end

#
# Right Bank (B)
#

live_loop :nm_detect_loops_b do
  use_real_time
  note, val = sync "/midi/dj2go2/1/6/note_on"
  button = "B#{note}".to_sym

  if get(playing_key(button))
    set playing_key(button), false
    val = 0
  else
    set playing_key(button), true
    val = 2
  end

  midi_note_on note, val, channel: channel_from_button(button)
end

## use other light brightness to indicate something is hitting a call to nm(:A1), e.g.
# registering if they are already being called or not in use yet
# or use it as third level for toggle

#
# sync method for loops
#

define :nm do |button|
  use_real_time

  return get(playing_key(button))
end

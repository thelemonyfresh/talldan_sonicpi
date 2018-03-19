#
# XTOUCH KNOBS
#

live_loop :xtouch_knobs do
  use_real_time
  midi_num, val = sync "/midi/x-touch_mini/2/11/control_change"

  knob_state = "knob_#{midi_num}_state".to_sym

  set knob_state, (val/127.0)

  if midi_num == 1 # start
    set knob_state, (val/127.0)
  elsif midi_num == 2 # finish
    set knob_state, (val/127.0)
  elsif midi_num == 3 # tuning
    set knob_state, (val/127)
  elsif midi_num == 4 # cutoff
    set knob_state, (val/127.0)
  elsif midi_num == 5 # attack
    set knob_state, (val/127.0)
  elsif midi_num == 6 # decay
    set knob_state, (val/127.0)
  elsif midi_num == 7 # sustain
    set knob_state, (val/127.0)
  elsif midi_num == 8 # release, should be -1 by default to stretch
    set knob_state, (val/127.0)
  elsif midi_num == 9
    set "slider_state".to_sym, (val/127.0)
    set_volume! (val/127.0)*1.3
  end
end

live_loop :xtouch_buttons do
  use_real_time
  midi_num, val = sync "/midi/x-touch_mini/2/11/note_on"

  if midi_num = 0
    set :knob_1_state, 1
  end
end

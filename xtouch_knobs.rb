#
# XTOUCH KNOBS
#

xtouch_channel = 1

# set initial values for knob_x_state to zero if nil

live_loop :xtouch_knobs do
  use_real_time
  midi_num, val = sync "/midi/x-touch_mini/#{xtouch_channel}/11/control_change"

  knob_state = "knob_#{midi_num}_state".to_sym

  set knob_state, (val/127.0)
end

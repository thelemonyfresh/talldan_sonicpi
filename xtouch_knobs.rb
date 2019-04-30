#
# XTOUCH KNOBS
#

xtouch_channel = 0

# Initialize ':knob_X_state' variables
24.times do |n|
  knob_state = "knob_#{n}_state".to_sym
  set(knob_state, 0) if get(knob_state).nil?
end

# Set up knob listeners
live_loop :xtouch_knobs do
  use_real_time
  midi_num, val = sync "/midi/x-touch_mini/#{xtouch_channel}/11/control_change"

  knob_state = "knob_#{midi_num}_state".to_sym

  set knob_state, (val / 127.0)
end

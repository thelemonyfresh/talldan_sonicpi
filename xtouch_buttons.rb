xtouch_channel = 1

live_loop :xtouch_buttons do
  use_real_time
  midi_num, val = sync "/midi/x-touch_mini/#{xtouch_channel}/11/note_on"

  # if range(24,32,1).include?(midi_num) # knob_press
  #   knob_num = midi_num - 13
  #   new_val = 1
  # elsif range(32,39,1).include?(midi_num)
  #   knob_num = midi_num - 21
  #   new_val = 0.5
  # elsif range(40,47,1).include?(midi_num)
  #   knob_num = midi_num - 29
  #   new_val = 0
  # end

  if range(0,8,1).include?(midi_num) # knob_press
    cannel_num = midi_num
    new_val = 1
  elsif range(32,39,1).include?(midi_num)
    knob_num = midi_num - 21
    new_val = 0.5
  elsif range(40,47,1).include?(midi_num)
    knob_num = midi_num - 29
    new_val = 0
  end

  set knob_state, new_val
end

# TODO: fix OSC in imported file, comments and structure

use_osc '192.168.0.237', 7400

# sample cutter

define :numark_sampler do |collection, sample|
  rate = 1 + get(:rate_coarse) + get(:rate_fine)

  sample collection, sample,
         rate: rate,
         start: get(:cue_a),
         finish: get(:cue_b)

  set(:ss_collection, collection)
  set(:ss_sample, sample)
  set(:ss_rate, rate)
end

puts "asdf"

#
# Cue listeners
#

set(:cue_b, 0.5) unless get(:cue_b)
set(:cue_a, 0.5) unless get(:cue_a)

live_loop :cue_a_loop do
  use_real_time
  note, val = sync "/midi/dj2go2/1/1/control_change"

  current = get(:cue_a) || 0.5
  inc = 0.0005
  if note == 6 #&& tick % 4 == 0
    puts "HERE IN DEBUGGER"
    change = val == 1 ? inc : -1 * inc

    new_total = (current + change).round(4)

    new_total = 0 if new_total <= 0
    new_total = 1 if new_total >= 1

    set(:cue_a, new_total)
    if one_in(10)
      cue_position(get(:cue_a), '#a')
    end
  end
end

live_loop :cue_b_loop do
  use_real_time
  note, val = sync "/midi/dj2go2/1/2/control_change"

  current = get(:cue_b) || 0.5
  inc = 0.0005
  if note == 6 #&& tick % 4 == 0
    change = val == 1 ? inc : -1 * inc

    new_total = (current + change).round(4)

    new_total = 0 if new_total <= 0
    new_total = 1 if new_total >= 1


    set(:cue_b, new_total)
    if one_in(10)
      cue_position(get(:cue_b), '#b')
    end

  end
end


#
# VIS -- update visualization
#
live_loop :window_scroll do
  note, val = sync "/midi/dj2go2/1/16/control_change"

  inc = 0.0025
  if note == 0 #&& tick % 4 == 0
    current_a = get(:cue_a)
    current_b = get(:cue_b)

    change = val == 1 ? inc : -1 * inc

    set(:cue_b, increment_knob(current_b, change))
    set(:cue_a, increment_knob(current_a, change))
  end

end

define :increment_knob do |current, change|
  new_total = (current + change).round(4)

  new_total = 0 if new_total <= 0
  new_total = 1 if new_total >= 1

  cue_position(get(:cue_a), '#a')
  cue_position(get(:cue_b), '#b')

  new_total
end


#
# RATE -- left (coarse) and right (fine) faders
#

set(:rate_coarse, 0) unless get(:rate_course)
set(:rate_fine, 0) unless get(:rate_fine)

live_loop :rate_slider_A do
  note, val = sync "/midi/dj2go2/1/1/control_change"

  if note == 9
    normed_val = 0.5 - val/127.0
    set(:rate_coarse, normed_val.round(2))
  end
end

live_loop :rate_slider_b do
  note, val = sync "/midi/dj2go2/1/2/control_change"

  if note == 9
    normed_val = ((0.5 - val/127.0)*0.25).round(3)
    set(:rate_fine, normed_val.round(2))
  end
end

#
# CLIPBOARD -- copy sample pettern to clipboard on center knob press
#

live_loop :clipboard do
  use_real_time
  note, val = sync "/midi/dj2go2/1/16/note_on"

  str = "sample '#{get(:ss_collection)}', '#{get(:ss_sample)}',
        rate: #{get(:ss_rate)},
        start: #{get(:cue_a)},
        finish: #{get(:cue_b)}"
  pbcopy(str)
end

def pbcopy(input)
  str = input.to_s
  IO.popen('pbcopy', 'w') { |f| f << str }
  str
end

channel = 0

# add optional params hash that gives initial values
define :numark_sampler_a do |collection, sample|
  in_thread do
    rate = tune_by(get(:rate_a))  # multiple this by array of steps?

    if get(:playing_a)
      start = get(:cue_a)
      sample_length = (get(:length_a_coarse) + 0.1 * get(:length_a_fine))
      finish = start + sample_length < 1 ? start + sample_length : 1
      sample collection, sample,
        rate: rate,
        start: start,
        finish: finish


      midi_note_on 0,2, channel: 1 if get(:playing_a) # set play button

      midi_note_on 1,2, channel: 1 # flash the cue
      sleep 0.125
      midi_note_on 1,0, channel: 1


      set(:start_a, start)
      set(:finish_a, finish)
      set(:ss_collection_a, collection)
      set(:ss_sample_a, sample)
      set(:ss_rate_a, rate)
    end
  end
end

define :numark_sampler_b do |collection, sample|
  in_thread do
    rate = tune_by(get(:rate_b))  # multiple this by array of steps

    if get(:playing_b)
      start = get(:cue_b)
      sample_length= (get(:length_b_coarse) + 0.1*get(:length_b_fine))
      finish = start + sample_length < 1 ? start + sample_length : 1
      sample collection, sample,
        rate: rate,
        start: start,
        finish: finish


      midi_note_on 0,2, channel: 2 if get(:playing_b)# set play button

      midi_note_on 1,2, channel: 2 # flash the cue
      sleep 0.125
      midi_note_on 1,0, channel: 2


      set(:start_b, start)
      set(:finish_b, finish)
      set(:ss_collection_b, collection)
      set(:ss_sample_b, sample)
      set(:ss_rate_b, rate)
    end
  end
end

define :tune_by do |rate|
  0.25*rate**2 + 0.75*rate + 1
  #rate_note(rate)
  #rate < 0 ? 1.0 / rate_note(rate) : rate_note(rate)
end

define :rate_note do |rate|
  13.times.map { |n| 2**(n/12.0) }[rate*12]
end

#
# Cue listeners
#

# convert these to just one side cue with knob
#



live_loop :cue_a_loop do
  use_real_time
  note, val = sync "/midi/dj2go2/#{channel}/1/control_change"

  current = get(:cue_a) || 0.5
  inc = 0.0005
  if note == 6 #&& tick % 4 == 0
    change = val == 1 ? inc : -1 * inc

    new_total = (current + change).round(4)

    new_total = 0 if new_total <= 0
    new_total = 1 if new_total >= 1

    set(:cue_a, new_total)
    ##| if one_in(10)
    ##|   cue_position(get(:cue_a), '#a')
    ##| end
  end
end

live_loop :cue_b_loop do
  use_real_time
  note, val = sync "/midi/dj2go2/#{channel}/2/control_change"

  current = get(:cue_b) || 0.5
  inc = 0.0005
  if note == 6 #&& tick % 4 == 0
    change = val == 1 ? inc : -1 * inc

    new_total = (current + change).round(4)

    new_total = 0 if new_total <= 0
    new_total = 1 if new_total >= 1


    set(:cue_b, new_total)
    ##| if one_in(10)
    ##|   cue_position(get(:cue_b), '#b')
    ##| end

  end
end


#
# VIS -- update visualization
#
##| live_loop :window_scroll do
##|   note, val = sync "/midi/dj2go2/1/16/control_change"

##|   inc = 0.0025
##|   if note == 0 #&& tick % 4 == 0
##|     current_a = get(:cue_a)
##|     current_b = get(:cue_b)

##|     change = val == 1 ? inc : -1 * inc

##|     set(:cue_b, increment_knob(current_b, change))
##|     set(:cue_a, increment_knob(current_a, change))
##|   end

##| end

##| define :increment_knob do |current, change|
##|   new_total = (current + change).round(4)

##|   new_total = 0 if new_total <= 0
##|   new_total = 1 if new_total >= 1

##|   #cue_position(get(:cue_a), '#a')
##|   #cue_position(get(:cue_b), '#b')

##|   new_total
##| end


#
# RATE
#

live_loop :rate_slider_a do
  use_real_time
  note, val = sync "/midi/dj2go2/#{channel}/1/control_change"

  if note == 9
    normed_val = 1 - 2*val/127.0
    normed_val = normed_val.between?(-0.01,0.01) ? 0 : normed_val
    set(:rate_a, normed_val.round(3))
  end
end

live_loop :rate_slider_b do
  use_real_time
  note, val = sync "/midi/dj2go2/#{channel}/2/control_change"

  if note == 9
    normed_val = 1 - 2*val/127.0
    normed_val = normed_val.between?(-0.01,0.01) ? 0 : normed_val
    set(:rate_b, normed_val.round(3))
  end
end

#
# LENGTH LISTENERS
#

live_loop :length_knob_a_coarse do
  use_real_time
  note, val = sync "/midi/dj2go2/#{channel}/16/control_change"

  if note == 10
    normed_val = val/127.0
    set(:length_a_coarse, normed_val)
  end
end

live_loop :length_knob_a_fine do
  use_real_time
  note, val = sync "/midi/dj2go2/#{channel}/1/control_change"

  if note == 22
    normed_val = val/127.0
    set(:length_a_fine, normed_val)
  end
end

live_loop :length_knob_b_coarse do
  use_real_time
  note, val = sync "/midi/dj2go2/#{channel}/16/control_change"

  if note == 10
    normed_val = val/127.0
    set(:length_b_coarse, normed_val)
  end
end

live_loop :length_knob_b_fine do
  use_real_time
  note, val = sync "/midi/dj2go2/#{channel}/2/control_change"

  if note == 22
    normed_val = val/127.0
    set(:length_b_fine, normed_val)
  end
end


#
# CLIPBOARD -- copy sample pettern to clipboard on center knob press
#

live_loop :clipboard_a do
  use_real_time
  note, val = sync "/midi/dj2go2/#{channel}/1/note_on"

  if note == 2
    str = "sample '#{get(:ss_collection_a)}', '#{get(:ss_sample_a)}',
        rate: #{get(:ss_rate_a)},
        start: #{get(:start_a)},
        finish: #{get(:finish_a)}"
    pbcopy(str)
  end
end


live_loop :clipboard_b do
  use_real_time
  note, val = sync "/midi/dj2go2/#{channel}/2/note_on"

  if note == 2
    str = "sample '#{get(:ss_collection_b)}', '#{get(:ss_sample_b)}',
        rate: #{get(:ss_rate_b)},
        start: #{get(:start_b)},
        finish: #{get(:finish_b)}"
    pbcopy(str)
  end
end

def pbcopy(input)
  str = input.to_s
  IO.popen('pbcopy', 'w') { |f| f << str }
  str
end

#
# PLAY/PAUSE BUTTON -- on when sample plays
#



live_loop :ppa do
  use_real_time
  note, val = sync("/midi/dj2go2/#{channel}/1/note_on")

  if note == 0
    now_playing = !get(:playing_a)
    set(:playing_a, !get(:playing_a))
    new_midi_state = now_playing ? 1 : 0
    midi_note_on 0, new_midi_state, channel: 1
  end
end

live_loop :ppb do
  use_real_time
  note, val = sync("/midi/dj2go2/#{channel}/2/note_on")

  if note == 0
    now_playing = !get(:playing_b)
    set(:playing_b, !get(:playing_b))
    new_midi_state = now_playing ? 1 : 0
    midi_note_on 0, new_midi_state, channel: 1
  end
end

#midi_note_on 1, 2, channel: 5

#midi_note_on 1,0, channel: 1

#
# INITIALIZE
#

# defonce :initialize do
#   set(:playing_a, false)
#   set(:cue_a, 0)
#   set(:rate_a, 1)
#   set(:rate_b, 1)
#  # set(:playing_a, false)

#   set(:cue_b, 0.5) unless get(:cue_b)
#   set(:cue_a, 0.5) unless get(:cue_a)

#   puts "intializing"
#   # turn off the lights
#   midi_note_on 0,0, channel: 1
#   midi_note_on 1,0, channel: 1
#   midi_note_on 2,0, channel: 1

# end


#
# FEATURES:
#

# sync button guesses rate change to the closest BPM based on length

# play button activates it

# cue button goes on  when sample is playing

#

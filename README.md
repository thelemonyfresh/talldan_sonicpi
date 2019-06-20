# talldan_sonicpi
Live coded music with [SonicPi](https://sonic-pi.net/).

I typically define a var with the path to this repo so I can load easily load files:
``` ruby
base_dir = "/Users/daniel/recording/talldan_sonicpi/"
```

## Snippets
This is a dir of snippets I find useful for live coding.

``` ruby
load_snippets("#{base_dir}snippets/")
```

For example, typing `ll 8<Tab>` gives the following, with the point after the semicolon to quickly name the `live_loop`.

``` ruby
live_loop : do

  sleep 8
end
```

## xtouch_knobs.rb (no longer maintained)
Set up to use [Behringer xtouch mini](https://www.google.com/search?q=behringer+xtouch+mini) midi controller for live coding. Load with:

``` ruby
run_file "#{base_dir}xtouch_knobs.rb"
```

Then use `get :knob_#_state` to get the value of the knob between 0 and 1. Knobs on layer "A" are 1-8, and on layer "B" are 11-18. For example:

``` ruby
live_loop :bd do
  sample :bd_808, amp: get(:knob_1_state)
end
```

## sonic_pi_notebook.rb
An Emacs `org-mode` notebook where I keep track of my sessions, nascent songs, and anything else I want to jot down.

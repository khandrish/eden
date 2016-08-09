defmodule Eden.Component.Time.Time do
  @moduledoc false
  @callback get_world_time(any()) :: any()
end

	# how will time in the game work?
    # time should pass at a fixed rate compared to real time
    # time should break down in a reasonably understandable way that in some way corresponds with real time
    # 1 IG day = 5 RL hours
    # 1 IG day = 30 IG hours
    # 6 IG hours = 1 RL hour
    # 1 IG hour = 10 RL minutes
    # 1/2 IG hour = 5 RL minutes
    # 1/10 IG hour = 1 RL minute

    # need to be able to translate seconds passing in real time to in game time
    # need to be able to set the exact time the engine should use to begin its calculations
    # need to be able to set the starting time down to at least hour granularity
    # taking the starting times, dynamically calculate what time it is at the moment of request

    # need to be able to generate offsets
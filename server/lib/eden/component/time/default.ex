defmodule Eden.Component.Time.Default do
  @moduledoc false
  @behaviour Eden.Component.Time.Time

  def get_world_time(current_time, world_start_time, world_start_date, transform) do
    # subtract the time the world was started from the current time to get the diff in seconds
    # using the world start date translate passed seconds into in game date
  end
end

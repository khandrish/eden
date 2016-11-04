defmodule Exmud.Time do
  @moduledoc """
  Provides utility functions for working with the Calendar module, simplifying
  and shortening common use cases.
  """

  alias Calendar.DateTime, as: DT

  def now_utc do
    DT.now_utc()
  end

  def timestamp_after_utc(seconds) do
    DT.advance!(now_utc(), seconds)
  end
end

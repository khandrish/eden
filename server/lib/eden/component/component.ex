defmodule Eden.Component do
  @moduledoc false
  @callback init() :: string()
  @callback name() :: string()
end
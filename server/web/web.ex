defmodule Eden.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Eden.Web, :controller
      use Eden.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def changeset do
    quote do
      use Ecto.Model
      import Ecto
      import Ecto.Changeset
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      before_insert Eden.UUID, :put_uuid, []
      use Calecto.Schema, usec: true
    end
  end

  def model do
    quote do
      use Ecto.Model
      import Ecto
      import Ecto.Changeset
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      before_insert Eden.UUID, :put_uuid, []
      use Calecto.Schema, usec: true
    end
  end

  def controller do
    quote do
      use Phoenix.Controller
      require Logger

      alias Eden.Repo
      import Ecto
      import Ecto.Query, only: [from: 1, from: 2]

      import Eden.Router.Helpers
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"
      require Logger

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Eden.Router.Helpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      require Logger

    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end

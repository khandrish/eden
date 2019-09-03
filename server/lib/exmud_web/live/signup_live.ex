defmodule ExmudWeb.SignupLive do
  use Phoenix.LiveView

  def mount(_session, socket) do
    {:ok,
     assign(socket, %{
       changeset: Exmud.Account.Profile.changeset(%Exmud.Account.Profile{}),
       has_nickname_error?: false,
       has_email_error?: false
     })}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    Phoenix.View.render(
      ExmudWeb.AuthView,
      "signup.html",
      assigns
    )
  end

  def handle_event("validate", _form = %{"profile" => params}, socket) do
    changeset = Exmud.Account.Profile.new(params) |> Map.put(:action, :insert)

    {:noreply,
     assign(socket,
       changeset: changeset,
       has_nickname_error?: Exmud.Util.changeset_has_error?(changeset, :nickname),
       has_email_error?: Exmud.Util.changeset_has_error?(changeset, :email)
     )}
  end

  def handle_event("save", _form = %{"profile" => signup_params}, socket) do
    case Exmud.Account.signup(signup_params) do
      {:ok, player_id} ->
        {:stop,
         socket
         |> put_flash(:success, "Welcome! You have been automatically logged in!")
         |> assign(:player_id, player_id)
         |> assign(:player_authenticated?, true)
         |> redirect(to: "/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket =
          socket
          |> put_flash(
            :error,
            "Something went wrong while creating account. Please see errors below."
          )
          |> assign(
            changeset: changeset,
            has_nickname_error?: Exmud.Util.changeset_has_error?(changeset, :nickname),
            has_email_error?: Exmud.Util.changeset_has_error?(changeset, :email)
          )

        {:noreply, socket}
    end
  end
end

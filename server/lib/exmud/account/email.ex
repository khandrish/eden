defmodule Exmud.Account.Email do
  import Bamboo.Email

  @doc """
  Create an email that can be used by a Player to log in.
  """
  @spec login_email(String.t(), String.t(), String.t()) :: Bamboo.Email.t()
  def login_email(to_email_address, from_email_address, login_token) do
    new_email(
      to: to_email_address,
      from: from_email_address,
      subject: "Log In Request",
      html_body: "<strong>Paste the following token into the token verification form: #{login_token}</strong>",
      text_body: "Paste the following token into the token verification form: #{login_token}"
    )
  end
end

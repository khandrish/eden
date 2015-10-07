defmodule Eden.MailerTest do
  use Eden.ConnCase

  test "Send welcome email" do
    assert {:ok, _} = Eden.Mailer.send_welcome_email("khandrish@gmail.com", "Khan")
  end

  test "Send password reset email" do
    assert {:ok, _} = Eden.Mailer.send_password_reset_email("khandrish@gmail.com", "foobar")
  end

  test "Send email verification email" do
    assert {:ok, _} = Eden.Mailer.send_email_verification_email("khandrish@gmail.com", "foobar")
  end
end

defmodule Eden.Mailer do
  use Mailgun.Client, domain: Application.get_env(:eden, :mailgun_domain),
                      key: Application.get_env(:eden, :mailgun_key),
                      mode: :test,
                      test_file_path: Application.get_env(:eden, :mailgun_test_file_path)

  @from "do-not-reply@eden.com"

  def send_welcome_email(email, name) do
    send_email to: email,
               from: @from,
               subject: ~s(Hello, #{name}!),
               html: ~s(<strong>Welcome #{name}!</strong>)
  end

  def send_password_reset_email(email, token) do
    send_email to: email,
               from: @from,
               subject: "Here is the password reset email you asked for!",
               html: """
                <p>First of all, if you didn't request this email be sent don't worry. You may safely disregard
                this email. Otherwise, please click the link below to be taken to our website where you will be
                able to enter in a new password.</p>
                <br/>
                <br/>
                <a href="thisisjustatest/#{token}">"thisisjustatest/#{token}"</a>
                """
  end

  def send_email_verification_email(email, token) do
    send_email to: email,
               from: @from,
               subject: "Here is the verification email you asked for!",
               html: """
                <p>First of all, if you didn't sign up for our service don't worry. We don't send email to unconfirmed
                email addresses. You may safely disregard this email. Otherwise, please click the link below to confirm
                that this email is valid and associated with your account.</p>
                <br/>
                <br/>
                <a href="thisisjustatest/#{token}">"thisisjustatest/#{token}"</a>
                """
  end
end
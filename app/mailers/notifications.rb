class Notifications < ActionMailer::Base
  default from: "editor@benyehuda.org"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.signup.subject
  #
  def signup(user, clear_passwd)
    @user = user
    @clear_passwd = clear_passwd

    mail to: user.email
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.forgot_password.subject
  #
  def forgot_password(user)
    @user = user

    mail to: user.email
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.monthly.subject
  #
  def monthly
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end

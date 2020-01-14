Devise.setup do |config|
  config.cas_base_url = Rails.application.credentials.cas[:base_url]
  config.mailer_sender = Settings.config.email
  require 'devise/orm/active_record'
  config.authentication_keys = [:username]
  config.case_insensitive_keys = [:username]
  config.strip_whitespace_keys = [:username]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 10
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 8..128
  config.lock_strategy = :none
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete

  config.cas_create_user = false
end

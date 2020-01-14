Devise.setup do |config|
  # ==> LDAP Configuration
  # config.ldap_logger = true
  # config.ldap_create_user = false
  # config.ldap_update_password = true
  # config.ldap_config = "#{Rails.root}/config/ldap.yml"
  # config.ldap_check_group_membership = false
  # config.ldap_check_group_membership_without_admin = false
  # config.ldap_check_attributes = false
  # config.ldap_check_attributes_presence = false
  # config.ldap_use_admin_to_bind = false
  # config.ldap_ad_group_check = false

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

end

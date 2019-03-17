URL_SETTINGS = { host: nil, port: 80 }.freeze
SMTP_SETTINGS = { address: '', port: nil, domain: '', user_name: '',
                  password: '', authentication: :plain,
                  enable_starttls_auto: true }.freeze

ActionMailer::Base.default_url_options =
  Cypress::Application.config.action_mailer.default_url_options = URL_SETTINGS
ActionMailer::Base.smtp_settings =
  Cypress::Application.config.action_mailer.smtp_settings = SMTP_SETTINGS

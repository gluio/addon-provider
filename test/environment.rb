ENV["DATABASE_URL"] = "#{ENV["DATABASE_URL"]}-test"

ENV["ADDON_NAME"] = "Cloud Widgets"
ENV["ADDON_ID"] = "cloudwidgets"
ENV["ADDON_API_PASSWORD"] = "cloudwidgets-api-sekret"
ENV["ADDON_SSO_SALT"] = "a-really-long-string-to-salt-sessions-auth-with"
ENV["ADDON_REGIONS"] = "us,eu"
ENV["ADDON_CONFIG_VARS"] = "CLOUDWIDGETS_URL"
ENV["ADDON_DOMAIN"] = "cloudwidgets.io"
ENV["DATABASE_ENCRYPT_KEY"] = "a-really-long-string-to-encrypt-secrets"
ENV["SIDEKIQ_ADMIN_PASSWORD"] = "yeop-chagi"
ENV["COMPANY_NAME"] = "Cloud Widgets Inc."
ENV["MAILING_ADDRESS"] = "123 Fillmore St."
ENV["SESSION_SECRET"] = "a-really-long-session-secret"

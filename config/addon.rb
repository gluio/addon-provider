module AddonConfig
  def self.settings
    { name: ENV.fetch("ADDON_NAME"),
      id: ENV.fetch("ADDON_ID"),
      password: ENV.fetch("ADDON_API_PASSWORD"),
      sso_salt: ENV.fetch("ADDON_SSO_SALT"),
      regions: ENV.fetch("ADDON_REGIONS"),
      vars: ENV.fetch("ADDON_CONFIG_VARS"),
      requires: ENV["ADDON_REQUIRES"],
      domain: ENV.fetch("ADDON_DOMAIN"),
      encrypt_key: ENV.fetch("DATABASE_ENCRYPT_KEY"),
      sidekiq_pass: ENV.fetch("SIDEKIQ_ADMIN_PASSWORD"),
      company_name: ENV.fetch("COMPANY_NAME"),
      mailing_address: ENV.fetch("MAILING_ADDRESS"),

      session_secret: ENV.fetch("SESSION_SECRET")
    }
  rescue KeyError => ex
    missing_key = ex.message.match(/not found: "([^"]+)"/)[1]
    display_error_message(missing_key)
    exit(1)
  end

  def self.check!
    settings
  end

  private
  def self.display_error_message(key)
    key, msg = error_messages.detect{|k,v| k == key }
    STDERR.puts "ERROR: #{msg}"
  end

  def self.error_messages
    { "ADDON_NAME" => instructions("name", "ADDON_NAME"),
      "ADDON_ID" => instructions("'id'", "ADDON_ID", "This is the shorthand version of your add-on name that developers will use on the CLI: https://devcenter.heroku.com/articles/add-on-manifest#fields"),
      "ADDON_API_PASSWORD" => instructions("password", "ADDON_API_PASSWORD", "You can generate a value to use with: `ruby -e \"require 'securerandom'; puts SecureRandom.hex();\"`"),
      "ADDON_SSO_SALT" => instructions("Single Sign-On shared secret", "ADDON_SSO_SALT", "This is a secret shared used in sign-on between the Heroku Dashboard and your own customer dashboard: https://devcenter.heroku.com/articles/add-on-manifest#fields\nYou can generate a value to use with: `ruby -e \"require 'securerandom'; puts SecureRandom.hex();\"`"),
      "ADDON_CONFIG_VARS" => instructions("config vars", "ADDON_CONFIG_VARS", "This is a comma seperated list of the configuration variables that will be set by your add-on: https://devcenter.heroku.com/articles/add-on-manifest#fields"),
      "ADDON_REGIONS" => instructions("available regions", "ADDON_REGIONS", "This is a comma seperated list of geographical regions supported by your add-on (e.g., \"us,eu\"): https://devcenter.heroku.com/articles/add-on-manifest#fields"),
      "ADDON_DOMAIN" => instructions("domain", "ADDON_DOMAIN"),
      "DATABASE_ENCRYPT_KEY" => instructions("database encryption key", "DATABASE_ENCRYPT_KEY", "You can generate a value to use with: `ruby -e \"require 'securerandom'; puts SecureRandom.hex();\"`"),
      "SIDEKIQ_ADMIN_PASSWORD" => instructions("Sidekiq admin password", "SIDEKIQ_ADMIN_PASSWORD"),
      "COMPANY_NAME" => instructions("company name", "COMPANY_NAME", "This will be displayed in the footer of you web pages and emails."),
      "MAILING_ADDRESS" => instructions("mailing address", "MAILING_ADDRESS", "This will be displayed in the footer of you web pages and emails."),
      "SESSION_SECRET" => instructions("session/cookie secret", "SESSION_SECRET", "You can generate a value to use with: `ruby -e \"require 'securerandom'; puts SecureRandom.hex();\"`")
    }
  end

  def self.instructions(name, key, additional = nil)
    instructions = ["You need to set the #{name} of your add-on "]
    instructions << "in the #{key} environment variable."
    instructions << "\n\n#{additional}" if additional
    instructions.join
  end
end

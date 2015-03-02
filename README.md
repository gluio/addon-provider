TODO:
 - Make sure static assets are being served
 - Style using Jumpstart
 - Add NestaDrop integration
 - Add manifest generation/pusher
 - Add script to log active users, revenue, etc. to Librato for dashboards
 - Adding a domain
 - Adding ExpeditedSSL
 - Add info on setting up Segment
   - Setting up Intercom
   - Setting up Customer.io
   - Setting up Tawk.to
   - Setting up Mailchimp
   - Setting up Qualaroo
   - Setting up Optimizely
 - Update app manifest to include default add-ons:
   - Papertrail
   - Librato
   - ExpeditedSSL
   - SSL
   - An exception tracker (might need to configure the app)
   - NestaDrop
   - GluIO ?

# README

## Checklist

- Set default values for config in `.env` file:
  - [ ] `DATABASE_URL`
  - [ ] `ADDON_NAME`
  - [ ] `ADDON_ID`
  - [ ] `ADDON_API_PASSWORD`\*
  - [ ] `ADDON_SSO_SALT`\*
  - [ ] `ADDON_REGIONS`
  - [ ] `ADDON_CONFIG_VARS`
  - [ ] `ADDON_DOMAIN`
  - [ ] `DATABASE_ENCRYPT_KEY`\*
  - [ ] `SIDEKIQ_ADMIN_PASSWORD`\*
  - [ ] `SESSION_SECRET`\*
  - [ ] `COMPANY_NAME`
  - [ ] `MAILING_ADDRESS`
- Migrate the database.
- Update `config.ru`:
  - [ ] Replace `/some-resource-name` with a base resource or action for your API.
- Update Dashboard:
  - [ ] Run `bin/create_demo_account` to create a local account to test with.
  - [ ] Visit `/sso` and make sure it works.

- Update product information:
  - [ ] Create feature flags
  - [ ] Create plans
  - [ ] Rename feature\_limit


\* *all secrets can be generated at once by running `bin/generate_secrets`*

## Getting Started

Install all the gems:

    $ bundle

Before you can run the tests or run the app locally you'll ned to setup
the database:

    $ createdb $DATABASE_URL
    $ createdb $DATABASE_URL-test

Run the migrations to create the tables:

    $ sequel -m db $DATABASE_URL
    $ sequel -m db $DATABASE_URL-test


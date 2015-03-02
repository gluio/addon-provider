Sequel.migration do
  up do
    run 'CREATE EXTENSION "uuid-ossp";'
    create_table(:accounts) do
      uuid :uuid, :null => false, :primary_key => true, :default => Sequel::SQL::Function.new(:uuid_generate_v4)
      String :heroku_uuid, :null => false
      bytea :password, :null => false
      DateTime :created_at, :null => true, :default => Sequel::SQL::Function.new(:now)
      index [:heroku_uuid]
    end
    create_table(:plans) do
      uuid :uuid, :null => false, :primary_key => true, :default => Sequel::SQL::Function.new(:uuid_generate_v4)
      String :slug, :null => false
      String :name, :null => false
      Integer :feature_limit, :null => false
      Integer :price_cents, :null => false, :default => 0
      index [:slug]
    end
    create_table(:resources) do
      uuid :uuid, :null => false, :primary_key => true, :default => Sequel::SQL::Function.new(:uuid_generate_v4)
      uuid :account_uuid, :null => false
      uuid :plan_uuid, :null => false
      DateTime :provisioned_at, :null => false, :default => Sequel::SQL::Function.new(:now)
      DateTime :deprovisioned_at, :null => true
      index [:account_uuid]
      index [:plan_uuid]
    end
    create_table(:feature_flags) do
      uuid :uuid, :null => false, :primary_key => true, :default => Sequel::SQL::Function.new(:uuid_generate_v4)
      String :name, :null => false
      index [:name]
    end
    create_table(:feature_flags_plans) do
      uuid :feature_flag_uuid, :null => false
      uuid :plan_uuid, :null => false
      primary_key [:feature_flag_uuid, :plan_uuid]
      index [:feature_flag_uuid, :plan_uuid]
    end
  end
  down do
    drop_table(:accounts)
    drop_table(:plans)
    drop_table(:resources)
    drop_table(:feature_flags)
    drop_table(:feature_flags_plans)
    run 'DROP EXTENSION "uuid-ossp";'
  end
end

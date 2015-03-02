require 'securerandom'
require 'encryptor'
require 'yajl'

require 'config/addon'
require 'config/sequel'
require 'heroku/app_info'
require 'models/feature_flag'
require 'models/plan'
require 'models/resource'
require 'workers/segment_worker'

class Account < Sequel::Model
  set_primary_key :uuid
  plugin :validation_helpers
  one_to_many :resources, key: :account_uuid

  def self.provision_from_json!(json)
    params = Yajl::Parser.parse(json)
    db.transaction do
      plan = Plan.first(:slug => params["plan"])
      if account = Account[:heroku_uuid => params["heroku_uuid"]]
        if account.resource && account.resource.plan != plan
          account.change_plan!(plan)
        elsif !account.resource
          account.add_resource(:plan_uuid => plan.uuid)
        end
      else
        account = Account.new
        account.heroku_uuid = params["heroku_uuid"]
        account.save
        account.add_resource(:plan_uuid => plan.uuid)
      end
      account
    end
  end

  def validate
    super
    validates_presence [:heroku_uuid, :password]
    validates_unique    :heroku_uuid
  end

  def before_validation
    generate_password
    super
  end

  def after_create
    SegmentWorker.perform_async(self.uuid, "signup")
    super
  end

  def resource
    resources_dataset.first(:deprovisioned_at => nil)
  end

  def generate_password
    self.password ||= SecureRandom.urlsafe_base64
  end

  def password=(val)
    super(self.class.encrypt(val))
  end

  def decrypted_password
    self.class.decrypt(self.password)
  end

  def to_heroku_json
    hash = {
      "config" => { "ADDONAPI_URL" => to_url },
      "id" => uuid
    }
    Yajl::Encoder.encode(hash)
  end

  def to_url
    "https://#{uuid}:#{decrypted_password}@api.addondomain.com/"
  end

  def feature_flag?(flag)
    return false unless resource
    resource.plan.feature_flag?(flag)
  end

  def deprovision!
    resources_dataset.
      where(:deprovisioned_at => nil).
      update(:deprovisioned_at => Time.now.utc)
  end

  def change_plan!(plan)
    db.transaction do
      deprovision!
      add_resource(:plan_uuid => plan.uuid)
    end
  end

  def change_plan_from_json!(json)
    params = Yajl::Parser.parse(json)
    plan = Plan[:slug => params["plan"]]
    change_plan!(plan)
  end

  def email_address
    heroku_app_info["owner_email"]
  end

  def app_name
    heroku_app_info["name"]
  end

  private
  def self.encryption_key
    @encryption_key ||= AddonConfig.settings[:encrypt_key]
  end

  def self.encrypt(val)
    Encryptor.encrypt(val, :key => encryption_key)
  end

  def self.decrypt(val)
    Encryptor.decrypt(val, :key => encryption_key)
  end

  def heroku_app_info
    @heroku_app_info ||= Heroku::AppInfo.get(heroku_uuid)
  end
end

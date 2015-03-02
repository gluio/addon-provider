require 'config/sequel'
class Resource < Sequel::Model
  plugin :validation_helpers
  plugin :timestamps
  many_to_one :account, key: :account_uuid
  many_to_one :plan, key: :plan_uuid

  def validate
    super
    validates_presence [:account_uuid, :plan_uuid]
  end

  def deprovision!
    self.deprovisioned_at = Time.now.utc
  end
end

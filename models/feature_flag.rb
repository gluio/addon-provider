require 'config/sequel'
class FeatureFlag < Sequel::Model
  set_primary_key :uuid
  plugin :validation_helpers
  many_to_many :plans, left_key: :plan_uuid, right_key: :feature_flag_uuid

  def validate
    super
    validates_presence [:uuid, :name]
  end

  def add_plan(plan)
    model.db[:feature_flags_plans].insert(feature_flag_id: self.uuid, plan_id: plan.uuid)
  end
end

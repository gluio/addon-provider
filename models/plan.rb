require 'config/sequel'
class Plan < Sequel::Model
  set_primary_key :uuid
  plugin :validation_helpers
  many_to_many :feature_flags, left_key: :feature_flag_uuid, right_key: :plan_uuid

  def validate
    super
    validates_presence [:slug, :name, :feature_limit]
  end

  def feature_flag?(flag)
    feature_flags.detect{|f| f.name == flag}
  end

end

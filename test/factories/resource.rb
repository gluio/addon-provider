FactoryGirl.define do
  factory :resource do
    uuid { SecureRandom.uuid }
    plan_uuid { FactoryGirl.build(:plan).save.uuid }
    account_uuid { FactoryGirl.build(:account).save.uuid }
  end
end

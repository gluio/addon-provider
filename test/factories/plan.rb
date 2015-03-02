FactoryGirl.define do
  factory :plan do
    uuid { SecureRandom.uuid }
    slug 'test'
    name 'Test Plan'
    feature_limit 30
  end
end


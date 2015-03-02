FactoryGirl.define do
  factory :account do
    uuid { SecureRandom.uuid }
    heroku_uuid 'app123@heroku.com'
  end
end

require_relative '../test_helper'
require 'models/account'

describe Account do
  def setup
    @account = Account.new
  end

  it "requires a Heroku ID" do
    @account.validate
    refute_empty @account.errors[:heroku_uuid]
  end

  it "requires a password" do
    @account.validate
    refute_empty @account.errors[:password]
  end

  it "restricts to 1 per Heroku ID" do
    existing_account = Account.new
    existing_account.heroku_uuid = "app123@heroku.com"
    existing_account.save

    @account.heroku_uuid = "app123@heroku.com"
    @account.validate
    refute_empty @account.errors[:heroku_uuid]
  end

  it "has a resource" do
    @account.heroku_uuid = "app123@heroku.com"
    @account.valid?
    @account.save
    @account.add_resource(:plan_uuid => FactoryGirl.build(:plan).save.uuid)
    refute_nil @account.resource
  end

  it "generates a UUID" do
    @account.heroku_uuid = "app123@heroku.com"
    @account.save
    refute_nil @account.uuid
  end

  it "generates a password" do
    @account.valid?
    refute_nil @account.password
  end

  it "encrypts the password" do
    @account.password = "mysecret"
    refute_equal "mysecret", @account.password
  end

  it "decrypts the password" do
    @account.password = "mysecret"
    assert_equal "mysecret", @account.decrypted_password
  end

  it "provisions via JSON" do
    plan = FactoryGirl.build(:plan).save
    json = Yajl::Encoder.encode({
      "heroku_uuid" => "app23@heroku.com",
      "plan"      => plan.slug })
    account = Account.provision_from_json!(json)
    assert account.valid?
  end

  it "finds existing account if provisioning via JSON" do
    existing_account = Account.new
    existing_account.heroku_uuid = "app123@heroku.com"
    existing_account.save
    plan = FactoryGirl.build(:plan).save
    json = Yajl::Encoder.encode({
      "heroku_uuid" => "app123@heroku.com",
      "plan"      => plan.slug })
    account = Account.provision_from_json!(json)
    assert_equal existing_account.uuid, account.uuid
  end

  it "treats JSON provision like a change plan if existing plan is different" do
    old_plan = FactoryGirl.build(:plan, :slug => "old-plan").save
    existing_account = Account.new
    existing_account.heroku_uuid = "app123@heroku.com"
    existing_account.save
    existing_account.add_resource(:plan_uuid => old_plan.uuid).save

    new_plan = FactoryGirl.build(:plan).save
    json = Yajl::Encoder.encode({
      "heroku_uuid" => "app123@heroku.com",
      "plan"      => new_plan.slug })
    account = Account.provision_from_json!(json)
    assert_equal new_plan.uuid, account.resource.plan.uuid
  end

  it "JSON provision creates resource if existing account was missing one" do
    existing_account = Account.new
    existing_account.heroku_uuid = "app123@heroku.com"
    existing_account.save

    json = Yajl::Encoder.encode({
      "heroku_uuid" => "app123@heroku.com",
      "plan"      => FactoryGirl.build(:plan).save.slug })
    account = Account.provision_from_json!(json)
    assert account.resource
  end

  it "ensures the UUID generated for the Account and Resource are not identical" do
    plan = FactoryGirl.build(:plan).save
    json = Yajl::Encoder.encode({
      "heroku_uuid" => "app23@heroku.com",
      "plan"      => plan.slug })
    account = Account.provision_from_json!(json)
    refute_equal account.uuid, account.resource.uuid
  end

  it "deprovisions" do
    resource = FactoryGirl.build(:resource).save
    account  = resource.account
    assert account.deprovision!
    refute_nil resource.reload.deprovisioned_at
  end

  it "changes plan" do
    new_plan = FactoryGirl.build(:plan, :slug => 'dev').save
    resource = FactoryGirl.build(:resource).save
    account  = resource.account
    assert account.change_plan!(new_plan)
    assert_equal 'dev', account.reload.resource.plan.slug
  end
end


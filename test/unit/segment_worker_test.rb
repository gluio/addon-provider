require_relative '../test_helper'
require 'workers/segment_worker'
describe SegmentWorker do
  def stub_heroku_app_info
  end

  def setup
    account_uuid = "f47ac10b-58cc-4372-a567-0e02b2c3d479"
    @account = Object.new
    time = Time.now
    stub(@account).created_at { time }
    stub(@account).email_address { "user@theirdomain.com" }
    stub(@account).uuid { account_uuid }
    stub(Account).first(uuid: account_uuid) { @account }
    @analytics = Object.new
    stub(@analytics).track {}
    stub(@analytics).identify {}
    stub(Segment::Analytics).new { @analytics }
  end

  it "adds new users" do
    expected_traits = { email: "user@theirdomain.com", cloudwidgets: 1, created_at: @account.created_at }
    mock(@analytics).identify(user_id: @account.uuid, traits: expected_traits) {}
    SegmentWorker.new.perform(@account.uuid, "signup")
  end

  it "tracks add-on events" do
    mock(@analytics).track(
      user_id: @account.uuid,
      event: "Cloud Widgets - Did a thing")
    SegmentWorker.new.perform(@account.uuid, "did-thing")
  end
end

require_relative '../test_helper'
require 'models/email'
describe Email do
  def setup
    @account_uuid = "f47ac10b-58cc-4372-a567-0e02b2c3d479"
    @account_email = "actualuser@theirdomain.com"
    @account = Object.new
    stub(@account).email_address { @account_email }
    stub(Account).first(uuid: @account_uuid) { @account }

    @message =<<-EOF
Dear user,

We think you are **great** and we'd like more of you.

Want a hug?

The Cloud Widgets team
    EOF
  end

  it "resolves an email address from an account UUID" do
    expected_args = hash_including(:to => @account_email)
    mock(Pony).mail(expected_args) { }
    Email.send(@account_uuid, "", "")
  end

  it "adds a subject" do
    expected_args = hash_including(:subject => "You should read this!")
    mock(Pony).mail(expected_args) { }
    Email.send(@account_uuid, "You should read this!", "")
  end

  it "sends markdown as the text body of the email" do
    expected_args = hash_including(:body => @message)
    mock(Pony).mail(expected_args) { }
    Email.send(@account_uuid, "", @message)
  end

  it "converts markdown to HTML for the HTML body" do
    expected_html = /<p.*>Dear user,<\/p>/m
    mock(Pony).mail(anything) do |args|
      raise "Didn't contain expected HTML" unless args[:html_body] =~ expected_html
    end
    Email.send(@account_uuid, "", @message)
  end

  it "wraps the HTML in standard email template" do
    expected_html = /<html.*Dear user.*<\/html>/m
    mock(Pony).mail(anything) do |args|
      raise "Didn't contain expected HTML" unless args[:html_body] =~ expected_html
    end
    Email.send(@account_uuid, "", @message)
  end

  it "replaces placeholders with attributes from account instance" do
    stub(@account).app_name { "fearless-headland-42" }
    stub(@account).foobar { "rumplestiltskin" }
    markdown = "So {{foobar}} told us that you've got an app named **{{app_name}}**"
    expected_args = hash_including(:body => "So rumplestiltskin told us that you've got an app named **fearless-headland-42**")
    mock(Pony).mail(expected_args) { }
    Email.send(@account_uuid, "", markdown)
  end

  it "replaces placeholders in subject" do
    stub(@account).app_name { "fearless-headland-42" }
    expected_args = hash_including(:subject => "You need to fix fearless-headland-42")
    mock(Pony).mail(expected_args) { }
    Email.send(@account_uuid, "You need to fix {{app_name}}", "")
  end

  it "expands [ACTION REQUIRED] subject to include app name" do
    stub(@account).app_name { "fearless-headland-42" }
    expected_args = hash_including(:subject => "[ACTION REQUIRED on fearless-headland-42] Upgrade time!")
    mock(Pony).mail(expected_args) { }
    Email.send(@account_uuid, "[ACTION REQUIRED] Upgrade time!", "")
  end
end


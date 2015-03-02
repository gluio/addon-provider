require_relative '../../test_helper'
require 'heroku/app_info'
describe Heroku::AppInfo do

  def setup
    stub_request(:get, "https://cloudwidgets:cloudwidgets-api-sekret@api.heroku.com/vendor/apps/app123%40heroku.com")
    stub_request(:get, "https://cloudwidgets:cloudwidgets-api-sekret@api.heroku.com/vendor/apps")
  end


  it "fetches all apps" do
    apps = [
      { "provider_id" => "1",
        "heroku_id" => "app123@heroku.com",
        "callback_url" => "https://api.heroku.com/vendor/apps/app123%40heroku.com",
        "plan" => "test" },
      { "provider_id" => "3",
        "heroku_id" => "app456@heroku.com",
        "callback_url" => "https://api.heroku.com/vendor/apps/app456%40heroku.com",
        "plan" => "premium" }
    ].to_json
    mock(RestClient).get(
      "https://cloudwidgets:cloudwidgets-api-sekret@api.heroku.com/vendor/apps", { accept: :json }) { apps }
    Heroku::AppInfo.all
  end

  it "handles pagination" do
  end

  it "fetches a single app" do
    app = { "id" => "app123@heroku.com",
            "name" => "myapp",
            "config" => {"CLOUDWIDGETS_URL" => "http://myaddon.com/52e82f5d73"},
            "callback_url" => "https://api.heroku.com/vendor/apps/app123%40heroku.com",
            "owner_email" => "glenn@getglu.io",
            "region" => "amazon-web-services::us-east-1",
            "domains" => ["www.the-consumer.com", "the-consumer.com"],
            "log_input_url" => "https://token:t.01234567-89ab-cdef-0123-456789abcdef@1.us.logplex.io/logs" }.to_json
    mock(RestClient).get(
      "https://cloudwidgets:cloudwidgets-api-sekret@api.heroku.com/vendor/apps/app123%40heroku.com", { accept: :json }) { app }
    Heroku::AppInfo.get "app123@heroku.com"
  end
end

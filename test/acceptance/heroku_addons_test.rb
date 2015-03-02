require_relative '../test_helper'
require 'yajl'
require 'models/plan'
describe "Heroku Add-ons API" do
  include AddonProvider::AcceptanceTestMethods
  describe "POST /heroku/resources" do
    describe "an unauthenticated user" do
      it "returns a 401" do
        post '/heroku/resources'
        assert_equal 401, last_response.status
      end
    end

    describe "as Heroku" do
      def setup
        Plan.create(:slug => "dev", :name => "Development", :feature_limit => 2)
        authorize "cloudwidgets", "cloudwidgets-api-sekret"
      end

      it "creates an account" do
        json = Yajl::Encoder.encode({ "heroku_uuid" => "app123@heroku.com", "plan" => "dev" })
        post '/heroku/resources', json
        assert_equal 201, last_response.status
        hash = Yajl::Parser.parse(last_response.body)
        account = Account.first(:uuid => hash["id"])

        assert_equal account.uuid, hash["id"]
        assert_equal "https://#{account.uuid}:#{account.decrypted_password}@api.addondomain.com/", hash["config"]["ADDONAPI_URL"]
      end

      it "returns errors as JSON"
      it "returns a 400 code on error"
    end
  end

  #describe "PUT /heroku/resources/:id" do
  #  describe "an unauthenticated user" do
  #    it "returns a 403"
  #  end

  #  describe "as Heroku" do
  #    it "changes the plan of a resource"
  #  end
  #end

  #describe "DELETE /heroku/resources/:id" do
  #  describe "an unauthenticated user" do
  #    it "returns a 403"
  #  end

  #  describe "as Heroku" do
  #    it "deprovisions the resource"
  #  end
  #end
end

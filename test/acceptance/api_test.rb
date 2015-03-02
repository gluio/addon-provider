require_relative '../test_helper'
describe "The API" do
  include AddonProvider::AcceptanceTestMethods
  describe "POST /some-path" do
    describe "an unauthenticated user" do
      it "returns a 401"
    end

    describe "as an authenticated user" do
      it "sends does a thing"
      it "returns a 401 if deprovisioned"
      it "returns errors as JSON"
      it "returns a 400 code on error"
    end
  end
end


require_relative '../test_helper'
require 'models/resource'
describe Resource do
  def setup
    @resource = Resource.new
  end

  it "belongs to an account" do
    @resource.validate
    refute_empty @resource.errors[:account_uuid]
  end

  it "belongs to a plan" do
    @resource.validate
    refute_empty @resource.errors[:plan_uuid]
  end

  it "records if/when the resource has been deprovisioned" do
    @resource.deprovision!
    refute_nil @resource.deprovisioned_at
  end

  it "generates a UUID"
end

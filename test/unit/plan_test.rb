require_relative '../test_helper'
require 'models/plan'
describe Plan do
  def setup
    @plan = Plan.new
  end

  it "requires a slug" do
    @plan.validate
    refute_empty @plan.errors[:slug]
  end

  it "requires a name" do
    @plan.validate
    refute_empty @plan.errors[:name]
  end

  it "requires a monthly limit on some feature" do
    @plan.validate
    refute_empty @plan.errors[:feature_limit]
  end

  it "has resources"
  it "generates UUID"
end


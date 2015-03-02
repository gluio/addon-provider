$:.unshift(File.dirname(__FILE__)+'/../')
require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)
require 'minitest/autorun'
require 'minitest/spec'
require 'webmock/minitest'
require 'rack/test'
require 'rr'

require 'environment'
require 'test/environment'
AddonConfig.check!
require 'config/sequel'
require 'database_cleaner'
require 'factory_girl'

FactoryGirl.find_definitions
DatabaseCleaner.strategy = :truncation
class MiniTest::Spec
  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end
end

class MiniTest::Unit::TestCase
  def assert_change(what)
    old = what.call
    yield
    assert_not_equal old, what.call
  end

  def refute_change(what)
    old = what.call
    yield
    refute_equal old, what.call
  end
end
module AddonProvider
  module AcceptanceTestMethods
    include Rack::Test::Methods
    include FactoryGirl::Syntax::Methods

    def app
      Rack::Builder.new do
        config = File.read('config.ru')
        app = eval config
      end
    end
  end
end

require_relative '../environment'
require 'segment'
require 'sidekiq'
require 'config/addon'
require 'models/account'

class SegmentWorker
  include Sidekiq::Worker

  def perform(account_id, action)
    account = Account.first(uuid: account_id)
    case action
    when "signup"
      traits = {
        email: account.email_address,
        created_at: account.created_at
      }
      traits.merge!(AddonConfig.settings[:id].to_sym => 1)
      self.class.client.identify(user_id: account_id, traits: traits)
    when "did-thing"
      addon_name = AddonConfig.settings[:name]
      self.class.client.track(user_id: account_id, event: "#{addon_name} - Did a thing")
    end
  end

  def self.client
    Segment::Analytics.new write_key: ENV["SEGMENT_WRITE_KEY"]
  end
end

require 'uri'
require 'cgi'
require 'rest_client'
require 'yajl'
require 'config/addon'
module Heroku
  module AppInfo
    def self.all
      parse(client.get(base, accept: :json))
    end

    def self.get(heroku_id)
      path = [base, CGI.escape(heroku_id)].join("/")
      parse(client.get(path, accept: :json))
    end

    def self.client
      RestClient
    end

    def self.base
      "https://#{username}:#{password}@api.heroku.com/vendor/apps"
    end

    def self.parse(json)
      Yajl::Parser.parse(json)
    end

    def self.username
      AddonConfig.settings[:id]
    end

    def self.password
      AddonConfig.settings[:password]
    end
  end
end

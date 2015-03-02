require 'gluio/metrics'
require 'config/addon'
require 'models/account'
class HerokuAddonsAPI < Sinatra::Base
  use Rack::Logger
  use Rack::Auth::Basic, 'Restricted Area' do |username, password|
    username == AddonConfig.settings[:id] && password == AddonConfig.settings[:password]
  end

  post '/resources' do
    GluIO::Metrics.time('heroku-addon-provision') do
      account = Account.provision_from_json!(request.body.read)
      content_type :json
      status 201
      GluIO::Metrics.count('heroku-addon-provision')
      account.to_heroku_json
    end
  end

  put '/resources/:id' do
    GluIO::Metrics.time('heroku-addon-planchange') do
      @account = Account[:uuid => params[:id]]
      @account.change_plan_from_json!(request.body.read)
      content_type :json
      status 201
      GluIO::Metrics.count('heroku-addon-planchange')
      @account.to_heroku_json
    end
  end

  delete '/resources/:id' do
    GluIO::Metrics.time('heroku-addon-deprovision') do
      @account = Account[:uuid => params[:id]]
      @account.deprovision!
      GluIO::Metrics.count('heroku-addon-deprovision')
      status 200
    end
  end

  get '/' do
    halt 404
  end
  post '/' do
    halt 404
  end
end

require 'config/addon'
class SingleSignOn < Sinatra::Base
  enable :sessions
  set :session_secret, AddonConfig.settings[:session_secret]
  if ENV["RACK_ENV"] == "production"
    set :sessions, :domain => AddonConfig.settings[:domain]
  else
    set :sessions, :domain => 'localhost'
  end

  helpers do
    def fake_local?
      (ENV["RACK_ENV"] != "production") && (["127.0.0.1","localhost"].include?(request.host))
    end

    def sso_setup
      if fake_local?
        account = Account.first
        session[:accounts] ||= {}
        session[:accounts][account.uuid] = params[:app] || "tantalising-server-42"
        session[:email] ||= "glenn@getglu.io"
        redirect "/dashboard/#{account.uuid}"
      else
        return_not_authorized if params[:id].nil? || params[:id].empty?
        return_not_authorized if params[:timestamp].nil? || params[:timestamp].empty?
        pre_token = params[:id] + ':' + AddonConfig.settings[:sso_salt] + ':' + params[:timestamp]
        token = Digest::SHA1.hexdigest(pre_token).to_s
        return_not_authorized if token != params[:token]
        return_not_authorized if params[:timestamp].to_i < (Time.now - 2*60).to_i
        account = Account[:uuid => params[:id]]
        return_not_authorized unless account
        session[:accounts] ||= {}
        session[:accounts][account.uuid] = params[:app] || "Heroku App"
        session[:email] ||= params[:email]
      end
      redirect "/dashboard/#{account.uuid}"
    end

    def return_not_authorized
      halt 401
    end
  end

  get '/' do
    return_not_authorized unless fake_local?
    GluIO::Metrics.time('heroku-addon-sso') do
      GluIO::Metrics.count('heroku-addon-sso')
      sso_setup
    end
  end

  post '/' do
    GluIO::Metrics.time('heroku-addon-sso') do
      GluIO::Metrics.count('heroku-addon-sso')
      sso_setup
    end
  end
end

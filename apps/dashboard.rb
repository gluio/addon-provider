require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/flash'
require 'config/addon'
class Dashboard < Sinatra::Base
  enable :sessions
  use Rack::Logger
  register Sinatra::Flash
  helpers Sinatra::ContentFor

  if ENV["RACK_ENV"] != "production"
    set :show_exceptions, true
  end
  set :session_secret, AddonConfig.settings[:session_secret]
  set :sessions, :domain => AddonConfig.settings[:domain]
  set :views, File.expand_path(File.dirname(__FILE__) + "/../views")

  helpers do
    def return_not_authorized
      halt 401
    end

    def check_auth!(account_uuid, feature_flag = nil)
      return_not_authorized unless account = has_access?(account_uuid)
      if feature_flag
        halt 402 unless account.feature_flag?(feature_flag)
      end
    end

    def has_access?(account_uuid)
      session[:accounts] ||= {}
      return !!session[:accounts][account_uuid] && Account[uuid: account_uuid]
    end

    def setup_dashboard
      @account = Account[uuid: params[:account_uuid]]
      @app_name = session[:accounts][@account.uuid]
      @email = session[:email]
    end

    def addon_config
      AddonConfig.settings
    end

    def overview_path
      "/dashboard/#{@account.uuid}"
    end

    def demo_path
      "/dashboard/#{@account.uuid}/demo"
    end

    def tabbed_content(active_tab, content)
      haml :tabs, layout: false, locals: { active_tab: active_tab, content: content }
    end

    def feature_available_on(flag)
      if feature = FeatureFlag[name: flag]
        feature.plans_dataset.order(:price_cents).first
      end
    end
  end

  error 402 do
  end

  get '/css/:sheet.css' do
    content_type 'text/css', :charset => 'utf-8'
    scss(params[:sheet].to_sym)
  end

  get '/:account_uuid' do
    GluIO::Metrics.time('dashboard') do
      check_auth!(params[:account_uuid])
      setup_dashboard
      @active_tab = "Overview"
      GluIO::Metrics.count('dashboard')
      haml :overview, layout: :dashboard
    end
  end

  get '/:account_uuid/demo' do
    GluIO::Metrics.time('dashboard/demo') do
      check_auth!(params[:account_uuid])
      setup_dashboard
      GluIO::Metrics.count('dashboard/demo')
      @active_tab = "Do a thing"
      haml :demo, layout: :dashboard
    end
  end
end

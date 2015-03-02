require './environment'
require 'config/sidekiq'
require 'app'

run Rack::URLMap.new(
  "/api/heroku" => HerokuAddonsAPI,
  "/api" => API,
  "/sso" => SingleSignOn,
  "/dashboard" => Dashboard,
  "/admin/background-jobs" => Sidekiq::Web
)

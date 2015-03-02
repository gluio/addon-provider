require 'sidekiq/web'
Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == ENV["SIDEKIQ_ADMIN_USER"] && password == ENV["SIDEKIQ_ADMIN_PASS"]
end

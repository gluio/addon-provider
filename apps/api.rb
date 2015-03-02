class API < Sinatra::Base
  use Rack::Logger

  helpers do
    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      throw(:halt, [401, "Not authorized\n"]) unless @auth.provided? && @auth.basic? && @auth.credentials
      user, pass = @auth.credentials
      if @account = Account[:uuid => user]
        @account.decrypted_password == pass && @account.resource
      else
        throw_unauthorized
      end
    end
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw_unauthorized
      end
    end

    def throw_unauthorized
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  post '/' do
    protected!
    GluIO::Metrics.time('some-api-action') do
      # do something
      content_type :json
      status 201
      GluIO::Metrics.count('some-api-action')
      Yajl::Encoder.encode({"message" => "ok"})
    end
  end
end

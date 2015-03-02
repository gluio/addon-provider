class APIError < StandardError
  def initialize(ex)
    @message = ex.message
  end

  def message
    if redisplayable?
      @message
    else
      "An error has occured, we've been notified."
    end
  end

  def to_json
    { "message" => message }
  end

  private
  def redisplayable?
    redisplayable_messages.detect{|r| @message =~ r}
  end

  def redisplayable_messages
    [
      /I'm an exception that is descriptive enough I can be re-displayed to the user as-is./
    ]
  end
end


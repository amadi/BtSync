module BtCommunicator
  include HTTParty
  def generate_secret
    res = self.class.get(path('generatesecret'), :headers => {"Cookie" => cookies })
    res.parsed_response["secret"]
  end
  def port
    @port ||= '8888'
  end
  def uri
    @uri ||= "http://localhost"
  end
  def token force = false
    @token_cache ||= 0
    time = DateTime.now.strftime("%s").to_i
    if time > @token_cache + 600 || force
      @token = request_token(force).gsub('</div></html>', '').gsub("<html><div id='token' style='display:none;'>", '')
      @token_cache = time
    end
    @cookies = nil if force
    @token
  end
  def cookies
    @cookies ||= request_token.headers["set-cookie"].split("; ")[0]
  end
  def request_token force = false
    if @request_token.nil? || force
      @request_token = self.class.get("#{uri}:#{port}/gui/token.html", :query => {:output => :text})
    else
      @request_token
    end
  end
  def path action_name
    "#{uri}:#{port}/gui/?token=#{token}&action=#{action_name}"
  end
end
require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash

  COOKIE_NAME = '_rails_lite_app'

  def initialize(req)
    all_cookies = req.cookies
    @cookie = nil

    all_cookies.each do |cookie|
      @cookie = JSON.parse(cookie.value) if cookie != {} && cookie.name == COOKIE_NAME
    end

    @cookie = {} if @cookie.nil?

    req.cookies << @cookie
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    webrick_cookie = WEBrick::Cookie.new(COOKIE_NAME, @cookie.to_json)

    res.cookies << webrick_cookie
  end
end

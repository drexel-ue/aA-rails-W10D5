require 'json'
require 'byebug'

class Session
  attr_reader :session

  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    cookie = req.cookies['_rails_lite_app']
    cookie ? @session = JSON.parse(cookie) : @session = {}
  end

  def [](key)
    @session[key]
  end

  def []=(key, val)
    @session[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
      res.set_cookie('_rails_lite_app', ActiveSupport::JSON.encode(session))
  end
end

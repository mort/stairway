require 'test_helper'

class OAuthTest < Test::Unit::TestCase
  should "initialize with consumer token and secret" do
    traveler = Traveler::OAuth.new('token', 'secret')

    traveler.ctoken.should == 'token'
    traveler.csecret.should == 'secret'
  end

  should "set autorization path to '/oauth/authorize' by default" do
    traveler = Traveler::OAuth.new('token', 'secret')
    traveler.consumer.options[:authorize_path].should == '/oauth/authorize'
  end

  should "have a consumer" do
    consumer = mock('oauth consumer')
    OAuth::Consumer.expects(:new).with('token', 'secret', {:site => 'http://durden.dev'}).returns(consumer)
    traveler = Traveler::OAuth.new('token', 'secret')

    traveler.consumer.should == consumer
  end

  should "have a request token from the consumer" do
    consumer = mock('oauth consumer')
    request_token = mock('request token')
    consumer.expects(:get_request_token).returns(request_token)
    OAuth::Consumer.expects(:new).with('token', 'secret', {:site => 'http://durden.dev'}).returns(consumer)
    traveler = Traveler::OAuth.new('token', 'secret')

    traveler.request_token.should == request_token
  end

  context "set_callback_url" do
    should "clear request token and set the callback url" do
      consumer = mock('oauth consumer')
      request_token = mock('request token')

      OAuth::Consumer.
        expects(:new).
        with('token', 'secret', {:site => 'http://durden.dev'}).
        returns(consumer)

      traveler = Traveler::OAuth.new('token', 'secret')

      consumer.
        expects(:get_request_token).
        with({:oauth_callback => 'http://myapp.com/oauth_callback'})

      traveler.set_callback_url('http://myapp.com/oauth_callback')
    end
  end

  should "be able to create access token from request token, request secret and verifier" do
    traveler = Traveler::OAuth.new('token', 'secret')
    consumer = OAuth::Consumer.new('token', 'secret', {:site => 'http://durden.dev'})
    traveler.stubs(:signing_consumer).returns(consumer)

    access_token  = mock('access token', :token => 'atoken', :secret => 'asecret')
    request_token = mock('request token')
    request_token.
      expects(:get_access_token).
      with(:oauth_verifier => 'verifier').
      returns(access_token)

    OAuth::RequestToken.
      expects(:new).
      with(consumer, 'rtoken', 'rsecret').
      returns(request_token)

    traveler.authorize_from_request('rtoken', 'rsecret', 'verifier')
    traveler.access_token.class.should be(OAuth::AccessToken)
    traveler.access_token.token.should == 'atoken'
    traveler.access_token.secret.should == 'asecret'
  end

  should "be able to create access token from access token and secret" do
    traveler = Traveler::OAuth.new('token', 'secret')
    consumer = OAuth::Consumer.new('token', 'secret', {:site => 'http://durden.dev'})
    traveler.stubs(:consumer).returns(consumer)

    traveler.authorize_from_access('atoken', 'asecret')
    traveler.access_token.class.should be(OAuth::AccessToken)
    traveler.access_token.token.should == 'atoken'
    traveler.access_token.secret.should == 'asecret'
  end

  should "delegate get to access token" do
    access_token = mock('access token')
    traveler = Traveler::OAuth.new('token', 'secret')
    traveler.stubs(:access_token).returns(access_token)
    access_token.expects(:get).returns(nil)
    traveler.get('/foo')
  end

  should "delegate post to access token" do
    access_token = mock('access token')
    traveler = Traveler::OAuth.new('token', 'secret')
    traveler.stubs(:access_token).returns(access_token)
    access_token.expects(:post).returns(nil)
    traveler.post('/foo')
  end
end

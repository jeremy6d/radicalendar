Twitter.configure do |config|
  config.consumer_key = OrvaEvents::Config.twitter.consumer_key
  config.consumer_secret = OrvaEvents::Config.twitter.consumer_secret
  config.oauth_token = OrvaEvents::Config.twitter.oauth_token
  config.oauth_token_secret = OrvaEvents::Config.twitter.oauth_token_secret
end
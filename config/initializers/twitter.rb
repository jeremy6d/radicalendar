Twitter.configure do |config|
  config.consumer_key = Config.twitter.consumer_key
  config.consumer_secret = Config.twitter.consumer_secret
  config.oauth_token = Config.twitter.oauth_token
  config.oauth_token_secret = Config.twitter.oauth_token_secret
end
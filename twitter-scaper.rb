require 'twitter'
require 'rest-client'
require 'yaml'

class TwitterScraper
  attr_accessor :client

  def initialize(options)
    @client = Twitter::REST::Client.new do |config|
                config.consumer_key        = options[:consumer_key] 
                config.consumer_secret     = options[:consumer_secret]
                config.access_token        = options[:access_token] 
                config.access_token_secret = options[:access_token_secret]
              end
  end

  def search_hashtag(hashtag, count)
    client.search('#' + hashtag).take(count).collect.map
  end  
end

class RestAPI
  attr_accessor :tweets, :users

  def initialize(address)
    @tweets = RestClient::Resource.new(address + '/tweets')
    @users = RestClient::Resource.new(address + '/users')
  end    
end

class Tweet
  attr_accessor :name, :body, :user, :user_id

  def initialize(tweet)
    @user = TweetUser.new(tweet.user)
    @name = tweet.user.screen_name
    @body = tweet.text
    @user_id = tweet.user.id
  end
end

class TweetUser

  attr_accessor :screen_name, :description, :followers_count, :location, :name, :website, :_id
  
  def initialize(user)
    @_id = user.id
    @screen_name = user.screen_name
    @description = user.description
    @followers_count = user.followers_count
    @location = user.location
    @name = user.name
    @website = user.website
  end

  def instance_variables_hash
    Hash[instance_variables.map { |name| [name.to_s[1..-1], instance_variable_get(name).nil? ? nil : instance_variable_get(name)] } ]
  end
end

class ConfigFile
  
  attr_accessor :config, :consumer_key, :consumer_secret, :access_token, :access_token_secret, :address

  def initialize
    @config = YAML.load_file("config.yml")
    @consumer_key = config["twitter"]["consumer_key"]
    @consumer_secret = config["twitter"]["consumer_secret"]
    @access_token = config["twitter"]["access_token"]
    @access_token_secret = config["twitter"]["access_token_secret"]
    @address = config["rest"]["address"]  
  end
end

cf = ConfigFile.new
twitter = TwitterScraper.new( { consumer_key: cf.consumer_key, 
                                consumer_secret: cf.consumer_secret,
                                access_token: cf.access_token,
                                access_token_secret: cf.access_token_secret } )

rest = RestAPI.new(cf.address)

twitter.search_hashtag(ARGV[0], ARGV[1].to_i).each do |t|
  tweet = Tweet.new(t)
  
  begin  
    rest.tweets.post({ name: tweet.name, body: tweet.body, user_id: tweet.user_id })
  
    rest.users.post(tweet.user.instance_variables_hash) 
   
  rescue Exception => e 
    puts e.message 
  end

end



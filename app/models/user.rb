class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid, :oauth_token, :oauth_token_secret
  has_many :links
  
  def self.from_omniauth(auth)
    delay.up
    
    where(auth.slice("provider", "uid")).first || create_from_omniauth(auth)
  end

  def self.create_from_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["nickname"]
      user.oauth_token = auth["credentials"]["token"]
      user.oauth_token_secret = auth["credentials"]["secret"]
    end
    
  end
  
  class << self
  
  def up
    Link.getTweets
  end
  handle_asynchronously :up
  
end
end

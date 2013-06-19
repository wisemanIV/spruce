require 'open-uri'
require 'json'

class Link < ActiveRecord::Base
  attr_accessible :url, :username, :follower_count, :status_id, :retweet_count, :favorite_count, :user_id, :fb_total_count, :fb_like_count, :fb_comment_count, :fb_share_count
  belongs_to :user
  validates :status_id, :uniqueness => true
  
  def self.getTweets
    
    @users = User.all
    
    @users.each do | u | 
      
      @twitter ||= Twitter::Client.new(:oauth_token => u.oauth_token,
           :oauth_token_secret => u.oauth_token_secret)
           
      @last_known_id = Link.maximum("status_id") 
      if @last_known_id.nil? then
          @last_known_id = 1
      end
          
      @timeline = @twitter.home_timeline({:since_id => @last_known_id, :count => 200})
      @timeline.each do | post |
         url = URI.escape(/https?:\/\/[\S]+/.match(post["text"]).to_s)
         
         if !url.blank? then 
           
           query = "select total_count,like_count,comment_count,share_count,click_count from link_stat where url='"+url+"'";
           call = "https://api.facebook.com/method/fql.query?query=" + URI.escape(query) + "&format=json";
         
           body = JSON.parse(open(call).read)
          
           puts "#{url} #{post["user"]["screen_name"]} #{post["user"]["follower_count"]}  #{post["id"]} #{post["retweet_count"]} #{post["favorite_count"]} #{body[0]["total_count"]} #{body[0]["like_count"]} #{body[0]["comment_count"]} #{body[0]["share_count"]}"
      
           @link = Link.create(:url => url, :username => post["user"]["screen_name"], :status_id => post["id"], :user_id => u.id, :follower_count => post["user"]["follower_count"], :retweet_count => post["retweet_count"], :favorite_count => post["favorite_count"], :fb_total_count => body[0]["total_count"].to_i, :fb_like_count => body[0]["like_count"].to_i, :fb_comment_count => body[0]["comment_count"].to_i, :fb_share_count => body[0]["share_count"].to_i)
     
         end
      end
      
    end
    
  
  end
      
  
end

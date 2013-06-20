require 'net/http'
require 'open-uri'
require 'json'

class Link < ActiveRecord::Base
  attr_accessible :url, :username, :follower_count, :status_id, :retweet_count, :favorite_count, :user_id, :fb_total_count, :fb_like_count, :fb_comment_count, :fb_share_count, :actual_url, :klout_score, :viewed
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
           
           begin
           
           query = "select total_count,like_count,comment_count,share_count,click_count from link_stat where url='"+url+"'";
           call = "https://api.facebook.com/method/fql.query?query=" + URI.escape(query) + "&format=json";
         
           body = JSON.parse(open(call).read)
           puts url
           actual_url = Net::HTTP.get_response(URI.parse(url))['location']
           
           rescue EOFError
             puts "encountered EOFError"
           rescue SocketError => e
             puts e.message
           rescue Exception => e  
             puts e.message  
           end
           
             if !actual_url.blank? then
           
                 screenname = post["user"]["screen_name"]
           
                 klout_score = getKlout(screenname)
          
                 puts "#{url} #{actual_url} #{screenname} #{post["user"]["follower_count"]}  #{post["id"]} #{post["retweet_count"]} #{post["favorite_count"]} #{body[0]["total_count"]} #{body[0]["like_count"]} #{body[0]["comment_count"]} #{body[0]["share_count"]} #{klout_score}"
      
                 @link = Link.create(:url => url, :actual_url => actual_url, :username => post["user"]["screen_name"], :status_id => post["id"], :user_id => u.id, :follower_count => post["user"]["follower_count"], :retweet_count => post["retweet_count"], :favorite_count => post["favorite_count"], :fb_total_count => body[0]["total_count"].to_i, :fb_like_count => body[0]["like_count"].to_i, :fb_comment_count => body[0]["comment_count"].to_i, :fb_share_count => body[0]["share_count"].to_i, :klout_score => klout_score)
     
            end
          
         end
      end
      
    end
    
  
  end
  
  def self.getKlout (screenname)
    
    klouturl = "http://api.klout.com/v2/identity.json/twitter?screenName="+screenname+"&key="+ENV["KLOUT_KEY"]
  
    body = JSON.parse(open(klouturl).read)
  
    kloutid = body["id"]
    
    scoreurl = "http://api.klout.com/v2/user.json/"+kloutid+"/score?key="+ENV["KLOUT_KEY"]
    
    body = JSON.parse(open(scoreurl).read)
    
    score = body["score"]
  
  end
      
  
end

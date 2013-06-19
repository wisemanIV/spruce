namespace :spruce do
  task :up => :environment do
    Link.getTweets
  end
end

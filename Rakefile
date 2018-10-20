task :environment do
  require_relative "./lib/tweet_pixles"

  @tweet_pixels = TweetPixels.new(
    twitter_id:      ENV["TWITTER_ID"],
    pixela_username: ENV["PIXELA_USERNAME"],
    pixela_token:    ENV["PIXELA_TOKEN"],
    pixela_graph_id: ENV["PIXELA_GRAPH_ID"],
  )
end

task :update_yesterday => :environment do
  @tweet_pixels.update_yesterday
end

task :update_today => :environment do
  @tweet_pixels.update_today
end

task :update_multi => :environment do
  @tweet_pixels.update_multi
end

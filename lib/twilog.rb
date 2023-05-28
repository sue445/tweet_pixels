require "open-uri"
require "date"

class Twilog
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36"

  attr_reader :twitter_id

  # @param twitter_id [String]
  def initialize(twitter_id)
    raise "twitter_id is required" unless twitter_id
    @twitter_id = twitter_id
  end

  def update
    # OpenURI::HTTPError (403 Forbidden) when no User-Agent
    URI.open("https://twilog.togetter.com/update.rb?id=#{twitter_id}&order=&filter=&kind=reg", "User-Agent" => USER_AGENT)
  end

  # @return [Hash<Date, Integer>]
  def stat_tweets_count
    html = URI.open("https://twilog.togetter.com/#{twitter_id}/stats", "User-Agent" => USER_AGENT).read

    m1 = %r{ar_data\[1\]\s*=\s*\[(.+)\];}.match(html)
    ar_data1 = m1.captures[0]
    daily_tweets = ar_data1.split(",").map(&:to_i)

    m2 = %r{ar_lbl\[1\]\s*=\s*\[(.+)\];}.match(html)
    ar_lbl1 = m2.captures[0]
    dates = ar_lbl1.split(",").map { |s| Date.parse("20" + s.gsub("'", "")) }

    unless daily_tweets.length == dates.length
      raise "miss match array length (daily_tweets.length=#{daily_tweets.length}, dates.length=#{dates.length})"
    end

    dates.zip(daily_tweets).each_with_object({}) do |(date, tweet), hash|
      hash[date] = tweet
    end
  end
end

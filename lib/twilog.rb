require "open-uri"
require "date"
require "capybara"
require "selenium-webdriver"

class Twilog
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36"

  DEFAULT_CHROME_OPTIONS_ARGS = %W(
    headless
    disable-gpu
    window-size=1280,800
    no-sandbox
    user-agent=#{USER_AGENT}
  ).freeze

  attr_reader :twitter_id

  # @param twitter_id [String]
  def initialize(twitter_id)
    raise "twitter_id is required" unless twitter_id
    @twitter_id = twitter_id
  end

  def update
    session.visit(twilog_url)
    session.find(:xpath, "//section[@id='side-update']//input[@type='submit' and @class='ub']").click

    if session.current_url != twilog_url && session.current_url != "#{twilog_url}?status=fetchSuccess"
      raise "current_url is unexpected: #{session.current_url}"
    end
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

  # @return [Capybara::Session]
  def session
    return @session if @session

    Capybara.register_driver :chrome_headless do |app|
      client = Selenium::WebDriver::Remote::Http::Default.new
      client.read_timeout = 120

      chrome_options = { args: DEFAULT_CHROME_OPTIONS_ARGS }

      opts = Selenium::WebDriver::Chrome::Options.new(profile: nil, **chrome_options)

      Capybara::Selenium::Driver.new(
        app,
        browser: :chrome,
        options: opts,
        http_client: client,
      )
    end

    @session = Capybara::Session.new(:chrome_headless)
  end

  # @return [String]
  def twilog_url
    "https://twilog.togetter.com/#{twitter_id}"
  end
end

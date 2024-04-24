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
    session.find(:xpath, "//form[@action='/#{@twitter_id}/fetch']//input[@type='submit']").click

    case session.current_url
    when twilog_url
      # nop
    when "#{twilog_url}?status=fetchSuccess"
      # FIXME: Because side-recent isn't instantly updated...
      puts "Wait for updating"
      sleep 10
    else
      raise "current_url is unexpected: #{session.current_url}"
    end
  end

  # @return [Hash<Date, Integer>]
  def recent_tweets_count
    session.visit(twilog_url)

    session.all("#side-recent ul li a").each_with_object({}) do |a, tweets|
      m = /date-([0-9]{6})$/.match(a["href"])
      date = Date.parse("20" + m[1])
      count = a.find("span").text.to_i

      tweets[date] = count
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

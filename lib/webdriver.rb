require 'watir-webdriver'
require 'rufus/scheduler'

class Webdriver
  def initialize(config, cookie_file)
    @base_url = config['base_url']
    @refresh_interval = config['refresh_interval'] || '1m'
    @cookie_file = cookie_file
    @current_url = @base_url
    @browser = Watir::Browser.new

    # Maximise and lose chrome
    @browser.send_keys :f11

    # Navigate to calendar, ready to load cookies
    @browser.goto @current_url
    Watir::Wait.until { @browser.body.visible? }

    # Load the cookies for the domain, then refresh
    @browser.cookies.load(@cookie_file)
    @browser.goto @current_url

    # Create a scheduled job to kick an update every minute
    @scheduler = Rufus::Scheduler.new
    @scheduler.interval @refresh_interval do
      refresh
    end

    # And keep the auth cookie fresh
    @scheduler.every '1h' do
      store_cookies
    end
  end

private
  def refresh
    @browser.goto @current_url
  end

  def store_cookies
    Watir::Wait.until { @browser.body.visible? }
    @browser.cookies.save(@cookie_file)
  end
end
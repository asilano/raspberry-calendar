require 'watir-webdriver'
require 'rufus/scheduler'

class Webdriver
  def initialize(config, cookie_file)
    @base_url = config['base_url']
    @refresh_interval = config['refresh_interval'] || '1m'
    @reset_interval = config['reset_to_base_timeout'] || '10m'
    @cookie_file = cookie_file
    @current_url = @base_url

    spawn_browser

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

  def show(params)
    @scheduler.pause
    @current_url = @base_url + params
    refresh
    Watir::Wait.until { @browser.body.visible? }

    # Schedule a reset-to-base
    if @reset_job
      @reset_job.unschedule
    end
    @reset_job = @scheduler.schedule_in @reset_interval do
      @current_url = @base_url
      puts "  Resetting to base..."
    end

    @scheduler.resume
  end

  def reset
    spawn_browser
  end

private
  def spawn_browser
    if @browser
      begin
        @browser.close
      rescue
      end
    end

    @browser = Watir::Browser.new

    # Maximise and lose chrome
    @browser.send_keys :f11

    # Navigate to calendar, ready to load cookies
    @browser.goto @current_url
    Watir::Wait.until { @browser.body.visible? }

    # Load the cookies for the domain, then refresh
    @browser.cookies.load(@cookie_file)
    @browser.goto @current_url
  end

  def refresh
    @browser.goto @current_url
  rescue
    spawn_browser
  end

  def store_cookies
    Watir::Wait.until { @browser.body.visible? }
    @browser.cookies.save(@cookie_file)
  end
end
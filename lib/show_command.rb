require 'active_support'
require 'active_support/core_ext/date'
require 'time_parser'

class ShowCommand
  def initialize(date_string)
    # Parse the time-string. Just a few things now.
    @params = nil

    date, scope = TimeParser.parse_date date_string
    if date && scope
      date_str = date.strftime('%Y%m%d')
      @params = "&mode=#{scope}&dates=#{date_str}%2f#{date_str}"
    end
  end

  def execute(ctrl)
    ctrl.webdriver.show(@params) if @params
  end
end

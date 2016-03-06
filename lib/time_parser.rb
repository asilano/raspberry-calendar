require 'regex_constants'
require 'deordinalize'
require 'numbers_in_words'
require 'active_support'
require 'active_support/core_ext/date'
require 'active_support/core_ext/numeric'

class TimeParser
  include RegexConstants

  TodayRE = /^today$/i
  TomoRE = /^tomorrow$/i
  YesterRE = /^yesterday$/i

  RelativeRE = /^(?<direction>this|next|last) (?<period>week|month)$/i

  DayThisMonthRE = /^(?<weekOf>week (containing |beginning )?)?(?<day>#{Ordinals})$/i
  DayInMonthRE = /^(?<weekOf>week (containing |beginning )?)?((?<daymonth>(?:#{Ordinals} #{Months}))|(?<monthday>(#{Months} #{Ordinals})))(?: (?<year>.*))?$/i

  MonthInYearRE = /^(?<month>#{Months})(?: (?<year>.*))?$/i
  NextDayRE = /^(?<day>#{Days})$/

  # Returns date, scope; where scope is how specific the time-string was - :day, :week, :month
  def self.parse_date(date_string)
    date_string.gsub!(/\b\s*(the|of)\s*\b/, ' ')
    date_string.strip!

    today = TodayRE.match date_string
    tomorrow = TomoRE.match date_string
    yesterday = YesterRE.match date_string
    relative = RelativeRE.match date_string
    dayThisMonth = DayThisMonthRE.match date_string
    dayInMonth = DayInMonthRE.match date_string
    monthInYear = MonthInYearRE.match date_string
    nextDay = NextDayRE.match date_string

    if today
      [Date.current, :day]
    elsif tomorrow
      [Date.tomorrow, :day]
    elsif yesterday
      [Date.yesterday, :day]
    elsif relative
      scope = relative[:period].to_sym
      date = Date.current
      if relative[:direction] == 'last'
        date = date.advance({week: :weeks, month: :months}[scope] => -1)
      elsif relative[:direction] == 'next'
        date = date.advance({week: :weeks, month: :months}[scope] => 1)
      end
      [date, scope]
    elsif dayThisMonth
      scope = dayThisMonth[:weekOf] ? :week : :day
      [Date.new(Date.current.year, Date.current.month, dayThisMonth[:day].deordinalize), scope]
    elsif dayInMonth
      year_str = dayInMonth[:year]
      year = year_str ? NumbersInWords.in_numbers(year_str) : 0
      if year < 2000 || year > 2050
        year = Date.current.year
      end
      scope = dayInMonth[:weekOf] ? :week : :day
      day, month = dayInMonth[:daymonth] ? dayInMonth[:daymonth].split : dayInMonth[:monthday].split.reverse
      month.capitalize!
      [Date.new(year, Date::MONTHNAMES.index(month), day.deordinalize), scope]
    elsif monthInYear
      month = Date::MONTHNAMES.index(monthInYear[:month].capitalize)
      year_str = monthInYear[:year]
      year = year_str ? NumbersInWords.in_numbers(year_str) : 0

      if year < 2000 || year > 2050
        year = Date.current.year
        year += 1 if month < Date.current.month
      end

      [Date.new(year, month, 1), :month]
    elsif nextDay
      day = Date::DAYNAMES.index(nextDay[:day].capitalize)
      diff = day - Date.current.wday
      diff += 7 if diff < 1

      [Date.current + diff.days, :day]
    else
      [nil, nil]
    end
    # "week (containing|beginning) <ordinal> ((of)? <month> <year>?)?"


  end
end
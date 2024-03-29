require 'date'
require 'ice_cube/deprecated'

# Use psych if we can
begin
  require 'psych'
rescue LoadError
  require 'yaml'
end

module IceCube

  autoload :VERSION, 'ice_cube/version'

  autoload :TimeUtil, 'ice_cube/time_util'
  autoload :FlexibleHash, 'ice_cube/flexible_hash'

  autoload :Rule, 'ice_cube/rule'
  autoload :Schedule, 'ice_cube/schedule'
  autoload :Occurrence, 'ice_cube/occurrence'

  autoload :IcalBuilder, 'ice_cube/builders/ical_builder'
  autoload :HashBuilder, 'ice_cube/builders/hash_builder'
  autoload :StringBuilder, 'ice_cube/builders/string_builder'

  autoload :CountExceeded, 'ice_cube/errors/count_exceeded'
  autoload :UntilExceeded, 'ice_cube/errors/until_exceeded'
  autoload :ZeroInterval, 'ice_cube/errors/zero_interval'

  autoload :ValidatedRule, 'ice_cube/validated_rule'
  autoload :SingleOccurrenceRule, 'ice_cube/single_occurrence_rule'

  autoload :SecondlyRule, 'ice_cube/rules/secondly_rule'
  autoload :MinutelyRule, 'ice_cube/rules/minutely_rule'
  autoload :HourlyRule, 'ice_cube/rules/hourly_rule'
  autoload :DailyRule, 'ice_cube/rules/daily_rule'
  autoload :WeeklyRule, 'ice_cube/rules/weekly_rule'
  autoload :MonthlyRule, 'ice_cube/rules/monthly_rule'
  autoload :YearlyRule, 'ice_cube/rules/yearly_rule'

  module Validations

    autoload :Lock, 'ice_cube/validations/lock'
    autoload :ScheduleLock, 'ice_cube/validations/schedule_lock'

    autoload :Count, 'ice_cube/validations/count'
    autoload :Until, 'ice_cube/validations/until'

    autoload :SecondlyInterval, 'ice_cube/validations/secondly_interval'
    autoload :MinutelyInterval, 'ice_cube/validations/minutely_interval'
    autoload :DailyInterval, 'ice_cube/validations/daily_interval'
    autoload :WeeklyInterval, 'ice_cube/validations/weekly_interval'
    autoload :MonthlyInterval, 'ice_cube/validations/monthly_interval'
    autoload :YearlyInterval, 'ice_cube/validations/yearly_interval'
    autoload :HourlyInterval, 'ice_cube/validations/hourly_interval'
    
    autoload :MonthlyBySetPos, 'ice_cube/validations/monthly_by_set_pos'
    autoload :YearlyBySetPos, 'ice_cube/validations/yearly_by_set_pos'
    
    autoload :HourOfDay, 'ice_cube/validations/hour_of_day'
    autoload :MonthOfYear, 'ice_cube/validations/month_of_year'
    autoload :MinuteOfHour, 'ice_cube/validations/minute_of_hour'
    autoload :SecondOfMinute, 'ice_cube/validations/second_of_minute'
    autoload :DayOfMonth, 'ice_cube/validations/day_of_month'
    autoload :DayOfWeek, 'ice_cube/validations/day_of_week'
    autoload :Day, 'ice_cube/validations/day'
    autoload :DayOfYear, 'ice_cube/validations/day_of_year'

  end

  # Define some useful constants
  ONE_SECOND = 1
  ONE_MINUTE = ONE_SECOND * 60
  ONE_HOUR =   ONE_MINUTE * 60
  ONE_DAY =    ONE_HOUR   * 24
  ONE_WEEK =   ONE_DAY    * 7

  def self.use_psych?
    @use_psych ||= defined?(Psych) && defined?(Psych::VERSION)
  end

  # Defines the format used by IceCube when printing out Schedule#to_s.
  # Defaults to '%B %e, %Y'
  def self.to_s_time_format
    @to_s_time_format ||= '%B %e, %Y'
  end

  # Sets the format used by IceCube when printing out Schedule#to_s.
  def self.to_s_time_format=(format)
    @to_s_time_format = format
  end
end

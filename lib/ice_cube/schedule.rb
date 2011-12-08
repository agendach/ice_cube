require 'yaml'

module IceCube

  class Schedule

    # Get the start time
    attr_accessor :start_time
    alias :start_date :start_time
    alias :start_date= :start_time=
    
    # Get the duration
    attr_accessor :duration

    # Get the end time
    attr_accessor :end_time
    alias :end_date :end_time

    # Create a new schedule
    def initialize(start_time = nil, options = {})
      @start_time = start_time || Time.now
      @end_time = options[:end_time]
      @duration = options[:duration]
      @all_recurrence_rules = []
      @all_exception_rules = []
    end

    # Add a recurrence time to the schedule
    def add_recurrence_time(time)
      return nil if time.nil?
      rule = SingleOccurrenceRule.new(time)
      add_recurrence_rule rule
      time
    end
    alias :rdate :add_recurrence_time
    alias :add_recurrence_date :add_recurrence_time

    # Add an exception time to the schedule
    def add_exception_time(time)
      return nil if time.nil?
      rule = SingleOccurrenceRule.new(time)
      add_exception_rule rule
      time
    end
    alias :exdate :add_exception_time
    alias :add_exception_date :add_exception_time

    # Add a recurrence rule to the schedule
    def add_recurrence_rule(rule)
      @all_recurrence_rules << rule unless @all_recurrence_rules.include?(rule)
    end
    alias :rrule :add_recurrence_rule

    # Remove a recurrence rule
    def remove_recurrence_rule(rule)
      res = @all_recurrence_rules.delete(rule)
      res.nil? ? [] : [res]
    end

    # Add an exception rule to the schedule
    def add_exception_rule(rule)
      @all_exception_rules << rule unless @all_exception_rules.include?(rule)
    end
    alias :exrule :add_exception_rule

    # Remove an exception rule
    def remove_exception_rule(rule)
      res = @all_exception_rules.delete(rule)
      res.nil? ? [] : [res]
    end

    # Get the recurrence rules
    def recurrence_rules
      @all_recurrence_rules.reject { |r| r.is_a?(SingleOccurrenceRule) }
    end
    alias :rrules :recurrence_rules

    # Get the exception rules
    def exception_rules
      @all_exception_rules.reject { |r| r.is_a?(SingleOccurrenceRule) }
    end
    alias :exrules :exception_rules

    # Get the recurrence times that are on the schedule
    def recurrence_times
      @all_recurrence_rules.select { |r| r.is_a?(SingleOccurrenceRule) }.map(&:time)
    end
    alias :rdates :recurrence_times
    alias :recurrence_dates :recurrence_times

    # Remove a recurrence time
    def remove_recurrence_time(time)
      found = false
      @all_recurrence_rules.delete_if do |rule|
        found = true if rule.is_a?(SingleOccurrenceRule) && rule.time == time
      end
      time if found
    end
    alias :remove_recurrence_date :remove_recurrence_time
    alias :remove_rdate :remove_recurrence_time

    # Get the exception times that are on the schedule
    def exception_times
      @all_exception_rules.select { |r| r.is_a?(SingleOccurrenceRule) }.map(&:time)
    end
    alias :exdates :exception_times
    alias :exception_dates :exception_times

    # Remove an exception time
    def remove_exception_time(time)
      found = false
      @all_exception_rules.delete_if do |rule|
        found = true if rule.is_a?(SingleOccurrenceRule) && rule.time == time
      end
      time if found
    end
    alias :remove_exception_date :remove_exception_time
    alias :remove_exdate :remove_exception_time

    # Get all of the occurrences from the start_time up until a
    # given Time
    def occurrences(closing_time)
      find_occurrences(start_time, closing_time)
    end

    # All of the occurrences
    def all_occurrences
      find_occurrences(start_time)
    end

    # The next n occurrences after now
    def next_occurrences(num, from = Time.now)
      find_occurrences(from + 1, nil, num)
    end

    # The next occurrence after now (overridable)
    def next_occurrence(from = Time.now)
      find_occurrences(from + 1, nil, 1).first
    end

    # The remaining occurrences (same requirements as all_occurrences)
    def remaining_occurrences(from = Time.now)
      find_occurrences(from)
    end

    # Occurrences between two times
    def occurrences_between(begin_time, closing_time)
      find_occurrences(begin_time, closing_time)
    end

    # Return a boolean indicating if an occurrence falls between
    # two times
    def occurs_between?(begin_time, closing_time)
      !find_occurrences(begin_time, closing_time, 1).empty?
    end

    # Return a boolean indicating if an occurrence falls on a certain date
    def occurs_on?(date)
      begin_time = TimeUtil.beginning_of_date(date)
      closing_time = TimeUtil.end_of_date(date)
      occurs_between?(begin_time, closing_time)
    end

    # Determine if the schedule is occurring at a given time
    def occurring_at?(time)
      if duration
        return false if exception_time?(time)
        occurs_between?(time - duration + 1, time)
      else
        occurs_at?(time)
      end
    end

    # Determine if the schedule occurs at a specific time
    def occurs_at?(time)
      occurs_between?(time, time)
    end

    # Get the first n occurrences, or the first occurrence if n is skipped
    def first(n = nil)
      occurrences = find_occurrences start_time, nil, n || 1
      n.nil? ? occurrences.first : occurrences
    end

    # String serialization
    def to_s
      pieces = []
      ed = exdates; rd = rdates - ed
      pieces.concat rd.sort.map { |t| t.strftime(TO_S_TIME_FORMAT) }
      pieces.concat rrules.map { |t| t.to_s }
      pieces.concat exrules.map { |t| "not #{t.to_s}" }
      pieces.concat ed.sort.map { |t| "not on #{t.strftime(TO_S_TIME_FORMAT)}" }
      pieces << "until #{end_time.strftime(TIME_FORMAT)}" if end_time
      pieces.join(' / ')
    end

    # Serialize this schedule to_ical
    def to_ical(force_utc = false)
      pieces = []
      pieces << "DTSTART#{IcalBuilder.ical_format(start_time, force_utc)}"
      pieces << "DURATION:#{IcalBuilder.ical_duration(duration)}" if duration
      pieces.concat recurrence_rules.map { |r| "RRULE:#{r.to_ical}" }
      pieces.concat exception_rules.map { |r| "EXRULE:#{r.to_ical}" }
      pieces.concat recurrence_times.map { |t| "RDATE#{IcalBuilder.ical_format(t, force_utc)}" }
      pieces.concat exception_times.map { |t| "EXDATE#{IcalBuilder.ical_format(t, force_utc)}" }
      pieces << "DTEND#{IcalBuilder.ical_format(end_time, force_utc)}" if end_time
      pieces.join("\n")
    end

    # Convert the schedule to yaml
    def to_yaml(*args)
      to_hash.to_yaml(*args)
    end

    # Convert the schedule to a hash
    # TODO make sure these names are the same
    def to_hash
      data = {}
      data[:start_date] = TimeUtil.serialize_time(start_time)
      data[:end_time] = end_time if end_time
      data[:duration] = duration if duration
      data[:rrules] = recurrence_rules.map(&:to_hash)
      data[:exrules] = exception_rules.map(&:to_hash)
      data[:rdates] = recurrence_times.map do |rt|
        TimeUtil.serialize_time(rt)
      end
      data[:exdates] = exception_times.map do |et|
        TimeUtil.serialize_time(et)
      end
      data
    end

    # Load the schedule from a hash
    def self.from_hash(data, options = {})
      data[:start_date] = options[:start_date_override] if options[:start_date_override]
      # And then deserialize
      schedule = IceCube::Schedule.new TimeUtil.deserialize_time(data[:start_date])
      schedule.duration = data[:duration] if data[:duration]
      schedule.end_time = TimeUtil.deserialize_time(data[:end_time]) if data[:end_time]
      data[:rrules] && data[:rrules].each { |h| schedule.rrule(IceCube::Rule.from_hash(h)) }  
      data[:exrules] && data[:exrules].each { |h| schedule.exrule(IceCube::Rule.from_hash(h)) }
      data[:rdates] && data[:rdates].each do |t|
        schedule.add_recurrence_time TimeUtil.deserialize_time(t)
      end
      data[:exdates] && data[:exdates].each do |t|
        schedule.add_exception_time TimeUtil.deserialize_time(t)
      end
      schedule
    end

    # Load the schedule from yaml
    def self.from_yaml(yaml, options = {})
      from_hash YAML.load(yaml), options
    end

    private

    # Reset all rules for another run
    def reset
      @all_recurrence_rules.each(&:reset)
      @all_exception_rules.each(&:reset)
    end

    # Find all of the occurrences for the schedule between opening_time
    # and closing_time
    def find_occurrences(opening_time, closing_time = nil, limit = nil)
      reset
      answers = []
      # ensure the bounds are proper
      if end_time
        closing_time = end_time unless closing_time && closing_time < @end_time
      end
      opening_time = start_time if opening_time < start_time
      # And off we go
      time = opening_time
      loop do
        res = next_time(time, closing_time)
        break unless res
        break if closing_time && res > closing_time
        answers << res
        break if limit && answers.length == limit
        time = res + 1
      end
      # and return our answers
      answers
    end

    # Get the next time after (or including) a specific time
    def next_time(time, closing_time)
      min_time = nil
      loop do
        @all_recurrence_rules.each do |rule|
          begin
            if res = rule.next_time(time, self, closing_time)
              if min_time.nil? || res < min_time
                min_time = res
              end
            end
          # Certain exceptions mean this rule no longer wants to play
          rescue CountExceeded, UntilExceeded
            next
          end
        end
        # If there is no match, return nil
        return nil unless min_time
        # Now make sure that its not an exception_time, and if it is
        # then keep looking
        if exception_time?(min_time)
          time = min_time + 1
          min_time = nil
          next
        end
        # Break, we're done
        break
      end
      min_time
    end

    # Return a boolean indicating whether or not a specific time
    # is excluded from the schedule
    def exception_time?(time)
      @all_exception_rules.any? do |rule|
        rule.on?(time, self)
      end
    end

  end

end

module IceCube

  class YearlyRule < ValidatedRule

    include Validations::YearlyInterval
    include Validations::YearlyBySetPos

    def initialize(interval = 1)
      super
      interval(interval)
      schedule_lock(:month, :day, :hour, :min, :sec)
      reset
    end

  end

end

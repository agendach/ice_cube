module IceCube

  module Validations::DayOfMonth

    include Validations::Lock

    def day_of_month(*days)
      days.each do |day|
        validations_for(:day_of_month) << Validation.new(day)
      end
      clobber_base_validations(:day, :wday)
      self
    end

    class Validation

      include Validations::Lock

      attr_reader :day
      alias :value :day

      def initialize(day)
        @day = day
      end

      def type
        :day
      end

    end

  end

end
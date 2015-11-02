class AirportChallenge
  # attr_reader :rspec_tests, :rspec_failures, :rubocop_offenses_detected, :coverall_coverage, :reek_warnings
  def initialize(rspec_tests:, rspec_failures:, rubocop_offenses_detected:, coverall_coverage:, reek_warnings:)
    local_variables.each do |v|
      value = (v.nil? ? 0 :  eval(v.to_s))
      value = (value.nil? ? 0 :  value)
      instance_variable_set("@#{v}", value) 
    end
  end
  # could  generalize with method_missing - but defending against incoming data in initialize better
  def rspec_tests
    @rspec_tests.nil? ? 0 : @rspec_tests.to_f / 19.0 # TODO have to work out max values for the set ... class method
  end
  def rspec_failures
    @rspec_failures.nil? ? 0 : @rspec_failures.to_f
  end
  def rubocop_offenses_detected
    @rubocop_offenses_detected.nil? ? 0 : @rubocop_offenses_detected.to_f / 31.0
  end
  def coverall_coverage
    @coverall_coverage.nil? ? 0 : @coverall_coverage.to_f / 100.0
  end
  def reek_warnings
    @reek_warnings.nil? ? 0 : @reek_warnings.to_f / 4.0
  end
end

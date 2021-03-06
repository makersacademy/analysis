require_relative '../data/start_dates'

class Person
  # include Forwardable
  AVERAGE_DAYS_TO_OFFER = 149 # people.map &:days_to_offer ; pos_days = days.select{|d|d > 0} ; pos_days.inject(:+)/pos_days.count
  attr_reader :name, :cohort, :first_offer_date, :salary, :company, :currency
  # delegate :rspec_tests, :airport_challenge
  attr_accessor :airport_challenge
  def initialize(name:, github_id:, cohort:, first_offer_date:, salary:, company:, currency:)
    local_variables.each { |v| instance_variable_set("@#{v}", eval(v.to_s) ) }
  end

  # strip url components if present
  def github_id
    @github_id.gsub(/(https?\:\/\/)?(www\.)?github\.com\//, '').gsub(/\/CV/i,'').gsub(/\/Github\-CV/,'').strip
  end

  def days_to_offer
    return AVERAGE_DAYS_TO_OFFER * 2 if first_offer_date.strip.empty? # count give double the max length as a guestimate for the population?
    offer = Date.parse first_offer_date
    cohort_start = Date.parse cohort # TODO this is not quite correct - need to correct for actual start of cohort ...
    (offer - cohort_start).to_f 
  end

  def start_date
    Date.parse(START_DATES[cohort.to_sym])
  end
end
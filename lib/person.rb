class Person
  AVERAGE_DAYS_TO_OFFER = 149 # people.map &:days_to_offer ; pos_days = days.select{|d|d > 0} ; pos_days.inject(:+)/pos_days.count
  attr_reader :name, :cohort, :first_offer_date, :salary, :company, :currency
  attr_accessor :airport_challenge
  def initialize(name:, github_id:, cohort:, first_offer_date:, salary:, company:, currency:)
    local_variables.each { |v| instance_variable_set("@#{v}", eval(v.to_s) ) }
  end

  # strip url components if present
  def github_id
    @github_id.gsub(/(https?\:\/\/)?(www\.)?github\.com\//, '').gsub(/\/CV/i,'').gsub(/\/Github\-CV/,'').strip
  end

  def days_to_offer
    return 1 if first_offer_date.empty? # count give double the max length as a guestimate for the population?
    offer = Date.parse first_offer_date
    cohort_start = Date.parse cohort # TODO this is not quite correct - need to correct for actual start of cohort ...
    (offer - cohort_start).to_f / (AVERAGE_DAYS_TO_OFFER * 2)
  end
end
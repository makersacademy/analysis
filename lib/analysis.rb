require 'csv'

CSV_CONFIG = { headers: true, header_converters: :symbol }

# hired_data = CSV.read('hired_data.csv',CSV_CONFIG)

class Person
  attr_reader :name, :cohort, :first_offer_date, :salary, :company, :currency
  def initialize(name:, github_id:, cohort:, first_offer_date:, salary:, company:, currency:)
    # must be simpler way to do this ...
    @name = name
    @github_id = github_id
    @cohort = cohort
    @first_offer_date = first_offer_date
    @salary = salary
    @company = company
    @currency = currency
  end

  # strip url components if present
  def github_id
    @github_id.gsub(/(https?\:\/\/)?(www\.)?github\.com\//, '').gsub(/\/CV/i,'').gsub(/\/Github\-CV/,'')
  end
end


people = []
CSV.foreach('hired_data.csv',CSV_CONFIG) do |row|
  # so for each person we'd like to get some data about them, e.g #rubocop fails on their airport challenge
  # hackily we could be jumping directories to do that, or we could dump that from directories as a file?
  # or start mucking about with storing in a db?
  people << Person.new(row.to_hash)
end

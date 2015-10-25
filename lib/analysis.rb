require 'csv'
require_relative 'airport_challenge'
require_relative 'person'
require 'yaml'

CSV_CONFIG = { headers: true, header_converters: :symbol }

# hired_data = CSV.read('hired_data.csv',CSV_CONFIG)

    # could be generating readers through metaprogramming --> should just use struct?
    # @name = name
    # @github_id = github_id
    # @cohort = cohort
    # @first_offer_date = first_offer_date
    # @salary = salary
    # @company = company
    # @currency = currency

people = []

# files = []
# CSV.foreach('hired_data.csv',CSV_CONFIG) do |row|
#   person = Person.new(row.to_hash)
#   files << [person.github_id, "../airport_challenge/analysis/#{person.github_id}.txt"]
# end

# people = []
# CSV.foreach('hired_data.csv',CSV_CONFIG) do |row|
#   people << Person.new(row.to_hash)
# end
# people.map &:days_to_offer


# files.select { |f| !File.exists? f[1] }.map {|f| f[0]}

  
CSV.foreach('hired_data.csv',CSV_CONFIG) do |row|
  # so for each person we'd like to get some data about them, e.g #rubocop fails on their airport challenge
  # hackily we could be jumping directories to do that, or we could dump that from directories as a file?
  # or start mucking about with storing in a db?
  # dumping files feels good
  person = Person.new(row.to_hash)

  
  # so here we should be loading the right file - grabbing the data from it - performing correlation analysis (ruby package for that https://github.com/sciruby/statsample ?)
  file = "../airport_challenge/analysis/#{person.github_id}.txt"
  airport_challenge_data = File.read(file) 
  rspec_tests = airport_challenge_data[/(\d+) examples, (\d+) failure/, 1]
  rspec_failures = airport_challenge_data[/(\d+) examples, (\d+) failure/, 2]

  rubocop_files_inspected = airport_challenge_data[/(\d+) files inspected, (\d+) offenses detected/, 1]
  rubocop_offenses_detected = airport_challenge_data[/(\d+) files inspected, (\d+) offenses detected/, 2]

  reek_warnings = airport_challenge_data[/(\d+) total warning/, 1]

  coverage_percentages = airport_challenge_data.scan(/\[\d+m(\d+)\%/)
  unless coverage_percentages.empty?
    coverall_coverage = coverage_percentages.map { |p| p[0].to_i }.inject(:+)/coverage_percentages.count
  end


  person.airport_challenge = AirportChallenge.new rspec_tests: rspec_tests, 
    rspec_failures: rspec_failures, 
    rubocop_offenses_detected: rubocop_offenses_detected, 
    coverall_coverage: coverall_coverage,
    reek_warnings: reek_warnings
  # no pull request for majieck? it was there - somehow didn't get pulled in ...
  # ilyafaybisovich --> deleted his original version? had a lab week version ...
  # found another 61 missing --> might need to look at them individually?  will try fetch
  # possible reasons include deleted pull request, deleted repo, changed github user name
  # * andyg72 --> changed to andygnewman
  # * robertpulson --> no airport challenge repo
  #  JUNK DATA FOR MOST OF DECEMBER AND FEBRUARY COHORTS - need to check all repos and redo basir
  # Airport challenge runs
  #  => ["andyg72", "theoleanse", "minhajraz", "bhrinchev", "siavosh", "timoxman", "stefan2422", "benjamink14", "monooran1", "guspowell", "andyg72", "ddemkiw", "iggyster3", "kierangoodacre", "mgedw", "tekhuy", "clint77", "indiadearlove", "olucas92", "jjlakin", "HannahCarney", "ciawalsh", "jackrubio26", "BibianaC", "stepholdcorn", "marcinwal", "matteomanzo", "jindai1783", "sandagolcea", "emilysas", "ptolemybarnes", "lukeclewlow", "jacobmitchinson", "jakealvarez", "GabeMaker", "noughtsandones", "newmanj77", "katebeavis", "c-christenson", "alexparkinson1", "ErikAGriffin", "costassarris", "wardymate", "robertpulson", "TStrothjohann", "tomcoakes", " kevinlanzon", "sphaughton", "SebastienPires", " guidovitafinzi", "vvirgitti", "tommasobratto", "eddbrown", "braunsnow", "Pau1fitz", "velingcreate", "loris-fo", "meads58", "RizAli", "jdiegoromero", "user9319062"] 
  people << person
  # want to read into single file and regex out some stats ...

  # do we want to just append the hiring data to the end of the existing airport challenge data?
end


File.open('airport_challenge_summary.yml','a') { |f| f.write people.to_yaml }
# people = YAML.read File.read('airport_challenge_summary.yml')

# then dump this to YAML?  we'll have a dataset that includes all the necessary data?


#  then for analysis we need:
# {
#   days_to_offer: people.map(&:days_to_offer),
#   rspec_tests: people.map { |p| p.airport_challenge.rspec_tests },
#   rspec_failures: people.map { |p| p.airport_challenge.rspec_failures },
#   rubocop_offenses_detected: people.map { |p| p.airport_challenge.rubocop_offenses_detected },
#   coverall_coverage: people.map { |p| p.airport_challenge.coverall_coverage },
#   reek_warnings: people.map { |p| p.airport_challenge.reek_warnings }
# }










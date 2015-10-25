require 'iruby'
require 'statsample'
require 'pp'
require_relative 'airport_challenge'
require_relative 'person'
require 'yaml'

Statsample::Analysis.store("Statsample::Bivariate.correlation_matrix") do
  
  # It so happens that Daru::Vector and Daru::DataFrame must update metadata
  # like positions of missing values every time they are created. 
  #
  # Since we dont have any missing values in the data that we are creating, 
  # we set Daru.lazy_update = true so that missing data is not updated every
  # time and things happen much faster.
  #
  # In case you do have missing data and lazy_update has been set to *true*, 
  # you _SHOULD_ called `#update` on the concerned Vector or DataFrame object
  # everytime an assingment or deletion cycle is complete.
  Daru.lazy_update = true
  
  # Create a Daru::DataFrame containing 4 vectors a, b, c and d.
  #
  # Notice that the `clone` option has been set to *false*. This tells Daru
  # to not clone the Daru::Vectors being supplied by `rnorm`, since it would
  # be unnecessarily counter productive to clone the vectors once they have
  # been assigned to the dataframe.

  people = YAML.load(File.read('airport_challenge_summary.yml'))

  ds = Daru::DataFrame.new({
    days_to_offer: people.map(&:days_to_offer),
    rspec_tests: people.map { |p| p.airport_challenge.rspec_tests },
    rspec_failures: people.map { |p| p.airport_challenge.rspec_failures },
    rubocop_offenses_detected: people.map { |p| p.airport_challenge.rubocop_offenses_detected },
    coverall_coverage: people.map { |p| p.airport_challenge.coverall_coverage },
    reek_warnings: people.map { |p| p.airport_challenge.reek_warnings }
  }, clone: false)
  
  
  puts "== DataFrame ==\n"
  pp ds.head
  
  # Calculate correlation matrix by calling the `cor` shorthand.
  # cm = Statsample::Bivariate.correlation_matrix(ds)

  cm=cor(ds) 
  puts "\n== Correlation Matrix ==\n"
  summary(cm)
  # pp cm

  # require 'byebug' ; byebug
  
  # puts "\n== Correlation Matrix ==\n"
  # pp cm
  
  # Set lazy_update to *false* once our job is done so that this analysis does
  # not accidentally affect code elsewhere.
  Daru.lazy_update = false
end

Statsample::Analysis.run_batch
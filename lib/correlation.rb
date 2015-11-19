# require 'iruby'
require 'statsample'
require 'pp'
require_relative 'airport_challenge'
require_relative 'person'
require 'yaml'
require 'nyaplot'
require 'nyaplot3d'

module Enumerable
  def normalize!
    xMin,xMax = self.minmax
    dx = (xMax-xMin).to_f
    self.map! {|x| (x-xMin) / dx }
  end
  def sum
    self.inject(0){|accum, i| accum + i }
  end

  def mean
    self.sum/self.length.to_f
  end

  def sample_variance
    m = self.mean
    sum = self.inject(0){|accum, i| accum +(i-m)**2 }
    sum/(self.length - 1).to_f
  end

  def standard_deviation
    return Math.sqrt(self.sample_variance)
  end
end

class Hash
  def hmap(&block)
    Hash[self.map {|k, v| block.call(k,v) }]
  end
end

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

  # TODO can Daru::DataFrame give us other stats and graphs???
  # checks of significance?

  people = YAML.load(File.read('data/airport_challenge_summary.yml'))

  ds = Daru::DataFrame.new({
    days_to_offer: people.map(&:days_to_offer),
    rspec_tests: people.map { |p| p.airport_challenge.rspec_tests }, 
    rspec_failures: people.map { |p| p.airport_challenge.rspec_failures },
    rubocop_offenses_detected: people.map { |p| p.airport_challenge.rubocop_offenses_detected },
    coverall_coverage: people.map { |p| p.airport_challenge.coverall_coverage },
    reek_warnings: people.map { |p| p.airport_challenge.reek_warnings }
  }, clone: false)
  

  ds_norm = Daru::DataFrame.new({
    days_to_offer: people.map(&:days_to_offer).normalize!,
    rspec_tests: people.map { |p| p.airport_challenge.rspec_tests }.normalize!, 
    rspec_failures: people.map { |p| p.airport_challenge.rspec_failures }.normalize!,
    rubocop_offenses_detected: people.map { |p| p.airport_challenge.rubocop_offenses_detected }.normalize!,
    coverall_coverage: people.map { |p| p.airport_challenge.coverall_coverage }.normalize!,
    reek_warnings: people.map { |p| p.airport_challenge.reek_warnings }.normalize!
  }, clone: false)
  
  
  puts "== DataFrame ==\n"
  pp ds.head


  pp ds.mean
  pp ds.std

  # require 'byebug' ; byebug

  frame = Nyaplot::Frame.new
  # would like to sort these by date - doing that already in person?
  f2f_people = people.reject{ |p| p.cohort == 'Ronin Mar 2015' }
  cohorts = f2f_people.group_by { |p| p.cohort }
  sorted_keys = cohorts.keys.sort_by { |cohort| Date.parse(cohort) }

  plot = Nyaplot::Plot.new

  # we can make this dataframe hash directly no? (use the hmap method we've pulled in above?)
  # maybe prefer the long winded for speed in order to just get the graphs we need quick

  # plot.add(:bar, sorted_keys, mean_day_to_offer)
  dec2014 = cohorts[sorted_keys[0]].map(&:days_to_offer)
  feb2015 = cohorts[sorted_keys[1]].map(&:days_to_offer)
  mar2015 = cohorts[sorted_keys[2]].map(&:days_to_offer)
  apr2015 = cohorts[sorted_keys[3]].map(&:days_to_offer)
  jun2015 = cohorts[sorted_keys[4]].map(&:days_to_offer)
  jul2015 = cohorts[sorted_keys[5]].map(&:days_to_offer)
  # puts dec2014
  # puts '----'
  # puts mar2015
  df = Nyaplot::DataFrame.new({dec2014: dec2014, feb2015: feb2015, mar2015: mar2015, apr2015: apr2015, jun2015: jun2015, jul2015: jul2015})
  plot = Nyaplot::Plot.new
  plot.add_with_df(df, :box, :dec2014, :feb2015, :mar2015, :apr2015, :jun2015, :jul2015)
  # box = plot.add(:box, dec2014, feb2015, mar2015, apr2015, jun2015, jul2015)
  # box.values [:dec2014, :feb2015]
  #plot.xrange([0,500])
  plot.yrange([0,320])
  plot.x_label('Cohort')
  plot.y_label('Mean Days to offer')
  frame.add(plot)

  
  frame.add(draw(cohorts, :coverall_coverage, 0, 110))
  frame.add(draw(cohorts, :rspec_failures, 0, 8))
  frame.add(draw(cohorts, :rspec_tests, 0, 20))
  frame.add(draw(cohorts, :rubocop_offenses_detected, 0, 30))
  frame.add(draw(cohorts, :reek_warnings, 0, 20))

 
  frame.export_html("graphs/box.html")
  # ds.plot type: :histogram do |plt|
  #   plt.width 300
  #   plt.height 300
  #   plt.legend true
  # end
  # https://github.com/domitry/nyaplot/issues/55
  # https://github.com/dilcom/gnuplotrb
  # http://www.lowindata.com/2013/installing-scientific-python-on-mac-os-x/
  
  # Calculate correlation matrix by calling the `cor` shorthand.
  # cm = Statsample::Bivariate.correlation_matrix(ds)

  cm=cor(ds_norm) 
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

def draw(cohorts, property, min, max)
  sorted_keys = cohorts.keys.sort_by { |cohort| Date.parse(cohort) }
  dec2014 = cohorts[sorted_keys[0]].map{ |p| p.airport_challenge.send(property) }
  feb2015 = cohorts[sorted_keys[1]].map{ |p| p.airport_challenge.send(property) }
  mar2015 = cohorts[sorted_keys[2]].map{ |p| p.airport_challenge.send(property) }
  apr2015 = cohorts[sorted_keys[3]].map{ |p| p.airport_challenge.send(property) }
  jun2015 = cohorts[sorted_keys[4]].map{ |p| p.airport_challenge.send(property) }
  jul2015 = cohorts[sorted_keys[5]].map{ |p| p.airport_challenge.send(property) }
  # puts dec2014
  # puts '----'
  # puts mar2015
  df = Nyaplot::DataFrame.new({dec2014: dec2014, feb2015: feb2015, mar2015: mar2015, apr2015: apr2015, jun2015: jun2015, jul2015: jul2015})
  plot = Nyaplot::Plot.new
  plot.add_with_df(df, :box, :dec2014, :feb2015, :mar2015, :apr2015, :jun2015, :jul2015)
  # box = plot.add(:box, dec2014, feb2015, mar2015, apr2015, jun2015, jul2015)
  # box.values [:dec2014, :feb2015]
  #plot.xrange([0,500])
  plot.yrange([min,max])
  plot.x_label('Cohort')
  plot.y_label(property.to_s)
  plot
end

Statsample::Analysis.run_batch
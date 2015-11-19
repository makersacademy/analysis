Data Analysis Tools
===================

Starting with some experimental scripts for data analysis

At the moment this repo is breaking the Single Responsibility Principle in that it includes two things that should probably be separated.

1. `lib/generate_code_review_summaries*.rb` which take data from a csv file exported from a google form spreadsheet.  That form is the one that students use when giving code reviews to each other.  Using these scripts the results of filling in the form are summarised and can be posted automatically to the pull request on a challenge on github

2. `lib/analysis.rb` and `lib/correlation.rb` which together crunch data on static code analysis from challenges and then perform a correlation analysis and generate graphs illustrating the data

These analytical scrips make use of a few other related files such `lib/airport_challenge.rb` and `lib\person.rb` and rely on the presence of a challenge folder on the same level as this analysis root folder, e.g. 

```
$ tree -L 1
.
├── airport_challenge
├── analysis
├── bowling-challenge
├── chitter-challenge
├── rps-challenge
└── takeaway-challenge
```

They also assume the presence of an analysis directory in the challenge directories:

```
├── analysis
│   ├── 5555482.txt
│   ├── 7091lapS.txt
│   ├── ALRW.txt
│   ├── Adrian1707.txt
│   ├── Aftermaths.txt
│   ├── Alaanzr.txt
```

which contains a number of text files the title of which are the github ids of students and contain the results of running the following script in the challenge directory itself:

```ruby
remotes = `git remote`.split

remotes.each do |remote|

  File.delete("analysis/#{remote}.txt")

  `git checkout -f #{remote}/master`  # handling other branches?
  `cp .gitignore-analysis .gitignore`
  `echo >> Gemfile`
  `echo gem \\'rake\\' >> Gemfile` # and rspec gem
  `echo gem \\'rspec\\' >> Gemfile` # and rspec gem
  `echo gem \\'coveralls\\' >> Gemfile` # and rspec gem
  `cp CoverallsRakefile Rakefile` 
  # needs to insert at beginning - if not already present?
  `echo require \\'coveralls\\' >> spec/spec_helper.rb`
  `echo Coveralls.wear! >> spec/spec_helper.rb`
  # and spec_helper with coveralls stuff
  `echo --require spec_helper >> .rspec`

  File.open("analysis/#{remote}.txt",'a') { |f| f.write "\n\n***** COVERALLS *****\n\n" }
  File.open("analysis/#{remote}.txt",'a') { |f| f.write `coveralls report` }
  File.open("analysis/#{remote}.txt",'a') { |f| f.write "\n\n***** REEK *****\n\n" }
  File.open("analysis/#{remote}.txt",'a') { |f| f.write `reek -U` }
  File.open("analysis/#{remote}.txt",'a') { |f| f.write "\n\n***** RUBOCOP *****\n\n" }
  File.open("analysis/#{remote}.txt",'a') { |f| f.write `rubocop -c .rubocop-upgraded.yml --format simple` }

  File.open("analysis/#{remote}.txt",'a') { |f| f.write "\n\n***** SANDI *****\n\n" }
  File.open("analysis/#{remote}.txt",'a') { |f| f.write `sandi_meter` }
  
  `git stash`
end
```

The above script assumes that all the repos of the students have been added to the challenge directories git repo as remotes and had all their branches fetched down, and it is not 100% reliable - there are various files it relies on.  

In the first instance this is just an attempt to document the data flow so that we can start cleaning it up.

The next step should be to work out where all the pieces should go.  Probably each script should go in its own gem and each gem pulled into the makers toolbelt so they can easily be run from the command line ...

Todo
----

* [x] ensure correct normalization
* [ ] finish cleaning data
* [x] must also calculate start date for cohort
* [ ] must checkout the code they submitted, not the subsequent submission

Future Work
-----------

* [bias analysis](http://paulgraham.com/bias.html)

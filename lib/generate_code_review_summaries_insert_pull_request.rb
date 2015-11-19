require 'csv'
require 'octokit'
require 'yaml'
require 'byebug'

CSV_CONFIG = { headers: true, header_converters: :symbol, return_headers: true }

CHALLENGE = 'chitter_challenge'

def create_review_comments
  headers = []
  reviews = {}
  CSV.foreach("data/#{CHALLENGE}_oct15.csv", CSV_CONFIG) do |row|
    if row.header_row?
      headers = row
      # NOTE that if we've cloned the form from the previous week some 
      # old stuff lags over ... those dud columns need deleted ...
      headers.delete :what_is_the_reviewees_github_username
      headers.delete :your_name
      headers.delete :whose_challenge_are_you_reviewing
      headers.delete :did_you_find_this_form_useful_in_completing_the_review
      headers.delete :any_additional_comments_on_the_code_you_reviewed
      headers.delete :timestamp
      headers.delete :features
      headers.delete :bonus_features
      headers.delete :add_details_of_your_alternate_approach_to_the_review_if_you_skipped_the_rest
      next
    end
    comments = "You had your #{CHALLENGE} reviewed by **#{row[:your_name]}**.\n"
    comments << "### The good points are:\n"
    headers.each do |header|
      comments << "* #{row.field(header[0])}\n" if row.field(header[0])
    end

    comments << "\n### You should consider the following improvements:"
    headers.each do |header|
      comments << "\n* #{header[1]}" unless row.field(header[0])
    end

    if row.field(:any_additional_comments_on_the_code_you_reviewed)
      comments << "\n\n### Additional comments:\n"
      comments << row.field(:any_additional_comments_on_the_code_you_reviewed) + "\n"
    end
    comments << "\n\nsee https://github.com/makersacademy/#{CHALLENGE}/blob/master/docs/review.md for more details"

    reviews[row[:what_is_the_reviewees_github_username].downcase] = comments
  end
  reviews
end

def update_pull_requests
  client = Octokit::Client.new access_token: ENV['MAKERS_TOOLBELT_GITHUB_TOKEN']
  pull_requests = client.pull_requests "makersacademy/#{CHALLENGE.gsub('_','-')}", state: 'open', per_page: 100

  reviews = create_review_comments
 
  no_review = []
  pull_requests.each do |pr|
    puts pr.number
    login = pr.user.login.downcase
    puts login
    puts reviews[login]
    # return
    # byebug
    unless reviews[login].nil?
      byebug
      # client.add_comment "makersacademy/#{CHALLENGE.gsub('_','-')}", pr.number, reviews[login]
    else
      no_review << pr.user.login
    end
  end
  puts no_review
end

create_review_comments
update_pull_requests

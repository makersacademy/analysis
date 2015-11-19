require 'csv'

CSV_CONFIG = { headers: true, header_converters: :symbol }

CSV.foreach('data/airport_challenge_oct15.csv', CSV_CONFIG) do |row|
  puts "\n\nhttp://github.com/#{row[:reviewee].strip}"
  puts "You had airport challenge reviewed by #{row[:reviewer]}, and the issues they identified were:\n\n"
  row.delete :reviewee
  row.delete :reviewer
  row.delete :did_you_find_this_form_useful_in_completing_the_review
  row.fields.each do |field|
    puts "* #{field}" unless field.nil?
  end
  puts "\nsee https://github.com/makersacademy/airport_challenge/blob/master/docs/review.md for more details"
end
